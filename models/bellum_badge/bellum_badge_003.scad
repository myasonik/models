// bellum_badge_003.scad
// v003: corrected layout, measured from the source photo. The design is
//   ONE continuous 45-degree checkerboard filling the whole circle with
//   thin white grout lines and a black tile at dead center - v001/v002's
//   "inner bordered diamond on a solid black ring" was a misreading of
//   the photo (the "border" was grout diagonals, the "black ring" was
//   glare on the glossy button). Proportions from the photo: tile pitch
//   ~0.162 D, grout ~0.008 D, text width ~0.86 D, centered.
// v002: "Bellum" lettering traced from the photo (bellum_text_traced.scad).
//
// Printable parts (print in the named color, glue together):
//   base_disc()          black - 3 mm circle; shows through the lattice
//                        holes as the black tiles
//   white_lattice()      white - 2 mm circle-wide lattice: white tiles +
//                        grout webs, one connected piece
//   black_tiles()        black - optional drop-ins for the full (unclipped)
//                        black tiles, if you want them flush
//   text_plate_black()   black - outline plate behind the letters
//   text_letters_white() white - "Bellum" letters (6 pieces), glue on plate
//
// Everything scales from badge_d; thicknesses and clearance are absolute.

$fa = 2;
$fs = 0.4;

// ---- scale ----
badge_d = 80;       // badge diameter: THE scale knob

// ---- thicknesses (absolute mm, independent of badge_d) ----
t_base = 3;         // black disc
t_top  = 2;         // white lattice and drop-in tiles (total badge = 5)
t_text = 1.2;       // each text layer (plate and letters)
clr    = 0.15;      // per-side XY clearance for the drop-in tiles

// ---- proportions (fractions of badge_d, measured from the photo) ----
pitch_frac = 0.162;                     // checker pitch (tile + grout)
grout_w   = max(0.008 * badge_d, 0.8);  // white web between tiles
text_w    = 0.86 * badge_d;             // width of "Bellum"
outline_w = max(0.015 * badge_d, 1.2);  // black outline around the letters

use <bellum_text_traced.scad>  // lettering traced from the logo photo

// ---- derived ----
R     = badge_d / 2;
pitch = pitch_frac * badge_d;
tile  = pitch - grout_w;                // black/white tile side
half_diag = tile / sqrt(2);             // rotated tile half-diagonal
range = ceil(R / pitch) + 1;

eps = 0.01;

// ---------------- 2D shapes ----------------

// black tile centers: (i+j) even puts a black tile at the exact center
module black_squares_2d(shrink = 0) {
    rotate(45)
        for (i = [-range : range], j = [-range : range])
            if ((i + j) % 2 == 0)
                translate([i * pitch, j * pitch])
                    square(tile - 2 * shrink, center = true);
}

// white tiles + grout webs across the whole circle, one connected piece
module lattice_2d() {
    difference() {
        circle(R);
        black_squares_2d();
    }
}

// traced lettering is normalized to 100 units wide, centered
module text_2d() {
    scale(text_w / 100) bellum_traced_2d();
}

// ---------------- printable parts (each flat on Z=0) ----------------

module base_disc() {
    linear_extrude(t_base) circle(R);
}

module white_lattice() {
    linear_extrude(t_top) lattice_2d();
}

// optional flush inlays for the black tiles that lie fully inside the rim
module black_tiles() {
    rotate(45)
        for (i = [-range : range], j = [-range : range])
            if ((i + j) % 2 == 0
                && norm([i, j]) * pitch + half_diag <= R - 1)
                translate([i * pitch, j * pitch])
                    linear_extrude(t_top)
                        square(tile - 2 * clr, center = true);
}

module text_plate_black() {
    linear_extrude(t_text) offset(r = outline_w) text_2d();
}

module text_letters_white() {
    linear_extrude(t_text) text_2d();
}

// ---------------- assembled preview ----------------

module assembly() {
    color([0.15, 0.15, 0.15]) base_disc();
    color("white") translate([0, 0, t_base]) white_lattice();
    color([0.15, 0.15, 0.15]) translate([0, 0, t_base + t_top])
        text_plate_black();
    color("white") translate([0, 0, t_base + t_top + t_text])
        text_letters_white();
}

assembly();
