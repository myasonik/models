# OpenSCAD Setup on Linux

The `openscad`, `preview-scad`, `export-stl`, and `print-audit` skills shell
out to OpenSCAD; the `gridfinity` skill builds on all of them. The scripts are
plain bash and run natively on Linux — no Git Bash layer like on Windows.
This file covers the Linux-specific requirements.

## 1. Install a *nightly* OpenSCAD, not just the distro package

This is the one requirement the gridfinity skill added. Most distro repos
ship OpenSCAD **2021.01**, which:

- lacks the Manifold engine (full renders of multi-cell bins take minutes
  instead of under a second), and
- does not propagate special variables into `use`d files, so the gridfinity
  library's `cgs()` / auto label tabs fail with **"No grid element available"**.

Plain (non-gridfinity) models work fine on 2021.01, but install a nightly so
everything works:

- **Debian/Ubuntu**: add the official snapshot repo from
  <https://openscad.org/downloads.html#snapshots> and
  `apt install openscad-nightly`. The package installs the binary as
  `openscad-nightly` and can coexist with a stable `openscad`.
- **Fedora**: no working option. The distro repos carry only 2021.01, and
  the `openscad-devel` COPRs are dead (their newest chroot is EPEL 7).
  Use the AppImage below.
- **Arch**: `openscad-git` from the AUR.
- **Any distro (AppImage)**: the fallback that always works, and the only
  route on Fedora. Rather than running the AppImage in place, extract it and
  drop a launcher on `PATH` — no FUSE dependency, no `OPENSCAD_BIN`, no
  `~/.bashrc` edit, and no root:

  ```bash
  .claude/skills/openscad-setup/scripts/update-openscad-appimage.sh
  ```

  That script does the whole install, not just updates: it picks the newest
  snapshot, verifies its SHA-256, extracts it to
  `~/.local/lib/openscad-nightly/`, and writes a launcher at
  `~/.local/bin/openscad-nightly`. Since `~/.local/bin` is normally on `PATH`,
  discovery step 3 below finds it.
- Avoid the Snap/Flatpak builds for this project: their sandboxing and
  wrapper-command invocation don't play well with `OPENSCAD_BIN` and the
  scripts' direct execution.

If your distro ships a stable release newer than 2021.01, check whether
`openscad --version` reports 2024 or later and renders gridfinity models
(verification below); if so, it's fine too.

## 2. Binary discovery

The scripts look for OpenSCAD in this order — any nightly beats any stable:

1. `$OPENSCAD_BIN`, if set (full path, overrides everything)
2. `/usr/bin/openscad-nightly`, `/usr/local/bin/openscad-nightly`
3. `openscad-nightly` on `PATH`
4. `/usr/bin/openscad`, `/usr/local/bin/openscad`
5. `openscad` on `PATH`

With the `openscad-nightly` package installed to the default location, step 2
finds it and no configuration is needed.

## When you do need `OPENSCAD_BIN`

The extracted-AppImage install above doesn't need it. Set it for a
self-built binary, an AppImage you'd rather run in place, or to pin a
specific build:

```bash
export OPENSCAD_BIN="$HOME/apps/OpenSCAD-nightly.AppImage"
```

Add that line to `~/.bashrc` to persist it.

## 3. After copying the project over

Windows filesystems don't store execute bits, so restore them once:

```bash
chmod +x .claude/skills/*/scripts/*.sh
```

Everything else copies cleanly: the scripts already use LF line endings, and
all `.scad` include paths are lowercase and match the on-disk names, so the
case-sensitive filesystem changes nothing.

## Keeping the AppImage current

A distro package updates with the system; an extracted AppImage does not.
OpenSCAD publishes snapshots to <https://files.openscad.org/snapshots/> with
no `latest` symlink, no zsync data, and no update info embedded in the
AppImage, so `--appimage-update` does nothing. Checking is a manual step:

```bash
# report only
.claude/skills/openscad-setup/scripts/update-openscad-appimage.sh --check

# install the newest snapshot if there is one
.claude/skills/openscad-setup/scripts/update-openscad-appimage.sh
```

Snapshots land every few days, and this repo does not track OpenSCAD features
closely — checking when something misbehaves, or every few months, is enough.
Re-run the verification below after any update.

**If you check by hand, match both filename shapes.** Older snapshots carry a
build-number suffix (`OpenSCAD-2026.01.02.ai30348-x86_64.AppImage`); newer
ones dropped it (`OpenSCAD-2026.08.19-x86_64.AppImage`). A pattern requiring
the `.aiNNNNN` suffix matches only stale builds while looking like it worked.
The listing is also not in date order, so sort before taking the last entry:

```bash
curl -s https://files.openscad.org/snapshots/ \
  | grep -oE 'OpenSCAD-[0-9]{4}\.[0-9]{2}\.[0-9]{2}(\.ai[0-9]+)?-x86_64\.AppImage' \
  | sort -u | tail -1
```

## 4. Headless machines only

PNG preview rendering needs an OpenGL context. Over SSH with no display,
wrap the binary with `xvfb-run` (from the `xvfb` package): create a small
wrapper script that runs `exec xvfb-run -a openscad-nightly "$@"` and point
`OPENSCAD_BIN` at it. On a desktop install this doesn't apply.

## Verifying the setup

Basic render check:

```bash
mkdir -p _check
printf 'cube(10);\n' > _check/_check.scad
.claude/skills/preview-scad/scripts/render-scad.sh _check/_check.scad
```

A working setup prints `Binary: .../openscad-nightly` (or your
`OPENSCAD_BIN`) and `Success: Preview saved to ...`.

Gridfinity check — this exercises the nightly-only special-variable scoping,
so it proves the right binary is actually being used:

```bash
cat > _check/_check_bin.scad <<'EOF'
include <../.claude/skills/gridfinity/lib/gridfinity-rebuilt-openscad/src/core/standard.scad>
use <../.claude/skills/gridfinity/lib/gridfinity-rebuilt-openscad/src/core/gridfinity-rebuilt-utility.scad>
use <../.claude/skills/gridfinity/lib/gridfinity-rebuilt-openscad/src/core/gridfinity-rebuilt-holes.scad>
use <../.claude/skills/gridfinity/lib/gridfinity-rebuilt-openscad/src/core/bin.scad>
use <../.claude/skills/gridfinity/lib/gridfinity-rebuilt-openscad/src/core/cutouts.scad>
use <../.claude/skills/gridfinity/lib/gridfinity-rebuilt-openscad/src/helpers/generic-helpers.scad>
use <../.claude/skills/gridfinity/lib/gridfinity-rebuilt-openscad/src/helpers/grid.scad>
use <../.claude/skills/gridfinity/lib/gridfinity-rebuilt-openscad/src/helpers/grid_element.scad>
bin = new_bin(grid_size = [1, 1], height_mm = height(2, 0),
              hole_options = bundle_hole_options());
bin_render(bin) bin_subdivide(bin, [1, 1])
    cut_compartment_auto(cgs(), style_tab = 1, scoop_percent = 1);
EOF
.claude/skills/preview-scad/scripts/render-scad.sh _check/_check_bin.scad
rm -rf _check
```

Success means the nightly works end to end. **"No grid element available"**
means a stable/2021.01 binary is being used — fix with `OPENSCAD_BIN` or by
installing the nightly package. A render that takes minutes instead of a
couple of seconds is the same problem in disguise.

If OpenSCAD is not found at all, revisit step 1.
