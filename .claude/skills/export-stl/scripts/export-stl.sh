#!/usr/bin/env bash

# OpenSCAD to STL Exporter with Geometry Validation
# Converts .scad files to .stl for 3D printing
# Checks for non-manifold geometry and other printability issues
# Cross-platform: macOS, Linux, Windows (Git Bash / MSYS2)

set -uo pipefail

# ---------------------------------------------------------------------------
# Locate the OpenSCAD binary (see render-scad.sh for rationale)
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

    # Any nightly before any stable install: Manifold engine (renders ~100x
    # faster) and fixed special-variable scoping across use'd files (gridfinity
    # needs it). Linux snapshot packages install as `openscad-nightly`.
    local nightly=(
        "/c/Program Files/OpenSCAD (Nightly)/openscad.com"
        "/usr/bin/openscad-nightly"
        "/usr/local/bin/openscad-nightly"
    )
    local c
    for c in "${nightly[@]}"; do
        [[ -x "$c" ]] && { printf '%s' "$c"; return 0; }
    done
    command -v openscad-nightly &>/dev/null && { printf '%s' "openscad-nightly"; return 0; }

    local stable=(
        "/c/Program Files/OpenSCAD/openscad.com"
        "/c/Program Files (x86)/OpenSCAD/openscad.com"
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

    command -v openscad.com &>/dev/null && { printf '%s' "openscad.com"; return 0; }
    command -v openscad     &>/dev/null && { printf '%s' "openscad";     return 0; }

    for c in "/c/Program Files/OpenSCAD/openscad.exe" \
             "/c/Program Files (x86)/OpenSCAD/openscad.exe"; do
        if [[ -x "$c" ]]; then
            echo "Warning: only found the GUI binary ($c)." >&2
            echo "         Geometry validation relies on stderr, which the GUI build" >&2
            echo "         may not emit. Install/point at openscad.com instead." >&2
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
OUTPUT=""
FORMAT="binstl"
INPUT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --output) OUTPUT="$2"; shift 2 ;;
        --binary) FORMAT="binstl"; shift ;;
        --ascii)  FORMAT="asciistl"; shift ;;
        --help|-h)
            cat <<'EOF'
Usage: export-stl.sh <input.scad> [options]

Options:
  --output <path>   Output STL path (default: <input>.stl)
  --binary          Binary STL format (default, smaller)
  --ascii           ASCII STL format (human-readable)

Environment:
  OPENSCAD_BIN      Full path to the OpenSCAD binary (overrides detection)

Performs geometry validation during export:
  - Non-manifold edges (holes in mesh)
  - Self-intersecting geometry
  - Degenerate faces

Example:
  export-stl.sh model.scad
  export-stl.sh model.scad --output print_ready.stl
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
    echo "Usage: export-stl.sh <input.scad> [options]" >&2
    exit 1
fi

if [[ ! -f "$INPUT" ]]; then
    echo "Error: Input file not found: $INPUT" >&2
    exit 1
fi

if [[ -z "$OUTPUT" ]]; then
    OUTPUT="${INPUT%.scad}.stl"
fi

# STLs belong beside their .scad, inside the model's folder -- never loose in
# the project root. With no --output that holds automatically, since OUTPUT is
# derived from INPUT; this catches an explicit --output aimed at the root.
if [[ "$(dirname "$OUTPUT")" == "." ]]; then
    echo "Error: refusing to write '$OUTPUT' to the project root." >&2
    echo "Exports live alongside the model, e.g. models/<name>/<name>_001.stl" >&2
    exit 1
fi

echo "========================================"
echo "Export STL: $(basename "$INPUT")"
echo "========================================"
echo ""
echo "Binary: $OPENSCAD"
echo ""

CMD=("$OPENSCAD" "--export-format" "$FORMAT" "-o" "$OUTPUT" "$INPUT")

echo "Rendering and exporting..."

