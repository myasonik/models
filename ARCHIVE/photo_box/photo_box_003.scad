// photo_box — shipping box for photos, with a proud inset lid
//
// Two parts, single-colour PLA, both print without supports.
//   box  prints open-face-up, floor on the bed
//   lid  prints top-face-down, skirt pointing up
//
// Two boxes, identical but for length — one model, not two designs. A
// change here is a change to both.
//
// The numbers below are the ones to change. Everything else is derived,
// so the model stays coherent at any size.

// ---- variant ----------------------------------------------------------
len_a = 195;      // first box
len_b = 245;      // second box
variant = "a";    // "a" | "b" — which of the two this file emits

// ---- outside envelope (lid on) ----------------------------------------
// HARD CONSTRAINT. No feature on either part may exceed these in any
// axis. Grips and the like are cut *into* the envelope, never added
// outside it. Checked against the exported meshes — see SPEC.md §9.
box_w = (variant == "b") ? len_b : len_a;   // length
box_d = 65;       // depth
box_h = 158.75;   // 6.25"  height, lid seated

// ---- thicknesses ------------------------------------------------------
wall_t  = 2.0;    // side walls        (5 perimeters @ 0.4)
floor_t = 2.4;    // box floor         (6 perimeters)
lid_t   = 3.2;    // lid plate         (8 perimeters)

// ---- lid interface ----------------------------------------------------
rabbet_h = 5.0;   // how far the ledge sits below the rim
ledge_w  = 2.0;   // horizontal width of the ledge
rim_t    = 1.6;   // standing rim above the ledge (4 perimeters)
ramp_h   = 2.4;   // ramp thickening the wall into the rabbet zone. Rises 2.4
                  // while growing 1.6 inward — 34 deg off vertical, so it sits
                  // clear of the 45 deg self-support limit rather than on it.
skirt_w  = 1.6;   // lid skirt thickness (4 perimeters)
clr      = 0.3;   // lateral clearance, skirt to rim (PLA)
seat_gap = 0.4;   // skirt clears the ledge — the rim is the seat, not the ledge

// ---- cosmetic / ergonomic --------------------------------------------
corner_r   = 4.0;  // outside corner radius
lid_relief = 0.25; // lid plate inset from the outer face, per side
skirt_cham = 1.0;  // 45 deg lead-in so the lid self-centres on the way in
foot_cham  = 0.6;  // bottom outer edge — chamfer, not a round (elephant's foot)

// Nail catch: a notch taken out of the BOX rim, front and back, leaving the
// lid edge overhanging a gap you put a fingernail into. Subtractive, so the
// grip costs no envelope.
//
// It is cut from the rim rather than the lid's underside because the plate
// only overhangs the skirt by 1.65 (lid_od/2 - skirt_od/2). Chamfering the
// lid deeper than that removes the plate from under the skirt and leaves the
// skirt bridging nail_w in mid-air. The rim has depth to give; the lid
// does not.
nail_d = 3.0;      // notch depth below the rim top
// Span along the edge. Derived and clamped: the notch must never approach
// the wall's length, or it eats the corners and the rim stops being a
// continuous ring. Inactive at both current lengths (stays 60).
nail_w = min(60.0, box_w - 4 * corner_r);

// ---- output -----------------------------------------------------------
part = "both";     // "box" | "lid" | "both"

$fa = 2;
$fs = 0.4;

// ---- derived ----------------------------------------------------------
body_h   = box_h - lid_t;        // rim top: the lid plate sits on this
ledge_z  = body_h - rabbet_h;    // up-facing ledge surface
ramp_z   = ledge_z - ramp_h;     // where the wall starts thickening
top_wall = rim_t + ledge_w;      // wall thickness through the rabbet zone
skirt_h  = rabbet_h - seat_gap;  // skirt stops short of the ledge

// Rounded-rectangle prism, centred in x/y, rising from z = 0.
module rrect_prism(w, d, r, h) {
    rr = max(min(r, w / 2 - 0.01, d / 2 - 0.01), 0.01);
    linear_extrude(height = h)
        offset(r = rr)
            square([w - 2 * rr, d - 2 * rr], center = true);
}

// ---- box --------------------------------------------------------------

