#!/bin/sh
# Disables DPMS while Firefox is playing media, re-enables otherwise.
# Requires: playerctl

DPMS_TIMEOUT=600  # seconds

set_dpms_on() {
    xset dpms "$DPMS_TIMEOUT" "$DPMS_TIMEOUT" "$DPMS_TIMEOUT" 2>/dev/null
}

set_dpms_off() {
    xset -dpms 2>/dev/null
}

# Start from a known state
set_dpms_on

# playerctl --follow prints a new line whenever the status changes.
# Blank line = no player / player exited.
playerctl --player=firefox --follow status 2>/dev/null | while IFS= read -r status; do
    case "$status" in
        Playing)
            set_dpms_off
            ;;
        ""|Stopped|Paused)
            set_dpms_on
            ;;
        *)
            # Unknown status — leave DPMS as-is
            ;;
    esac
done
