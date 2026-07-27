// Marsh repot liner — rebuilt from "Marsh repot - FIX flat rim setback.step"
// (two-body Fusion export, 2026-07-10) plus the user's section screenshots.
// Dimensions taken from per-body vertex extraction; see comments.
//
// TWO PARTS: set `part` to "pot", "tray", or "all" (assembly preview;
// `pullout` slides the tray out along +X for illustration).
//
// PRINT ORIENTATION (pot): on its BACK face — the +X end wall — rotated
// (90 - draft) about Y so that wall lies flat: 85deg at the current 5deg
// draft. Hanging tension then runs along layer planes [25]. The drawer
// slot lives in that same wall, so in use it faces the wall it hangs on
// and the pot reads as an unbroken solid from the front and sides.
// The tray prints as modelled: flat on the bed, basin up.
//
// v019: v011's transition fillets return on the body chamfers (user
//   request — they were nice). The shell corners are again the
//   chamfer+fillet combo [10]: 45deg chamfer core, its four transition
//   edges rounded by corner_rf = 3. Unlike v011-v015, the rim roundover
//   is now swept finely (6deg steps, since v016), so the combo reads as
//   one soft crisp edge instead of banded lines. Print cost returns to
//   the v011 number: a ~0.9mm-wide steep band along the two bed-side
//   corner rails (first-layer stick-out ~1.1mm, elephant-foot zone) —
//   accepted then, accepted now. Interior prisms stay sharp-chamfered.
// v018: two changes.
//   - Finger pocket DEEPENED for easy use: pocket_d 2.2 -> 5.0 (a real
//     first-knuckle hook), mouth raised to 6.2mm (pocket_z1 9.5, nib
//     1.2 x 0.8). The face plate thickened to carry it (face_t 4.4 ->
//     6.8, web behind the pocket ~2.0mm). Pocket roof is now a 3.8mm
//     bridge in the flat tray print — still clean.
//   - Body wall corners: pure 45deg CHAMFERS return (ch_top 10.4 /
//     ch_bot 5, the v009 treatment) in place of v016's round fillets.
//     The "bumps" that prompted v016 were v011's fillet TRANSITION
//     bands, not the chamfer itself: a clean chamfer is two crisp edges
//     and flat planes, matches the 45deg language of the slot, drain
//     hexes, and tray, and prints with no support on the corner rails
//     (the round fillets needed painted supports on the two bed-side
//     rails). The rim keeps the smooth v016 roundover (6deg steps).
//     In the face print the two bed-side chamfer planes sit at 45+draft
//     = 50deg overhang — 5deg past ideal, accepted since v009.
// v017: protruding pull lip replaced by an inset pull: the face plate
//   is a wedge parallel to the back wall's draft plane, parked 0.3mm
//   inside it, with a recessed finger pocket + hook nib. Grip grooves
//   on the tray underside (bay is open below). The whole tray sits
//   strictly inside the pot's hanging silhouette.
// v016: outer surfaces smoothed: round corner fillets (superseded by
//   v018 chamfers), rim roundover swept at 6deg steps (kept), $fn 96.
// v015: the pot HANGS, so the drawer bay carries the tray: two
//   L-section channel rails run the bay's length; the slot bottom sits
//   on a solid sill at sill_h, keeping the skirt ring continuous.
// v014: hex band, struts, and captive drip tray REMOVED. The under-floor
//   bay became a drawer bay: a slot through the back wall accepts a
//   separate pull-out drip tray under the 5 drainage holes. Visible
//   only from the back.
// v013: flat-rim setback REMOVED. Uniform 3.2mm wall to the top, 3mm
//   outer roundover. Print cost: ~1mm under-curl band, bed-end rim edge.
// v012: rim outer edge rounded with rim_r = 1 (superseded by v013).
// v011: chamfer+fillet corner combo [10] — the transition bands read as
//   bumps; superseded by v016 fillets, then v018 pure chamfers.
// v010: pot elongated until every wall is at a 5deg draft;
//   height = 11.15/tan(5) = 127.44.
// v009: side-print audit fixes: 45deg corner chamfers (restored in
//   v018), hex drainage holes, 3.2mm walls.
// v008: band-to-tray attachment on struts (removed in v014 with band).
// v007: merged into one body (reverted in v014: two parts again).
// v006: exact geometry from the two-body export. Shell taper is LINEAR
//   rim-to-ground: outer 163.2x95.2 at Z0 to 185.5x117.5 at the rim.
//   Skirt is SOLID.
// v005: center tray + windowed ring (architecture right, details wrong).
// v004: 5x 8mm round drainage holes per horticultural guidance, kept
//   (as 10x7 hexes since v009).
// v002/v003: rim setback fix / open-tray rework (superseded).

