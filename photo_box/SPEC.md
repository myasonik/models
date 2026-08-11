# Photo Box — Design Specification

All dimensions in mm unless noted. Two parts, single-colour PLA, both
print in one orientation each with slicer supports **off**.

## 1. What it is

A lidded box that protects a stack of photos inside a larger shipping
carton. Nothing latches: the lid drops into a rabbet at the top of the
box, is held laterally by a skirt, and rests on the wall rim under its
own weight. The outer carton keeps it closed in transit.

- **Box** — open-topped rounded-rectangle shell.
- **Lid** — flat plate covering the full outside footprint, with a
  downward skirt that registers in the rabbet.

**There are two boxes**, identical in every respect but length. They are
one model with a `variant` switch, not two designs — every requirement
here applies to both, and a change to one is a change to both.

`variant = "a" | "b"` picks the length; `part = "box" | "lid" | "both"`
picks the layout, `"both"` being an exploded preview with the lid lifted
40. Any other `part` emits nothing, so the file can be `include`d and
section-cut for debugging. The four print layouts are
`photo_box_003_{a,b}_{box,lid}.scad`.

## 2. Outside envelope

| | Variant A | Variant B | |
|---|---|---|---|
| Length (`box_w`) | **195** | **245** | the only difference |
| Depth (`box_d`) | 65 | 65 | |
| Height, lid seated (`box_h`) | 158.75 | 158.75 | 6.25 in |

These are the intended adjustment points — everything else derives from
them, so the model stays coherent at any size. Lengths live in `len_a`
and `len_b`; `box_w` selects between them.

**The envelope is a hard constraint. No feature on either part may
exceed it in any axis.** It is not a nominal size to be traded against
ergonomics or convenience: the box ships inside another carton sized to
these numbers. Every grip, tab, boss or label must be cut *into* the
envelope, never added outside it. Both parts' bounding boxes are checked
against `box_w × box_d` at export (§9) — that check is the acceptance
test for this requirement, not a formality.

The lid is inset `lid_relief` per side, so A measures 194.5 × 64.5 and B
244.5 × 64.5; being *under* the envelope is fine, over is not.

**Build-volume headroom.** The longest part is B's lid at 244.5, leaving
12.75 per side on the U1's 270 bed — comfortable. `box_w` must not
exceed ~262 without re-checking bed clearance and brim allowance.

## 3. Usable cavity

The wall thickens inward near the top (§5), so the throat is narrower
than the main volume. The **throat** is what an object has to pass
through:

| | Variant A | Variant B |
|---|---|---|
| Throat length | 187.8 | 237.8 |
| Throat depth | 57.8 | 57.8 |
| Floor to ledge | 148.15 | 148.15 |

Below the ramp the cavity opens out by `2 × (top_wall − wall_t)` = 3.2
in each horizontal axis, for the lower 145.75.

**Photo sizes that fit** (laid flat against the long face, stacked into
the 57.8 depth):

| Print | Size | A (187.8) | B (237.8) |
|---|---|---|---|
| 4 × 6 in | 102 × 152 | ✅ | ✅ |
| 5 × 7 in | 127 × 178 | ✅ | ✅ |
| 8 × 10 in | 203 × 254 | ❌ | ❌ |

8 × 10 fits neither: its 254 long edge exceeds both throats, and it is
also longer than the 148.15 floor-to-ledge height, so it cannot stand on
end either. Variant B would need `box_w ≈ 264` to take one flat.

## 4. Thicknesses

All are multiples of the 0.4 line width.

| Feature | Param | mm | Lines |
|---|---|---|---|
| Side walls | `wall_t` | 2.0 | 5 |
| Box floor | `floor_t` | 2.4 | 6 |
| Lid plate | `lid_t` | 3.2 | 8 |
| Standing rim | `rim_t` | 1.6 | 4 |
| Lid skirt | `skirt_w` | 1.6 | 4 |

Walls are deliberately thin. A closed box is a rigid shell — the
geometry carries the load, not the wall section — and wall thickness is
solid extrusion here, so it scales filament linearly. 2.0 walls are the
point past which extra thickness buys stiffness the part does not need.
If more crush resistance is ever wanted, ribs on the lid underside are
far cheaper per unit stiffness than thicker walls.

## 5. Lid interface

Heights are measured from the bed; the rim top (`body_h`) is at 155.55.

- **Ramp** — from z 148.15 to 150.55 the wall thickens inward from 2.0
  to `top_wall` = 3.6, giving the rabbet solid material to be cut from
  and hooping the top of a large thin-walled box. It rises 2.4 while
  growing 1.6 inward: **34° off vertical**, clear of the 45° limit
  rather than sitting on it.
- **Ledge** — the up-facing shelf left at z 150.55, `ledge_w` = 2.0
  wide, running the full perimeter.
- **Rim** — the standing fin above the ledge, `rim_t` = 1.6 thick ×
  `rabbet_h` = 5.0 tall. The rabbet opening it encloses is
  `box_w − 3.2` × 61.8 — 191.8 × 61.8 for A, 241.8 × 61.8 for B.
- **Skirt** — on the lid underside, outer size `box_w − 3.8` × 61.2, so
  `clr` = 0.3 per side against the rim's inner face. It hangs
  `skirt_h` = 4.6 down from the plate, engaging 4.6 of the rabbet's 5.0
  depth. A 1.0 ×
  45° chamfer (`skirt_cham`) on its bottom outer edge is the lead-in
  that self-centres the lid on the way down.
