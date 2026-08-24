#!/usr/bin/env bash
# Shared locations and guards for the Snapmaker Orca preset scripts.
# Source this; don't run it.

ORCA_APP_ID="io.github.Snapmaker.Snapmaker_Orca"
ORCA_CONFIG="${ORCA_CONFIG:-$HOME/.var/app/$ORCA_APP_ID/config/Snapmaker_Orca}"

ORCA_SYSTEM="$ORCA_CONFIG/system/Snapmaker"
ORCA_VENDOR_INDEX="$ORCA_CONFIG/system/Snapmaker.json"
ORCA_LOG_DIR="$ORCA_CONFIG/log"

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_PROCESS="$SKILL_DIR/presets/process"
REPO_FILAMENT="$SKILL_DIR/presets/filament"

# Signed-out installs keep presets in user/default; signing into a Snapmaker
# account moves the active profile to user/<account-id>. Pick the profile
# directory that is actually in use, newest first when several exist.
# Override with ORCA_PROFILE=<dirname> if the guess is ever wrong.
orca_detect_user_dir() {
    local base="$ORCA_CONFIG/user" chosen="" d count=0
    if [ -n "${ORCA_PROFILE:-}" ]; then
        ORCA_USER="$base/$ORCA_PROFILE"
        return
    fi
    for d in "$base"/*/; do
        [ -d "$d" ] || continue
        count=$((count + 1))
        if [ -z "$chosen" ] || [ "$d" -nt "$chosen" ]; then chosen="$d"; fi
    done
    ORCA_USER="${chosen:-$base/default}"
    ORCA_USER="${ORCA_USER%/}"
    if [ "$count" -gt 1 ]; then
        echo "note: multiple Orca profiles under $base — using $(basename "$ORCA_USER")" \
             "(newest); set ORCA_PROFILE to override" >&2
    fi
}

orca_detect_user_dir
ORCA_USER_PROCESS="$ORCA_USER/process"
ORCA_USER_FILAMENT="$ORCA_USER/filament/base"

orca_require_config() {
    if [ ! -d "$ORCA_CONFIG" ]; then
        echo "ERROR: Snapmaker Orca config not found at $ORCA_CONFIG" >&2
        echo "       Is the flatpak $ORCA_APP_ID installed? Set ORCA_CONFIG to override." >&2
        exit 1
    fi
}

# Orca rewrites every user preset from memory when it exits, so any file we
# touch while it runs gets silently reverted. Refuse to act until it is closed.
orca_is_running() {
    # flatpak ps is authoritative — when it runs at all, trust its answer and
    # never fall through to pgrep.
    local out
    if out="$(flatpak ps --columns=application 2>/dev/null)"; then
        grep -qx "$ORCA_APP_ID" <<< "$out"
        return
    fi
    # Fallback when flatpak isn't callable: the app's own process is named
    # "entrypoint" (useless to match), so look for its bwrap sandbox instead.
    # Anchoring on "bwrap" keeps this from matching unrelated processes — like
    # a shell — whose command line merely mentions the app id in a path.
    pgrep -f "bwrap.*$ORCA_APP_ID" >/dev/null 2>&1
}

orca_require_closed() {
    if orca_is_running; then
        echo "ERROR: Snapmaker Orca is running. Close it first — it overwrites" >&2
        echo "       user presets from memory on exit, discarding edits made on disk." >&2
        exit 1
    fi
}

# Read updated_time from a .info sidecar; prints 0 if absent.
orca_info_time() {
    local info="$1" t=""
    [ -f "$info" ] && t="$(sed -n 's/^updated_time *= *//p' "$info" | head -1)"
    echo "${t:-0}"
}
