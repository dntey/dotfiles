import {
	Action,
	ActionPanel,
	closeMainWindow,
	environment,
	getPreferenceValues,
	Grid,
	Icon,
	showToast,
	Toast,
	type ImageLike,
} from "@vicinae/api";
import { execFile } from "node:child_process";
import { mkdir, readdir, unlink, writeFile } from "node:fs/promises";
import { join } from "node:path";
import { promisify } from "node:util";
import { useCallback, useEffect, useState } from "react";

const execFileAsync = promisify(execFile);
const sleep = (milliseconds: number) =>
	new Promise((resolve) => setTimeout(resolve, milliseconds));

type Rect = { x: number; y: number; width: number; height: number };

type I3Node = {
	id: number;
	type: string;
	name: string | null;
	window: number | null;
	window_type?: string;
	app_id?: string | null;
	focused: boolean;
	focus?: number[];
	rect: Rect;
	nodes?: I3Node[];
	floating_nodes?: I3Node[];
	window_properties?: {
		class?: string;
		instance?: string;
		title?: string;
	};
};

type I3Workspace = { name: string; visible: boolean };

type SortOrder =
	| "i3"
	| "workspace"
	| "current-workspace"
	| "recent-focus"
	| "title"
	| "application";
type ExtensionPreferences = {
	sortOrder: SortOrder;
	sortDirection: "ascending" | "descending";
};

type I3Window = {
	id: string;
	windowId: string;
	title: string;
	application: string;
	workspace: string;
	focused: boolean;
	visible: boolean;
	rect: Rect;
	i3Order: number;
	focusOrder: number;
	preview?: string;
	placeholder?: ImageLike;
	hasCachedIcon?: boolean;
};

async function i3Message(...args: string[]) {
	return execFileAsync("i3-msg", args);
}

function collectWindows(
	node: I3Node,
	workspace = "",
	result: I3Window[] = [],
): I3Window[] {
	const currentWorkspace =
		node.type === "workspace" ? node.name || "" : workspace;
	const application =
		node.app_id ||
		node.window_properties?.class ||
		node.window_properties?.instance ||
		"Unknown application";

	if (
		node.window !== null &&
		node.window_type !== "unknown" &&
		application.toLowerCase() !== "vicinae"
	) {
		result.push({
			id: String(node.id),
			windowId: String(node.window),
			title: node.name || node.window_properties?.title || application,
			application,
			workspace: currentWorkspace || "scratchpad",
			focused: node.focused,
			visible: false,
			rect: node.rect,
			i3Order: result.length,
			focusOrder: Number.MAX_SAFE_INTEGER,
		});
	}

	for (const child of [...(node.nodes || []), ...(node.floating_nodes || [])]) {
		collectWindows(child, currentWorkspace, result);
	}
	return result;
}

/**
 * i3 stores each container's children in most-recently-focused order. Walking
 * those focus stacks from the root gives us a stable MRU rank across workspaces.
 */
function rankByRecentFocus(root: I3Node, windows: I3Window[]) {
	const rank = new Map<string, number>();
	let nextRank = 0;

	function visit(node: I3Node) {
		if (node.window !== null && !rank.has(String(node.id))) {
			rank.set(String(node.id), nextRank++);
		}
		const children = [...(node.nodes || []), ...(node.floating_nodes || [])];
		const byId = new Map(children.map((child) => [child.id, child]));
		const visited = new Set<number>();
		for (const id of node.focus || []) {
			const child = byId.get(id);
			if (child) {
				visited.add(id);
				visit(child);
			}
		}
		for (const child of children) {
			if (!visited.has(child.id)) visit(child);
		}
	}

	visit(root);
	for (const window of windows) {
		window.focusOrder = rank.get(window.id) ?? Number.MAX_SAFE_INTEGER;
	}
}

const collator = new Intl.Collator(undefined, {
	numeric: true,
	sensitivity: "base",
});

function comparePosition(a: I3Window, b: I3Window) {
	return a.rect.y - b.rect.y || a.rect.x - b.rect.x || a.i3Order - b.i3Order;
}

function sortWindows(windows: I3Window[], preferences: ExtensionPreferences) {
	const compare = (a: I3Window, b: I3Window) => {
		switch (preferences.sortOrder) {
			case "i3":
				return a.i3Order - b.i3Order;
			case "current-workspace":
				return (
					Number(b.visible) - Number(a.visible) ||
					collator.compare(a.workspace, b.workspace) ||
					comparePosition(a, b)
				);
			case "recent-focus":
				return a.focusOrder - b.focusOrder || a.i3Order - b.i3Order;
			case "title":
				return collator.compare(a.title, b.title) || comparePosition(a, b);
			case "application":
				return (
					collator.compare(a.application, b.application) ||
					collator.compare(a.title, b.title) ||
					comparePosition(a, b)
				);
			case "workspace":
			default:
				return (
					collator.compare(a.workspace, b.workspace) || comparePosition(a, b)
				);
		}
	};
	const direction = preferences.sortDirection === "descending" ? -1 : 1;
	return [...windows].sort((a, b) => direction * compare(a, b));
}