- **Seat** — the **rim is the seat, not the ledge**. The plate underside
  lands on the rim top at 155.55; the skirt stops `seat_gap` = 0.4 above
  the ledge so the two contacts cannot fight. Should the gap ever close
  through tolerance, the skirt's inner face sits 0.1 inboard of the
  ledge's inner edge, so it lands on the ledge rather than on nothing.
- **Reveal** — the lid plate is inset `lid_relief` = 0.25 per side from
  the outer face, so it never proud-catches on the wall.
- Verified by boolean check: box ∩ lid is a zero-thickness sheet at
  z = 155.55 only — tangent contact at the rim seat, no interference.

## 6. Ergonomics

The lid stands `lid_t` = 3.2 proud of the rim, with a `lid_relief` = 0.25
reveal around it.

The grip is a **nail catch**: a notch `nail_d` = 3.0 deep × `nail_w`
wide taken out of the **box rim**, centred on the front and back walls.
The lid edge overhangs the resulting window, and a fingernail enters it
to lift the lid.

`nail_w` is derived, not fixed: `min(60, box_w − 4 × corner_r)`. It must
never approach the wall's length or the notch eats the corners and the
rim stops being continuous. At both current lengths the clamp is
inactive and `nail_w` = 60.

**The notch is cut from the rim, not the lid.** The plate overhangs the
skirt by only `lid_od/2 − skirt_od/2` = 1.65, so a chamfer in the lid's
underside deeper than that removes the plate from beneath the skirt and
leaves the skirt bridging `nail_w` in mid-air — 161 mm² of flat-down
overhang that prints as a drooping island. The rim has 5.0 of depth to
spend; the lid has 1.65. Any future grip must come out of the rim for
the same reason.

Over the two notches the lid spans the gap unsupported — 60 of a 195 (A)
or 245 (B) edge, at full plate thickness, with the rim carrying it either
side. The 1.65 overhang figure above is independent of `box_d`: it is
`lid_relief + rim_t + clr` measured inward, so it holds at any size.

**The gap must not open a path into the cavity.** Directly behind the
notch is the skirt, which closes it; the only route inward is the 0.3
skirt clearance, which dead-ends on the ledge. Any change to `nail_d`,
`rim_t`, `clr` or `skirt_w` must preserve this.

Being a cut, the nail catch consumes no envelope — it is the reason the
grip is subtractive rather than a projecting tab.

## 7. Printability requirements

- **Box prints open-face-up, floor on the bed, supports OFF.** Every
  wall is vertical; the ramp is 34° and the ledge faces up, so the
  cavity's three stacked cuts expose nothing that needs support. Only
  downward face above the bed is the 45° foot chamfer (`foot_cham` 0.6)
  at the first layer — 423 mm² (A) / 508 mm² (B), which is what the
  chamfer is for.
- **Lid prints visible-face-down, skirt up, supports OFF.** Zero
  overhang area. The visible face gets the textured-PEI matte finish,
  matching the box floor. The plate is uncut, so the skirt has full
  plate beneath it everywhere.
- The nail-catch notches sit in the box: their floors face up and their
  walls are vertical, so they cost the upright box print nothing.
- Bottom outer edge is a 45° **chamfer, not a fillet**, to control
  elephant's foot.
- All vertical corners are filleted `corner_r` = 4. This is also the
  warp mitigation on the long thin bed contact — use a brim.
- One manifold solid per part (genus 0, no console warnings).
- `$fa = 2`, `$fs = 0.4`.

**Layer orientation is the structural weak point.** Printed upright, the
box's layer planes are horizontal, so a corner drop loads them in
tension. This is accepted: the part lives inside a shipping carton and
is not a structural component. Do not re-orient to fix it — every other
orientation introduces overhangs.

**Test the fit before committing the full print.** The four parts are
~628 g together. The rabbet is identical on both variants, so **one**
corner test covers both: print a ~40 × 40 section of the rabbet plus the
matching lid corner and confirm the 0.3 clearance before running any of
the real parts.

## 8. Material

| | Variant A | Variant B |
|---|---|---|
| Box | 184.9 cm³ ≈ 229 g | 223.3 cm³ ≈ 277 g |
| Lid | 43.5 cm³ ≈ 54 g | 54.5 cm³ ≈ 68 g |
| Per box | ≈ 283 g | ≈ 345 g |

Filament is PLA, single colour. **Both boxes together ≈ 628 g.**

Clearances (`clr` 0.3) are set for PLA. PETG swells more — open to 0.4
and reprint the corner test. ASA/ABS would additionally need the 254
length re-checked for warp.

## 9. Acceptance checks

Run these against the exported STLs — **all four, both variants** —
before the model is considered correct. They are requirements, not conveniences.

1. **Envelope.** Each part's mesh bounding box satisfies
   `X ≤ box_w` and `Y ≤ box_d` **for its own variant**, and the assembled stack is `box_h` tall
   (box Z + `lid_t`). A part that measures over on any axis fails,
   regardless of how useful the offending feature is.
2. **Bed fit.** Each part's X and Y are inside 270 with margin left for
   a brim.
3. **Print orientation.** Each part's mesh sits at `z = 0`, already
   oriented for the bed, so no rotation is needed in the slicer.
4. **Manifold.** Genus 0, `NoError`, no console warnings, per part.
5. **Fit.** `box ∩ lid` is zero-volume — tangent contact at the rim seat
   only, no interference.
