#!/usr/bin/env bash
# Validate Orca preset JSON files against the rules Orca enforces silently.
# With no arguments, checks the presets stored in this skill.
#
#   check-presets.sh [file.json ...]
#
# Works without a live Orca config: rules needing the system profiles
# (inherits resolution, machine names) degrade to warnings.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/orca-env.sh"

if [ "$#" -gt 0 ]; then
    FILES=("$@")
else
    shopt -s nullglob
    FILES=("$REPO_PROCESS"/*.json "$REPO_FILAMENT"/*.json)
    shopt -u nullglob
fi

[ "${#FILES[@]}" -eq 0 ] && { echo "No preset files to check."; exit 0; }

ORCA_SYSTEM="$ORCA_SYSTEM" ORCA_VENDOR_INDEX="$ORCA_VENDOR_INDEX" \
ORCA_CONFIG="$ORCA_CONFIG" python3 "$SKILL_DIR/scripts/check_presets.py" "${FILES[@]}"
