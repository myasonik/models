#!/usr/bin/env bash
# Copy presets from this skill into the live Snapmaker Orca config.
# Validates first — an invalid preset is skipped by Orca without any error.
#
#   install-presets.sh [--force]                # install every preset in the skill
#   install-presets.sh [--force] "Draft @ .4"   # install one, by preset name
#
# Refuses to overwrite a live preset whose .info updated_time is newer than the
# repo copy's — that means it was tuned in the GUI and never exported. Run
# export-presets.sh first, or pass --force to overwrite anyway. Every file that
# gets overwritten is backed up under $ORCA_CONFIG/user_backup-orca-presets/.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/orca-env.sh"

FORCE=0
ARGS=()
for arg in "$@"; do
    case "$arg" in
        --force) FORCE=1 ;;
        --*) echo "ERROR: unknown option '$arg' (expected --force)" >&2; exit 2 ;;
        *) ARGS+=("$arg") ;;
    esac
done

orca_require_config
orca_require_closed

shopt -s nullglob
if [ "${#ARGS[@]}" -gt 0 ]; then
    FILES=()
    for want in "${ARGS[@]}"; do
        found=0
        for dir in "$REPO_PROCESS" "$REPO_FILAMENT"; do
            if [ -f "$dir/$want.json" ]; then FILES+=("$dir/$want.json"); found=1; fi
        done
        [ "$found" -eq 0 ] && { echo "ERROR: no preset named '$want' in this skill" >&2; exit 1; }
    done
else
    FILES=("$REPO_PROCESS"/*.json "$REPO_FILAMENT"/*.json)
fi
shopt -u nullglob

echo "Validating..."
"$SKILL_DIR/scripts/check-presets.sh" "${FILES[@]}"
echo

# The live config drifts ahead of the repo whenever presets are tuned in the
# GUI; overwriting that without noticing loses work Orca keeps no history of.
STALE=()
for f in "${FILES[@]}"; do
    base="$(basename "$f" .json)"
    case "$f" in
        "$REPO_PROCESS"/*) dst="$ORCA_USER_PROCESS" ;;
        *)                 dst="$ORCA_USER_FILAMENT" ;;
    esac
    if [ -f "$dst/$base.json" ] && ! cmp -s "$f" "$dst/$base.json"; then
        live_t="$(orca_info_time "$dst/$base.info")"
        repo_t="$(orca_info_time "${f%.json}.info")"
        if [ "$live_t" -gt "$repo_t" ] 2>/dev/null; then
            STALE+=("$base")
        fi
    fi
done
if [ "${#STALE[@]}" -gt 0 ] && [ "$FORCE" -eq 0 ]; then
    echo "ERROR: these live presets are newer than the repo copies (tuned in the" >&2
    echo "       GUI, never exported) — run export-presets.sh first, or pass --force:" >&2
    for s in "${STALE[@]}"; do echo "         $s" >&2; done
    exit 1
fi

BACKUP="$ORCA_CONFIG/user_backup-orca-presets/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$ORCA_USER_PROCESS" "$ORCA_USER_FILAMENT"
NOW="$(date +%s)"
for f in "${FILES[@]}"; do
    base="$(basename "$f" .json)"
    case "$f" in
        "$REPO_PROCESS"/*) dst="$ORCA_USER_PROCESS" ;;
        *)                 dst="$ORCA_USER_FILAMENT" ;;
    esac
    if [ -f "$dst/$base.json" ] && ! cmp -s "$f" "$dst/$base.json"; then
        mkdir -p "$BACKUP"
        cp -p "$dst/$base.json" "$BACKUP/$base.json"
        [ -f "$dst/$base.info" ] && cp -p "$dst/$base.info" "$BACKUP/$base.info"
    fi
    cp "$f" "$dst/$base.json"
    info_src="${f%.json}.info"
    if [ -f "$info_src" ]; then
        # Refresh updated_time so Orca does not consider the copy stale.
        sed "s/^updated_time = .*/updated_time = $NOW/" "$info_src" > "$dst/$base.info"
    fi
    echo "  installed: $base -> ${dst/#$HOME/\~}"
done
[ -d "$BACKUP" ] && echo "  (overwritten files backed up to ${BACKUP/#$HOME/\~})"

echo
echo "Start Snapmaker Orca to pick these up. It reads user presets only at"
echo "startup, and rewrites them from memory on exit."
