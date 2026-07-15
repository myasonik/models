# gridfinity-rebuilt API reference (current, post-2025 rewrite)

This documents the API the vendored library actually ships (checked against
`src/core/*.scad` at commit `910e22d`, 2025-08-31). The repo's own `docs/`
folder predates the rewrite — `gridfinityInit`, `cutEqual`, `cut`, and
`cut_move` no longer exist. If something here disagrees with the source,
the source wins: signatures live in `src/core/bin.scad`, `src/core/cutouts.scad`,
`src/core/gridfinity-rebuilt-utility.scad`, `src/core/gridfinity-rebuilt-holes.scad`,
and `gridfinity-rebuilt-baseplate.scad`.

> **OpenSCAD version note.** The render scripts prefer an OpenSCAD nightly
> build wherever one is installed (see `SETUP-LINUX.md` / `SETUP-WINDOWS.md`
> at the project root) — with it the full API below works as written, and
> full renders take seconds (Manifold engine). Stable
> 2021.01 cannot run anything built on the
> library's `$_grid_element` special variable — `cgs()`,
> `grid_element_current()`, `child_per_element()`, `style_tab = 1` (Auto),
> `tab_top_left_only = true` — failing with "No grid element available",
> because 2021.01 doesn't propagate special variables into functions in
> `use`d files. If you ever see that error (or minutes-long renders), the
> nightly isn't being used. Last-resort 2021.01 workaround: compute sizes
> in mm manually — `infill = bin_get_infill_size_mm(bin)` divided by the
> subdivision counts — and use explicit tab styles (0/2/3/4/5).

## Contents

