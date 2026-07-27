---
name: archive-model
description: Retire a finished or abandoned model into ARCHIVE/, deleting renders and STL exports that can be rebuilt from source. Use when the user says a model is done, dead, abandoned, or should be archived, filed away, or cleaned up.
allowed-tools:
  - Bash(*/archive-model.sh*)
  - Read
  - Glob
---

# Archive Model Skill

Retire a model into `ARCHIVE/` and drop everything that can be regenerated
from its `.scad` sources.

## Usage

```bash
.claude/skills/archive-model/scripts/archive-model.sh <model-name>
```

Add `--dry-run` to see what it would delete without touching anything. Use it
first on any model you haven't archived before.

Already-archived models can be passed too — the script skips the move and runs
only the deletion pass. A trailing slash is fine, so tab completion works.

## When it refuses

If the folder contains no `.scad` files, nothing is deleted and the script
says so. "Regenerable" means *some `.scad` can rebuild it* — with no sources
present, the renders and STLs are orphans and deleting them would destroy the
only copy.

## What it keeps and what it deletes

**Deleted** — renders (`.png`) and exports (`.stl`). Both rebuild from source:
`preview-scad` regenerates the renders, `export-stl` regenerates the STLs.

**Kept** — `.scad` sources, `SPEC.md`, `HISTORY.md`, and any `.stl`/`.png` that
a `.scad` in the folder `import()`s or `surface()`s.

Deleting an STL is only safe when some `.scad` can recreate it. Never widen
this to "delete all STLs."

## Kept files are a problem to resolve, not a result

The script protects any `.stl`/`.png` a `.scad` imports, because deleting one
could be unrecoverable. But a protected file inside a model folder is always
one of two things, and the script cannot tell them apart:

1. **A genuine external input** — a vendor mesh, a scan, a downloaded part.
   Nothing in this repo rebuilds it. It should not be in `ARCHIVE/` either:
   move it into a skill and repoint the imports. `u1-reference` holds the U1
   hardware meshes and is the model for this.
2. **A self-export** — an STL of one of the model's own sources, imported by a
   fit-check or section view. It should be deleted and regenerated on demand.

So the script prints a **REVIEW** block naming each kept file, and where it
can, the sibling source it was probably exported from. Work that list; don't
treat a kept file as settled.

`ARCHIVE/snapmaker-back-tray/v002.stl` is the live example of case 2 left
in place deliberately: it is an ASCII export of `snapmaker-back-tray_002.scad`
(identical bounding box and triangle count), imported by `bincheck.scad` for a
collision test. It stays only because deleting it would break that view until
someone re-exports it.

**Move external inputs out before archiving, not after.** Archiving a model
that still owns its reference geometry is what creates this ambiguity.

## Include depth

Model folders live at the repo root, so their escaping includes use a single
`../`. Moving into `ARCHIVE/` adds a directory level, so those paths need
`../../`. The script rewrites them automatically — it adds one `../` to any
`include`/`use` path that already starts with `../`.

Getting this wrong fails silently: OpenSCAD renders an empty or partial model
rather than erroring clearly. After archiving a model with external includes
(anything gridfinity), render it once to confirm it still resolves.

## After archiving

The script stages its own deletions when the files are tracked, but does not
commit. Review with `git status` and commit when ready.
