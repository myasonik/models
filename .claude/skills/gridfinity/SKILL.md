---
name: gridfinity
description: Design Gridfinity storage-system models — bins, divided trays, baseplates, drawer organizers, bit/tool holders — using the vendored gridfinity-rebuilt OpenSCAD library. Use whenever the user mentions gridfinity, storage bins or trays, drawer inserts or organizers, baseplates, or wants to store/organize small parts on a 42mm grid, even if they never say the word "gridfinity".
allowed-tools:
  - Bash(*/render-scad.sh*)
  - Bash(*/version-scad.sh*)
  - Bash(*/export-stl.sh*)
  - Bash(*/audit-scad.sh*)
  - Read
  - Write
  - Edit
  - Glob
---

# Gridfinity Design Skill

Create Gridfinity bins and baseplates as versioned `.scad` models, built on the
vendored [gridfinity-rebuilt-openscad](lib/gridfinity-rebuilt-openscad/) library
(MIT, kennetek). The library owns the fussy geometry — base profile, stacking
lip, magnet pockets — so a model file is mostly one `new_bin()` call plus
cutters. Never hand-roll the base or lip profiles: they mate with other
people's prints, and a fraction of a millimeter of error makes bins wobble or
not seat at all.

This skill layers on the standard pipeline:
`/openscad → /preview-scad → /print-audit → /export-stl`.

## Step 0 — Pin down the ask

