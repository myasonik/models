// Plant Jigger — goblet-shaped double-ended jigger (SPEC.md), v015.
// v014 -> v015: supportless cup roof. The bell cavity's spherical cap was
// a ~25 mm near-flat interior roof printed rim-down (needed supports).
// Above latitude asin(0.475687) ~ 28.40 deg the interior is now a 45 deg
// cone whose apex tunnels into the solid neck. The blend latitude is the
// root of 2s^3 + 6s^2 + 3s - 3 = 0, which makes the cone's volume equal
// the spherical cap it replaces (4156.5 mm^3 each), so the cup still
// holds 15.268 ml. Outer geometry is unchanged; the wall is 2 mm below
// the blend and thickens above it (>= ~2.2 mm along the dome, >= ~2.9 mm
// where the cone rises inside the neck). The cone base is extended lap
// below the blend for a robust union (adds ~2 mm^3, 0.013% — noise).
//
// Frame note (v009+): bed plane = rim plane in use. The lip pour edge
// lies in the rim plane and prints flat on the bed; the flare occupies
// the top ~8 mm of the cup in use.

$fa = 2;
$fs = 0.4;

/* ---------- body layout (spec coords translated up by skirt_h) ---------- */
skirt_h  = 3;              // bell skirt height; also z of bell sphere center
bell_c   = skirt_h;        // bell sphere center height
cup_c    = 45 + skirt_h;   // large-cup sphere center height
cup_top  = 93 + skirt_h;   // large-cup rim
r_out    = 20;             // outer radius, both cups
r_in     = 18;             // inner radius (2 mm wall)
neck_r   = 10;
neck_z0  = 15 + skirt_h;
neck_z1  = 30 + skirt_h;
sink     = 0.3;            // neck ends sunk into each shell (no tangency)
lap      = 0.3;            // generic union overlap

/* ---------- cavity roof: sphere-to-cone blend (volume-neutral) ---------- */
blend_s  = 0.475687;             // sin(latitude); root of 2s^3+6s^2+3s-3=0
blend_r  = r_in * sqrt(1 - blend_s * blend_s);  // 15.833 blend circle
blend_z  = bell_c + r_in * blend_s;             // 11.562 blend height
// 45 deg cone: apex at blend_z + blend_r = 27.40, inside the neck (r 9.4
// against neck_r 10 at neck_z0; the neck is solid, so it just hollows)

/* ---------- pitcher-lip parameters (print frame) ---------- */
tip_y    = -21.2;   // spout circle center at the rim (z = 0)
tip_or   = 4.3;     // outer spout circle: tip reaches y -25.5 (5.5 past wall)
tip_ir   = 3.5;     // inner spout circle: lip channel width 7, 0.8 walls
merge_oy = -14.5;   // outer spout circle center once fully merged into bowl
merge_iy = -13.5;   // inner merge center (shorter reach: wall thickens)
H_o      = 8;       // outer flare height: rim to tangent merge with dome
H_i      = 7.5;     // channel height (slightly shorter than the outer flare)
n_o      = 40;      // loft slices, outer (0.2 mm steps: no visible banding)
n_i      = 38;      // loft slices, channel
kick_p   = 1.3;     // >1 concentrates the flare at the pour edge (~60 deg)

// lip ease: aggressive but finite kick-out at the rim ((1-sin)^p),
// tangent (zero slope) at the merge into the dome
function reach(t, y0, y1) =
    y1 + (y0 - y1) * pow(1 - sin(90 * min(t, 1)), kick_p);

// bell outer/inner silhouette radius at height z (skirt, then hemisphere)
function osil(z) = z <= bell_c ? r_out : sqrt(r_out * r_out - (z - bell_c) * (z - bell_c));
function isil(z) = z <= bell_c ? r_in  : sqrt(r_in  * r_in  - (z - bell_c) * (z - bell_c));

/* ---------- small cup (bell) ---------- */
module bell_outer() {
    cylinder(r = r_out, h = bell_c);              // skirt, z 0..3
    intersection() {                              // upper hemisphere, lapped
        translate([0, 0, bell_c]) sphere(r = r_out);
        translate([-25, -25, bell_c - lap]) cube([50, 50, 25]);
    }
}
module bell_cavity() {
    translate([0, 0, -1]) cylinder(r = r_in, h = bell_c + 1 + lap);
    intersection() {                              // sphere zone, up to blend
        translate([0, 0, bell_c]) sphere(r = r_in);
        translate([-25, -25, bell_c - lap]) cube([50, 50, blend_z - bell_c + lap]);
    }
    translate([0, 0, blend_z - lap])              // 45 deg roof cone, lapped
        cylinder(r1 = blend_r + lap, r2 = 0, h = blend_r + lap);
}

/* ---------- neck: column seated 0.3 into each sphere ---------- */
module neck() {
    difference() {
        translate([0, 0, neck_z0])
            cylinder(r = neck_r, h = neck_z1 - neck_z0);
        translate([0, 0, bell_c]) sphere(r = r_out - sink);
        translate([0, 0, cup_c])  sphere(r = r_out - sink);
    }
}

/* ---------- large cup: spherical bottom, open barrel ---------- */
module cup_outer() {
    translate([0, 0, cup_c]) sphere(r = r_out);
    translate([0, 0, cup_c - lap])
        cylinder(r = r_out, h = cup_top - cup_c + lap);
}
module cup_cavity() {
    translate([0, 0, cup_c]) sphere(r = r_in);
    translate([0, 0, cup_c - lap])
        cylinder(r = r_in, h = cup_top - cup_c + lap + 1);
}

/* ---------- pitcher lip: stacked-hull loft ---------- */
// one thin loft section: bowl silhouette blended with the spout circle
module lip_slice(z, rb, yc, rc) {
    translate([0, 0, z]) linear_extrude(0.001) hull() {
        circle(rb);
        translate([0, yc]) circle(rc);
    }
}

module lip_outer() {
    for (i = [0 : n_o - 1]) hull() {
        lip_slice( i      * H_o / n_o, osil( i      * H_o / n_o),
                  reach( i      / n_o, tip_y, merge_oy), tip_or);
        lip_slice((i + 1) * H_o / n_o, osil((i + 1) * H_o / n_o),
                  reach((i + 1) / n_o, tip_y, merge_oy), tip_or);
    }
}

// channel void: same loft on the inner silhouette, open across the rim
// plane (extends 1 mm below the bed so the difference is clean)
module lip_void() {
    hull() {
        lip_slice(-1, r_in, tip_y, tip_ir);
        lip_slice( 0, r_in, tip_y, tip_ir);
    }
    for (i = [0 : n_i - 1]) hull() {
        lip_slice( i      * H_i / n_i, isil( i      * H_i / n_i),
                  reach( i      / n_i, tip_y, merge_iy), tip_ir);
        lip_slice((i + 1) * H_i / n_i, isil((i + 1) * H_i / n_i),
                  reach((i + 1) / n_i, tip_y, merge_iy), tip_ir);
    }
}

/* ---------- assembly ---------- */
difference() {
    union() {
        bell_outer();
        lip_outer();
        neck();
        cup_outer();
    }
    bell_cavity();
    lip_void();
    cup_cavity();
}
