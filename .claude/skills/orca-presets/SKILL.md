---
name: orca-presets
description: Create, edit, and version-control custom Snapmaker Orca slicer presets — process (print settings) and filament profiles for the Snapmaker U1. Use when asked for a new print or filament preset, to tune print settings for a material or a kind of part, to change layer height/walls/infill/speeds/supports/temps outside a .scad file, or when a preset does not show up in Orca's dropdown.
allowed-tools:
  - Bash(*/export-presets.sh*)
  - Bash(*/install-presets.sh*)
  - Bash(*/check-presets.sh*)
  - Bash(pgrep*)
  - Read
  - Write
  - Edit
  - Glob
---

# Snapmaker Orca Presets Skill

Custom slicer presets for the U1 live in two places: Orca's own config, which
is where they take effect, and this skill, which is where they are
version-controlled. Nothing in the repo can rebuild them, so they belong in a
skill rather than a model folder.

Current presets and the reasoning behind their values:
**`references/preset-catalog.md`**. Read it before tuning anything — several
values are there because a print already failed without them.

## Ask first

Two questions decide most of a preset, and neither is safe to assume:

- **What is the part for?** A fit check, a planter, a threaded functional part
  and a display piece want different walls, layers and speeds. "Fast" alone is
  not a spec — the draft preset once cost a print because it was fast in a way
  that made a threaded lid hollow.
- **Which filament?** Temps, cooling and flow live in the filament preset, and
  the process preset's speeds are capped by the filament's volumetric ceiling.

## Layout

```
~/.var/app/io.github.Snapmaker.Snapmaker_Orca/config/Snapmaker_Orca/
  system/Snapmaker.json              # vendor index: every system preset name
  system/Snapmaker/{process,filament,machine}/*.json   # system presets + setting_id
  system/OrcaFilamentLibrary/filament/<brand>/*.json   # third-party filaments
  user/<profile>/process/<name>.json         # custom process presets  (+ .info)
  user/<profile>/filament/base/<name>.json   # custom filament presets (+ .info)
  log/<timestamp>.log.0              # startup log — says why a parent was not found
  Snapmaker_Orca.conf                # selected machine, recent presets
```

It is a flatpak, so nothing lives under `~/.config`. Set `ORCA_CONFIG` to
override the path. `<profile>` is `default` while signed out of a Snapmaker
account and an account id after signing in — the scripts pick the newest
profile directory automatically; set `ORCA_PROFILE` to override.

**Process vs filament.** Process = how the toolpath is built (layer height,
walls, infill, speeds, accelerations, supports, brim) — independent of
material. Filament = how the material behaves (temperatures, cooling, flow
ratio, volumetric cap) — independent of geometry. When a part prints badly,
deciding which of the two owns the fix is usually the whole diagnosis.

## Creating a preset

1. **Close Orca.** It reads user presets only at startup and rewrites all of
   them from memory on exit, so anything written to disk while it runs is
   discarded. `install-presets.sh` refuses to run until it is closed.

2. **Pick a real parent.** Read the vendor index for exact names — they are
   long and easy to get subtly wrong:

   ```bash
   source .claude/skills/orca-presets/scripts/orca-env.sh   # defines ORCA_CONFIG etc.
   python3 -c "import json;d=json.load(open('$ORCA_CONFIG/system/Snapmaker.json'));
   print('\n'.join(p['name'] for p in d['process_list'] if 'U1 (0.4 nozzle)' in p['name']))"
   ```

   Same for `filament_list`. A wrong `inherits` shows up in the log as
   `can not find parent for config`.

3. **Write the JSON** into `presets/process/<name>.json` or
   `presets/filament/<name>.json` in this skill, overriding only what differs
   from the parent. Minimum viable process preset:

   ```json
   {
       "type": "process",
       "name": "Example @ 0.4",
       "print_settings_id": "Example @ 0.4",
       "from": "User",
       "is_custom_defined": "1",
       "inherits": "0.20 Standard @Snapmaker U1 (0.4 nozzle)",
       "compatible_printers": ["Snapmaker U1 (0.4 nozzle)"],
       "version": "2.2.50.2",
       "layer_height": "0.2"
   }
   ```

   A filament preset is the same shape with `"type": "filament"`,
   `filament_settings_id`, and **every setting value wrapped in a list**
   (`"nozzle_temperature": ["228"]`) because filament settings are per-extruder.

