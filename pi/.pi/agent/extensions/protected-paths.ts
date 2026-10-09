/**
 * Protected Paths Extension
 *
 * Blocks write and edit operations to protected paths, so the agent cannot
 * modify sensitive files or directories. Also inspects `bash` commands for
 * obvious writes/redirects into protected paths (shell redirections, mv/cp/
 * ln targets, tee, rsync destinations).
 *
 * Based on the official example:
 *   examples/extensions/protected-paths.ts
 *
 * Configure the list below, or set PI_PROTECTED_PATHS as a colon-separated
 * list (e.g. PI_PROTECTED_PATHS="~/.ssh:~/.gnupg:.env:.git/") to override.
 *
 * Install: ~/.pi/agent/extensions/protected-paths.ts (auto-discovered globally).
 * Reload with /reload or restart pi.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const DEFAULT_PROTECTED = [
	".env",
	".git/",
	"node_modules/",
	"~/.ssh/",
	"~/.gnupg/",
	"~/.pi/agent/auth.json",
    "~/Documents/",
    "~/Config/",
    "~/Documents/",
    "~/Org/",
    "~/Pictures/",
    "~/Sync/",
    "~/Videos/",
    "~/Zotero/",
];

const envList = process.env.PI_PROTECTED_PATHS;
const protectedPaths = (envList ? envList.split(":") : DEFAULT_PROTECTED)
	.map((p) => p.trim())
	.filter(Boolean);

const HOME = process.env.HOME ?? "";

/** Normalize a user-supplied path for matching (expand ~, resolve relative). */
function normalize(p: string): string {
	let s = p.trim();
	if (s.startsWith("~/")) s = HOME + s.slice(1);
	if (!s.startsWith("/")) s = "/" + s.replace(/^\.\//, "");
	// strip trailing separators except for root
	s = s.replace(/\/+$/, "") || "/";
	return s;
}

/** True if target is inside (or equal to) a protected path. */
function isProtected(target: string): boolean {
	if (!target) return false;
	const t = normalize(target);
	return protectedPaths.some((p) => {
		const n = normalize(p);
		return t === n || t.startsWith(n.endsWith("/") ? n : n + "/");
	});
}

/** Check a shell command string for writes into protected paths. */
function bashTouchesProtected(command: string): string | null {
	// Redirections like  > path,  >> path
	for (const m of command.matchAll(/>{1,2}\s*(\S+)/g)) {
		const target = m[1].replace(/^["']|["']$/g, "");
		if (isProtected(target)) return `redirection to "${target}"`;
	}
	// Commands whose trailing operands are destinations
	const destCmds = ["cp", "mv", "ln", "rsync", "install"];
	for (const word of command.split(/[;&|]/)) {
		const tokens = word.trim().split(/\s+/).filter(Boolean);
		if (!tokens.length) continue;
		let i = 0;
		while (i < tokens.length && ["sudo", "env", "nice", "nohup"].includes(tokens[i])) i++;
		const cmd = tokens[i]?.split("/").pop();
		if (cmd && destCmds.includes(cmd)) {
			// last non-flag operand is the destination
			for (let j = tokens.length - 1; j > i; j--) {
				if (tokens[j].startsWith("-")) continue;
				const target = tokens[j].replace(/^["']|["']$/g, "");
				if (isProtected(target)) return `${cmd} destination "${target}"`;
				break;
			}
		}
	}
	// tee / tee -a file
	for (const m of command.matchAll(/\btee\b\s+((?:-\S+\s+)*)(\S+)/g)) {
		const target = m[2].replace(/^["']|["']$/g, "");
		if (isProtected(target)) return `tee to "${target}"`;
	}
	return null;
}

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event, ctx) => {
		if (event.toolName === "write" || event.toolName === "edit") {
			const path = event.input.path as string;
			if (path && isProtected(path)) {
				if (ctx.hasUI) {
					ctx.ui.notify(`Blocked write to protected path: ${path}`, "warning");
				}
				return { block: true, reason: `Path "${path}" is protected and cannot be written or edited.` };
			}
			return undefined;
		}

		if (event.toolName === "bash") {
			const command = event.input.command as string;
			if (!command) return undefined;
			const hit = bashTouchesProtected(command);
			if (hit) {
				if (ctx.hasUI) {
					ctx.ui.notify(`Blocked bash command (${hit})`, "warning");
				}
				return {
					block: true,
					reason: `Command writes to a protected path (${hit}). This path is protected and cannot be modified.`,
				};
			}
			return undefined;
		}

		return undefined;
	});
}
