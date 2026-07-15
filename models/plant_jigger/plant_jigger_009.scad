// Plant Jigger — goblet-shaped double-ended jigger (SPEC.md), v009.
// Prints bell-down: bell rim, spout walls, and lip edge sit on Z=0.
//
// Frame note: the print bed plane (Z=0) becomes the RIM plane when the
// jigger is flipped for use, so print-height-above-bed = use-depth-below-rim.
// The pour channel therefore opens TOWARD THE BED in print orientation:
// side walls stand on the bed, the channel floor bridges between them, and
// the doorway is cut to the bed so it reads as a pour notch at the rim in
// use. The floor plane descends toward the tip in print coords, which is
// the spec's "rising floor" in use coords (residue drains back to the cup).

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

/* ---------- spout (print frame; flip for use frame) ----------
   Plan: interior converges ~10 -> 7 mm, ending in an r3.5 round U-end
   (the tip radius water pours around). Outer profile is a rounded
   rectangle at the tip (corner cylinders) so the walls hold ~0.8 mm.
   The lip is the front bottom edge, ON the bed = AT the rim in use. */
root_y     = -17.2;   // buried root plate (inside bell shell)
mid_y      = -22;     // mid station: crest has fallen gently to mid_top
mid_top    = 3.2;
mid_hw     = 4.5;
u_end_y    = -21.2;   // inner channel U-end circle center
u_end_r    = 3.5;     // tip radius; lip interior width 7
end_cyl_y  = -24.7;   // front corner-cylinder centers (rounded-rect tip)
end_cyl_x  = 3.5;
end_cyl_r  = 0.8;     // outer tip reach = 25.5 (5.5 beyond wall), 0.8 front wall
nose_top   = 1.1;     // front face height; crest->here is the ~45 undercut
crest_root = bell_c + 1.7;  // walls emerge low on the dome (4.7)
sill_z     = 2.0;     // use frame: floor ~2 below rim at the outer wall face
floor_a    = 17.15;   // floor plane angle; use frame: climbs ~1.45 to the lip

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
    intersection() {
        translate([0, 0, bell_c]) sphere(r = r_in);
        translate([-25, -25, bell_c - lap]) cube([50, 50, 25]);
    }
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

/* ---------- spout outer solid ----------
   One convex loft: full-width root buried in the dome, gentle crest fall
   to the mid station, then a ~45-degree nose down to the rounded tip whose
   bottom edge (the lip, in use) lies on the bed. */
module spout_hull() {
    hull() {
        translate([-7, root_y, 0]) cube([14, 0.05, crest_root]);
        translate([-mid_hw, mid_y, 0]) cube([2 * mid_hw, 0.05, mid_top]);
        for (sx = [-1, 1])
            translate([sx * end_cyl_x, end_cyl_y, 0])
                cylinder(r = end_cyl_r, h = nose_top);
    }
}

/* ---------- spout channel void ----------
   Open toward the bed (open-topped in use). Bounded above by the floor
   plane: sill_z at the outer wall face, descending (print) to ~0.55 at the
   U-end, i.e. rising monotonically toward the lip in use. Cutting the bell
   wall from bed to floor plane makes the rim pour notch (the doorway). */
module spout_void() {
    intersection() {
        hull() {
            translate([-5.15, -16, -1]) cube([10.3, 0.05, 5.5]);
            translate([0, u_end_y, -1]) cylinder(r = u_end_r, h = 5.5);
        }
        translate([0, -20, sill_z]) rotate([floor_a, 0, 0])
            translate([-15, -25, -12]) cube([30, 40, 12]);
    }
}

/* ---------- assembly ---------- */
difference() {
    union() {
        bell_outer();
        neck();
        cup_outer();
        spout_hull();
    }
    bell_cavity();
    cup_cavity();
    spout_void();
}