part    = "all";   // "pot" | "tray" | "all"
pullout = 40;      // assembly preview only: tray drawn out along +X (mm)

$fn = 96;   // smooth corner_rf fillet arcs

// --- Shell: linear taper, ground to rim (per-body verts) ---
top_x   = 185.5;
top_y   = 117.5;
bot_x   = 163.2;   // skirt outer at Z=0 (+-81.59)
bot_y   = 95.2;    // (+-47.59)
draft   = 5;       // wall draft, degrees — all four walls
height  = (top_x - bot_x)/2 / tan(draft);   // 127.44 at 5deg
// One height can only set every wall to `draft` because both directions
// share the same half-difference; keep it that way.
assert(abs((top_x - bot_x) - (top_y - bot_y)) < 1e-6,
       "X and Y tapers differ; a single height cannot give one draft");
ch_top  = 10.4;    // 45deg corner chamfer at the rim
ch_bot  = 5;       // 45deg corner chamfer at the base
corner_rf = 3;     // fillet on the chamfer transition edges [10]; ~3mm
                   // is the ceiling before the bed-side rails droop
wall    = 3.2;     // 8x a 0.4mm extrusion line [1]

// --- Rim: uniform wall thickness to the top, rounded outer lip ---
rim_r = 3;   // top-edge roundover; on a 3.2 wall this sweeps to within
             // 0.2mm of the inner face (a near-full-width rounded lip)
assert(rim_r <= wall,
       "rim_r > wall: the roundover would undercut the inner face");

// --- Pot floor (STEP: bottom face Z=19, top ~22) ---
floor_bot = 19;
floor_top = 22;

// Drainage: 5 holes (v004 horticultural spec), hexagonal for the face
// print — pointed along pot-X so the points face print-vertical [3,4].
// 10x7 hex ~= 45mm2 open, matching the previous 8mm round hole.
drain_x  = 10;     // point-to-point, along pot-X
drain_y  = 7;      // across, along pot-Y
hole_pos = [[0, 0], [38, 19], [-38, 19], [38, -19], [-38, -19]];

// --- Drawer slot (back wall = +X end wall, the print-bed face) ---
sill_h    = 3;     // solid sill below the slot; its top is the channel
                   // floor at the back, and it keeps the skirt ring whole
slot_open = 13.5;  // opening height above the sill
slot_w    = 70;    // opening width, centered in Y
slot_top  = sill_h + slot_open;   // 16.5
slot_ch   = 2;     // 45deg chamfer on the slot's top corners
tray_clr  = 0.5;   // per-side clearance, slot to tray
assert(slot_top <= floor_bot - 2,
       "slot too tall: keep a solid lintel band below the pot floor");
assert(slot_w/2 <= bot_y/2 - wall - ch_bot,
       "slot_w too wide: slot must stay in the flat of the back wall");

// --- Channel rails: L-section, one per side, full bay length ---
rail_under = 3.5;  // shelf reach beneath each tray edge
rail_lip_t = 3;    // upstand thickness
rail_lip_h = 8;    // upstand height (guides the basin's lower half)
rail_gap   = 0.5;  // lateral clearance, tray edge to upstand

// --- Pull-out drip tray (modelled with its bottom at Z0 = as printed;
//     seated in the pot it rides the channel at Z = sill_h) ---
tray_len   = 160;    // front edge stops 0.26 shy of the far wall when
                     // the face plate is flush with the back at Z0
