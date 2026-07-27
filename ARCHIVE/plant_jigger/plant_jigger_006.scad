// plant_jigger_006.scad
// v006: working spout passage, open trough, no stray holes.
//   - v005's niche back wall sealed the doorway, so the basin had no path
//     to the spout. The arch is a through-doorway again, but its cut floor
//     now sits at sill height so the wall stock below it forms the sill.
//   - the bell gets a thin basin floor (sill_h thick, prints flat on the
//     bed). The interior is now a real basin that drains over the sill,
//     and the open doorway shows basin floor instead of bare ground --
//     the see-through complaint that motivated v005's back wall.
//   - the beak was a domed solid; the channel cut only pierced its top
//     near the tip, leaving a roof over the channel and a skylight hole
//     where the cut broke through. A crest cut now shaves everything
//     above a line falling from the doorway top to the lip crest, so the
//     spout is an open trough for its whole length.
//   - channel floor starts at sill height (was 0.25 mm above the beak
//     bottom), giving one monotonically rising ramp basin -> sill -> lip
//     with no dip that would trap water.
// v004: stubbier spout (5.5 mm reach), doorway sill, rounded-rect lip.
// v003: floor leading edge conforms to the bell wall (gap fix).
// v002: pour spout added: thin sharp lip, U-channel, rising floor,
//   45 degree undercut for a clean pour edge.
//
// Base geometry unchanged from 001: bell (r20, 2 mm wall, 3 mm skirt,
// arched opening), neck (o20 column, spherical seats), tube reservoir
// (r20, 2 mm wall, domed bottom, open top). Model sits with the bell rim
// on Z=0.

$fa = 2;
$fs = 0.4;

// ---- key dimensions (from STEP, bell center = origin) ----
bell_or  = 20;      // bell outer radius
bell_ir  = 18;      // bell inner radius (2 mm wall)
skirt_h  = 3;       // straight cylindrical skirt below the dome equator
arch_r   = 7.1785;  // arched opening: arc radius
arch_cz  = -2.97;   // arch axis height (relative to bell center)
arch_w   = 2 * 6.686; // width of the straight-sided lower part of the arch

neck_r   = 10;      // neck column radius
mate     = 0.3;     // penetration into the shells for a robust union

tube_c   = 45;      // center of the tube's bottom dome
tube_top = 93;      // open top of the tube
tube_or  = 20;      // tube outer radius
tube_ir  = 18;      // tube inner radius (2 mm wall)

// ---- pour spout ----
spout_root_y = -(bell_or - 3);   // buried 3 mm into the wall for the union
spout_mid_y  = -(bell_or + 0.5); // taper starts just past the wall
spout_tip_y  = -(bell_or + 5.5); // lip reaches 5.5 mm beyond the wall
spout_wall   = 2;                // wall thickness at the root (matches bell)
lip_w        = 7;                // channel width at the lip (tip r 3.5 mm)
lip_wall     = 0.8;              // wall and floor thickness at the lip
lip_floor_z  = -skirt_h + 1.6;   // channel floor climbs to here at the lip
lip_top_z    = 1.5;              // wall crest height at the lip
sill_h       = 1.2;              // basin floor / doorway sill thickness
sill_z       = -skirt_h + sill_h; // top of the basin floor and sill
arch_pass_y  = -8;               // doorway cut ends here, well inside the
                                 // cavity: the passage is a true opening

eps = 0.01;

module bell() {
    union() {
        difference() {
            union() {
                // upper hemisphere
                difference() {
                    sphere(bell_or);
                    translate([0, 0, -2 * bell_or]) cube(4 * bell_or, center = true);
                }
                // skirt
                translate([0, 0, -skirt_h]) cylinder(h = skirt_h + eps, r = bell_or);
            }
            // cavity
            sphere(bell_ir);
            translate([0, 0, -skirt_h - eps])
                cylinder(h = skirt_h + 2 * eps, r = bell_ir);
            // arched doorway on the -Y side, cut clean through the wall.
            // The cut floor sits at sill height, so the skirt stock below
            // it becomes the doorway sill.
            intersection() {
                translate([0, -bell_or - 1, arch_cz])
                    rotate([-90, 0, 0])
                        cylinder(h = bell_or + 1 + arch_pass_y, r = arch_r);
                translate([-arch_w / 2, -bell_or - 2, sill_z])
                    cube([arch_w, bell_or + 2, bell_or]);
            }
        }
        // basin floor: thin disc on the bed, fused 1 mm into the wall;
        // its top is level with the sill so the basin drains freely
        translate([0, 0, -skirt_h]) cylinder(h = sill_h, r = bell_ir + 1);
    }
}

