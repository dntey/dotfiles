# i3 Window Grid — Vicinae Extension

A fast, visual window switcher extension for Vicinae under i3wm. It displays open i3 windows in a responsive, searchable grid with live screenshots, window titles, workspace numbers, and application icons.

---

## Extension Installation & Quick Start

To build and run Vicinae extensions locally:

```bash
# 1. Install dependencies
npm install

# 2. Start live development (hot reloads as you edit code)
npm run dev

# 3. Build for production (installs bundle to ~/.local/share/vicinae/extensions)
npm run build
```

Once built, the extension registers its launcher command under `@dntey/i3-window-grid:test` (or search for **Show i3 Windows** inside Vicinae).

---

## Overview of Features

* **Visual Window Grid:** Renders all open i3 windows in a 3-column thumbnail layout with search support.
* **Instant Switching & Management:** Select a window and press **Enter** to focus it, or **Ctrl+X** to close it.
* **Flexible Sorting Preferences:** Configurable via Vicinae command settings:
  * **Window Order:** *Workspace, Then Position* (default), *Most Recently Focused*, *Current Workspace First*, *i3 Layout Order*, *Window Title*, or *Application Name*.
  * **Sort Direction:** *Ascending* or *Descending*.
* **Live Previews & Fallbacks:** Uses `maim` for window screenshots. If a window is unvisited or unmapped, it automatically falls back to its X11 `_NET_WM_ICON` title-bar icon or application icon.
* **Asynchronous Preview Caching:** Caches captured PNGs in Vicinae’s support directory (`~/.local/share/vicinae/support/i3-window-grid`) for fast re-opening.

---

## i3 Integration & Configuration

The extension communicates with i3 using `i3-msg` over i3’s IPC socket. To launch the switcher directly with a shortcut, add a deeplink binding to your i3 configuration (`~/.config/i3/config`):

```i3
# Bind $mod+w to launch the i3 Window Grid in Vicinae
bindsym $mod+w exec --no-startup-id vicinae vicinae://launch/@dntey/i3-window-grid/test
```

Then reload i3:

```bash
i3-msg reload
```

---

## Implementation Details

1. **i3 Tree Parsing:** Calls `i3-msg -t get_tree` and `i3-msg -t get_workspaces` to discover all container nodes, window IDs, workspace visibility, and nested focus stacks.
2. **Focus-Rank Extraction:** Recursively walks i3 container focus arrays to build an accurate Most Recently Used (MRU) ranking across all workspaces.
3. **Optimized Load Pipeline:** Loads window metadata, filesystem caches, and application icons concurrently, rendering the grid UI in ~1–2 ms before streaming fresh screenshot updates in the background.
4. **Deferred Focus Capture:** When focusing a window via `i3-msg [con_id="..."] focus`, Vicinae closes immediately to avoid UI delay, then captures the window preview asynchronously.

---

## Performance & Security Considerations

### Performance Status
* **Zero Shell Overhead:** Uses Node's `execFile` directly without shell interpretation (`/bin/sh`).
* **Non-Blocking UI:** Scans directories once, restricts concurrent `maim`/`xprop`/ImageMagick worker processes to `2`, and renders cached assets immediately.
* **Unmapped Window Handling:** Windows on inactive i3 workspaces are unmapped by X11 and lack framebuffer pixels. Rather than executing visible workspace flashes, inactive windows render cached previews or extracted `_NET_WM_ICON` icons until focused.

### Security Status
* **Process Isolation:** All command arguments are passed as typed array strings, preventing shell-injection vectors from malformed window titles or application classes.
* **Unencrypted On-Disk Previews:** Window thumbnails contain screen content (which may display sensitive information) and are stored as unencrypted PNG files in user support storage (`0700` directory permissions recommended).
* **Buffer Safety:** Calls to `xprop` enforce a strict `maxBuffer` limit (16 MB) and include error boundaries to prevent memory overflow or runtime crashes.
