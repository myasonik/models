// bellum_badge_005.scad
// v005: ENTIRELY FLAT two-color version. One plaque, two complementary
//   models at the same Z (zero clearance, exact shared edges) for a
//   two-color print, e.g. on top of a lid:
//     black_flat() - 13 checker tiles (4 rim-clipped), the thin square
//                    frame around the checkerboard (per the source image),
//                    and the outline band around the letters
//     white_flat() - everything else: circle background, grout, white
//                    tiles, and the letters themselves
//   Load both STLs at the same position in the slicer and assign colors.
//
// Layout per the source photo: white circle; 5x5 checkerboard rotated 45
// degrees (black corners and center, diagonal ~1.09 D so the corners clip
// the rim); thin white grout; thin black frame around the checker square,
// offset from the tiles by one grout width; "Bellum" (traced lettering,
// bellum_text_traced.scad) with a black outline, slightly above center.

$fa = 2;
$fs = 0.4;

// ---- scale ----
badge_d = 80;       // badge diameter: THE scale knob
n       = 5;        // checker tiles per row (odd -> black corners + center)

// ---- thickness (absolute mm) ----
t_flat = 5;         // plaque thickness; drop to ~1.5-2 for a lid inlay

// ---- proportions (fractions of badge_d, measured from the photo) ----
diag_frac = 1.09;                       // diamond diagonal vs diameter
grout_w   = max(0.008 * badge_d, 0.8);  // white gap between tiles
frame_w   = max(0.008 * badge_d, 0.8);  // black frame around the field
text_w    = 0.88 * badge_d;             // width of "Bellum"
text_dy   = 0.015 * badge_d;            // text sits a touch above center
outline_w = max(0.015 * badge_d, 1.2);  // black outline around the letters

use <bellum_text_traced.scad>  // lettering traced from the logo photo

// ---- derived ----
R     = badge_d / 2;
sq_f  = diag_frac * badge_d / sqrt(2);  // checker field side
tile  = (sq_f - (n - 1) * grout_w) / n; // tile size
pitch = tile + grout_w;

// ---------------- 2D regions ----------------

module black_squares_2d() {
    rotate(45)
        for (i = [0 : n - 1], j = [0 : n - 1])
            if ((i + j) % 2 == 0)
                translate([(i - (n - 1) / 2) * pitch,
                           (j - (n - 1) / 2) * pitch])
                    square(tile, center = true);
}

// thin black frame around the field, one grout width out from the tiles
module frame_2d() {
    rotate(45) difference() {
        square(sq_f + 2 * (grout_w + frame_w), center = true);
        square(sq_f + 2 * grout_w, center = true);
    }
}

module text_2d() {
    translate([0, text_dy]) scale(text_w / 100) bellum_traced_2d();
}

module text_stamp_2d() {  // letters plus their outline band
    offset(r = outline_w) text_2d();
}

// all black: (tiles + frame, rim-clipped, with the text stamped out)
// plus the outline band around the letters
module black_2d() {
    difference() {
        intersection() {
            union() { black_squares_2d(); frame_2d(); }
            circle(R);
        }
        text_stamp_2d();
    }
    difference() { text_stamp_2d(); text_2d(); }
}

// exact complement inside the circle
module white_2d() {
    difference() { circle(R); black_2d(); }
}

// ---------------- printable parts (same Z, zero clearance) ----------------

module black_flat() { linear_extrude(t_flat) black_2d(); }
module white_flat() { linear_extrude(t_flat) white_2d(); }

// ---------------- assembled preview ----------------

module assembly() {
    color([0.15, 0.15, 0.15]) black_flat();
    color("white") white_flat();
}

assembly();
