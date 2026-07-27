---
name: u1-reference
description: Reference geometry and hardware dimensions for the Snapmaker U1 printer — build volume, toolheads, and meshes of U1 parts that models mate with, such as the filament holder. Use when designing anything that has to fit, seat against, stack on, or clear a U1 part, or when a model needs the printer's own dimensions.
allowed-tools:
  - Read
  - Glob
---

# Snapmaker U1 Reference Skill

Hardware facts and reference meshes for the printer this repo targets. Use it
instead of re-deriving U1 dimensions or keeping private copies of reference
geometry inside a model folder.

## Printer

| Property | Value |
| --- | --- |
| Build volume | 270 × 270 × 270 mm |
| Toolheads | 4 (SnapSwap), 0.4 mm stainless nozzles |
| Hotend max | 300 °C |
| Bed max | 100 °C, textured PEI |
| Motion | CoreXY |

## Reference meshes

### `assets/holder_reference.stl`

The U1 filament holder — the part the `u1_holder_lid` model was designed to
seat onto. Binary STL, 48,666 triangles.

| Property | Value |
| --- | --- |
| Bounding box | 83.5 × 41.5 × 45.8 mm |
| Origin | centered in X/Y, bottom face on Z=0 |
| Rim height | 45.8 mm |
| Lid seat height | 41.62 mm above the holder base |
| Stack pitch | 5.45 mm from a seated lid to the next holder's base |

Import it with a path relative to the model file:

```scad
// model folder at the repo root (one level deep)
import("../.claude/skills/u1-reference/assets/holder_reference.stl");

// model under ARCHIVE/ (two levels deep)
import("../../.claude/skills/u1-reference/assets/holder_reference.stl");
```

## Why assets live here

A mesh nothing in this repo can regenerate is an **input**. Inputs belong in a
skill, where they are shared and obviously permanent — not inside a model
folder, where `archive-model` has to special-case them to avoid deleting them.

If a model needs a reference mesh, add it here and import it from the skill.
Don't copy it into the model folder.

## Verifying an import resolves

A wrong path does **not** fail the render. OpenSCAD prints
`WARNING: Can't open import file ...`, skips the geometry, and still exits
successfully — so the model renders missing whatever it was supposed to mate
with. After changing an import path, check the render output for that warning
rather than trusting the exit status.
