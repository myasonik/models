// bellum_badge_004.scad
// v004: corrected again after a closer look at the photo. The design is a
//   WHITE circle with a 5x5 checkerboard rotated 45 degrees on top: black
//   corner tiles, black center tile, thin white grout, and the diamond's
//   four corners slightly clipped by the circle rim. (v003's full-circle
//   checkerboard misread glare on the button photo as extra tiles.)
//
// Printable parts (print in the named color, glue together):
//   white_body()         white - 3 mm disc + 2 mm top layer with square
//                        pockets; the top layer IS the white circle, white
//                        tiles, and grout, all one solid piece
//   black_tiles()        black - 13 drop-in tiles (4 rim-clipped), flush
//                        with the white top when seated
//   text_plate_black()   black - outline plate behind the letters
//   text_letters_white() white - "Bellum" letters (6 pieces), glue on plate
//
// Everything scales from badge_d; thicknesses and clearance are absolute.
// v002/v003 history: lettering traced from the photo (bellum_text_traced).

$fa = 2;
$fs = 0.4;

// ---- scale ----
badge_d = 80;       // badge diameter: THE scale knob
n       = 5;        // checker tiles per row (odd -> black corners + center)

// ---- thicknesses (absolute mm, independent of badge_d) ----
t_base = 3;         // white disc under the pockets
t_top  = 2;         // pocketed top layer; tiles sit flush (total = 5)
t_text = 1.2;       // each text layer (plate and letters)
clr    = 0.15;      // per-side XY clearance for the drop-in tiles

// ---- proportions (fractions of badge_d, measured from the photo) ----
diag_frac = 1.09;                       // diamond diagonal vs diameter:
                                        // the four corners clip the rim
grout_w   = max(0.008 * badge_d, 0.8);  // white gap between tiles
text_w    = 0.88 * badge_d;             // width of "Bellum"
text_dy   = 0.015 * badge_d;            // text sits a touch above center
outline_w = max(0.015 * badge_d, 1.2);  // black outline around the letters

use <bellum_text_traced.scad>  // lettering traced from the logo photo

// ---- derived ----
R     = badge_d / 2;
sq_f  = diag_frac * badge_d / sqrt(2);  // checker field side
tile  = (sq_f - (n - 1) * grout_w) / n; // tile size
pitch = tile + grout_w;

eps = 0.01;

// ---------------- 2D shapes ----------------

// black tile positions: (i+j) even -> corners and center are black
module black_squares_2d(shrink = 0) {
    rotate(45)
        for (i = [0 : n - 1], j = [0 : n - 1])
            if ((i + j) % 2 == 0)
                translate([(i - (n - 1) / 2) * pitch,
                           (j - (n - 1) / 2) * pitch])
                    square(tile - 2 * shrink, center = true);
}

// traced lettering is normalized to 100 units wide, centered
module text_2d() {
    translate([0, text_dy]) scale(text_w / 100) bellum_traced_2d();
}

// ---------------- printable parts (each flat on Z=0) ----------------

// disc + pocketed top layer, one white piece
module white_body() {
    linear_extrude(t_base) circle(R);
    translate([0, 0, t_base])
        linear_extrude(t_top) difference() {
            circle(R);
            black_squares_2d();  // pockets; rim clips the 4 corner ones
        }
}

// drop-in tiles, rim-clipped ones trimmed slightly inside the disc edge
module black_tiles() {
    intersection() {
        linear_extrude(t_top) black_squares_2d(clr);
        cylinder(h = t_top + eps, r = R - 0.3);
    }
}

module text_plate_black() {
    linear_extrude(t_text) offset(r = outline_w) text_2d();
}

module text_letters_white() {
    linear_extrude(t_text) text_2d();
}

// ---------------- assembled preview ----------------

module assembly() {
    color("white") white_body();
    color([0.15, 0.15, 0.15]) translate([0, 0, t_base]) black_tiles();
    color([0.15, 0.15, 0.15]) translate([0, 0, t_base + t_top])
        text_plate_black();
    color("white") translate([0, 0, t_base + t_top + t_text])
        text_letters_white();
}

assembly();