# NOTE: the original did `RESULT=$(...) || true` then `EXIT_CODE=$?`, which
# always captured the exit status of `true` (0). Capture the real status.
RESULT=""
EXIT_CODE=0
RESULT="$("${CMD[@]}" 2>&1)" || EXIT_CODE=$?

# ---------------------------------------------------------------------------
# Geometry validation
# ---------------------------------------------------------------------------
WARNINGS=""
HAS_ISSUES=false

if grep -qi "not.*manifold\|non-manifold" <<<"$RESULT"; then
    WARNINGS+=$'\n- Non-manifold geometry detected (mesh has holes)'
    HAS_ISSUES=true
fi

if grep -qi "self-intersect" <<<"$RESULT"; then
    WARNINGS+=$'\n- Self-intersecting geometry detected'
    HAS_ISSUES=true
fi

if grep -qi "degenerate" <<<"$RESULT"; then
    WARNINGS+=$'\n- Degenerate faces detected (zero-area triangles)'
    HAS_ISSUES=true
fi

OTHER_WARNS="$(grep -i "warning" <<<"$RESULT" | head -5 || true)"
if [[ -n "$OTHER_WARNS" ]]; then
    WARNINGS+=$'\n- Other warnings:\n'"$OTHER_WARNS"
fi

# If OpenSCAD produced no output at all, validation is meaningless -- say so
# rather than reporting a false PASSED. This is the common Windows failure mode
# when running the GUI-subsystem openscad.exe.
VALIDATION_BLIND=false
[[ -z "${RESULT//[[:space:]]/}" ]] && VALIDATION_BLIND=true

# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------
if [[ -f "$OUTPUT" ]]; then
    SIZE="$(ls -lh "$OUTPUT" | awk '{print $5}')"

    TRIANGLES=""
    if [[ "$FORMAT" == "binstl" ]] && command -v od &>/dev/null; then
        TRIANGLES="$(od -An -tu4 -j80 -N4 "$OUTPUT" 2>/dev/null | tr -d ' ' || true)"
    fi

    echo ""
    echo "--- Export Results ---"
    echo "Output: $OUTPUT"
    echo "Size: $SIZE"
    # NOTE: original tested $TRIANGULAR (a typo / never-set variable), so the
    # triangle count was never printed. Test $TRIANGLES.
    [[ -n "$TRIANGLES" ]] && echo "Triangles: $TRIANGLES"

    echo ""
    echo "--- Geometry Validation ---"

    if [[ "$VALIDATION_BLIND" == true ]]; then
        echo "STATUS: UNKNOWN - OpenSCAD produced no console output"
        echo "Validation could not run. On Windows this usually means the"
        echo "GUI binary (openscad.exe) is being used. Set OPENSCAD_BIN to"
        echo "the openscad.com console build to enable warning detection."
    elif [[ "$HAS_ISSUES" == true ]]; then
        echo "STATUS: WARNING - Issues detected"
        printf '%s\n' "$WARNINGS"
        echo ""
        echo "The model may still print, but consider fixing these issues:"
        echo "- Non-manifold: Ensure all shapes are closed solids"
        echo "- Self-intersect: Use union() to properly combine overlapping shapes"
        echo "- Degenerate: Check for very thin or zero-thickness features"
    else
        echo "STATUS: PASSED - No geometry issues detected"
        echo "- Mesh appears manifold (watertight)"
        echo "- No self-intersections found"
        echo "- Ready for slicing"
    fi

    echo ""
    echo "========================================"
    if [[ "$VALIDATION_BLIND" == true ]]; then
        echo "RESULT: Exported, but NOT validated"
    elif [[ "$HAS_ISSUES" == true ]]; then
        echo "RESULT: Exported with warnings"
    else
        echo "RESULT: Export successful"
    fi
    echo "========================================"
    exit 0
else
    echo ""
    echo "--- Export Failed ---"
    echo "OpenSCAD exit code: $EXIT_CODE"
    echo "OpenSCAD output:"
    echo "$RESULT"
    echo ""
    echo "========================================"
    echo "RESULT: Export failed"
    echo "========================================"
    exit 1
fi
