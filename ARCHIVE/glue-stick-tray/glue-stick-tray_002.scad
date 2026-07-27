// Gridfinity 2x1 tray for two glue sticks standing upright
// Sticks: 30mm diameter; holes 31mm for easy in/out clearance

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
grid_x = 2;            // grid cells in x
grid_y = 1;            // grid cells in y
height_units = 6;      // 6 x 7mm = 42mm tall (plus stacking lip)
stick_diameter = 29;   // glue stick diameter, mm (measured)
clearance = 1;         // added to hole diameter, mm

hole_radius = (stick_diameter + clearance) / 2;

bin = new_bin(
    grid_size = [grid_x, grid_y],
    height_mm = height(height_units, 0),
    hole_options = bundle_hole_options()   // plain base, no magnet/screw holes
);

bin_render(bin) {
    bin_subdivide(bin, [grid_x, grid_y]) {
        cut_chamfered_cylinder(
            radius = hole_radius,
            depth = cgs().z,
            chamfer_radius = 1
        );
    }
}
