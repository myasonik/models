// u1_holder_lid_001 — stackable lid for the 1x Snapmaker U1 hotend holder
//
// Interface reverse-engineered from 1xholder_u1.3mf (mesh cross-sections).
// Every profile in the holder is an offset of the same 76x34 skeleton
// rectangle (corner centers at +/-38, +/-17), so the lid reuses that scheme:
//   - underside = exact copy of the holder's stacking plug (drops into a holder)
//   - top       = exact copy of the holder's rim socket (a holder or another
//                 lid stacks on it)
// Stack seating is on mating 45-degree cones; the plug tip of whatever sits
// on top hangs 4.15 mm below the rim, so the socket floor sits 4.5 below.

$fn = 96;

// ---- measured interface (from the holder mesh — don't tweak casually) ----
skel      = [76, 34];   // skeleton rectangle
o_body    = 3.75;       // outer wall offset  -> 83.5 x 41.5 footprint
o_plug    = 1.60;       // bottom plug offset -> 79.2 x 37.2
o_bot     = 0.80;       // plug bottom-edge chamfer offset
o_band    = 1.85;       // socket registration band -> 79.7 x 37.7 (0.25/side fit)
o_below   = 2.55;       // socket wall below the band
o_rim_in  = 3.15;       // rim inner edge at top of lead-in chamfer (rim face 0.6)

plug_cham  = 0.8;       // plug entry chamfer height (45 deg)
plug_str   = 1.8;       // plug straight height
plug_flare = 2.15;      // 45-deg flare from plug out to full body
band_h     = 1.4;       // registration band height
rim_cham   = 1.3;       // lead-in chamfer height (45 deg)
socket_deep = 4.5;      // rim -> socket floor (plug tip needs 4.15 + margin)

pad    = [34, 34];      // each plug pad; the 4.8 mm center channel between
pad_dx = 21;            //   pads is kept from the holder (clearance below)
pocket_d = 6.5;         // underside clearance pockets, same as holder
pocket_h = 2.3;
pockets  = [[34, 13], [-34, -13], [-8, 13], [8, -13]];

// ---- derived ----
z_shoulder = plug_cham + plug_str + plug_flare;  // 4.75
floor_t    = 0.45;                               // floor above the channel
z_floor    = z_shoulder + floor_t;               // 5.20
H          = z_floor + socket_deep;              // 9.70 overall

module prof(o)     { offset(r = o) square(skel, center = true); }
module pad_prof(o) { offset(r = o) square(pad,  center = true); }

module slab(z, o, pads = false) {
    translate([0, 0, z]) linear_extrude(0.01)
        if (pads) pad_prof(o); else prof(o);
}

// 45-degree transition between two offsets (profiles are convex, so hull
// is exactly the chamfer surface)
module cham(z1, z2, o1, o2, pads = false) {
    hull() { slab(z1, o1, pads); slab(z2, o2, pads); }
}

module lid() {
    difference() {
        union() {
            for (s = [-1, 1]) translate([s * pad_dx, 0, 0]) {
                cham(0, plug_cham, o_bot, o_plug, pads = true);
                translate([0, 0, plug_cham])
                    linear_extrude(plug_str + 0.01) pad_prof(o_plug);
                cham(plug_cham + plug_str, z_shoulder, o_plug, o_body,
                     pads = true);
            }
            translate([0, 0, z_shoulder])
                linear_extrude(H - z_shoulder) prof(o_body);
        }
        // rim socket
        translate([0, 0, z_floor])
            linear_extrude(H - band_h - rim_cham - z_floor + 0.01)
                prof(o_below);
        translate([0, 0, H - band_h - rim_cham])
            linear_extrude(band_h + 0.01) prof(o_band);
        cham(H - rim_cham, H + 0.5, o_band, o_rim_in + 0.5);
        // underside clearance pockets
        for (p = pockets)
            translate([p[0], p[1], -0.1])
                cylinder(d = pocket_d, h = pocket_h + 0.1);
    }
}

lid();
