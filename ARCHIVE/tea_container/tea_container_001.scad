// tea_container_001 — cylindrical tea canister with 2-start screw lid
//
// Inner Ø70 × 70mm deep. Jar-style: external threads on the body neck,
// knurled lid caps over. Thread is a 2-start trapezoid/buttress hybrid:
//   - lead 8mm (2 starts → crests 4mm apart), ~1.4 turns to close
//   - depth 1.6mm, 45° lower flank so it prints upright unsupported,
//     near-flat upper flank as the load face
//   - 0.5mm radial clearance to the mating part, lead-in fades on both
//     parts so it starts blind without cross-threading
//   - two small bumps inside the lid mouth click over the male thread
//     starts at end-of-travel so the lid doesn't back off in a bag
//
// Print: body as modeled (upright), lid as modeled (top face on bed).
// No supports. PETG recommended over PLA for thread toughness.
// Tunables if the fit is off: radial_clear (looser/tighter spin),
// bump_squeeze (detent strength).

part = "both"; // [both, body, lid, assembly]

$fa = 3;
$fs = 0.4;

/* [Body] */
inner_d = 70;
inner_h = 70;
wall    = 2.4;   // 6 perimeters at 0.4mm
floor_t = 2.4;

/* [Thread] */
starts       = 2;
lead         = 8;    // axial travel per full turn
thread_len   = 11;   // engagement ≈ 1.4 turns
thread_depth = 1.6;
radial_clear = 0.5;  // radial gap between mating threads
crest_w      = 0.8;  // axial tooth widths, mm
flank_lo_w   = 1.6;  // lower flank run = depth → 45°, printable
flank_hi_w   = 0.3;  // near-flat load flank
embed        = 0.4;  // how far teeth sink into their wall

/* [Lid] */
lid_wall     = 2.0;
lid_top_t    = 2.4;
seat_gap     = 1.4;  // skirt longer than male thread; lid seats on rim
knurl_n      = 60;
knurl_r      = 1.2;
knurl_proud  = 1.0;
bump_squeeze = 0.2;  // detent interference against male crests

/* [Derived] */
neck_r    = inner_d/2 + wall;             // 37.4
crest_r   = neck_r + thread_depth;        // 39.0 male major
bore_r    = crest_r + radial_clear;       // 39.5 lid bore
f_tip_r   = neck_r + radial_clear;        // 37.9 female minor
lid_r     = bore_r + lid_wall;            // 41.5
body_h    = floor_t + inner_h;            // 72.4
thread_z0 = body_h - thread_len;          // 61.4
skirt_len = thread_len + seat_gap;        // 12.4
lid_h     = lid_top_t + skirt_len;        // 14.8
root_w    = crest_w + flank_lo_w + flank_hi_w;  // 2.7
knurl_c   = lid_r - knurl_r + knurl_proud;      // knurl rod center radius
lid_max_r = knurl_c + knurl_r;                  // 42.5

// One tooth profile, swept helically. tip_r > base_r → external thread,
// tip_r < base_r → internal. Low-angle edge of the lobe becomes the
// bottom flank in print orientation for both parts.
module thread_teeth(tip_r, base_r, len) {
    ext    = tip_r > base_r;
    br     = ext ? base_r - embed : base_r + embed;
    dpm    = 360 / lead;            // degrees of helix per mm of axial width
    a_root = root_w * dpm;
    a_lo   = flank_lo_w * dpm;
    a_cr   = crest_w * dpm;
    n      = 30;
    pts = concat(
        [for (i = [0:n]) br    * [cos(a_root*i/n),            sin(a_root*i/n)]],
        [for (i = [0:n]) tip_r * [cos(a_lo + a_cr*(n-i)/n),   sin(a_lo + a_cr*(n-i)/n)]]
    );
    linear_extrude(height = len, twist = -360*len/lead,
                   slices = ceil(len * 360 / lead / 3), convexity = 10)
        for (s = [0:starts-1]) rotate(s * 360/starts) polygon(pts);
}

