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

One folder per model, at the repo root. Never write a `.scad`, render, or
export loose at the top level — it always goes inside the model's folder.

```
snowman/
  SPEC.md           # current spec — required
  HISTORY.md        # one entry per version — required
  snowman_001.scad
  snowman_001.png
  snowman_001.stl
  snowman_002.scad
bracket/
  SPEC.md
  HISTORY.md
  bracket_001.scad
ARCHIVE/            # finished/abandoned models, left alone
```

`version-scad.sh` creates the model's folder and prints the full path to write
to. The render and export scripts derive their output paths from the input
`.scad`, so artifacts land beside the model without being told where to go.
Both refuse to write to the top level.

Because model folders are one level deep, a model reaching back into the repo
uses a single `../` — e.g. `../.claude/skills/gridfinity/lib/...`.

`ARCHIVE/` holds retired models, kept as sources only — renders and STLs are
stripped because they rebuild from the `.scad`. Its contents are two levels
deep, so escaping includes use `../../`. Don't add to it or edit inside it
unless asked; use the `archive-model` skill to retire a model rather than
moving folders by hand.

Set `MODELS_DIR` to put model folders somewhere other than the repo root.

## Spec and History Files

Every model folder carries two markdown files next to the `.scad` versions:

- **`SPEC.md`** — the current specification: purpose, required dimensions,
  constraints, and design decisions. It describes the latest version as if the
  model were being specced fresh today — no version numbers, no "changed from",
  no history.
- **`HISTORY.md`** — one entry per version, newest first, saying what changed
  from the previous version and why.

A new version exists because the spec was incomplete or wrong — that is what
iteration means. So **every new `.scad` version ships with both** a `SPEC.md`
update (add the requirement that was missing, or correct the one that was
wrong) and a new `HISTORY.md` entry. The change narrative lives only in
`HISTORY.md`; `SPEC.md` never accumulates it.

Templates:

```markdown
# <Model> — Spec

## Purpose
What it's for, where it lives, how it's used.

## Requirements
- Concrete dimensions with tolerances, fit constraints, material/print constraints.

## Design decisions
- Choices made and why (orientation, wall thickness, joint style, ...).
```

```markdown
# <Model> — History

## v003
- What changed and why.

## v002
- ...

## v001
- Initial version.
```

## Workflow

### 1. Determine the Next Version Number

Before creating a new .scad file, find existing versions:

```bash
.claude/skills/openscad/scripts/version-scad.sh <name>
```

This creates `<name>/` if needed and prints the next version path. For
example, if `piano/piano_001.scad` exists, it prints
`piano/piano_002.scad`.

### 2. Create the Versioned .scad File

Write the OpenSCAD code to the path printed after `Create:`.

First version of a model: also create `SPEC.md` (the spec the code implements)
and `HISTORY.md` (with its `v001` entry) in the model folder, using the
templates above.

### 3. Render the Preview

```bash
.claude/skills/preview-scad/scripts/render-scad.sh <name>/<name>_<version>.scad \
    --output <name>/<name>_<version>.png
```

### 4. Compare with Previous Version

Read both the current and previous PNG images to visually compare:

- Current: `piano/piano_002.png`
- Previous: `piano/piano_001.png` (if it exists)

Evaluate what changed and whether the new version better matches requirements.

### 5. Iterate

If the design needs improvement:

1. Analyze what's wrong
2. Update `SPEC.md` — capture what this iteration revealed: the requirement
   that was missing or the decision that changed
3. Create the next version (e.g., `piano/piano_003.scad`)
4. Add a `HISTORY.md` entry for the new version — what changed and why
5. Render and compare again

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