4. **Write the `.info` sidecar** next to it, `<name>.info`:

   ```
   sync_info = create
   user_id =
   setting_id =
   base_id = GP004
   updated_time = 1784839191
   ```

   `base_id` is the `setting_id` of the parent preset — read it out of the
   parent's own JSON under `system/Snapmaker/`. `install-presets.sh` refreshes
   `updated_time` for you.

5. **Validate**, then install and restart Orca:

   ```bash
   .claude/skills/orca-presets/scripts/check-presets.sh
   .claude/skills/orca-presets/scripts/install-presets.sh "Example @ 0.4"
   ```

6. **Document it** in `references/preset-catalog.md` — what it is for, and why
   each deliberately-chosen value is what it is. A preset with no recorded
   reasoning gets re-tuned from scratch the next time something prints badly.

## The rules Orca enforces silently

A preset that breaks any of these is skipped at startup with **no error and no
log line** — it simply never appears in the dropdown. `check-presets.sh` checks
all of them.

- **`version` is mandatory.** Orca parses it as a semver and `continue`s past
  the file if that fails (`PresetCollection::load_presets` in `Preset.cpp`).
  This is the single most common cause of a missing preset. Copy the value from
  a preset that already works.
- **`name` must match the filename** exactly, including spaces and the
  `@Snapmaker U1 (0.4 nozzle)` suffix if used.
- **`print_settings_id` / `filament_settings_id` must equal `name`.** Orca
  writes these itself and expects them back.
- **`inherits` must name an existing system preset**, or be empty for a
  flattened preset.
- **`compatible_printers` gates visibility.** With the wrong machine name the
  preset loads and stays hidden.
- **Filament values are lists, process values are strings.** Numbers written as
  bare JSON numbers rather than strings cause trouble.

## Editing an existing preset

Prefer editing the copy in this skill and running `install-presets.sh`, so the
repo stays the source of truth. When editing Orca's live file directly, export
afterwards.

Presets built in the GUI are **flattened** — no `inherits`, every key spelled
out (`Claude PLA Draft` is one). Change those field by field; adding an
override key does nothing useful when there is no parent to override.

Re-saving a preset inside Orca rewrites the file alphabetically and may drop
keys the parent already supplies, so a diff after a GUI save can look alarming
without meaning anything. Export and check the diff rather than assuming.

## Keeping the repo in sync

```bash
.claude/skills/orca-presets/scripts/export-presets.sh    # live config -> this skill
.claude/skills/orca-presets/scripts/install-presets.sh   # this skill -> live config
.claude/skills/orca-presets/scripts/check-presets.sh     # validate the skill's copies
```

Export after any session where presets were tuned in the GUI, then commit.
Both directions guard against drift:

- Export refuses to run while Orca is open (it would capture pre-session
  values — Orca only writes presets to disk on exit) and flags repo presets
  that vanished from the live config; `--prune` deletes them, so a rename in
  the GUI doesn't leave a zombie that the next install resurrects.
- Install refuses to overwrite a live preset whose `.info` `updated_time` is
  newer than the repo copy's — that means GUI tuning was never exported. Run
  the export first, or `--force` to overwrite; anything overwritten is backed
  up under `user_backup-orca-presets/` in the Orca config.

## When a preset does not show up

1. `check-presets.sh` on the live file — it catches the silent-skip rules.
2. Was Orca restarted? It does not hot-reload.
3. Is the right printer selected? `compatible_printers` hides mismatches.
4. Read the newest file in `log/` for `can not find parent for config`, which
   means a bad `inherits`. Note that Orca logs that error harmlessly if a
   preset file changes underneath a *running* instance — only errors from a
   clean startup count.
5. If the file vanished entirely, Orca deleted it as unparseable JSON.

## Settings that live somewhere non-obvious

- **Overhang cooling and bed temperature** are filament settings, not process
  settings. Bed temp is per plate type — the U1's textured PEI has its own
  field.
- **Overhang slowdown brackets** are process settings (Speed → Overhang speed),
  but they only help once layers are thin enough that the overhang step is
  narrower than a line width.
- **Scarf joint seams** exist on both sides: the process preset has the real
  toggle (Quality → Seam), the filament preset has `filament_scarf_*`
  overrides. Set the process one and leave the filament keys alone.
- **`filament_max_volumetric_speed`** silently caps every speed in the process
  preset. Under-extrusion at high speed is fixed there.
- Seam *position* is best controlled by painting a seam enforcer on the plated
  model, not by `seam_position` — that setting works in plate coordinates, not
  model ones.
