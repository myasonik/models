# Preset Catalog

What each custom preset is for, and the reasoning behind the values that were
tuned deliberately. Inherited values are not repeated here — read the parent
profile for those.

The copies in `presets/` are exported verbatim from the live Orca config. If a
value here disagrees with the JSON, the JSON is the truth and this file needs
updating.

---

## Process — `Draft @ .4`

*Parent: `0.28 Extra Draft @Snapmaker U1 (0.4 nozzle)`*

Fast throwaway prints: check a shape, check a fit, hold the thing in your hand.
Not for anything that has to survive being used.

| Setting | Value | Why |
|---|---|---|
| `layer_height` | 0.32 | 80% of a 0.4 nozzle — the coarsest sane layer. ~12% fewer layers than the 0.28 parent. |
| `wall_loops` | 2 | One loop leaves a feature wall as two unbonded skins with infill air between them. Two loops bond. |
| `top_shell_layers` / `bottom_shell_layers` | 3 / 2 | 2 top layers at 0.32 over sparse infill sag into the voids. 3 closes reliably. |
| `sparse_infill_pattern` | grid | Lightning only props up flat tops and gives ~zero lateral strength. |
| `sparse_infill_density` | 10% | Enough to keep top surfaces from spanning voids. |
| `detect_thin_wall` | on | Prints sub-line-width slivers as single lines instead of dropping them. |
| walls 220 / 330, infill 400, travel 550 mm/s | | ~10% over the parent. Pushing further trades ringing and layer shifts for little time. |
| `default_acceleration` 9000 | | Modest bump; the U1's real accel ceiling is firmware-internal and not readable from the machine profile. |
| `support_threshold_angle` | 25 | The single biggest support lever — only overhangs past 65° from vertical get trees at all. |
| `support_style` tree_slim, `tree_support_branch_distance` 7, `support_line_width` 0.5, `tree_support_wall_count` 1 | | Thin the forest; drafts do not need pretty undersides. |
| `support_interface_top_layers` 1 / bottom 0, `support_top_z_distance` 0.32 | | One full layer of gap so supports snap off by hand. |
| `support_speed` 250 / `support_interface_speed` 200 | | Supports are scrap; print them fast. |

**Known failure mode.** At 0.32 mm layers a steep overhang steps
`0.32 · tan(θ)` outward per layer — 0.55 mm at 60°, more than one 0.4 mm line
width, so the perimeter extrudes over open air no matter what speed or fan you
set. Anything past ~50° needs finer layers (variable layer height over just
that band works well) or a different process preset. Slowdown and cooling
settings cannot rescue a step wider than a line.

**History.** v1 of this preset ran `wall_loops: 1` and 8% lightning infill.
A threaded jar lid printed with it came out as separate thin ribbons with
daylight between them, and the rim face sagged into the hollow interior as
loose strands. The wall/infill/top-layer values above are the fix; the speeds
were never the problem.

---

## Process — `Watertight @ 0.4`

*Parent: `0.20 Standard @Snapmaker U1 (0.4 nozzle)`*

Planters and anything that has to hold liquid. Doubles as the go-to preset for
functional parts — threads, load-bearing features — because four wall loops
fill a 2 mm feature wall essentially solid.

| Setting | Value | Why |
|---|---|---|
| `layer_height` | 0.16 | Thinner layers fuse better; interlayer gaps are what leak. |
| `wall_loops` | 4 | Watertightness comes from wall count, not infill — the strongest finding in the research behind this preset. |
| `sparse_infill_density` | 0% | Walls do all the sealing work. Infill only adds time and leak paths. |
| `bottom_shell_layers` | 5 | Thick floor under soil and water weight. |
| `top_shell_layers` | 2 | Only matters if the model has a rim. |
| `wall_sequence` | outer wall/inner wall | Cleaner, more consistent exterior seam — easier to spot and seal a leak. |
| walls 130 / 150, top 120 mm/s | | Slow walls bond better at the seam. |
| `brim_type` outer_only, `brim_width` 6 | | Tall prints on a small footprint tip and warp without a brim. |
| `detect_thin_wall` | on | |

Pair with `Planter PETG` for anything living outdoors: PLA embrittles under UV
within months and its ~57 °C glass transition is reachable in a sun-heated dark
pot.

**Drift note.** This preset was re-saved through the Orca GUI at some point,
which rewrote it alphabetically and dropped the `compatible_printers`,
`initial_layer_height` (0.2) and `seam_position` (aligned) keys it was created
with. `compatible_printers` has been restored; the other two are left off
because the parent supplies the same values anyway.

---

## Filament — `Claude PLA Draft @Snapmaker U1 (0.4 nozzle)`

*No parent — flattened.* Generic PLA at draft speed, to pair with `Draft @ .4`.

| Setting | Value | Why |
|---|---|---|
| `nozzle_temperature` | 225 | Hotter than stock PLA to keep up with the flow rate. |
| `nozzle_temperature_initial_layer` | 220 | First-layer temp swings hurt bed adhesion more than they help speed. |
| `filament_max_volumetric_speed` | 20 mm³/s | Matches Snapmaker's own ceiling for the U1: their `Snapmaker PLA SnapSpeed @U1` profile caps at 20, `Generic PLA High Speed @base` at 18, `Snapmaker PLA Basic @U1` at 15. This is a hard ceiling — Orca slows the process's requested speeds to respect it, so under-extrusion at speed is fixed here, not in the process preset. The U1's nozzles are **stainless** (worse thermal conductivity than brass), so don't raise this past 20 without an actual max-flow test. |
| `close_fan_the_first_x_layers` | 2 | Cooling fights bed adhesion exactly when it matters most. |
| `fan_cooling_layer_time` | 60 | Reaches full cooling sooner to match short layer times. |
| `slow_down_layer_time` | 3 | |
| `overhang_fan_speed` 100 @ `overhang_fan_threshold` 50% | | Overhang cooling lives in the *filament* preset, not the process one. Slow-but-uncooled just gives a perimeter more time to droop. |

**This preset is flattened** — it was built in the GUI rather than imported, so
it carries every filament key explicitly with `"inherits": ""`. It will not
pick up vendor profile updates, and edits must be made field by field rather
than by adding an override. Rebuilding it on top of `Generic PLA High Speed`
would fix that, at the cost of re-checking every value.

---

## Filament — `Planter PLA @Snapmaker U1 (0.4 nozzle)`

*Parent: `Generic PLA`*

| Setting | Value | Why |
|---|---|---|
| `nozzle_temperature` / initial | 228 / 222 | Hotter fuses wall seams tighter — the thing that keeps water in. |
| `filament_flow_ratio` | 1.02 | Slightly fuller extrusion closes microscopic interlayer gaps. |
| `fan_min_speed` / `fan_max_speed` | 70 / 100 | Pulled back from full so layers stay hot enough to weld, while flared pot walls still get real cooling. |
| `fan_cooling_layer_time` | 80 | |

## Filament — `Planter PETG @Snapmaker U1 (0.4 nozzle)`

*Parent: `Generic PETG`*

| Setting | Value | Why |
|---|---|---|
| `nozzle_temperature` / initial | 238 / 245 | Hot for layer fusion; the *hotter* first layer is deliberate — PETG needs it for bed adhesion. |
| `filament_flow_ratio` | 1.0 | |
| `fan_min_speed` / `fan_max_speed` | 20 / 50 | PETG bonds far better with restrained cooling. Over-cooling PETG is a common cause of weak, leak-prone layers. |

---

## Outstanding drift

None — `check-presets.sh` is the source of truth for whether the repo and live
copies are healthy; run it rather than trusting this section.
