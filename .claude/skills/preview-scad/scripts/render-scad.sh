#!/usr/bin/env bash

# OpenSCAD Preview Renderer
# Renders .scad files to PNG images for visual verification
# Cross-platform: macOS, Linux, Windows (Git Bash / MSYS2)

set -euo pipefail

# ---------------------------------------------------------------------------
# Locate the OpenSCAD binary
#
# Order of preference:
#   1. $OPENSCAD_BIN (user override)
#   2. Windows console binary (openscad.com) -- writes to stdout/stderr properly
#   3. Anything named openscad on PATH
#   4. Known install locations per platform
# ---------------------------------------------------------------------------
find_openscad() {
    if [[ -n "${OPENSCAD_BIN:-}" ]]; then
        if [[ -x "$OPENSCAD_BIN" ]] || command -v "$OPENSCAD_BIN" &>/dev/null; then
            printf '%s' "$OPENSCAD_BIN"
            return 0
        fi
        echo "Error: OPENSCAD_BIN is set to '$OPENSCAD_BIN' but that is not executable" >&2
        return 1
    fi

    # Any nightly before any stable install: the Manifold engine (much faster
    # renders) and fixed special-variable scoping across use'd files
    # (gridfinity needs it) are nightly-only. Linux snapshot packages install
    # the binary as `openscad-nightly`, alongside a possibly-stale `openscad`.
    local nightly=(
        "/c/Program Files/OpenSCAD (Nightly)/openscad.com"
        "/usr/bin/openscad-nightly"
        "/usr/local/bin/openscad-nightly"
    )
    local c
    for c in "${nightly[@]}"; do
        [[ -x "$c" ]] && { printf '%s' "$c"; return 0; }
    done
    if command -v openscad-nightly &>/dev/null; then
        printf '%s' "openscad-nightly"; return 0
    fi

    local stable=(
        # Windows: prefer the .com console wrapper over the GUI-subsystem .exe,
        # otherwise stderr never reaches us and warning detection silently fails.
        "/c/Program Files/OpenSCAD/openscad.com"
        "/c/Program Files (x86)/OpenSCAD/openscad.com"
        # macOS
        "/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD"
        "$HOME/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD"
        # Linux: distro packages are often 2021.01 -- fine for plain models,
        # too old for the gridfinity library (see SETUP-LINUX.md)
        "/usr/bin/openscad"
        "/usr/local/bin/openscad"
    )
    for c in "${stable[@]}"; do
        [[ -x "$c" ]] && { printf '%s' "$c"; return 0; }
    done

    # Fall back to PATH. On Windows, still prefer the .com wrapper if present.
    if command -v openscad.com &>/dev/null; then
        printf '%s' "openscad.com"; return 0
    fi
    if command -v openscad &>/dev/null; then
        printf '%s' "openscad"; return 0
    fi

    # Last resort on Windows: the GUI exe. It works, but warnings may be lost.
    for c in "/c/Program Files/OpenSCAD/openscad.exe" \
             "/c/Program Files (x86)/OpenSCAD/openscad.exe"; do
        if [[ -x "$c" ]]; then
            echo "Warning: only found the GUI binary ($c)." >&2
            echo "         Console output may be suppressed. Prefer openscad.com." >&2
            printf '%s' "$c"; return 0
        fi
    done

    return 1
}

if ! OPENSCAD="$(find_openscad)"; then
    cat >&2 <<'EOF'
Error: OpenSCAD not found.

Install it from https://openscad.org/ then either:
  - add its directory to your PATH, or
  - set OPENSCAD_BIN to the full path of the binary.

Windows note: the installer does not add OpenSCAD to PATH, and the default
location is C:\Program Files\OpenSCAD\. Point OPENSCAD_BIN at openscad.com
(the console build) rather than openscad.exe so warnings are captured.
EOF
    exit 1
fi

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
SIZE="800x600"
COLORSCHEME="Cornfield"
RENDER_MODE="preview"
OUTPUT=""
CAMERA=""
INPUT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --output)      OUTPUT="$2"; shift 2 ;;
        --size)        SIZE="$2"; shift 2 ;;
        --camera)      CAMERA="$2"; shift 2 ;;
        --colorscheme) COLORSCHEME="$2"; shift 2 ;;
        --render)      RENDER_MODE="render"; shift ;;
        --preview)     RENDER_MODE="preview"; shift ;;
        --help|-h)
            cat <<'EOF'
Usage: render-scad.sh <input.scad> [options]

Options:
  --output <path>       Output PNG path (default: <input>_preview.png)
  --size <WxH>          Image size (default: 800x600)
  --camera <params>     Camera position: x,y,z,tx,ty,tz,d
  --colorscheme <name>  Color scheme (default: Cornfield)
  --render              Full render mode (slower, accurate)
  --preview             Preview mode (faster, default)

Environment:
  OPENSCAD_BIN          Full path to the OpenSCAD binary (overrides detection)

Example:
  render-scad.sh model.scad --size 1024x768
EOF
            exit 0 ;;
        -*) echo "Unknown option: $1" >&2; exit 1 ;;
        *)
            if [[ -z "$INPUT" ]]; then
                INPUT="$1"
            else
                echo "Error: Multiple input files specified" >&2
                exit 1
            fi
            shift ;;
    esac
done

if [[ -z "$INPUT" ]]; then
    echo "Error: No input file specified" >&2
    echo "Usage: render-scad.sh <input.scad> [options]" >&2
    exit 1
fi

if [[ ! -f "$INPUT" ]]; then
    echo "Error: Input file not found: $INPUT" >&2
    exit 1
fi

if [[ -z "$OUTPUT" ]]; then
    OUTPUT="${INPUT%.scad}_preview.png"
fi

# Renders belong beside their .scad, inside the model's folder -- never loose in
# the project root. With no --output that holds automatically, since OUTPUT is
# derived from INPUT; this catches an explicit --output aimed at the root.
if [[ "$(dirname "$OUTPUT")" == "." ]]; then
    echo "Error: refusing to write '$OUTPUT' to the project root." >&2
    echo "Renders live alongside the model, e.g. models/<name>/<name>_001.png" >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Build and run
# ---------------------------------------------------------------------------
CMD=("$OPENSCAD")
CMD+=("--viewall" "--autocenter")
CMD+=("--imgsize" "${SIZE/x/,}")
CMD+=("--colorscheme" "$COLORSCHEME")
[[ -n "$CAMERA" ]] && CMD+=("--camera" "$CAMERA")
[[ "$RENDER_MODE" == "preview" ]] && CMD+=("--preview")
CMD+=("-o" "$OUTPUT")
CMD+=("$INPUT")

echo "Rendering: $INPUT -> $OUTPUT"
echo "Mode: $RENDER_MODE, Size: $SIZE"
echo "Binary: $OPENSCAD"

# NOTE: the original script did `if OUTPUT=$("${CMD[@]}" 2>&1)`, which
# overwrote the output *path* with the command's *output*. Use RESULT instead.
RESULT=""
STATUS=0
RESULT="$("${CMD[@]}" 2>&1)" || STATUS=$?

if [[ $STATUS -ne 0 ]]; then
    echo "OpenSCAD failed (exit $STATUS):" >&2
    echo "$RESULT" >&2
    exit 1
fi

if [[ -f "$OUTPUT" ]]; then
    echo "Success: Preview saved to $OUTPUT"
    [[ -n "$RESULT" ]] && { echo "--- OpenSCAD output ---"; echo "$RESULT"; }
    exit 0
fi

echo "Error: OpenSCAD exited cleanly but no file was written to $OUTPUT" >&2
echo "$RESULT" >&2
exit 1
