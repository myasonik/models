// plant_jigger_001.scad
// Recreation of "plant jigger.step" as a parametric OpenSCAD model.
// Three bodies from the STEP, unioned into one printable solid:
//   - bell: hollow dome (outer r20, 2 mm wall) with a 3 mm skirt and an
//     arched opening on one side
//   - neck: o20 column with spherical ends mating the bell and the tube
//   - tube: long hollow reservoir (outer r20, 2 mm wall), domed bottom,
//     open top
// All dimensions in mm, taken from the STEP. Model is shifted up by
// skirt_h so the bell rim sits on Z=0.

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

translate([0, 0, skirt_h])
union() {
    bell();
    neck();
    tube();
}
