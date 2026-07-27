// tea_container_004 — cylindrical tea canister with 2-start screw lid
// v004: two-color split — white bodies with black rings as separate,
//       exactly complementary solids for multi-material slicing.
//       Ring width w = ring_w is also the offset spacing everywhere:
//         1. body underside: ring inset w from the edge
//         2. body wall: ring starting w above the floor
//         3. body wall: ring ending w below the threads
//         4. lid wall: ring starting w below the assembled top
//            (lid prints top-face-down, so that is z = [w, 2w] as printed)
//         5. lid top face: ring inset w from the edge
//       Rings are 1.2mm deep on walls (3 perimeters black + 3 white
//       behind) and 0.8mm on horizontal faces (4 layers at 0.2mm).
// v003: tooth profile flank order flipped — linear_extrude's twist maps the
//       high-angle edge of the lobe to the tooth UNDERSIDE, so v001/v002 had
//       the near-flat load flank facing down (~8° overhang). The 45° flank
//       is now the underside in each part's print orientation; the near-flat
//       flank on top remains the load face.
// v002: lower thread flank widened to 45° over the full embedded depth
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

part = "both"; // [both, body, lid, assembly, fit_test, body_white, body_black, lid_white, lid_black]

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
flank_lo_w   = 2.0;  // lower flank run = depth + embed → true 45° on the
                     // visible flank (v001 used 1.6, which the wall embed
                     // stretched to a ~51° overhang)
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

/* [Two-color rings] */
ring_w      = 4;    // w: ring width, and the offset spacing for placement
ring_wall_d = 1.2;  // ring depth into vertical walls (3 perimeters)
ring_face_d = 0.8;  // ring depth into horizontal faces (4 layers at 0.2mm)

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
    a_hi   = flank_hi_w * dpm;
    a_cr   = crest_w * dpm;
    n      = 24;
    m      = 16;
    // Higher profile angle = lower z in the extrusion, so the wide 45°
    // flank goes on the high-angle side to become the printable underside.
    // Flanks are Archimedean spiral segments (radius linear in angle), NOT
    // straight chords — a chord across the flank's arc would sag far inside
    // the wall and leave a near-flat emergent overhang.
    pts = concat(
        // root arc
        [for (i = [0:n]) br * [cos(a_root*i/n), sin(a_root*i/n)]],
        // 45° flank spiral: (br, a_root) -> (tip_r, a_hi + a_cr)
        [for (i = [1:m]) let (t = i/m,
                              a = a_root + (a_hi + a_cr - a_root)*t,
                              r = br + (tip_r - br)*t) r * [cos(a), sin(a)]],
        // crest arc
        [for (i = [1:n]) let (a = a_hi + a_cr*(n-i)/n) tip_r * [cos(a), sin(a)]],
        // near-flat load flank spiral: (tip_r, a_hi) -> (br, 0)
        [for (i = [1:m-1]) let (t = i/m,
                                a = a_hi*(1-t),
                                r = tip_r + (br - tip_r)*t) r * [cos(a), sin(a)]]
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

// straight knurl cross-section: lid disc plus vertical ridge rods
module knurl2d() {
    circle(r = lid_r);
    for (i = [0 : knurl_n - 1])
        rotate(i * 360 / knurl_n)
            translate([knurl_c, 0])
                circle(r = knurl_r, $fn = 24);
}

module lid() {
    union() {
        difference() {
            linear_extrude(height = lid_h, convexity = 4) knurl2d();
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

// ---- Two-color split ------------------------------------------------------
// The ring solids are cut regions extended past the surfaces they mark;
// white = part minus rings, black = part intersect rings, so the two STLs
// are exact complements with flush mating faces.

module ring_tube(r_in, r_out, z0, h) {
    translate([0, 0, z0])
        difference() {
            cylinder(h = h, r = r_out);
            translate([0, 0, -0.5]) cylinder(h = h + 1, r = r_in);
        }
}

module body_ring_cuts() {
    // 1. underside: inset w from the edge, then a w-wide ring
    ring_tube(neck_r - 2*ring_w, neck_r - ring_w, -1, 1 + ring_face_d);
    // 2. wall: w above the floor, then a w-tall band
    ring_tube(neck_r - ring_wall_d, neck_r + 2, ring_w, ring_w);
    // 3. wall: a w-tall band ending w below the threads
    ring_tube(neck_r - ring_wall_d, neck_r + 2, thread_z0 - 2*ring_w, ring_w);
}

module lid_ring_cuts() {
    // 5. top face (on the bed as printed): inset w from the edge
    ring_tube(lid_r - 2*ring_w, lid_r - ring_w, -1, 1 + ring_face_d);
    // 4. wall: w below the assembled top = z [w, 2w] in print orientation;
    //    covers the knurl ridges through their full depth
    ring_tube(lid_r - ring_wall_d, lid_max_r + 2, ring_w, ring_w);
}

module body_white() { difference() { body(); body_ring_cuts(); } }
module lid_white()  { difference() { lid();  lid_ring_cuts(); } }

// Black rings as exact solids (every ring sits on a plain cylinder or flat
// face, so no boolean against the whole part is needed — this also avoids
// the OpenCSG preview artifact where intersection() paints its first
// operand over the scene).
module body_black() {
    // 1. underside ring
    ring_tube(neck_r - 2*ring_w, neck_r - ring_w, 0, ring_face_d);
    // 2. base band
    ring_tube(neck_r - ring_wall_d, neck_r, ring_w, ring_w);
    // 3. band w below the threads
    ring_tube(neck_r - ring_wall_d, neck_r, thread_z0 - 2*ring_w, ring_w);
}

module lid_black() {
    // 5. top-face ring (bed side as printed)
    ring_tube(lid_r - 2*ring_w, lid_r - ring_w, 0, ring_face_d);
    // 4. wall band following the knurl ridges exactly
    translate([0, 0, ring_w])
        linear_extrude(height = ring_w, convexity = 4)
            difference() {
                knurl2d();
                circle(r = lid_r - ring_wall_d);
            }
}

module body_colored() {
    color("white")        body_white();
    color([0.15,0.15,0.15]) body_black();
}
module lid_colored() {
    color("white")        lid_white();
    color([0.15,0.15,0.15]) lid_black();
}

// Lid screwed fully home; rotation chosen so the threads nest in section.
module assembly(open_turns = 0) {
    body_colored();
    translate([0, 0, body_h + lid_top_t + open_turns * lead])
        rotate([0, 0, 130 + open_turns * 360])
            rotate([180, 0, 0])
                lid_colored();
}

// Just the threaded neck ring + the lid: a quick clearance check before
// committing ~8h of print time to the full canister.
module fit_test() {
    ring_z0 = thread_z0 - 2;
    translate([0, 0, -ring_z0])
        intersection() {
            body();
            translate([0, 0, ring_z0]) cylinder(h = body_h, r = lid_r + 2);
        }
    translate([100, 0, 0]) lid();
}

if (part == "body") body();
else if (part == "lid") lid();
else if (part == "body_white") body_white();
else if (part == "body_black") body_black();
else if (part == "lid_white") lid_white();
else if (part == "lid_black") lid_black();
else if (part == "assembly") assembly();
else if (part == "fit_test") fit_test();
else {
    body_colored();
    translate([100, 0, 0]) lid_colored();
}