Gridfinity requests are almost always under-specified ("make me a bin for
screws"). Before writing any SCAD, resolve the points below. If the user's
message doesn't answer them, ask — presenting sensible defaults so they can
just say "defaults are fine" — and offer the common niceties they may not know
to ask for (scoops, label tabs, magnets):

1. **Footprint** — grid units in x·y (cells are 42mm). Does it need to fit a
   specific drawer or existing baseplate?
2. **Height** — in 7mm z-units (2, 3, 6 are the stock sizes), or "must fit an
   object X mm tall" (the library can work from internal height directly).
   Warn that the stacking lip adds ~4.4mm *on top* of the nominal height.
3. **Stacking** — will bins stack? If not (e.g. top shelf of a drawer),
   dropping the lip saves height.
4. **Base** — project default is a **plain base, no holes**. Offer magnet
   pockets (6×2mm) and/or M3 screw holes only if the user mounts bins.
5. **Interior** — one open cavity, equal divisions (n×m), custom-sized
   compartments, cylindrical holes (bit/pen holders), or a custom-shaped
   cutout for a specific object.
6. **Niceties** — scoop (curved floor for finger access to small parts) and
   label tabs. Both default off for plain bins; suggest both when the bin
   stores small loose parts.

For baseplates: exact drawer interior dimensions (mm), and whether leftover
space should go to one side or be split evenly.

## Spec cheat sheet

Sanity-check numbers (the library enforces these — never redefine them):

| Thing | Value |
|---|---|
| Grid pitch | 42 × 42 mm per cell |
| Height unit | 7 mm (`gridz`), stock bins are 2u / 3u / 6u |
| Stacking lip | 4.4 mm nominal on top of bin height (~3.55 printed, fillet — stacks identically) |
| Base height | first 7 mm of every bin is the base section |
| Magnets | 6 mm ⌀ × 2 mm; holes 6.5 mm (5.9 mm with crush ribs) |
| Screws | M3, at the same corner pockets |
| Hole positions | 8 mm from each cell edge (26 mm apart per cell) |

## Using the library

The library lives at `.claude/skills/gridfinity/lib/gridfinity-rebuilt-openscad/`.
Model files under `models/<name>/` reach it with `../../`.

**Bin model — start every bin file with this exact block:**

```scad
include <../../.claude/skills/gridfinity/lib/gridfinity-rebuilt-openscad/src/core/standard.scad>
use <../../.claude/skills/gridfinity/lib/gridfinity-rebuilt-openscad/src/core/gridfinity-rebuilt-utility.scad>
use <../../.claude/skills/gridfinity/lib/gridfinity-rebuilt-openscad/src/core/gridfinity-rebuilt-holes.scad>
use <../../.claude/skills/gridfinity/lib/gridfinity-rebuilt-openscad/src/core/bin.scad>
use <../../.claude/skills/gridfinity/lib/gridfinity-rebuilt-openscad/src/core/cutouts.scad>
use <../../.claude/skills/gridfinity/lib/gridfinity-rebuilt-openscad/src/helpers/generic-helpers.scad>
use <../../.claude/skills/gridfinity/lib/gridfinity-rebuilt-openscad/src/helpers/grid.scad>
use <../../.claude/skills/gridfinity/lib/gridfinity-rebuilt-openscad/src/helpers/grid_element.scad>

$fa = 4;
$fs = 0.25;
```

**Baseplate model:**

```scad
include <../../.claude/skills/gridfinity/lib/gridfinity-rebuilt-openscad/src/core/standard.scad>
use <../../.claude/skills/gridfinity/lib/gridfinity-rebuilt-openscad/gridfinity-rebuilt-baseplate.scad>

$fa = 8;
$fs = 0.25;
```

Three traps to avoid:

- **Never `include` the top-level entry files** (`gridfinity-rebuilt-bins.scad`
  etc.) — they render their own default model, so you'd get stray geometry
  unioned into yours. `use` is safe (imports modules only).
- **The repo's `docs/` folder is stale.** It documents the pre-2025 API
  (`gridfinityInit`, `cutEqual`, `cut`). The shipped code uses `new_bin` /
  `bin_render` / `bin_subdivide`. Trust [references/api.md](references/api.md)
  and the comments in `src/core/*.scad`, not `docs/`.
- **The `cgs()` family needs a nightly OpenSCAD build.** The
  render/export/audit scripts prefer a nightly wherever one is installed
  (the platform setup doc at the project root — `SETUP-LINUX.md` /
  `SETUP-WINDOWS.md` — covers installing one), and with it the full library
  API works. But if a render ever fails with "No grid element available" —
  or suddenly takes minutes instead of seconds — a script has fallen back
  to stable OpenSCAD 2021.01, which doesn't propagate special variables
  into `use`d files. Check with `openscad --version`-style diagnostics or
  set `OPENSCAD_BIN`, and see the compatibility note in
  [references/api.md](references/api.md) for the 2021.01 workaround if the
  nightly is truly unavailable.

## Core recipes

**Plain divided bin** (3×2 cells, 6 units tall, 3×2 compartments, scoop +
auto label tabs, plain base):

```scad
bin = new_bin(
    grid_size = [3, 2],
    height_mm = height(6, 0),     // 6 × 7mm units, lip not included
                                  // (gridz_define has NO default — always pass it)
    hole_options = bundle_hole_options()   // plain base — project default
);

bin_render(bin) {
    bin_subdivide(bin, [3, 2]) {
        // cgs() = this compartment's size in mm; style_tab 1 = edge-aware auto
        cut_compartment_auto(cgs(), style_tab = 1, scoop_percent = 1);
    }
}
```

**Sized to an object** ("must fit something 30mm tall inside"):

```scad
height_mm = height(30, 1, enable_zsnap = false)  // gridz_define 1 = internal mm
```

**Bit/pen holder** (cylindrical holes instead of compartments):

```scad
bin_render(bin) {
    bin_subdivide(bin, [4, 4]) {
        cut_chamfered_cylinder(radius = 4, depth = cgs().z, chamfer_radius = 0.5);
    }
}
```

**Baseplate fit to a drawer** (auto-fills as many 42mm cells as fit, pads the
remainder solid — `[0,0]` grid + drawer size in mm does the math for you):

```scad
gridfinityBaseplate(
    [0, 0],                 // auto: floor(drawer / 42) cells each way
    l_grid,                 // 42, from standard.scad
    [227, 331],             // measured drawer interior, mm
    0,                      // style_plate: 0 thin (1 weighted, 2 skeletonized, 3/4 screw-together)
    bundle_hole_options(),  // no magnets — plain default
    0,                      // no mounting holes (1 countersink, 2 counterbore)
    [1, 1]                  // push padding to +x/+y edges (0 = split evenly)
);
```

More patterns — custom compartment layouts, custom-shaped cutouts, solid bins,
lite bins, half-grid, `only_corners`, thumbscrews — are in
[references/api.md](references/api.md). Read it whenever a request goes beyond
the recipes above. The commented-out examples at the bottom of
`lib/gridfinity-rebuilt-openscad/gridfinity-rebuilt-bins.scad` are also
excellent working references.

## Workflow

1. Clarify the ask (Step 0), then get a versioned path:
   `.claude/skills/openscad/scripts/version-scad.sh <name>`
2. Write the model. Keep user-tweakable parameters (grid size, height,
   divisions) as named variables at the top of the file.
3. Render and **read the echo output**: every bin prints its bounding box and
   a height breakdown. Confirm the numbers match the ask (drawer clearance,
   internal height) instead of eyeballing.
4. Render verification views and read the PNGs:
   - three-quarter (`--camera 0,0,0,68,0,28,0`) — overall shape, compartments
   - bottom (`--camera 0,0,0,180,0,30,0`) — base profile and hole pattern;
     this is where a broken base is visible and it's the side you can't unsee
     after printing
   - front (`--camera 0,0,0,90,0,0,0`) — height, lip, tab geometry
5. Iterate as new versions (`_002`, `_003`, …) per the openscad skill.
6. Finish with `/print-audit`, then `/export-stl`.

## Printing notes

- Everything the library generates prints **support-free** (45° chamfers
  throughout). Any custom cutout you add must keep that property — chamfer
  hole tops (`cut_chamfered_cylinder` does this) and avoid flat internal
  ceilings wider than a short bridge.
- `/print-audit` will WARN about overhangs on label tabs and the stacking
  lip — those are the library's own 45°-supported geometry and print fine.
  Only investigate overhang warnings on geometry *you* added.
- Magnet pockets default to crush ribs (press-fit, no glue) and chamfered
  openings. Keep those defaults.
- With an OpenSCAD nightly (Manifold engine), even full renders of
  multi-cell bins take under a second. If a render or STL export takes
  minutes, a script has silently fallen back to stable 2021.01 — fix the
  binary selection rather than waiting.
- A bin that seats too tightly or wobbles almost always means base-profile
  geometry got altered — diff against a recipe above rather than fudging
  dimensions.
