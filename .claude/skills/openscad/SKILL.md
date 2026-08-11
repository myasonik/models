---
name: openscad
description: Use when designing or iterating on a 3D-printable part — creating a new model, revising an existing .scad, or changing a model's dimensions, fits, or geometry.
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

### The spec comes first

**`SPEC.md` is written before any `.scad` code, and the code is written to
satisfy it.** Same for every later version: the spec change lands first, then
the code that implements it.

A spec written after the code is not a specification — it is a description of
whatever got built. Nothing in it can fail, because it was read off the
finished part. Written first, it does the job it exists for: it forces the
dimensions, clearances, fits, wall thicknesses and print orientation to be
decided on paper, where changing them is free, instead of being discovered
while pushing geometry around.

**No exceptions:**

- Not for "simple" models. A cube with a hole still has a wall thickness, a
  clearance, and a print orientation to commit to.
- Not "I'll write the spec once the geometry settles." That is the
  description-of-code failure by another name.
- Not "the design is already settled in the conversation." Settled in
  conversation is not settled on disk, and code gets written against the file.
- Wrote code first anyway? The spec you write afterward is suspect. Write it,
  then re-read the code against it and fix whatever does not match.

| Excuse | Reality |
|---|---|
| "It's a simple part, the spec is obvious" | Then it costs two minutes. Simple parts are where unstated clearances bite. |
| "I need to model it before I know the dimensions" | Derived dimensions belong in the spec as formulas. A number you genuinely cannot state yet is the thing to resolve first. |
| "I'll capture the decisions in SPEC.md at the end" | That produces documentation, not a specification. |
| "The user already gave me the dimensions" | They gave three numbers. The spec is the other twenty. |

### Red flags — stop and write the spec

- About to Write a `.scad` when `SPEC.md` does not exist, or does not yet
  describe the change being made
- Picking a wall thickness, clearance, or print orientation inside the geometry
  code
- Writing `SPEC.md` after the render already looks right
- Thrashing between design options while editing geometry — that decision
  belonged in the spec

**All of these mean: stop, write or update `SPEC.md`, then write code against
it.**

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

Running it writes no code — the spec goes in next, and the `.scad` after that.

### 2. Write the Spec — Before Any Code

New model: write `SPEC.md` in the model folder from the template above.
Existing model: edit `SPEC.md` to state the requirement that was missing or
wrong in the version being replaced.

Pin down, in the file, everything the geometry has to honor:

- Every driving dimension, and the formula for each derived one
- Clearances and fits at every mating surface, with the material they assume
- Wall thicknesses, as multiples of the extrusion line width
- Print orientation per part, and what makes it support-free
- Anything that has to fit the build volume

If a decision is still open, resolve it here — not in the geometry. See
**The spec comes first** above.

### 3. Create the Versioned .scad File

Write the OpenSCAD code to the path printed after `Create:`, implementing what
`SPEC.md` now says. Where the code and the spec disagree, one of them is wrong:
fix the code, or go back and fix the spec deliberately — never let them drift
apart silently.

Then add the version's `HISTORY.md` entry (`v001` for a new model), using the
template above.

### 4. Render the Preview

```bash
.claude/skills/preview-scad/scripts/render-scad.sh <name>/<name>_<version>.scad \
    --output <name>/<name>_<version>.png
```

### 5. Compare with Previous Version

Read both the current and previous PNG images to visually compare:

- Current: `piano/piano_002.png`
- Previous: `piano/piano_001.png` (if it exists)

Evaluate what changed and whether the new version better matches requirements.

### 6. Iterate

If the design needs improvement, the order is the same as it was the first
time — **spec, then code:**

1. Analyze what's wrong
2. **Update `SPEC.md` first** — the requirement that was missing, or the
   decision that changed. A render that looks wrong means the spec was wrong or
   silent; say what it should have required.
3. Create the next version (e.g., `piano/piano_003.scad`) against the amended
   spec
4. Add a `HISTORY.md` entry for the new version — what changed and why
5. Render and compare again

Editing the `.scad` and updating `SPEC.md` afterward to match is the failure
this ordering exists to prevent.

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