// column whose ends are shaped by the mating spheres
module neck() {
    difference() {
        translate([0, 0, 15]) cylinder(h = 15, r = neck_r); // z 15..30
        sphere(bell_or - mate);                       // seats on the bell
        translate([0, 0, tube_c]) sphere(tube_or - mate); // seats on the tube
    }
}

module tube() {
    difference() {
        union() {
            translate([0, 0, tube_c]) sphere(tube_or);         // bottom dome
            translate([0, 0, tube_c])
                cylinder(h = tube_top - tube_c, r = tube_or);  // barrel
        }
        translate([0, 0, tube_c]) sphere(tube_ir);
        translate([0, 0, tube_c])
            cylinder(h = tube_top - tube_c + 1, r = tube_ir);  // open top
    }
}

// ---- spout helpers: 2D profiles in the XZ plane, swept along -Y ----

// arch cross-section (matches the doorway cut), offset outward by `grow`
module arch2d(grow = 0, zbot = -skirt_h - 1) {
    intersection() {
        hull() {
            translate([0, arch_cz]) circle(arch_r + grow);
            translate([-(arch_r + grow), zbot])
                square([2 * (arch_r + grow), eps]);
        }
        translate([-(arch_w / 2 + grow), zbot])
            square([arch_w + 2 * grow, 2 * bell_or]);
    }
}

// rounded rectangle: flat bottom at zbot, vertical sides, corner radius rc
module rrect2d(w, ztop, zbot, rc = 1.2) {
    hull() {
        for (sx = [-1, 1])
            translate([sx * (w / 2 - rc), ztop - rc]) circle(rc);
        translate([-w / 2, zbot]) square([w, eps]);
    }
}

// U-channel: round trough bottom, open upward
module chan2d(r, zbot) {
    hull() {
        translate([0, zbot + r]) circle(r);
        translate([-r, 3 * arch_r]) square([2 * r, eps]);
    }
}

// sweep a 2D XZ profile along -Y from y0 to y1 (y0 > y1)
module sweepY(y0, y1) {
    translate([0, y0, 0]) rotate([90, 0, 0])
        linear_extrude(y0 - y1) children();
}

// thin slab at height y, for use as a hull() endpoint
module slabY(y) {
    sweepY(y, y - eps) children();
}

module spout() {
    difference() {
        // outer beak: full arch section to spout_mid_y, then taper to the tip
        hull() {
            slabY(spout_root_y) arch2d(spout_wall, -skirt_h);
            slabY(spout_mid_y)  arch2d(spout_wall, -skirt_h);
            slabY(spout_tip_y)
                rrect2d(lip_w + 2 * lip_wall, lip_top_z, -skirt_h);
        }
        // open the passage through the beak root, leaving the sill as the
        // continuous floor from the doorway to the channel
        sweepY(-15, spout_mid_y) arch2d(0, sill_z);
        // channel: arch section narrowing to a U-trough, floor rising in
        // one straight ramp from sill height to the lip
        hull() {
            slabY(-(bell_ir + 0.5)) arch2d(0, sill_z);
            slabY(spout_tip_y) chan2d(lip_w / 2, lip_floor_z);
        }
        // straight exit keeps the channel a constant 7 mm through the end
        // face, so the side walls hold lip_wall thickness at the lip
        sweepY(spout_tip_y, spout_tip_y - 2) chan2d(lip_w / 2, lip_floor_z);
        // crest cut: shave everything above a line falling from the
        // doorway top at the inner wall to the lip crest -- the trough is
        // open to the sky for its whole length (no roof, no skylight hole)
        hull() {
            slabY(-bell_ir)
                translate([-2 * bell_or, arch_cz + arch_r]) square(4 * bell_or);
            slabY(spout_tip_y - 2)
                translate([-2 * bell_or, lip_top_z]) square(4 * bell_or);
        }
        // keep the bell cavity clear above the basin floor
        sphere(bell_ir);
        translate([0, 0, sill_z])
            cylinder(h = skirt_h, r = bell_ir);
        // 45 degree undercut under the lip -> sharp lower pour edge
        translate([0, spout_tip_y, lip_floor_z - lip_wall])
            rotate([-45, 0, 0]) translate([0, 0, -50])
                cube([2 * bell_or + 20, 100, 100], center = true);
    }
}

translate([0, 0, skirt_h])
union() {
    bell();
    neck();
    tube();
    spout();
}
