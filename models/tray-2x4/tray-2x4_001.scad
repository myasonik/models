// Gridfinity tray 2x4 — one open cavity, 3u tall (21mm), no stacking lip,
// plain base. Fits under a 24mm clearance with 3mm to spare.

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

// --- user-tweakable parameters ---
grid = [2, 4];      // footprint in 42mm cells
gridz = 3;          // height in 7mm units (3u = 21mm)
with_lip = false;   // no stacking lip — tray stays a true 21mm tall

bin = new_bin(
    grid_size = grid,
    height_mm = height(gridz, 0),
    include_lip = with_lip,
    hole_options = bundle_hole_options()   // plain base, no holes
);

echo(bounding_box_mm = bin_get_bounding_box(bin));
echo(interior_mm = bin_get_infill_size_mm(bin));
echo(height_breakdown = bin_get_height_breakdown(bin));

bin_render(bin) {
    bin_subdivide(bin, [1, 1]) {
        cut_compartment_auto(cgs(), style_tab = 5, scoop_percent = 0);
    }
}