tray_w     = slot_w - 2*tray_clr;   // 69
tray_wall  = 2;      // basin wall
tray_floor = 2;      // basin floor plate
tray_rim   = 11;     // basin wall height (passes the opening with air)
tray_ch    = 2;      // basin corner chamfer, in plan
face_t     = 6.8;    // face plate thickness at its base — thick enough
                     // to hide the deep finger pocket behind a 2mm web
face_h     = slot_open - tray_clr;  // 13
face_setback = 0.3;  // face plane parked this far inside the wall plane

// Inset pull: finger pocket recessed into the face plate [v017; v018
// deepened for a proper first-knuckle hook].
pocket_w  = 40;      // opening width, centered
pocket_d  = 5.0;     // depth, measured from the (drafted) face plane
pocket_z0 = 2.5;     // pocket floor (tray-local Z)
pocket_z1 = 9.5;     // hook shelf: flat roof your fingertip curls behind
nib_d     = 1.2;     // nib at the shelf's outer edge...
nib_h     = 0.8;     //   ...hangs this far below the shelf

// Grip grooves across the tray's underside near the back — the bay is
// open beneath, so a fingertip can drag the tray out from below.
grip_n     = 3;
grip_w     = 4;      // groove width (45deg-chamfered sides, prints flat)
grip_d     = 0.6;    // depth into the tray_floor plate
grip_x0    = 58;     // outermost groove center (pot X)
grip_pitch = 8;

assert(tray_rim < slot_open - tray_clr, "basin rim cannot pass the slot");
assert(sill_h + face_h + tray_clr <= slot_top,
       "face plate taller than the opening above the sill");
assert(pocket_z1 <= face_h - 3,
       "pocket shelf too high: keep a stiff rail above the pocket");
assert(face_t - face_setback + (pocket_z0 + sill_h)*tan(draft) - pocket_d
           >= 1.6,
       "pocket too deep: <1.6mm web behind the finger pocket");
assert(grip_d <= tray_floor - 1.2,
       "grip grooves too deep for the tray floor plate");

back_x = bot_x/2;    // back wall outer plane at Z0 (the flush reference)
// Insertion stop: front edge meets the far wall inner face at sill_h.
assert(back_x - tray_len >= -(bot_x/2 - wall) - sill_h*tan(draft),
       "tray_len too long: front edge starts inside the far wall");

// Rail cross-section, derived from the tray so the fit is definitional:
rail_y_in   = tray_w/2 - rail_under;          // shelf inner edge (31)
rail_lip_in = tray_w/2 + rail_gap;            // upstand inner face (35)
rail_y_weld = bot_y/2 - wall + 2;             // buried into the skirt
rail_x_end  = bot_x/2 - 1.6;                  // buried into both end walls
assert(rail_lip_in >= slot_w/2 - 0.01,
       "upstand faces must not sit inside the slot side walls");

eps = 0.01;

// Chamfered-rectangle corner points — the design language throughout:
// body shell, floor plinth, slot, and tray all share it [v018].
function cham_pts(x, y, ch) =
    [[-x/2 + ch, -y/2], [x/2 - ch, -y/2], [x/2, -y/2 + ch],
     [x/2,  y/2 - ch], [x/2 - ch,  y/2], [-x/2 + ch,  y/2],
     [-x/2,  y/2 - ch], [-x/2, -y/2 + ch]];

// Rectangle with sharp 45deg chamfered corners, extruded — the interior
// prisms (floor plinth, tray, basin) stay crisp.
module hex_prism(x, y, h, ch) {
    linear_extrude(height = h) polygon(cham_pts(x, y, ch));
}

// Chamfer+fillet combo [10]: chamfered rectangle whose transition edges
// are rounded by rf (shrink, then round-offset back out). `inset`
// additionally shrinks the whole outline by a parallel offset — used to
// build the rim roundover slices. Every call shares $fn, so hulled
// outlines have matching arc vertices and loft crease-free.
module soft_prism(x, y, h, ch, rf, inset = 0) {
    linear_extrude(height = h)
        offset(r = rf) offset(delta = -rf - inset)
            polygon(cham_pts(x, y, ch));
}

