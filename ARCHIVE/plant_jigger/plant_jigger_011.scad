// Plant Jigger — goblet-shaped double-ended jigger (SPEC.md), v011.
// v010 -> v011: spout made one fluid piece with the bowl. The outer form
// is the hull of the bowl circle and the tip circle, so it leaves the wall
// on exact tangents (a pitcher-lip flare with no seam); the channel void
// is likewise a hull of two circles, giving a smoothly converging mouth.
// Cosine-eased crest, minkowski edge rounding (flat bed, sharp lip edge),
// filleted channel, 45-degree lip chamfer kept for the pour edge.
//
// Frame note (v009+): bed plane = rim plane in use, so the channel opens
// toward the bed in print orientation; SPEC 3's "rising floor" and
// "45 undercut below the lip" are use-frame statements.

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

/* ---------- spout parameters (print frame) ---------- */
tip_c_y    = -21.2;   // plan-circle center for the tip (inner and outer)
u_end_r    = 3.5;     // inner tip radius -> lip interior width 7
tip_out_r  = u_end_r + 0.8;  // outer tip circle: 0.8 front wall, reach -25.5
root_c_y   = -14.5;   // channel root circle (inside the cavity)
root_c_r   = 5;       // gives a ~10 mm mouth at the inner wall
crest_root = bell_c + 1.7;   // 4.7: crest height where the flare lives
crest_tip  = 1.1;            // crest height at the very tip
crest_y0   = -18;            // crest starts easing here...
crest_y1   = -25.5;          // ...and bottoms out at the tip
sill_z     = 2.1;     // use frame: floor ~2.1 below rim at the outer wall face
floor_a    = atan(1.6 / 4.7);  // floor plane: climbs ~1.6 to the lip (use frame)
r_edge     = 0.6;     // outer edge rounding
r_fil      = 0.5;     // channel floor/wall fillet

// crest curve: flat over the flare, cosine ease down the nose to the tip
function crest(y) =
    let (s = min(max((crest_y0 - y) / (crest_y0 - crest_y1), 0), 1))
    crest_tip + (crest_root - crest_tip) * (1 + cos(180 * s)) / 2;

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

/* ---------- smooth-spout building blocks ---------- */
// solid below z = crest(y) - drop, any x (sampled every 0.25 mm)
module under_curve(drop) {
    rotate([90, 0, 90]) linear_extrude(50, center = true)
        polygon([for (y = [-26:0.25:-15]) [y, crest(y) - drop], [-15, -1], [-26, -1]]);
}
// upper hemisphere: minkowski rounds top edges, keeps bottoms flat/sharp
module dome_r(r) {
    intersection() {
        sphere(r = r, $fn = 28);
        translate([-r, -r, 0]) cube([2 * r, 2 * r, r]);
    }
}
// plan silhouettes: exact tangent blends between circles
module outer_plan() {
    hull() {
        circle(r_out);                       // the bowl itself
        translate([0, tip_c_y]) circle(tip_out_r);
    }
}
module void_plan() {
    hull() {
        translate([0, root_c_y]) circle(root_c_r);
        translate([0, tip_c_y]) circle(u_end_r);
    }
}

/* ---------- spout outer: tangent flare off the bowl wall ---------- */
module spout_smooth() {
    minkowski() {
        intersection() {
            linear_extrude(6) offset(r = -r_edge) outer_plan();
            under_curve(r_edge);
        }
        dome_r(r_edge);
    }
}

/* ---------- channel void: open to the bed, filleted ----------
   Bounded above by the floor plane (sill_z at the outer wall face,
   descending to ~0.5 at the tip in print = rising to the lip in use). */
module spout_void() {
    minkowski() {
        intersection() {
            translate([0, 0, -1]) linear_extrude(8) offset(r = -r_fil) void_plan();
            translate([0, -20, sill_z - r_fil]) rotate([floor_a, 0, 0])
                translate([-15, -25, -12]) cube([30, 40, 12]);
        }
        dome_r(r_fil);
    }
}

/* ---------- lip chamfer: sharp 45-degree pour edge at the tip ---------- */
module lip_chamfer() {
    intersection() {
        translate([0, -25.5, 0]) rotate([-45, 0, 0])
            translate([-8, -7, 0]) cube([16, 14, 10]);
        translate([-8, -26.5, -0.1]) cube([16, 3.6, 4]);
    }
}

/* ---------- assembly ---------- */
difference() {
    union() {
        bell_outer();
        neck();
        cup_outer();
        spout_smooth();
    }
    bell_cavity();
    cup_cavity();
    spout_void();
    lip_chamfer();
}
