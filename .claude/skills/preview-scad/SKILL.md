---
name: preview-scad
description: Render OpenSCAD (.scad) files to PNG images for visual verification. Use this after creating or modifying .scad files to see the 3D result and self-correct if needed.
allowed-tools:
  - Bash(*/render-scad.sh*)
  - Read
---

# OpenSCAD Preview Skill

Render OpenSCAD files to PNG images so you can visually verify your work.

## Usage

```
/preview-scad <file.scad> [options]
```

## Where Renders Go

Beside the `.scad` they came from, inside the model's folder. With no
`--output`, the render script derives the path from the input, so this happens
on its own. The script refuses to write to the project root.

```
models/phone_stand/phone_stand_001.scad  ->  models/phone_stand/phone_stand_001_preview.png
```

## Workflow

1. After creating or editing a `.scad` file, run this skill to render a preview
2. Read the generated PNG image to visually inspect the result
3. If the result doesn't look right, fix the code and re-render
4. Repeat until the design matches the requirements

## Running the Render Script

```bash
.claude/skills/preview-scad/scripts/render-scad.sh <input.scad> [options]
```

### Options

- `--output <path>` - Custom output path (default: `<input>_preview.png`)
- `--size <WxH>` - Image dimensions (default: `800x600`)
- `--camera <tx,ty,tz,rx,ry,rz,d>` - Camera placement (see below)
- `--colorscheme <name>` - Color scheme (default: `Cornfield`)
- `--render` - Full render mode (slower, more accurate)
- `--preview` - Preview mode (faster, default)

### Camera

The seven `--camera` values are **translation, then rotation in degrees, then
distance** — a gimbal, not an eye position aimed at a target. The rotation is
what picks the viewpoint:

- `0,0,0,90,0,0,0` — front elevation
- `0,0,0,0,0,0,0` — top-down (this is the default rotation, and a common
  surprise if you expected a front view)
- `0,0,0,68,0,28,0` — three-quarter view, good for inspecting a whole model

The script always passes `--viewall --autocenter`, which frame the model for
you. That means the translation and distance values are overridden; only the
three rotation values meaningfully affect the output.

## Example

```bash
.claude/skills/preview-scad/scripts/render-scad.sh models/phone_stand/phone_stand_001.scad
```

Then read `models/phone_stand/phone_stand_001_preview.png` to see the result.

Rendering two views — a front elevation and a three-quarter — catches problems
that a single angle hides.

## Visual Feedback Loop

When working on OpenSCAD designs:

1. Write/edit the .scad file
2. Render preview with this skill
3. Read the PNG image to see what was created
4. Evaluate: Does it match what the user asked for?
   - If yes: You're done
   - If no: Identify what's wrong, fix the code, and repeat from step 2

This iterative process helps ensure the final design meets requirements.

## Next Steps

Once the preview looks correct:

1. **Export to STL**: Use `/export-stl` to convert to printable format with geometry validation

## Full Pipeline

```
/openscad → /preview-scad → /export-stl (with validation)
```