// Outer shell with a rounded top edge: the hull's top is a stack of
// inset slices tracing a quarter-round of radius rim_r, at 6deg steps.
module outer_shell() {
    hull() {
        soft_prism(bot_x, bot_y, eps, ch_bot, corner_rf);
        for (t = [0 : 6 : 90])
            translate([0, 0, height - rim_r + rim_r*sin(t) - eps])
                soft_prism(top_x, top_y, eps, ch_top, corner_rf,
                           inset = rim_r*(1 - cos(t)));
    }
}

// Tapered shell: hull of two soft prisms.
module shell(bx, by, tx, ty, h, cb, ct) {
    hull() {
        soft_prism(bx, by, eps, cb, corner_rf);
        translate([0, 0, h - eps]) soft_prism(tx, ty, eps, ct, corner_rf);
    }
}

// Drainage hexagon: pointed along pot-X (print-vertical when the floor
// prints as a vertical wall), 45deg point slopes, punched along pot-Z.
module drain_hole() {
    hu = drain_x/2; hv = drain_y/2; rise = hv;   // rise = hv -> 45deg
    linear_extrude(height = floor_top - floor_bot + 4, center = true)
        polygon([[-hu, 0], [-hu + rise, hv], [hu - rise, hv],
                 [hu, 0], [hu - rise, -hv], [-hu + rise, -hv]]);
}

function ox(z) = bot_x + (top_x - bot_x) * z / height;
function oy(z) = bot_y + (top_y - bot_y) * z / height;

module cavity() {
    translate([0, 0, -eps])
        shell(bot_x - 2*wall, bot_y - 2*wall,
              top_x - 2*wall, top_y - 2*wall,
              height + 2*eps, ch_bot, max(ch_top - wall, 1));
}

// Slot / face-plate profile in the Y-Z plane: flat bottom at `bot`,
// 45deg chamfers on the top two corners only (the bottom rides the
// sill / channel floor).
function slot_pts(w, h, ch, bot) =
    [[-w/2, bot], [w/2, bot], [w/2, h - ch], [w/2 - ch, h],
     [-w/2 + ch, h], [-w/2, h - ch]];

// Punch the drawer slot along +X through the back wall, from the sill
// top up. The wall leans outward with height (5deg draft), so the
// cutter runs from inside the empty bay to well past the outer face.
module slot_cut() {
    run = 10 + wall + slot_top*tan(draft) + 5;
    translate([back_x - 10, 0, 0])
        rotate([90, 0, 90])
            linear_extrude(height = run)
                polygon(slot_pts(slot_w, slot_top, slot_ch, sill_h));
}

// Channel rails: an L per side — shelf under the tray edge, upstand
// beside it. Both run the full bay length and bury into the skirt side
// walls and both end walls. In the face print these are vertical fins:
// no overhangs.
module rails() {
    for (m = [0, 1]) mirror([0, m, 0]) {
        // Shelf: channel floor, continuous with the sill top.
        translate([-rail_x_end, rail_y_in, 0])
            cube([2*rail_x_end, rail_y_weld - rail_y_in, sill_h]);
        // Upstand: lateral guide, coplanar with the slot side wall.
        translate([-rail_x_end, rail_lip_in, 0])
            cube([2*rail_x_end, rail_lip_t, rail_lip_h]);
    }
}

// Drainage must drip inside the tray basin (checked against the basin's
// inner faces with the tray fully seated).
basin_in_y  = tray_w/2 - tray_wall;
basin_in_x0 = back_x - tray_len + tray_wall;   // front inner face
basin_in_x1 = back_x - face_t;                 // face-plate inner face
function holes_over_tray() =
    [for (p = hole_pos)
        assert(p[0] + drain_x/2 < basin_in_x1,
               str("hole at ", p, " past the tray face plate"))
        assert(p[0] - drain_x/2 > basin_in_x0,
               str("hole at ", p, " past the tray front wall"))
        assert(abs(p[1]) + drain_y/2 < basin_in_y,
               str("hole at ", p, " outside the tray basin in Y"))
        p];