// Crest-limiting envelope: fades the male thread to nothing at both ends
// (lead-in at the rim, no flat overhang at the start).
module male_thread_env() {
    rotate_extrude(convexity = 4)
        polygon([
            [neck_r - 1,   thread_z0],
            [neck_r + 0.1, thread_z0],
            [crest_r + 0.2, thread_z0 + thread_depth + 0.2],
            [crest_r + 0.2, body_h - thread_depth],
            [neck_r + 0.1, body_h],
            [neck_r - 1,   body_h]
        ]);
}

// Same for the female thread: full depth near the lid top, fading out
// toward the mouth as the entry lead-in.
module female_thread_env() {
    top = lid_top_t + thread_len + 0.8;
    rotate_extrude(convexity = 4)
        polygon([
            [f_tip_r - 0.1, lid_top_t],
            [bore_r + 1,    lid_top_t],
            [bore_r + 1,    top],
            [bore_r,        top],
            [f_tip_r - 0.1, top - (bore_r - f_tip_r + 0.1)]
        ]);
}

module body() {
    difference() {
        union() {
            cylinder(h = body_h, r = neck_r);
            intersection() {
                translate([0, 0, thread_z0])
                    thread_teeth(crest_r, neck_r, thread_len);
                male_thread_env();
            }
        }
        // cavity
        translate([0, 0, floor_t])
            cylinder(h = inner_h + 1, r = inner_d/2);
        // inner rim chamfer
        translate([0, 0, body_h - 0.8])
            cylinder(h = 0.81, r1 = inner_d/2 - 0.01, r2 = inner_d/2 + 0.8);
        // elephant-foot relief at the bed
        rotate_extrude(convexity = 4)
            polygon([[neck_r - 0.5, -0.01], [neck_r + 1, -0.01], [neck_r + 1, 1.49]]);
    }
}

module lid() {
    union() {
        difference() {
            union() {
                cylinder(h = lid_h, r = lid_r);
                // straight knurl: vertical ridges, print cleanly upright
                for (i = [0 : knurl_n - 1])
                    rotate(i * 360 / knurl_n)
                        translate([knurl_c, 0, 0])
                            cylinder(h = lid_h, r = knurl_r, $fn = 24);
            }
            // bore
            translate([0, 0, lid_top_t])
                cylinder(h = lid_h, r = bore_r);
            // mouth inner lead chamfer
            rotate_extrude(convexity = 4)
                polygon([[bore_r - 0.01, lid_h - 0.9],
                         [bore_r + 0.9,  lid_h + 0.01],
                         [bore_r - 0.01, lid_h + 0.01]]);
            // mouth outer chamfer (also chamfers the knurl ridges)
            rotate_extrude(convexity = 4)
                polygon([[lid_r,          lid_h + 0.01],
                         [lid_max_r + 0.1, lid_h + 0.01],
                         [lid_max_r + 0.1, lid_h - 1.11]]);
            // elephant-foot relief at the bed
            rotate_extrude(convexity = 4)
                polygon([[lid_r,           -0.01],
                         [lid_max_r + 0.1, -0.01],
                         [lid_max_r + 0.1,  1.09]]);
        }
        // female threads
        intersection() {
            translate([0, 0, lid_top_t])
                thread_teeth(f_tip_r, bore_r, thread_len + 0.8);
            female_thread_env();
        }
        // end-of-travel detent bumps: ride over the male thread starts
        // just before the lid seats
        for (a = [90, 270])
            rotate(a)
                translate([bore_r + 0.3 + bump_squeeze - 0.2, 0, lid_h - 1.6])
                    sphere(r = 1.0, $fn = 32);
    }
}

// Lid screwed fully home; rotation chosen so the threads nest in section.
module assembly(open_turns = 0) {
    body();
    translate([0, 0, body_h + lid_top_t + open_turns * lead])
        rotate([0, 0, 15 + open_turns * 360])
            rotate([180, 0, 0])
                lid();
}

if (part == "body") body();
else if (part == "lid") lid();
else if (part == "assembly") assembly();
else {
    body();
    translate([100, 0, 0]) lid();
}