- [Bins: the new_bin / bin_render model](#bins)
- [Height helpers](#height-helpers)
- [Base hole options](#base-hole-options)
- [Cutters (compartments, cylinders, custom)](#cutters)
- [Introspection helpers](#introspection-helpers)
- [Baseplates](#baseplates)
- [Variants: lite, half-grid, vase](#variants)
- [Constants](#constants)

## Bins

A bin is built in two steps: `new_bin()` returns a data structure, then
`bin_render()` turns it into geometry and **subtracts all children** from it.
A `bin_render` call with no children yields a solid bin.

```scad
function new_bin(
    grid_size,                          // [x, y] in bases, e.g. [3, 2]
    height_mm,                          // use height(...); includes base, excludes lip
    fill_height = 0,                    // 0 = auto. Negative = subtract from auto. -height_mm = no infill
    include_lip = true,                 // stacking lip (adds ~4.4mm above height_mm)
    hole_options = bundle_hole_options(),  // see below; default = plain base
    only_corners = false,               // holes only at bin corners, not every cell
    thumbscrew = false,                 // gridfinity-refined center thumbscrew
    grid_dimensions = GRID_DIMENSIONS_MM,  // [42, 42]; divide by 2 for half-grid
    base_thickness = BASE_HEIGHT        // lower for hollow "lite" bins
)
```

Inside `bin_render(bin) { ... }`, children are cutting tools. The coordinate
frame is translated so **[0,0,0] is the center of the bin at the top of the
infill**; cutters extend downward. Guard rails prevent children from cutting
into the base and stacking lip.

Positioning helpers (children of `bin_render` only):

- `bin_subdivide(bin, [nx, ny]) { ... }` — repeats children once per grid
  element, centered in each. Inside it, `cgs()` gives the element's size.
- `bin_translate(bin, [x, y])` — moves children to bin-grid coordinates:
  [0,0] is the bin's bottom-left corner, 1 unit = 1 base (42mm). Fractional
  positions are fine ([0.5, 0.5] = center of first cell).

## Height helpers

```scad
height(z, gridz_define, enable_zsnap = true)
```

`gridz_define` has **no default value** — `height(6)` fails an assert. Always
pass it explicitly: `height(6, 0)`.

| gridz_define | meaning of `z` |
|---|---|
| 0 | 7mm increments, lip excluded (classic "6u" sizing) — the default |
| 1 | **internal** usable mm ("must fit a 30mm-tall object") |
| 2 | external mm, lip excluded |
| 3 | external mm, lip included |

`enable_zsnap` rounds up to the next full 7mm increment — good for staying
grid-compatible, turn it off when an exact internal fit matters.

`fromGridfinityUnits(u)` = `u * 7` (mm), for quick literal heights.

## Base hole options

```scad
bundle_hole_options(
    refined_hole = false,   // gridfinity-refined snap-in style; incompatible with magnet_hole
    magnet_hole = false,    // 6x2mm magnet pockets
    screw_hole = false,     // M3 through-holes
    crush_ribs = false,     // press-fit ribs inside magnet holes (recommended with magnets)
    chamfer = false,        // eased opening for magnet insertion (recommended with magnets)
    supportless = false     // print-in-place geometry over screw holes
)
```

Project default is `bundle_hole_options()` — a completely plain base.
For glue-free magnets use
`bundle_hole_options(magnet_hole=true, crush_ribs=true, chamfer=true)`.
Pass the result as `hole_options` to `new_bin` (and to baseplates).

## Cutters

**`cut_compartment_auto(size_mm, style_tab=5, tab_top_left_only=false, scoop_percent=0)`**
The standard compartment: rounded box, optional label tab and scoop. Use
inside `bin_subdivide` with `cgs()`:

```scad
bin_render(bin) {
    bin_subdivide(bin, [divx, divy]) {
        cut_compartment_auto(cgs(), style_tab = 1, scoop_percent = 1);
    }
}
```

`style_tab`: 0 Full · 1 Auto (edge-aware) · 2 Left · 3 Center · 4 Right ·
5 None. `scoop_percent`: 0 off → 1 full curve. For a shallower compartment,
pass `cgs(height = 25)` (depth in mm).

**`cgs(size=[1,1], height=0)`** — "current grid size": converts a size in
subdivision units to mm, only valid inside `bin_subdivide`. `cgs(height=25)`
overrides depth (mm); `height=0` means full depth.

**`compartment_cutter(size_mm, scoop_percent=0, tab_width=0, tab_angle=90, center_top=true)`**
Free-placement compartment for custom layouts. Pair with `bin_translate`;
`center_top=false` puts the compartment's corner (not center) at the current
position, which reads naturally with corner coordinates:

```scad
bin_render(bin) {   // bin is 3x3
    bin_translate(bin, [0, 0])
    compartment_cutter(cgs([2, 3]), center_top = false);  // tall left section
    bin_translate(bin, [2, 0])
    compartment_cutter(cgs([1, 3]), center_top = false);  // narrow right section
}
```

Compartments may overlap — union of overlapping cutters makes L/T-shaped
pockets.

**`cut_chamfered_cylinder(radius, depth, chamfer_radius=0, cut_lip=false)`**
Cylindrical pocket with a 45° chamfered rim (keeps the top printable and
finger-friendly). The go-to for bit holders, pen cups, test-tube racks.

**Custom-shaped cutouts** — any solid works as a cutter. Position with
`bin_translate`, remember z=0 is the top of the infill, so extrude downward:

```scad
bin_render(bin) {
    depth = bin_get_infill_size_mm(bin).z;
    bin_translate(bin, [1, 0.5])        // center of a specific region
    translate([0, 0, -depth])
    linear_extrude(depth)
    offset(0.4)                          // printing clearance around the object
    import("caliper_outline.dxf");       // or polygon(), square(), etc.
}
```

Give object-shaped pockets 0.3–0.5mm of clearance (`offset()`) and add a
finger notch (an overlapping cylinder or compartment) so the object can be
lifted out.

## Introspection helpers

Every bin echoes its infill size, bounding box, and a height breakdown on
render — read that output to verify dimensions. Programmatic versions:

- `bin_get_bounding_box(bin)` → outer [x, y, z] mm (excl. printed-lip nuance)
- `bin_get_infill_size_mm(bin)` → usable interior [x, y, z] mm
- `bin_get_bases(bin)` → [gridx, gridy]
- `bin_get_height_breakdown(bin)` → labeled height components

Use `bin_get_infill_size_mm(bin).z` as the `depth` for full-depth custom
cutters.

## Baseplates

Defined in the top-level `gridfinity-rebuilt-baseplate.scad` — `use` that file
(plus `include` standard.scad). One module does everything:

```scad
gridfinityBaseplate(
    grid_size_bases,   // [x, y] in cells; [0, 0] = auto-fit from min_size_mm
    length,            // cell size: pass l_grid (42)
    min_size_mm,       // [x, y] minimum outer size in mm ([0, 0] to ignore);
                       //   extra space beyond whole cells is filled solid
    sp,                // style_plate: 0 thin · 1 weighted · 2 skeletonized
                       //   · 3 screw-together · 4 screw-together minimal
    hole_options,      // bundle_hole_options(...) — magnets in the plate
    sh,                // mounting screw style: 0 none · 1 countersink · 2 counterbore
    fit_offset = [0, 0] // -1..1 per axis: where the solid padding goes
                       //   (-1 = all at negative edge, 0 = split, 1 = positive edge)
)
```

Drawer workflow: measure the drawer interior, subtract ~0.5–1mm slack per
axis, pass that as `min_size_mm` with `grid_size_bases=[0,0]`. The module
echoes cells-per-axis and padding per edge — read it back to the user so they
know how many cells they're getting and where the gap sits. For drawers wider
than the printer bed, use `style_plate=3` (screw-together) and print in
sections.

Thin plates (style 0) are flat on the bottom and print fastest. Weighted (1)
has pockets for steel/washers plus rubber-feet cutouts. Skeletonized (2)
saves plastic on large plates. Magnet holes require styles 1–4 (thin plates
have no material to hold them).

## Variants

- **Lite bins** (less plastic): `new_bin(..., base_thickness = 1.2)` hollows
  the base section. The `gridfinity-rebuilt-lite.scad` entry file shows the
  pattern with stacked compartment walls.
- **Half-grid**: `grid_dimensions = GRID_DIMENSIONS_MM / 2` with
  `only_corners = true` — 21mm sub-cells that still seat on standard plates.
- **Spiral vase bins**: `gridfinity-spiral-vase.scad` is a separate
  customizer-oriented system; open that file directly if ever needed, don't
  mix it with `new_bin`.

## Constants

From `src/core/standard.scad` (already in scope via the `include`):

| Constant | Value | Meaning |
|---|---|---|
| `GRID_DIMENSIONS_MM` | [42, 42] | cell pitch |
| `l_grid` | 42 | legacy scalar cell pitch (baseplate arg) |
| `BASE_HEIGHT` | 7 | height of the base section of a bin |
| `STACKING_LIP_HEIGHT` | ~4.4 | nominal lip height above `height_mm` |
| `MAGNET_HOLE_RADIUS` | 3.25 | 6.5mm hole for 6mm magnets |
| `SCREW_HOLE_RADIUS` | 1.5 | M3 |
| `d_hole_from_side` | 8 | hole center inset from cell edge |

Never redefine these — they're the interoperability contract with every other
gridfinity print in existence.