module pot() {
    difference() {
        union() {
            // Shell: solid skirt, ground to rim, linear taper.
            difference() {
                outer_shell();
                cavity();
            }
            // Floor.
            intersection() {
                cavity();
                translate([0, 0, floor_bot])
                    hex_prism(ox(floor_top), oy(floor_top),
                              floor_top - floor_bot, ch_bot);
            }
            // Channel rails for the tray.
            rails();
        }

        // Drainage holes through the floor.
        for (p = holes_over_tray())
            translate([p[0], p[1], (floor_bot + floor_top)/2])
                drain_hole();

        // Drawer slot through the back wall, above the sill.
        slot_cut();
    }
}

// Face plane of the seated tray, in tray-local coords (bottom at Z0):
// parallel to the back wall's draft plane, face_setback inside it.
face_x0 = back_x - face_setback + sill_h*tan(draft);   // at tray Z0
function face_x(z) = face_x0 + z*tan(draft);

// Finger pocket cutter: side profile in X-Z, extruded across pocket_w.
// Inner wall parallels the face plane (uniform pocket_d); flat hook
// shelf at pocket_z1 with a nib at its outer edge. All faces are
// vertical walls, up-facing floors, or short bridges in the flat print.
module pocket_cut() {
    pts = [[face_x(pocket_z0) + 2,        pocket_z0],
           [face_x(pocket_z0) - pocket_d, pocket_z0],
           [face_x(pocket_z1) - pocket_d, pocket_z1],
           [face_x(pocket_z1) - nib_d,    pocket_z1],
           [face_x(pocket_z1 - nib_h) - nib_d, pocket_z1 - nib_h],
           [face_x(pocket_z1 - nib_h) + 2,     pocket_z1 - nib_h]];
    rotate([90, 0, 0])
        linear_extrude(height = pocket_w, center = true)
            polygon(pts);
}

// Grip grooves: shallow 45deg-sided channels across the tray underside.
module grip_grooves() {
    for (i = [0 : grip_n - 1])
        translate([grip_x0 - i*grip_pitch, 0, 0])
            rotate([90, 0, 0])
                linear_extrude(height = tray_w - 2*tray_ch - 2,
                               center = true)
                    polygon([[-grip_w/2, -eps], [grip_w/2, -eps],
                             [grip_w/2 - grip_d, grip_d],
                             [-grip_w/2 + grip_d, grip_d]]);
}

// Pull-out drip tray: basin + inset-pull face plate. Modelled with its
// bottom at Z0 (prints as-is, basin up); main() seats it at sill_h.
module tray() {
    xc = back_x - tray_len/2;   // basin center
    difference() {
        union() {
            // Basin: uniform tray_wall walls on a tray_floor plate.
            difference() {
                translate([xc, 0, 0])
                    hex_prism(tray_len, tray_w, tray_rim, tray_ch);
                translate([xc, 0, tray_floor])
                    hex_prism(tray_len - 2*tray_wall,
                              tray_w - 2*tray_wall, tray_rim, tray_ch);
            }
            // Face plate: extruded past the draft plane, then trimmed
            // back to it — a wedge whose outer face parallels the wall.
            difference() {
                translate([back_x - face_t, 0, 0])
                    rotate([90, 0, 90])
                        linear_extrude(height = face_t + 4)
                            polygon(slot_pts(tray_w, face_h, slot_ch, 0));
                translate([face_x0, 0, 0])
                    rotate([0, draft, 0])
                        translate([0, -tray_w, -5])
                            cube([30, 2*tray_w, face_h + 10]);
            }
        }
        // Inset pull.
        pocket_cut();
        // Underside grip.
        grip_grooves();
    }
}

module main() {
    if (part == "pot" || part == "all") pot();
    if (part == "tray") tray();
    if (part == "all")
        translate([pullout, 0, sill_h]) tray();   // seated on the channel
}

if (is_list(holes_over_tray())) main();
