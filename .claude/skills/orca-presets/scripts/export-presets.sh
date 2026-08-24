#!/usr/bin/env bash
# Copy every custom (user) preset out of the live Snapmaker Orca config into
# this skill, so they are version-controlled with the repo.
#
#   export-presets.sh [--dry-run] [--prune]
#
#   --dry-run   show what would be copied/pruned without writing anything
#   --prune     delete repo presets that no longer exist in the live config
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/orca-env.sh"

DRY=0 PRUNE=0
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY=1 ;;
        --prune)   PRUNE=1 ;;
        *) echo "ERROR: unknown argument '$arg' (expected --dry-run and/or --prune)" >&2
           exit 2 ;;
    esac
done

orca_require_config
# Orca only writes user presets to disk on exit, so an export taken while it
# runs captures pre-session values and silently records them as truth.
orca_require_closed

copy_dir() {
    local src="$1" dst="$2" label="$3" n=0
    [ -d "$src" ] || { echo "  (no $label presets)"; return; }
    [ "$DRY" -eq 0 ] && mkdir -p "$dst"
    shopt -s nullglob
    for f in "$src"/*.json; do
        local base; base="$(basename "$f" .json)"
        echo "  $label: $base"
        if [ "$DRY" -eq 0 ]; then
            cp -p "$f" "$dst/$base.json"
            # .info carries Orca's sync metadata; keep it beside the JSON.
            [ -f "$src/$base.info" ] && cp -p "$src/$base.info" "$dst/$base.info"
        fi
        n=$((n+1))
    done
    shopt -u nullglob
    echo "  -> $n $label preset(s)"
}

# Repo presets with no live counterpart are stale — deleted or renamed in the
# GUI. Left in place, the next install would resurrect them into Orca.
prune_dir() {
    local src="$1" dst="$2" label="$3"
    [ -d "$dst" ] || return 0
    shopt -s nullglob
    for f in "$dst"/*.json; do
        local base; base="$(basename "$f" .json)"
        if [ ! -f "$src/$base.json" ]; then
            if [ "$PRUNE" -eq 1 ]; then
                [ "$DRY" -eq 0 ] && rm -f "$f" "$dst/$base.info"
                echo "  pruned $label: $base (gone from live config)"
            else
                echo "  STALE $label: $base — not in the live config; re-run with --prune to remove"
            fi
        fi
    done
    shopt -u nullglob
}

echo "Exporting from $ORCA_USER"
copy_dir "$ORCA_USER_PROCESS"  "$REPO_PROCESS"  "process"
copy_dir "$ORCA_USER_FILAMENT" "$REPO_FILAMENT" "filament"
prune_dir "$ORCA_USER_PROCESS"  "$REPO_PROCESS"  "process"
prune_dir "$ORCA_USER_FILAMENT" "$REPO_FILAMENT" "filament"
[ "$DRY" -eq 1 ] && echo "(dry run — nothing written)"
echo "Done. Review with: git -C $(git -C "$SKILL_DIR" rev-parse --show-toplevel 2>/dev/null || echo .) status"
