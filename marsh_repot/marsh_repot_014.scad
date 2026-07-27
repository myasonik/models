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
// slot lives in that same wall, so in use it faces the wall/shelf and
// the pot reads as an unbroken solid from the front and sides.
// The tray prints as modelled: flat on the bed, basin up.
//
// v014: hex band, struts, and captive drip tray REMOVED. The under-floor
//   bay is now a plain drawer bay: a slot_w x slot_h slot through the
//   back wall at ground level accepts a separate pull-out drip tray
//   (basin + face plate + pull lip) that slides on the shelf surface
//   under the 5 drainage holes. Visible only from the back. The face
//   plate fills the slot to 0.5mm clearance per side; the tray's front
//   edge meeting the far wall is the insertion stop, parking the face
//   ~flush with the back wall's ground-level plane (the wall's 5deg
//   draft means the wall face leans 1.4mm proud of the plate at the
//   slot's top edge). Slot top corners chamfered to match the pot's
//   45deg corner language; slot top sits 3mm below the pot floor so a
//   solid lintel band remains all the way around.
// v013: flat-rim setback REMOVED (a deliberate departure from the
//   original Fusion design this file was rebuilt from — the source file
//   was named for that feature). The wall now runs uniform 3.2mm
//   thickness to the top, capped by a 3mm outer roundover that sweeps
//   to within 0.2mm of the inner face. Same print cost as the corner
//   fillets: ~1mm under-curl band on the bed-end rim edge only.
// v012: rim outer edge rounded with rim_r = 1 (superseded by v013).
// v011: shell corners softened with the chamfer+fillet combo [10]: the
//   45deg chamfer core stays, its transition edges rounded by
//   corner_rf = 3. In the side print the surface exceeds 45deg only in
//   a ~0.9mm band along the two bed-side corner rails.
// v010: pot elongated in height until every wall is at a 5deg draft.
//   Footprints unchanged (rim 185.5x117.5, base 163.2x95.2);
//   height = 11.15/tan(5) = 127.44.
// v009: side-print audit fixes (hex drainage holes, 3.2mm walls, 45deg
//   shell corner chamfers). Drain hexes kept in v014.
// v008: band-to-tray attachment on struts (removed in v014 with band).
// v007: merged into one body (reverted in v014: two parts again).
// v006: exact geometry from the two-body export. Shell taper is LINEAR
//   rim-to-ground: outer 163.2x95.2 at Z0 to 185.5x117.5 at the rim
//   (skirt ring verts at Z=0: +-81.59 x +-47.59). Skirt is SOLID.
// v005: center tray + windowed ring (architecture right, details wrong).
// v004: 5x 8mm round drainage holes per horticultural guidance, kept
//   (as 10x7 hexes since v009).
// v002/v003: rim setback fix / open-tray rework (superseded).

part    = "all";   // "pot" | "tray" | "all"
pullout = 40;      // assembly preview only: tray drawn out along +X (mm)

$fn = 48;

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
ch_bot  = 5;       // corner chamfer at the base
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
slot_w   = 70;     // opening width, centered in Y
slot_h   = 16;     // opening height from the ground plane
slot_ch  = 2;      // 45deg chamfer on the slot's top corners
tray_clr = 0.5;    // per-side clearance, slot to tray
assert(slot_h <= floor_bot - 2,
       "slot_h too tall: keep a solid lintel band below the pot floor");
assert(slot_w/2 <= bot_y/2 - wall - ch_bot,
       "slot_w too wide: slot must stay in the flat of the back wall");

// --- Pull-out drip tray ---
tray_len   = 159.5;  // front edge stops 0.5 shy of the far wall when
                     // the face plate is flush with the back at Z0
tray_w     = slot_w - 2*tray_clr;   // 69
tray_wall  = 2;      // basin wall
tray_floor = 2;      // basin floor plate
tray_rim   = 12;     // basin wall height (passes the slot with 4mm air)
tray_ch    = 2;      // basin corner chamfer, in plan
face_t     = 3.2;    // face plate thickness (matches pot wall)
face_h     = slot_h - tray_clr;     // 15.5
lip_w      = 30;     // pull lip: bar across the face plate top,
lip_d      = 8;      //   protruding lip_d out the back,
lip_t      = 4;      //   lip_t thick, 45deg chamfer underneath [print]
assert(tray_rim < slot_h - tray_clr, "basin rim cannot pass the slot");
assert(face_h - lip_t - lip_d >= 0, "lip 45deg root runs off the plate");

