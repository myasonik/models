// bellum_badge_002.scad
// v002: "Bellum" lettering traced from the source logo image (see
// bellum_text_traced.scad) instead of approximated with a system font,
// so the letterforms match the original exactly.
// Two-color badge of the "Bellum" checkerboard logo, built as separate
// printable parts (print some in white, some in black, glue together):
//   base_disc()          black - circle background; its top surface shows
//                        through the lattice holes as the black squares
//   white_lattice()      white - diamond border + white squares + grout
//                        webs, one connected piece; glue onto the disc
//   black_tiles()        black - optional drop-in tiles if you want the
//                        black squares flush with the white top surface
//   text_plate_black()   black - outline plate behind the letters (the
//                        logo's dark text outline)
//   text_letters_white() white - "Bellum" letters, glue onto the plate
//
// Everything scales from badge_d. Layer thicknesses and fit clearance are
// absolute (printer-dependent), so they stay put when you rescale.
// Companion files export one part each: _base, _lattice, _tiles,
// _text_black, _text_white. This master file shows the assembled badge.

$fa = 2;
$fs = 0.4;

// ---- scale ----
badge_d = 80;       // badge diameter: THE scale knob
n       = 5;        // checker tiles per row (odd -> black diamond corners)

// ---- thicknesses (absolute mm, independent of badge_d) ----
t_base = 3;         // black disc
t_top  = 2;         // white lattice and drop-in tiles (total badge = 5)
t_text = 1.2;       // each text layer (plate and letters)
clr    = 0.15;      // per-side XY clearance for the drop-in tiles

// ---- proportions (fractions of badge_d, from the logo) ----
diamond_frac = 0.94;   // diamond diagonal / badge diameter
border_w = max(0.045 * badge_d, 1.6);  // white rim around the checker field
grout_w  = max(0.014 * badge_d, 0.8);  // white web between tiles
text_w   = 0.80 * badge_d;             // width of "Bellum"
outline_w = max(0.022 * badge_d, 1.2); // black outline around the letters

use <bellum_text_traced.scad>  // lettering traced from the logo image

// ---- derived ----
half_diag = diamond_frac * badge_d / 2;
sq_o  = half_diag * sqrt(2);            // outer side of the white diamond
sq_f  = sq_o - 2 * border_w;            // side of the checker field
tile  = (sq_f - (n - 1) * grout_w) / n; // checker tile size
pitch = tile + grout_w;

eps = 0.01;

// ---------------- 2D shapes ----------------

// centers of the black squares, in the unrotated field frame
function tile_org(i) = -sq_f / 2 + i * pitch;

module black_squares_2d(shrink = 0) {
    for (i = [0 : n - 1], j = [0 : n - 1])
        if ((i + j) % 2 == 0)
            translate([tile_org(i) + shrink, tile_org(j) + shrink])
                square(tile - 2 * shrink);
}

// white diamond: border + white squares + grout webs (one connected piece)
module lattice_2d() {
    rotate(45) difference() {
        square(sq_o, center = true);
        black_squares_2d();
    }
}

// traced lettering is normalized to 100 units wide, centered
module text_2d() {
    scale(text_w / 100) bellum_traced_2d();
}

// ---------------- printable parts (each flat on Z=0) ----------------

module base_disc() {
    linear_extrude(t_base) circle(badge_d / 2);
}

module white_lattice() {
    linear_extrude(t_top) lattice_2d();
}

// optional flush inlays for the black squares, laid out for printing
module black_tiles() {
    for (i = [0 : n - 1], j = [0 : n - 1])
        if ((i + j) % 2 == 0)
            translate([i * (tile + 3), j * (tile + 3)])
                linear_extrude(t_top)
                    square(tile - 2 * clr);
}

module text_plate_black() {
    linear_extrude(t_text) offset(r = outline_w) text_2d();
}

module text_letters_white() {
    linear_extrude(t_text) text_2d();
}

// ---------------- assembled preview ----------------

module assembly() {
    color([0.15, 0.15, 0.15])  base_disc();
    color("white")   translate([0, 0, t_base]) white_lattice();
    color([0.15, 0.15, 0.15])  translate([0, 0, t_base + t_top]) text_plate_black();
    color("white")   translate([0, 0, t_base + t_top + t_text])
                         text_letters_white();
}

assembly();
