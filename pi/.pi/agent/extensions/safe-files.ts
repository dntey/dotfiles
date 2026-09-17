/**
 * Safe Files Extension
 *
 * Redirects the agent's `rm` commands to `trash-put` (from trash-cli) so
 * deleted files go to the recoverable trash instead of being permanently
 * removed. Also gates a few catastrophic, non-recoverable commands behind
 * confirmation.
 *
 * Behavior for `rm`:
 *   - Simple `rm [flags] <paths>` (incl. inside `&&`/`;`/`|` chains) is
 *     rewritten in place to `trash-put <paths>` and runs automatically.
 *     Flags like -f/-r are dropped (trash is always recursive; force is
 *     unnecessary). Original operand quoting is preserved.
 *   - `sudo rm ...` is NOT auto-rewritten (trashing as your user changes
 *     privilege semantics) — it falls back to confirmation.
 *   - `rm` with no operands, or rm hidden in command substitution, falls
 *     back to confirmation rather than being silently altered.
 *   - In non-interactive mode, rewrites still apply (the safe intent is
 *     preserved without needing a human to confirm).
 *
 * Catastrophic commands (mkfs, dd to a block device, shred, redirection to
 * a block device, chmod -R) are NOT recoverable via trash, so they are
 * gated: confirmed in interactive mode, blocked in non-interactive mode.
 *
 * Install: ~/.pi/agent/extensions/safe-files.ts (auto-discovered globally).
 * Reload with /reload or restart pi. Requires trash-cli (`trash-put`) on PATH.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const TRASH_CMD = "trash-put";
const WRAPPERS = new Set(["env", "nice", "ionice", "time", "nohup", "strace", "command"]);

/** Range of one shell token (whitespace-delimited, quote/escape-aware). */
interface TokenRange {
	start: number;
	end: number;
}

/** Advance past whitespace; return null at end of string. */
function nextTokenRange(s: string, pos: number): TokenRange | null {
	let i = pos;
	while (i < s.length && /\s/.test(s[i])) i++;
	if (i >= s.length) return null;
	const start = i;
	while (i < s.length && !/\s/.test(s[i])) {
		const ch = s[i];
		if (ch === "'") {
			i++;
			while (i < s.length && s[i] !== "'") i++;
			if (i < s.length) i++;
		} else if (ch === '"') {
			i++;
			while (i < s.length && s[i] !== '"') {
				if (s[i] === "\\" && i + 1 < s.length) i += 2;
				else i++;
			}
			if (i < s.length) i++;
		} else if (ch === "\\" && i + 1 < s.length) {
			i += 2;
		} else {
			i++;
		}
	}
	return { start, end: i };
}

/** Raw text of a token (preserves quotes exactly as written). */
function raw(s: string, r: TokenRange): string {
	return s.slice(r.start, r.end);
}

type Rewrite =
	| { ok: true; rewritten: string }
	| { ok: false; reason: string; confirm: boolean };

/**
 * Rewrite a single command segment (no control operators) from `rm` to
 * `trash-put`. Collects operand tokens (skipping flags anywhere they
 * appear, e.g. `rm file -rf`) and re-emits their raw text so original
 * quoting survives.
 */
function rewriteRmSegment(segment: string): Rewrite {
	let pos = 0;
	let tok = nextTokenRange(segment, pos);
	if (!tok) return { ok: false, reason: "empty segment", confirm: false };

	// Skip wrapper prefixes (sudo tracked separately).
	let hadSudo = false;
	while (tok) {
		const t = raw(segment, tok);
		if (t === "sudo") {
			hadSudo = true;
		} else if (WRAPPERS.has(t)) {
			// keep skipping
		} else {
			break;
		}
		pos = tok.end;
		tok = nextTokenRange(segment, pos);
	}
	if (!tok) return { ok: false, reason: "wrapper-only segment", confirm: false };
	if (raw(segment, tok) !== "rm") return { ok: false, reason: "not rm", confirm: false };

	// Collect operands after `rm`, skipping flag tokens wherever they appear.
	let afterDoubleDash = false;
	const operands: string[] = [];
	let p = tok.end;
	let t2 = nextTokenRange(segment, p);
	while (t2) {
		const t = raw(segment, t2);
		const isFlag = segment[t2.start] === "-"; // quoted "dash" is not a flag
		if (!afterDoubleDash && t === "--" && isFlag) {
			afterDoubleDash = true;
		} else if (!afterDoubleDash && isFlag) {
			// skip flag token (-f, -rf, --force, etc.); trash needs none of them
		} else {
			operands.push(t); // raw text preserves original quoting
		}
		p = t2.end;
		t2 = nextTokenRange(segment, p);
	}

	if (operands.length === 0) {
		return { ok: false, reason: "rm with no operands", confirm: true };
	}
	if (hadSudo) {
		// Don't silently change privilege semantics; ask first.
		return { ok: false, reason: "sudo rm — privilege-sensitive", confirm: true };
	}

	const ops = operands.join(" ");
	return {
		ok: true,
		rewritten: afterDoubleDash ? `${TRASH_CMD} -- ${ops}` : `${TRASH_CMD} ${ops}`,
	};
}