back_x = bot_x/2;    // back wall outer plane at Z0 (the flush reference)
// Insertion stop: front edge meets the far wall inner face at Z0.
assert(back_x - tray_len > -(bot_x/2 - wall) - 0.51,
       "tray_len too long: front edge starts inside the far wall");

eps = 0.01;

// Chamfered-rectangle corner points, shared by the prism modules.
function cham_pts(x, y, ch) =
    [[-x/2 + ch, -y/2], [x/2 - ch, -y/2], [x/2, -y/2 + ch],
     [x/2,  y/2 - ch], [x/2 - ch,  y/2], [-x/2 + ch,  y/2],
     [-x/2,  y/2 - ch], [-x/2, -y/2 + ch]];

// Rectangle with sharp 45deg chamfered corners, extruded.
module hex_prism(x, y, h, ch) {
    linear_extrude(height = h) polygon(cham_pts(x, y, ch));
}

// Chamfer+fillet combo [10]: chamfered rectangle whose transition edges
// are rounded by rf (shrink, then round-offset back out). `inset`
// additionally shrinks the whole outline by a parallel offset — used to
// build the rim roundover slices.
module soft_prism(x, y, h, ch, rf, inset = 0) {
    linear_extrude(height = h)
        offset(r = rf) offset(delta = -rf - inset)
            polygon(cham_pts(x, y, ch));
}

// Outer shell with a rounded top edge: the hull's top is a stack of
// inset slices tracing a quarter-round of radius rim_r.
module outer_shell() {
    hull() {
        soft_prism(bot_x, bot_y, eps, ch_bot, corner_rf);
        for (t = [0, 30, 60, 90])
            translate([0, 0, height - rim_r + rim_r*sin(t) - eps])
                soft_prism(top_x, top_y, eps, ch_top, corner_rf,
                           inset = rim_r*(1 - cos(t)));
    }
}

// Tapered shell: hull of two soft prisms. The 45deg chamfer core prints
// from any orientation [9]; the rf-rounded transitions soften the look
// while confining >45deg surface to a sub-millimetre band in the face
// print (see the v011 note).
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
// 45deg chamfers on the top two corners only (the bottom is the ground
// plane; the tray floor slides through it).
function slot_pts(w, h, ch, bot) =
    [[-w/2, bot], [w/2, bot], [w/2, h - ch], [w/2 - ch, h],
     [-w/2 + ch, h], [-w/2, h - ch]];

// Punch the drawer slot along +X through the back wall. The wall leans
// outward with height (5deg draft), so the cutter runs from inside the
// empty bay to well past the outer face at slot_h.
module slot_cut() {
    run = 10 + wall + slot_h*tan(draft) + 5;
    translate([back_x - 10, 0, 0])
        rotate([90, 0, 90])
            linear_extrude(height = run)
                polygon(slot_pts(slot_w, slot_h, slot_ch, -1));
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
        }

        // Drainage holes through the floor.
        for (p = holes_over_tray())
            translate([p[0], p[1], (floor_bot + floor_top)/2])
                drain_hole();

        // Drawer slot through the back wall.
        slot_cut();
    }
}

// Pull-out drip tray: basin + face plate + pull lip. Modelled seated
// (face plate at the back wall's Z0 plane); prints as-is, basin up.
module tray() {
    xc = back_x - tray_len/2;   // basin center
    union() {
        // Basin: uniform tray_wall walls on a tray_floor plate.
        difference() {
            translate([xc, 0, 0])
                hex_prism(tray_len, tray_w, tray_rim, tray_ch);
            translate([xc, 0, tray_floor])
                hex_prism(tray_len - 2*tray_wall, tray_w - 2*tray_wall,
                          tray_rim, tray_ch);
        }
        // Face plate: fills the slot minus clearance; overlaps the
        // basin's back wall for stiffness.
        translate([back_x - face_t, 0, 0])
            rotate([90, 0, 90])
                linear_extrude(height = face_t)
                    polygon(slot_pts(tray_w, face_h, slot_ch, 0));
        // Pull lip: bar across the face plate top, 45deg underside so
        // the tray prints flat with no supports.
        hull() {
            translate([back_x - eps, -lip_w/2, face_h - lip_t - lip_d])
                cube([eps, lip_w, lip_d + lip_t]);
            translate([back_x - eps, -lip_w/2, face_h - lip_t])
                cube([lip_d + eps, lip_w, lip_t]);
        }
    }
}

module main() {
    if (part == "pot" || part == "all") pot();
    if (part == "tray" || part == "all")
        translate([part == "all" ? pullout : 0, 0, 0]) tray();
}

if (is_list(holes_over_tray())) main();
