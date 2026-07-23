#!/usr/bin/env bash

# OpenSCAD Version Helper
# Finds the next available version number for a model name.
# Models live one-folder-per-model under $MODELS_DIR (default: models/).
# Cross-platform: macOS, Linux, Windows (Git Bash / MSYS2)

set -uo pipefail

if [[ $# -lt 1 || -z "${1:-}" ]]; then
    cat <<'EOF'
Usage: version-scad.sh <model-name>

Finds existing versions and returns the next version number. Creates the
model's folder if it does not already exist.

Models are stored one folder per model, never at the project root:

  models/<name>/<name>_001.scad
  models/<name>/<name>_002.scad

Environment:
  MODELS_DIR   Root directory holding model folders (default: models)

Example:
  version-scad.sh piano
  # If models/piano/piano_001.scad exists, outputs: models/piano/piano_002.scad
EOF
    exit 1
fi

MODEL_NAME="$1"

# A model name is a single path segment. Reject anything that would let a model
# escape its folder or climb back up to the project root.
if [[ "$MODEL_NAME" == *[/\\]* || "$MODEL_NAME" == .* ]]; then
    echo "Error: model name must be a plain name, not a path: '$MODEL_NAME'" >&2
    exit 1
fi

MODELS_DIR="${MODELS_DIR:-models}"
MODEL_DIR="${MODELS_DIR}/${MODEL_NAME}"

if ! mkdir -p "$MODEL_DIR"; then
    echo "Error: could not create $MODEL_DIR" >&2
    exit 1
fi

# NOTE: the original used `ls | sort -V | tail -1` plus a sed regex built from
# the model name -- both break on names containing regex metacharacters or
# spaces, and `sort -V` is not portable. Use a glob + pure-bash parsing instead.
shopt -s nullglob

FILES=( "${MODEL_DIR}/${MODEL_NAME}_"[0-9][0-9][0-9].scad )

if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "No existing versions found for '${MODEL_NAME}'"
    echo "Folder: ${MODEL_DIR}/"
    echo ""
    echo "Next version: ${MODEL_NAME}_001"
    echo "Create: ${MODEL_DIR}/${MODEL_NAME}_001.scad"
    exit 0
fi

HIGHEST=0
for f in "${FILES[@]}"; do
    # Strip the ".scad" suffix, then take the trailing three digits.
    base="${f%.scad}"
    num="${base: -3}"
    # 10# forces base-10 so 008 / 009 don't get read as invalid octal.
    if (( 10#$num > HIGHEST )); then
        HIGHEST=$((10#$num))
    fi
done

NEXT_VERSION="$(printf '%03d' $((HIGHEST + 1)))"
LATEST="$(printf '%s/%s_%03d.scad' "$MODEL_DIR" "$MODEL_NAME" "$HIGHEST")"

echo "Existing versions:"
printf '%s\n' "${FILES[@]}"
echo ""
echo "Folder: ${MODEL_DIR}/"
echo "Latest: ${LATEST}"
echo ""
echo "Next version: ${MODEL_NAME}_${NEXT_VERSION}"
echo "Create: ${MODEL_DIR}/${MODEL_NAME}_${NEXT_VERSION}.scad"
