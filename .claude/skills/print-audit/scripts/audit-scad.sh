#!/usr/bin/env bash

# OpenSCAD Printability Auditor
# Mechanical checks from Billie Ruben's "CAD Design Tips for 3D Printing":
#   - manifold validation (via OpenSCAD console output)
#   - overhang analysis from STL facet normals (>45deg flagged, bed excluded)
#   - bridge detection (downward-horizontal faces above the bed)
#   - horizontal-hole candidates (teardrop advisory) from the .scad source
#   - wall-width and parametric-style lints from the .scad source
# Cross-platform: macOS, Linux, Windows (Git Bash / MSYS2)

set -uo pipefail

# --- Locate OpenSCAD (same search order as render-scad.sh) -----------------
find_openscad() {
    if [[ -n "${OPENSCAD_BIN:-}" ]]; then
        if [[ -x "$OPENSCAD_BIN" ]] || command -v "$OPENSCAD_BIN" &>/dev/null; then
            printf '%s' "$OPENSCAD_BIN"; return 0
        fi
        echo "Error: OPENSCAD_BIN is set to '$OPENSCAD_BIN' but that is not executable" >&2
        return 1
    fi
    # Any nightly before any stable install: Manifold engine (much faster
    # renders) and fixed special-variable scoping across use'd files
    # (gridfinity needs it). Linux snapshot packages install as
    # `openscad-nightly`, alongside a possibly-stale `openscad`.
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
        "/usr/bin/openscad" "/usr/local/bin/openscad"
    )
    for c in "${stable[@]}"; do
        [[ -x "$c" ]] && { printf '%s' "$c"; return 0; }
    done
    command -v openscad.com &>/dev/null && { printf '%s' "openscad.com"; return 0; }
    command -v openscad     &>/dev/null && { printf '%s' "openscad";     return 0; }
    return 1
}

