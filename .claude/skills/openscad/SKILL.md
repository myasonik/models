---
name: openscad
description: Create versioned OpenSCAD (.scad) files for 3D printing, render previews, and compare iterations. Use this when designing or iterating on 3D models.
allowed-tools:
  - Bash(*/render-scad.sh*)
  - Bash(*/version-scad.sh*)
  - Read
  - Write
  - Glob
---

# OpenSCAD Design Skill

Create versioned OpenSCAD files, render previews, and compare iterations for 3D printing designs.

## Where Models Live

One folder per model, under `models/`. Never write a `.scad`, render, or export
to the project root.

```
models/
  snowman/
    snowman_001.scad
    snowman_001.png
    snowman_001.stl
    snowman_002.scad
  bracket/
    bracket_001.scad
```

`version-scad.sh` creates the model's folder and prints the full path to write
to. The render and export scripts derive their output paths from the input
`.scad`, so artifacts land beside the model without being told where to go.
Both refuse to write to the project root.

Set `MODELS_DIR` to use a root other than `models/`.

## Workflow

### 1. Determine the Next Version Number

Before creating a new .scad file, find existing versions:

```bash
.claude/skills/openscad/scripts/version-scad.sh <name>
```

This creates `models/<name>/` if needed and prints the next version path. For
example, if `models/piano/piano_001.scad` exists, it prints
`models/piano/piano_002.scad`.

### 2. Create the Versioned .scad File

Write the OpenSCAD code to the path printed after `Create:`.

### 3. Render the Preview

```bash
.claude/skills/preview-scad/scripts/render-scad.sh models/<name>/<name>_<version>.scad \
    --output models/<name>/<name>_<version>.png
```

### 4. Compare with Previous Version

Read both the current and previous PNG images to visually compare:

- Current: `models/piano/piano_002.png`
- Previous: `models/piano/piano_001.png` (if it exists)

Evaluate what changed and whether the new version better matches requirements.

### 5. Iterate

If the design needs improvement:

1. Analyze what's wrong
2. Create the next version (e.g., `models/piano/piano_003.scad`)
3. Render and compare again

## Design Notes for Printability

- Shapes that should union into one solid must actually overlap. Tangent spheres
  touch at a single point and produce a non-manifold mesh.
- Give the model a flat footprint. Slice the bottom flat rather than letting a
  curved surface meet the bed at one point.
- Avoid tapering features to a true zero-width tip; leave a small flat face.

## Full Pipeline

```
/openscad → /preview-scad → /export-stl (with validation)
```
