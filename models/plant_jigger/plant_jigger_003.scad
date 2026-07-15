// plant_jigger_003.scad
// v003: close the gap in the spout floor. In v002 the doorway re-cut ran
// 2 mm past the bell wall, leaving the trough floorless at the root. The
// re-cut now stops at the wall and the floor ramp starts right behind it.
// v002: pour spout added at the bell's arched cutout.
//
// Spout design follows drip-free ("teapot effect") research:
//   - thin U-shaped channel, walls taper 2 mm -> 0.8 mm at the lip; a thin
//     sharp lip forces flow separation, thick/rounded lips dribble
//   - tip radius 3.5 mm (studies recommend < 4 mm) and 12 mm reach beyond
//     the wall (recommend >= 4-5 mm)
//   - spout is radial (perpendicular to the body axis), a geometric
//     discontinuity that compels the stream to detach
//   - channel floor ramps up from the rim to an elevated lip, so the flow
//     path is smooth and residue drains back inside when set down
//   - 45 degree undercut below the lip gives a sharp lower pour edge and
//     keeps the overhang printable; underside is otherwise flat on the bed
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
spout_mid_y  = -(bell_or + 1.5); // taper starts just clear of the skirt
spout_tip_y  = -(bell_or + 12);  // lip reaches 12 mm beyond the wall
spout_wall   = 2;                // wall thickness at the root (matches bell)
lip_w        = 7;                // channel width at the lip (tip r 3.5 mm)
lip_wall     = 0.8;              // wall and floor thickness at the lip
lip_floor_z  = -skirt_h + 2.5;   // channel floor climbs to here at the lip
lip_top_z    = 2.0;              // wall crest height at the lip

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
        // arched doorway through the wall on the -Y side
        intersection() {
            translate([0, -bell_or - 1, arch_cz])
                rotate([-90, 0, 0]) cylinder(h = bell_or + 1, r = arch_r);
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

// rounded-top slab: flat bottom at zbot, semicircular crest of radius r
module slab2d(r, ztop, zbot) {
    hull() {
        translate([0, ztop - r]) circle(r);
        translate([-r, zbot]) square([2 * r, eps]);
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
                slab2d(lip_w / 2 + lip_wall, lip_top_z, -skirt_h);
        }
        // re-open the doorway, but only inside the bell wall: the trough
        // floor starts exactly at the wall's curved outer surface
        intersection() {
            sweepY(-15, spout_mid_y) arch2d();
            translate([0, 0, -skirt_h - 2])
                cylinder(h = 2 * bell_or, r = bell_or);
        }
        // channel: arch section narrowing to a U-trough, floor ramping up
        // from just above the threshold (0.15 mm keeps the floor's leading
        // edge from tapering to zero thickness); starts inside the wall so
        // the previous cut trims it back to the wall surface
        hull() {
            slabY(-(bell_ir + 0.5)) arch2d(0, -skirt_h + 0.15);
            slabY(spout_tip_y - 1) chan2d(lip_w / 2, lip_floor_z);
        }
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
