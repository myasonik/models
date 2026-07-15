# OpenSCAD Setup on Windows

The `openscad`, `preview-scad`, and `export-stl` skills shell out to OpenSCAD.
This file covers the two Windows-specific gotchas.

## 1. Run the scripts from Git Bash

The skill scripts are bash. They will not run under PowerShell or `cmd.exe`.

## 2. Use `openscad.com`, not `openscad.exe`

The Windows installer ships two binaries in the same directory:

| Binary | Subsystem | Console output |
| --- | --- | --- |
| `openscad.com` | console | writes to stdout/stderr |
| `openscad.exe` | GUI | swallows stdout/stderr |

`export-stl` detects non-manifold geometry, self-intersections, and degenerate
faces by reading OpenSCAD's console output. Under `openscad.exe` there is no
output to read, so validation cannot run. The script reports
`STATUS: UNKNOWN` in that case rather than a misleading `PASSED`.

Prefer `openscad.com`.

## Binary discovery

The scripts look for OpenSCAD in this order:

1. `$OPENSCAD_BIN`, if set (full path, overrides everything)
2. Nightly builds (the gridfinity library needs one — see the gridfinity
   skill), starting with `C:\Program Files\OpenSCAD (Nightly)\openscad.com`
3. Known stable install locations, `.com` before `.exe`:
   - `C:\Program Files\OpenSCAD\openscad.com`
   - `C:\Program Files (x86)\OpenSCAD\openscad.com`
4. `openscad.com`, then `openscad`, on `PATH`
5. `openscad.exe` as a last resort, with a warning

The installer does not add OpenSCAD to `PATH`. If you installed to the default
location, step 2 finds `openscad.com` and no configuration is needed.

## When you do need `OPENSCAD_BIN`

Set it if OpenSCAD is installed somewhere non-standard, or if you want to pin a
specific build. Point it at the `.com`:

```bash
export OPENSCAD_BIN="/c/Program Files/OpenSCAD/openscad.com"
```

Add that line to `~/.bashrc` to make it persist across Git Bash sessions.

Note the Git Bash path style: `/c/Program Files/...`, not `C:\Program Files\...`.
Quote it — the path contains a space.

## Verifying the setup

```bash
printf 'cube(10);\n' > _check.scad
.claude/skills/preview-scad/scripts/render-scad.sh _check.scad
rm -f _check.scad _check_preview.png
```

A working setup prints `Binary: /c/Program Files/OpenSCAD/openscad.com` and
`Success: Preview saved to ...`. If the `Binary:` line ends in `.exe`, geometry
validation will be blind — set `OPENSCAD_BIN` as above.

If OpenSCAD is not found at all, install it from <https://openscad.org/>.
