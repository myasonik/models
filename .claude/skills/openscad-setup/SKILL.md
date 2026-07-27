---
name: openscad-setup
description: Install, configure, and troubleshoot the OpenSCAD binary the modeling skills depend on. Use when OpenSCAD is not found, renders fail or hang, geometry validation reports STATUS: UNKNOWN, gridfinity models error with "No grid element available", or when setting this repo up on a new machine.
allowed-tools:
  - Bash(*/render-scad.sh*)
  - Bash(openscad*)
  - Read
---

# OpenSCAD Setup Skill

The `openscad`, `preview-scad`, `export-stl`, `print-audit`, and `gridfinity`
skills all shell out to an OpenSCAD binary. This skill covers getting that
binary installed and discovered correctly.

## Which reference to read

- **Linux** — `references/linux.md`
- **Windows** — `references/windows.md`

## Binary discovery, in short

Every script resolves OpenSCAD the same way, and `$OPENSCAD_BIN` overrides
everything:

```bash
export OPENSCAD_BIN="/path/to/openscad"
```

## Symptom to cause

| Symptom | Cause |
| --- | --- |
| `No grid element available` on a gridfinity model | A stable/2021.01 build is being used. Gridfinity needs a nightly. |
| A full render takes minutes instead of seconds | Same — the old build lacks the Manifold engine. |
| `STATUS: UNKNOWN` from `export-stl` | Windows only: `openscad.exe` is being used. It swallows console output, so validation is blind. Use `openscad.com`. |
| OpenSCAD not found at all | Not installed, or installed somewhere discovery doesn't look. Set `OPENSCAD_BIN`. |
| Scripts won't run at all | Windows only: run them from Git Bash, not PowerShell or `cmd.exe`. |
| `Permission denied` on a script | Execute bits lost in transit. `chmod +x .claude/skills/*/scripts/*.sh` |
| PNG render fails on a headless box | No OpenGL context. Wrap the binary in `xvfb-run` — see `references/linux.md`. |

## Verifying

Both reference files end with a verification procedure. Run the gridfinity
check specifically, not just the plain `cube(10)` one — it exercises the
nightly-only special-variable scoping, so it proves the right binary is
actually in use rather than merely present.
