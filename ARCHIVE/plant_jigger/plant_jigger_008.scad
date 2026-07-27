// Plant Jigger — goblet-shaped double-ended jigger (SPEC.md), v008.
// Prints bell-down: bell rim and spout underside sit on Z=0, no supports.
// Built from spec only; spec coordinates (bell sphere center = origin)
// are translated up by skirt_h so the rim lands on Z=0.

$fa = 2;
$fs = 0.4;

/* ---------- body layout ---------- */
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

/* ---------- spout (drip-free open trough, -Y) ---------- */
sp_root_y    = -17;                    // buried root (trimmed by shell/cavity)
sp_wend_y    = -22;                    // side walls end / tip-disc center
sp_tip_y     = -25.5;                  // lip apex, 5.5 beyond outer wall
sill_z       = 2;                      // sill height (2 mm root floor)
ramp_y0      = -20.5;                  // sill is flat to here, then climbs
lip_floor_z  = sill_z + 1.6;           // floor top at lip (3.6)
lip_under_z  = lip_floor_z - 0.8;      // underside at lip (0.8 mm lip)
under_y0     = sp_tip_y + lip_under_z; // 45-degree undercut start (-22.7)
ramp_a       = atan((lip_floor_z - sill_z) / (ramp_y0 - sp_tip_y));
chan_hw_root = 5;                      // interior half-width at root (10)
chan_hw_lip  = 3.5;                    // interior half-width / tip radius (7)
wall_t_root  = 2;
wall_t_lip   = 0.8;
crest_root_z = bell_c + 1.7;           // walls emerge low on the dome (4.7)
crest_lip_z  = bell_c + 1.5;           // crest falls gently to 4.5
arch_shldr_z = 5;                      // arch shoulder, above the wall crest

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

/* ---------- spout floor: flat sill, rising ramp, 45-degree undercut ---------- */
module spout_floor() {
    difference() {
        linear_extrude(height = 5) union() {
            polygon([[-(chan_hw_root + wall_t_root), sp_root_y],
                     [  chan_hw_root + wall_t_root,  sp_root_y],
                     [  chan_hw_lip  + wall_t_lip,   sp_wend_y],
                     [-(chan_hw_lip  + wall_t_lip),  sp_wend_y]]);
            translate([0, sp_wend_y]) circle(r = chan_hw_lip); // rounded tip
        }
        // flat sill: shave to z=2 behind the ramp start
        translate([-15, ramp_y0, sill_z]) cube([30, 10, 10]);
        // monotonic ramp: sill_z at ramp_y0 up to lip_floor_z at the tip
        translate([0, ramp_y0, sill_z]) rotate([-ramp_a, 0, 0])
            translate([-15, -12, 0]) cube([30, 12, 10]);
        // 45-degree undercut below the lip (sharp lower pour edge)
        translate([0, under_y0, 0]) rotate([-45, 0, 0])
            translate([-15, -10, -10]) cube([30, 10.5, 10]);
    }
}

/* ---------- spout side wall (+X side; mirrored for -X) ----------
   Tapers 2 -> 0.8 thick, crest 4.7 -> 4.5; bottom sunk 0.5 into floor. */
module spout_wall() {
    hull() {
        translate([chan_hw_root, sp_root_y, 1.5])
            cube([wall_t_root, 0.05, crest_root_z - 1.5]);
        translate([chan_hw_lip, sp_wend_y - 0.05, 1.5])
            cube([wall_t_lip, 0.05, crest_lip_z - 1.5]);
    }
}

/* ---------- arched doorway through the bell wall ----------
   Tapered prism whose sides sit 0.05 inside the trough walls' inner
   faces; flat sill at z=2, straight jambs to the shoulder, semicircular
   top. Hulled between two thin arch plates to follow the channel taper. */
module arch2d(hw) {
    translate([-hw, sill_z]) square([2 * hw, arch_shldr_z - sill_z]);
    intersection() {
        translate([0, arch_shldr_z]) circle(r = hw);
        translate([-hw, arch_shldr_z]) square([2 * hw, hw + 1]);
    }
}
module arch_plate(y, hw) {
    translate([0, y, 0]) rotate([90, 0, 0])
        linear_extrude(0.05) arch2d(hw);
}
module doorway() {
    hull() {
        arch_plate(-15,   5.5);
        arch_plate(ramp_y0, 3.9);
    }
}

/* ---------- assembly ---------- */
difference() {
    union() {
        bell_outer();
        neck();
        cup_outer();
        spout_floor();
        spout_wall();
        mirror([1, 0, 0]) spout_wall();
    }
    bell_cavity();
    cup_cavity();
    doorway();
}