module box_outer() {
    // Chamfered foot, then a straight prism the rest of the way up.
    hull() {
        rrect_prism(box_w - 2 * foot_cham, box_d - 2 * foot_cham,
                    corner_r - foot_cham, 0.01);
        translate([0, 0, foot_cham]) rrect_prism(box_w, box_d, corner_r, 0.01);
    }
    translate([0, 0, foot_cham])
        rrect_prism(box_w, box_d, corner_r, body_h - foot_cham);
}

// The cavity is cut in three stacked pieces. Each one is *wider* than the
// piece below it or tapers into it, so every newly exposed surface faces up
// or sits at 45 deg — nothing to support.
module box_cavity() {
    // Main volume, floor up to the ramp.
    translate([0, 0, floor_t])
        rrect_prism(box_w - 2 * wall_t, box_d - 2 * wall_t,
                    corner_r - wall_t, ramp_z - floor_t + 0.01);

    // 45 deg ramp: the wall thickens inward from wall_t to top_wall, giving
    // the rabbet something solid to be cut out of and hooping the top of a
    // large thin-walled box.
    hull() {
        translate([0, 0, ramp_z])
            rrect_prism(box_w - 2 * wall_t, box_d - 2 * wall_t,
                        corner_r - wall_t, 0.01);
        translate([0, 0, ledge_z - 0.01])
            rrect_prism(box_w - 2 * top_wall, box_d - 2 * top_wall,
                        corner_r - top_wall, 0.01);
    }

    // Rabbet: a wider cut above the ledge leaves the ledge as an up-facing
    // shelf and the rim as a standing fin.
    translate([0, 0, ledge_z])
        rrect_prism(box_w - 2 * rim_t, box_d - 2 * rim_t,
                    corner_r - rim_t, rabbet_h + 1);
}

// Notch through the rim, front and back. Its floor faces up and its walls are
// vertical, so it costs the upright box print nothing. Inboard of the rim is
// already rabbet void, so the cut reaches past it harmlessly.
module nail_catch_cut() {
    for (s = [1, -1])
        translate([0, s * (box_d / 2 - 3), body_h - nail_d / 2 + 1])
            cube([nail_w, 10, nail_d + 2], center = true);
}

module box() {
    difference() {
        box_outer();
        box_cavity();
        nail_catch_cut();
    }
}

// ---- lid --------------------------------------------------------------
// Modelled in the assembled orientation: plate on top, skirt hanging down
// into the rabbet. Flipped for printing at the bottom of the file.

skirt_ow = box_w - 2 * rim_t - 2 * clr;
skirt_od = box_d - 2 * rim_t - 2 * clr;
skirt_or = corner_r - rim_t - clr;
skirt_z0 = body_h - skirt_h;

lid_ow = box_w - 2 * lid_relief;
lid_od = box_d - 2 * lid_relief;

module lid() {
    // Plain plate. The grip lives in the box rim, so nothing is cut from
    // here and the skirt keeps full plate under it.
    translate([0, 0, body_h])
        rrect_prism(lid_ow, lid_od, corner_r - lid_relief, lid_t);

    // Skirt: lateral register only. Its outer face runs against the rim's
    // inner face; a 45 deg lead-in lets it find the opening on the way down.
    difference() {
        union() {
            hull() {
                translate([0, 0, skirt_z0])
                    rrect_prism(skirt_ow - 2 * skirt_cham,
                                skirt_od - 2 * skirt_cham,
                                skirt_or - skirt_cham, 0.01);
                translate([0, 0, skirt_z0 + skirt_cham])
                    rrect_prism(skirt_ow, skirt_od, skirt_or, 0.01);
            }
            translate([0, 0, skirt_z0 + skirt_cham])
                rrect_prism(skirt_ow, skirt_od, skirt_or,
                            skirt_h - skirt_cham + 0.01);
        }
        translate([0, 0, skirt_z0 - 1])
            rrect_prism(skirt_ow - 2 * skirt_w, skirt_od - 2 * skirt_w,
                        skirt_or - skirt_w, skirt_h + 2);
    }
}

// Lid rotated onto its print orientation: visible face down on the bed.
module lid_printed() {
    translate([0, 0, box_h]) rotate([180, 0, 0]) lid();
}

// ---- output -----------------------------------------------------------

if (part == "box") {
    box();
} else if (part == "lid") {
    lid_printed();
} else if (part == "both") {
    // Exploded preview — lid lifted clear so the rabbet is visible.
    box();
    translate([0, 0, 40]) lid();
}
// Any other value emits nothing, so this file can be included and
// section-cut for debugging without drawing the whole model.