/** Split a command into segments on shell control operators, keeping them. */
function splitSegments(command: string): string[] {
	// split() with a capturing group keeps the delimiters as array elements,
	// yielding alternating [segment, operator, segment, operator, ...].
	return command.split(/(&&|\|\||;|\||\n)/);
}

/** Catastrophic, non-recoverable patterns — gated, never auto-run. */
const CATASTROPHIC: RegExp[] = [
	/\bmkfs(\.\w+)?\b/,
	/\bshred\b/,
	/\bdd\b[^&|;]*\bof=\/dev\/(sd|nvme|mmc|vd|hd)/i,
	/>\s*\/dev\/(sd|nvme|mmc|vd|hd)\w*\b/i,
	/\bchmod\s+-R\b/,
];

function hasCatastrophic(command: string): string | null {
	for (const seg of command.split(/(?:&&|\|\||;|\||\n)/)) {
		for (const re of CATASTROPHIC) {
			if (re.test(seg)) return seg.trim();
		}
	}
	return null;
}

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event, ctx) => {
		if (event.toolName !== "bash") return undefined;

		const command = (event.input as { command?: string }).command ?? "";

		// 1) Catastrophic, non-recoverable commands: confirm / block.
		const catastrophic = hasCatastrophic(command);
		if (catastrophic) {
			if (!ctx.hasUI) {
				return { block: true, reason: `Blocked catastrophic command: \`${catastrophic}\`` };
			}
			const ok = await ctx.ui.confirm(
				"⚠️ Catastrophic command blocked",
				`This cannot be sent to trash. Allow?\n\n  ${command}`,
			);
			return ok ? undefined : { block: true, reason: `Blocked by user: \`${catastrophic}\`` };
		}

		// 2) Rewrite rm -> trash-put across all segments of the command.
		const parts = splitSegments(command);
		let changed = false;
		let needsConfirm: { reason: string } | null = null;
		for (let i = 0; i < parts.length; i += 2) {
			const seg = parts[i];
			if (!seg || !/\brm\b/.test(seg)) continue; // quick reject
			const r = rewriteRmSegment(seg);
			if (r.ok) {
				// Preserve whitespace around the segment so operators stay spaced.
				const lead = seg.match(/^\s*/)?.[0] ?? "";
				const trail = seg.match(/\s*$/)?.[0] ?? "";
				parts[i] = lead + r.rewritten + trail;
				changed = true;
			} else if (r.confirm) {
				needsConfirm = { reason: r.reason };
				break;
			}
			// non-confirm, non-ok (e.g. "not rm"): leave as-is
		}

		if (!changed && !needsConfirm) return undefined; // no rm involved

		if (needsConfirm) {
			if (!ctx.hasUI) {
				return { block: true, reason: `Blocked rm (${needsConfirm.reason}); no UI to confirm.` };
			}
			const ok = await ctx.ui.confirm(
				"⚠️ rm not auto-rewritten",
				`Could not safely redirect to trash (${needsConfirm.reason}). Allow original command?\n\n  ${command}`,
			);
			return ok ? undefined : { block: true, reason: `Blocked by user (${needsConfirm.reason})` };
		}

		// Apply the rewrite.
		const newCommand = parts.join("");
		(event.input as { command: string }).command = newCommand;
		if (ctx.hasUI) {
			ctx.ui.notify(`rm → ${TRASH_CMD}`, "info");
		}
		return undefined;
	});
}