function previewDirectory() {
	return join(environment.supportPath, "window-previews");
}

function iconDirectory() {
	return join(environment.supportPath, "window-icons");
}

function indexCachedPreviews(files: string[]): Map<string, string> {
	const previews = new Map<string, string>();
	for (const file of files.sort().reverse()) {
		const match = file.match(/^(\d+)-\d+\.png$/);
		if (match && !previews.has(match[1])) {
			previews.set(match[1], join(previewDirectory(), file));
		}
	}
	return previews;
}

async function mapWithConcurrency<T>(
	items: T[],
	concurrency: number,
	worker: (item: T) => Promise<void>,
) {
	let next = 0;
	await Promise.all(
		Array.from({ length: Math.min(concurrency, items.length) }, async () => {
			while (next < items.length) {
				const item = items[next++];
				await worker(item);
			}
		}),
	);
}

async function capturePreview(window: I3Window): Promise<string | undefined> {
	const directory = previewDirectory();
	await mkdir(directory, { recursive: true });
	const filename = `${window.windowId}-${Date.now()}.png`;
	const preview = join(directory, filename);

	try {
		await execFileAsync("maim", [
			"--hidecursor",
			"--window",
			window.windowId,
			preview,
		]);

		// Versioned filenames prevent Vicinae's image cache from showing an older
		// capture. Keep only the newest capture for this X11 window ID.
		const oldFiles = (await readdir(directory)).filter(
			(file) =>
				file.startsWith(`${window.windowId}-`) &&
				file.endsWith(".png") &&
				file !== filename,
		);
		await Promise.all(
			oldFiles.map((file) =>
				unlink(join(directory, file)).catch(() => undefined),
			),
		);
		return preview;
	} catch {
		await unlink(preview).catch(() => undefined);
		return undefined;
	}
}

function fallbackIcon(application: string): Icon {
	const name = application.toLowerCase();
	if (name.includes("firefox")) return Icon.Firefox;
	if (name.includes("kitty") || name.includes("terminal")) return Icon.Terminal;
	if (name.includes("code") || name.includes("editor")) return Icon.Code;
	return Icon.AppWindow;
}

/** Extract the icon an X11 application supplies for its i3 title bar. */
async function extractWindowIcon(window: I3Window): Promise<ImageLike> {
	const directory = iconDirectory();
	const iconPath = join(directory, `${window.windowId}.png`);
	const pamPath = join(directory, `${window.windowId}.pam`);

	try {
		await mkdir(directory, { recursive: true });
		const { stdout } = await execFileAsync(
			"xprop",
			["-id", window.windowId, "-f", "_NET_WM_ICON", "32c", "_NET_WM_ICON"],
			{ maxBuffer: 16 * 1024 * 1024 },
		);
		const values = (
			stdout.slice(stdout.indexOf("=") + 1).match(/\d+/g) || []
		).map(Number);

		// _NET_WM_ICON contains one or more [width, height, ARGB pixels...] blocks.
		// Pick the largest valid image, matching what a title bar normally does.
		let offset = 0;
		let selected:
			| { width: number; height: number; pixels: number[] }
			| undefined;
		while (offset + 2 <= values.length) {
			const width = values[offset++];
			const height = values[offset++];
			const count = width * height;
			if (!width || !height || offset + count > values.length) break;
			const pixels = values.slice(offset, offset + count);
			offset += count;
			if (!selected || count > selected.width * selected.height) {
				selected = { width, height, pixels };
			}
		}
		if (!selected) return fallbackIcon(window.application);

		const rgba = Buffer.alloc(selected.pixels.length * 4);
		selected.pixels.forEach((pixel, index) => {
			rgba[index * 4] = (pixel >>> 16) & 0xff;
			rgba[index * 4 + 1] = (pixel >>> 8) & 0xff;
			rgba[index * 4 + 2] = pixel & 0xff;
			rgba[index * 4 + 3] = (pixel >>> 24) & 0xff;
		});
		const header = `P7\nWIDTH ${selected.width}\nHEIGHT ${selected.height}\nDEPTH 4\nMAXVAL 255\nTUPLTYPE RGB_ALPHA\nENDHDR\n`;
		await writeFile(pamPath, Buffer.concat([Buffer.from(header), rgba]));
		await execFileAsync("magick", [pamPath, iconPath]);
		await unlink(pamPath).catch(() => undefined);
		return iconPath;
	} catch {
		await unlink(pamPath).catch(() => undefined);
		return fallbackIcon(window.application);
	}
}

