#!/usr/bin/env bash

# OpenSCAD Nightly AppImage Updater (Linux)
# Compares the installed openscad-nightly against the newest snapshot on
# files.openscad.org, and installs the newer one if there is one.
#
# Only for the extracted-AppImage install described in references/linux.md.
# If openscad-nightly came from a distro package, update it with the package
# manager instead -- this script would shadow it.

set -euo pipefail

SNAPSHOTS="https://files.openscad.org/snapshots"
LIB_DIR="$HOME/.local/lib/openscad-nightly"
BIN="$HOME/.local/bin/openscad-nightly"

CHECK_ONLY=0
[[ "${1:-}" == "--check" ]] && CHECK_ONLY=1

# ---------------------------------------------------------------------------
# Newest snapshot
#
# Two filename shapes are in play: older builds carry a build-number suffix
# (OpenSCAD-2026.01.02.ai30348-x86_64.AppImage), newer ones do not
# (OpenSCAD-2026.08.19-x86_64.AppImage). Match both -- a pattern that requires
# the suffix silently hides every recent build.
#
# The directory listing is not in date order, so sort by the version itself.
# The fixed-width YYYY.MM.DD prefix makes a lexical sort correct, and orders a
# suffixed build before the unsuffixed build of the same day.
# ---------------------------------------------------------------------------
latest=$(curl -sS --max-time 60 "$SNAPSHOTS/" \
    | grep -oE 'OpenSCAD-[0-9]{4}\.[0-9]{2}\.[0-9]{2}(\.ai[0-9]+)?-x86_64\.AppImage' \
    | sort -u | tail -1)

if [[ -z "$latest" ]]; then
    echo "Error: found no x86_64 AppImage in the snapshot listing." >&2
    echo "The naming scheme may have changed again -- check $SNAPSHOTS/ by hand." >&2
    exit 1
fi

latest_ver=${latest#OpenSCAD-}
latest_ver=${latest_ver%-x86_64.AppImage}

if command -v openscad-nightly &>/dev/null; then
    installed_ver=$(openscad-nightly --version 2>&1 | grep -oE '[0-9]{4}\.[0-9]{2}\.[0-9]{2}(\.ai[0-9]+)?' | head -1)
else
    installed_ver=""
fi

echo "Installed: ${installed_ver:-(none)}"
echo "Newest:    $latest_ver"

if [[ "$installed_ver" == "$latest_ver" ]]; then
    echo "Already up to date."
    exit 0
fi

if (( CHECK_ONLY )); then
    echo "Update available. Re-run without --check to install it."
    exit 0
fi

# Refuse to clobber a distro package: only manage our own install.
if [[ -n "$installed_ver" && ! -e "$BIN" ]]; then
    echo "Error: openscad-nightly is on PATH but $BIN does not exist," >&2
    echo "so it was not installed by this script. Update it with your package manager." >&2
    exit 1
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cd "$tmp"

echo "Downloading $latest ..."
curl -fSL --max-time 900 -O "$SNAPSHOTS/$latest"
curl -fsSL --max-time 60 -O "$SNAPSHOTS/$latest.sha256"

echo "Verifying checksum ..."
sha256sum -c "$latest.sha256"

# Extract rather than run the AppImage in place: no FUSE dependency, and the
# scripts exec the binary directly.
chmod +x "$latest"
"./$latest" --appimage-extract >/dev/null

mkdir -p "$HOME/.local/lib" "$HOME/.local/bin"
rm -rf "$LIB_DIR"
mv squashfs-root "$LIB_DIR"

cat > "$BIN" <<'LAUNCHER'
#!/bin/sh
# OpenSCAD nightly (extracted AppImage), installed by the openscad-setup skill.
exec "$HOME/.local/lib/openscad-nightly/AppRun" "$@"
LAUNCHER
chmod +x "$BIN"

echo "Installed: $(openscad-nightly --version 2>&1 | head -1)"