if [[ $# -lt 1 || -z "${1:-}" ]]; then
    cat <<'EOF'
Usage: audit-scad.sh <input.scad> [--line-width <mm>]

Runs mechanical printability checks and prints a report to stdout.
Options:
  --line-width <mm>   Extrusion line width for wall checks (default 0.4)
EOF
    exit 1
fi

INPUT="$1"; shift
LINE_W=0.4
while [[ $# -gt 0 ]]; do
    case $1 in
        --line-width) LINE_W="$2"; shift 2 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

[[ -f "$INPUT" ]] || { echo "Error: not found: $INPUT" >&2; exit 1; }

if ! OPENSCAD="$(find_openscad)"; then
    echo "Error: OpenSCAD not found (set OPENSCAD_BIN)." >&2
    exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
STL="$TMP/audit.stl"

echo "=============================================="
echo "PRINTABILITY AUDIT: $(basename "$INPUT")"
echo "=============================================="

# --- Export ASCII STL, capture console for manifold check ------------------
RESULT=""
RESULT="$("$OPENSCAD" --export-format asciistl -o "$STL" "$INPUT" 2>&1)" || {
    echo "FAIL: OpenSCAD could not render the model:"
    echo "$RESULT"
    exit 1
}

echo ""
echo "--- [21] Manifold geometry ---"
if grep -qiE "not.*manifold|non-manifold|self-intersect|degenerate" <<<"$RESULT"; then
    echo "WARN: OpenSCAD reported geometry issues:"
    grep -iE "manifold|intersect|degenerate|warning" <<<"$RESULT" | head -5
elif [[ -z "${RESULT//[[:space:]]/}" ]]; then
    echo "UNKNOWN: no console output (GUI binary?). Cannot validate."
else
    echo "PASS: no manifold/self-intersection/degenerate warnings."
fi

# --- Facet analysis: overhangs and bridges ---------------------------------
echo ""
echo "--- [2,7-9] Overhangs (bed excluded) / [12] Bridges ---"
grep -E "facet normal|vertex" "$STL" | awk -v bedtol=0.3 '
$1=="facet" { fnx=$3; fny=$4; fnz=$5; nv=0; next }
$1=="vertex" {
    nv++
    vx[nv]=$2; vy[nv]=$3; vz[nv]=$4
    if(minz=="" || $4<minz) minz=$4
    if(nv==3){
        ux=vx[2]-vx[1]; uy=vy[2]-vy[1]; uz=vz[2]-vz[1]
        wx=vx[3]-vx[1]; wy=vy[3]-vy[1]; wz=vz[3]-vz[1]
        cx=uy*wz-uz*wy; cy=uz*wx-ux*wz; cz=ux*wy-uy*wx
        A=0.5*sqrt(cx*cx+cy*cy+cz*cz)
        if(A>1e-9){
            nzg=cz/(2*A)
            if(fnx*cx+fny*cy+fnz*cz<0) nzg=-nzg
            n++
            area[n]=A; nz[n]=nzg
            gx[n]=(vx[1]+vx[2]+vx[3])/3
            gy[n]=(vy[1]+vy[2]+vy[3])/3
            gz[n]=(vz[1]+vz[2]+vz[3])/3
            zl[n]=(vz[1]<vz[2]?(vz[1]<vz[3]?vz[1]:vz[3]):(vz[2]<vz[3]?vz[2]:vz[3]))
            zh[n]=(vz[1]>vz[2]?(vz[1]>vz[3]?vz[1]:vz[3]):(vz[2]>vz[3]?vz[2]:vz[3]))
        }
    }
}
END{
    okA=0; warnA=0; sevA=0; bedA=0
    for(i=1;i<=n;i++){
        if(nz[i] > -0.7071){ okA+=area[i]; continue }         # wall or upward
        if(zh[i] <= minz+bedtol){ bedA+=area[i]; continue }    # bed contact
        if(nz[i] > -0.8660){ warnA+=area[i]; w++; wl[w]=i }    # 45-60 deg
        else               { sevA+=area[i];  s++; sl[s]=i }    # >60 deg / flat
    }
    printf "Bed contact: %.0f mm2. Faces >45deg overhang: %.0f mm2 (45-60deg), %.0f mm2 (>60deg or flat-down).\n", bedA, warnA, sevA
    if(warnA+sevA < 1){ print "PASS: no meaningful overhang area above the bed."; exit }
    if(sevA>=1){
        print "WARN: severe overhangs / bridges (flat-ish downward faces above the bed):"
        # top offenders by area
        for(i=1;i<=s;i++) idx[i]=sl[i]
        for(i=1;i<=s;i++) for(j=i+1;j<=s;j++)
            if(area[idx[j]]>area[idx[i]]){t=idx[i];idx[i]=idx[j];idx[j]=t}
        lim = s<8 ? s : 8
        for(i=1;i<=lim;i++)
            printf "  ~%.0f mm2 at (%.0f, %.0f, Z=%.1f)\n",
                   area[idx[i]], gx[idx[i]], gy[idx[i]], gz[idx[i]]
        print "  Flat spans up to ~20mm usually bridge cleanly [12];"
        print "  larger ones need supports, ribs [15,23], or a 45deg chamfer [9]."
    }
    if(warnA>=1)
        printf "NOTE: %.0f mm2 in the 45-60deg range: printable on tuned machines, visible quality loss likely.\n", warnA
}'

# --- Source lints -----------------------------------------------------------
echo ""
echo "--- [1] Wall widths vs ${LINE_W}mm line width ---"
awk -v lw="$LINE_W" '
/^[a-zA-Z_][a-zA-Z0-9_]* *= *[0-9.]+ *;/ {
    name=$1
    if(name ~ /wall|thick|_t$|_w$/){
        val=$0; sub(/^[^=]*= */,"",val); sub(/ *;.*/,"",val)
        r = val/lw
        frac = r - int(r+0.5); if(frac<0) frac=-frac
        if(frac > 0.126)
            printf "WARN: %s = %s is not a multiple of %.1f (nearest: %.1f)\n",
                   name, val, lw, int(r+0.5)*lw
        else
            printf "PASS: %s = %s (~%dx line width)\n", name, val, int(r+0.5)
    }
}' "$INPUT"

echo ""
echo "--- [3,16] Horizontal-axis holes / curves (teardrop advisory) ---"
HORIZ="$(grep -nE "rotate\(\[ *(90|-90)|rotate\(\[ *[0-9]+ *, *(90|-90)" "$INPUT" | head -8 || true)"
if [[ -n "$HORIZ" ]]; then
    echo "Candidates (cylinders/curves rotated to a horizontal axis):"
    echo "$HORIZ"
    echo "Review: horizontal round holes should be teardrop/pointed [3,4];"
    echo "curves with X/Y axes print with visible stepping [16]."
else
    echo "PASS: no horizontal-axis rotations found."
fi

echo ""
echo "--- [11] Parametric style ---"
NPARAM="$(grep -cE '^[a-zA-Z_][a-zA-Z0-9_]* *= *[-0-9.]+' "$INPUT" || true)"
NMAGIC="$(grep -oE '(cube|cylinder|translate|sphere)\([^)]*[0-9]{2,}' "$INPUT" | wc -l || true)"
echo "Named parameters: $NPARAM; geometry calls with inline 2+ digit literals: $NMAGIC"
if [[ "$NPARAM" -ge 5 ]]; then
    echo "PASS: model is parameter-driven."
else
    echo "NOTE: few named parameters; consider extracting dimensions [11]."
fi

echo ""
echo "=============================================="
echo "Mechanical checks done. Visual checklist: see SKILL.md sections B and C."
echo "=============================================="
