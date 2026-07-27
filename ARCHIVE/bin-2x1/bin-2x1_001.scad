// Gridfinity bin 2x1, 3 units tall (21mm + stacking lip)
// Plain open cavity, plain base (no magnets/screws), stackable.

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

// --- Parameters ---
grid_size = [2, 1];   // grid cells (42mm each)
gridz = 3;            // height in 7mm units

bin = new_bin(
    grid_size = grid_size,
    height_mm = height(gridz, 0),
    hole_options = bundle_hole_options()   // plain base
);

bin_render(bin) {
    bin_subdivide(bin, [1, 1]) {
        cut_compartment_auto(cgs(), style_tab = 5, scoop_percent = 0);  // 5 = no tab
    }
}
