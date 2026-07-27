// plant_jigger_005.scad
// v005: seal the doorway. The bell is an open-bottomed dome, so the
//   through-doorway showed the bare ground and read as a hole from every
//   angle. The arch is now a recessed niche: the cut stops arch_recess_y
//   short of the inner surface, leaving a thin back wall. Set
//   arch_recess_y = bell_or to restore the original through-opening.
// v004: stubbier spout + doorway sill.
//   - beak reach cut from 12 mm to 5.5 mm beyond the wall (still above the
//     4-5 mm minimum extension from the drip-free spout studies)
//   - the doorway gets a 0.6 mm sill across the wall thickness, so the
//     trough floor now runs continuously from inside the doorway to the
//     lip; previously the doorway bottom was open ground and read as a
//     see-through hole at the spout root
//   - lip crest lowered to 1.5 mm; outer tip profile is now a rounded
//     rectangle so the side walls hold 0.8 mm thickness all the way down
//     (the old semicircular crest pinched to ~0.1 mm at floor level)
// v003: floor leading edge conforms to the bell wall (gap fix).
// v002: pour spout added at the bell's arched cutout, following teapot-
//   effect research: thin sharp lip, tip radius < 4 mm, U-channel, rising
//   floor, 45 degree undercut for a clean pour edge.
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
sill_h       = 0.6;              // doorway sill thickness (2-3 print layers)
arch_back_y  = -(bell_ir + 0.6); // flat back wall of the arched niche;
                                 // use bell_or to cut the doorway through

eps = 0.01;

module bell() {
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
        // cavity (open at the bottom)
        sphere(bell_ir);
        translate([0, 0, -skirt_h - eps])
            cylinder(h = skirt_h + 2 * eps, r = bell_ir);
        // arched niche on the -Y side, stopping at a flat back wall
        intersection() {
            translate([0, -bell_or - 1, arch_cz])
                rotate([-90, 0, 0])
                    cylinder(h = bell_or + 1 + arch_back_y, r = arch_r);
            translate([-arch_w / 2, -bell_or - 2, -skirt_h - 1])
                cube([arch_w, bell_or + 2, bell_or]);
        }
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
        // re-open the doorway, leaving a thin sill so the passage has a
        // floor instead of a see-through slot at ground level
        sweepY(-15, spout_mid_y) arch2d(0, -skirt_h + sill_h);
        // channel: arch section narrowing to a U-trough; the floor starts
        // below the sill inside the wall so the two cuts blend into one
        // continuous ramp from the doorway to the lip
        hull() {
            slabY(-(bell_ir + 0.5)) arch2d(0, -skirt_h + 0.25);
            slabY(spout_tip_y) chan2d(lip_w / 2, lip_floor_z);
        }
        // straight exit keeps the channel a constant 7 mm through the end
        // face, so the side walls hold lip_wall thickness at the lip
        sweepY(spout_tip_y, spout_tip_y - 2) chan2d(lip_w / 2, lip_floor_z);
        // keep the bell cavity clear
        sphere(bell_ir);
        translate([0, 0, -skirt_h - eps])
            cylinder(h = skirt_h + 2 * eps, r = bell_ir);
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