async function loadWindows(): Promise<I3Window[]> {
	const directory = previewDirectory();
	const icons = iconDirectory();
	await Promise.all([
		mkdir(directory, { recursive: true }),
		mkdir(icons, { recursive: true }),
	]);
	const [{ stdout: tree }, { stdout: workspaceJson }, cacheFiles, iconFiles] =
		await Promise.all([
			i3Message("-t", "get_tree"),
			i3Message("-t", "get_workspaces"),
			readdir(directory),
			readdir(icons),
		]);
	const root = JSON.parse(tree) as I3Node;
	const windows = collectWindows(root);
	rankByRecentFocus(root, windows);
	const visibleWorkspaces = new Set(
		(JSON.parse(workspaceJson) as I3Workspace[])
			.filter((workspace) => workspace.visible)
			.map((workspace) => workspace.name),
	);
	const cachedPreviews = indexCachedPreviews(cacheFiles);
	const cachedIcons = new Set(iconFiles);

	// This function deliberately does no screenshot or icon generation. Metadata
	// and cached images can therefore be rendered as soon as i3 answers.
	for (const window of windows) {
		window.visible = visibleWorkspaces.has(window.workspace);
		window.preview = cachedPreviews.get(window.windowId);
		const iconFilename = `${window.windowId}.png`;
		window.hasCachedIcon = cachedIcons.has(iconFilename);
		window.placeholder = window.hasCachedIcon
			? join(icons, iconFilename)
			: fallbackIcon(window.application);
	}
	return sortWindows(windows, getPreferenceValues<ExtensionPreferences>());
}

export default function WindowGrid() {
	const [windows, setWindows] = useState<I3Window[]>([]);
	const [isLoading, setIsLoading] = useState(true);
	const [error, setError] = useState<string>();

	const hydratePreviews = useCallback(async (initialWindows: I3Window[]) => {
		// Keep process pressure low and update each tile as soon as it is ready.
		await mapWithConcurrency(initialWindows, 2, async (window) => {
			const preview = window.visible
				? await capturePreview(window)
				: window.preview;
			const placeholder =
				preview || window.hasCachedIcon
					? window.placeholder
					: await extractWindowIcon(window);
			setWindows((current) =>
				current.map((item) =>
					item.id === window.id ? { ...item, preview, placeholder } : item,
				),
			);
		});
	}, []);

	const refresh = useCallback(async () => {
		setIsLoading(true);
		setError(undefined);
		try {
			const loadedWindows = await loadWindows();
			setWindows(loadedWindows);
			setIsLoading(false);
			void hydratePreviews(loadedWindows);
		} catch (cause) {
			const message = cause instanceof Error ? cause.message : String(cause);
			setError(message);
			setIsLoading(false);
			await showToast({
				style: Toast.Style.Failure,
				title: "Could not read i3 windows",
				message,
			});
		}
	}, [hydratePreviews]);

	useEffect(() => {
		void refresh();
	}, [refresh]);

	async function focusWindow(window: I3Window) {
		try {
			await i3Message(`[con_id="${window.id}"]`, "focus");
			// Do not make launcher dismissal wait for rendering or PNG encoding.
			await closeMainWindow();
			void (async () => {
				await sleep(200);
				await capturePreview(window);
			})();
		} catch (cause) {
			await showToast({
				style: Toast.Style.Failure,
				title: "Could not focus window",
				message: cause instanceof Error ? cause.message : String(cause),
			});
		}
	}

	async function closeWindow(window: I3Window) {
		try {
			await i3Message(`[con_id="${window.id}"]`, "kill");
			await refresh();
		} catch (cause) {
			await showToast({
				style: Toast.Style.Failure,
				title: "Could not close window",
				message: cause instanceof Error ? cause.message : String(cause),
			});
		}
	}

	return (
		<Grid
			columns={3}
			aspectRatio="16/9"
			fit={Grid.Fit.Contain}
			inset={Grid.Inset.Small}
			isLoading={isLoading}
			searchBarPlaceholder="Search open windows..."
			navigationTitle="i3 Windows"
		>
			{!isLoading && windows.length === 0 ? (
				<Grid.EmptyView
					icon={Icon.AppWindowGrid3x3}
					title={error ? "Unable to load i3 windows" : "No windows found"}
					description={error || "Open a window, then refresh this view."}
					actions={
						<ActionPanel>
							<Action
								title="Refresh"
								icon={Icon.ArrowClockwise}
								onAction={() => void refresh()}
							/>
						</ActionPanel>
					}
				/>
			) : (
				windows.map((window) => (
					<Grid.Item
						key={window.id}
						id={window.id}
						title={window.title}
						subtitle={`${window.application} · workspace ${window.workspace}`}
						keywords={[window.application, window.workspace]}
						content={window.preview || window.placeholder || Icon.AppWindow}
						accessory={
							window.focused
								? { icon: Icon.CheckCircle, tooltip: "Focused" }
								: undefined
						}
						actions={
							<ActionPanel>
								<ActionPanel.Section>
									<Action
										title="Focus Window"
										icon={Icon.AppWindow}
										onAction={() => void focusWindow(window)}
									/>
									<Action
										title="Refresh Windows"
										icon={Icon.ArrowClockwise}
										shortcut={{ modifiers: ["ctrl"], key: "r" }}
										onAction={() => void refresh()}
									/>
								</ActionPanel.Section>
								<ActionPanel.Section>
									<Action
										title="Close Window"
										icon={Icon.XMarkCircle}
										style={Action.Style.Destructive}
										shortcut={{ modifiers: ["ctrl"], key: "x" }}
										onAction={() => void closeWindow(window)}
									/>
								</ActionPanel.Section>
							</ActionPanel>
						}
					/>
				))
			)}
		</Grid>
	);
}
