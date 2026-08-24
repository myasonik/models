#!/usr/bin/env python3
"""Validate Snapmaker Orca user presets.

Checks the rules Orca applies without telling you: a preset that fails any of
them is skipped at startup and simply never appears in the dropdown.

Runs without a live Orca config too — the rules that need one (inherits
resolution, machine names, .info base_id) degrade to warnings so the
self-contained rules still gate an install on a fresh machine.
"""
import json
import os
import re
import sys
from pathlib import Path

SYSTEM = Path(os.environ.get("ORCA_SYSTEM", ""))
CONFIG = Path(os.environ.get("ORCA_CONFIG", ""))
INDEX = Path(os.environ.get("ORCA_VENDOR_INDEX", ""))
SEMVER = re.compile(r"^\d+(\.\d+){1,3}$")

# Filament keys are per-extruder lists; process keys are bare strings. These
# are the scalar exceptions on the filament side.
FILAMENT_SCALARS = {
    "type", "name", "from", "inherits", "is_custom_defined", "version",
    "filament_id", "compatible_printers_condition", "compatible_prints_condition",
    "instantiation", "setting_id",
}

load_problems = []


def load_system_names():
    """name -> setting_id for every system preset Orca can inherit from.

    Empty tables mean the system profiles could not be read — callers treat
    that as "cannot check", not "nothing exists".
    """
    process, filament, machines = {}, {}, set()
    roots = [r for r in (SYSTEM, CONFIG / "system" / "OrcaFilamentLibrary")
             if str(r) not in ("", ".") and r.is_dir()]
    if not roots:
        load_problems.append(f"system profiles not found under {SYSTEM or '(ORCA_SYSTEM unset)'}")
    for root in roots:
        for kind, table in (("process", process), ("filament", filament)):
            for path in root.glob(f"{kind}/**/*.json"):
                try:
                    data = json.loads(path.read_text())
                except Exception:
                    continue
                name = data.get("name")
                if name:
                    table[name] = data.get("setting_id")
        for path in root.glob("machine/**/*.json"):
            try:
                data = json.loads(path.read_text())
            except Exception:
                continue
            if data.get("name"):
                machines.add(data["name"])
    if INDEX.is_file():
        try:
            idx = json.loads(INDEX.read_text())
        except Exception as exc:
            # A truncated vendor index (Orca killed mid-update) must not take
            # the whole validator down with a traceback.
            load_problems.append(f"vendor index {INDEX.name} is unreadable: {exc}")
        else:
            for entry in idx.get("machine_list", []):
                if entry.get("name"):
                    machines.add(entry["name"])
    return process, filament, machines


SYS_PROCESS, SYS_FILAMENT, SYS_MACHINES = load_system_names()


def infer_kind(data, path: Path):
    """process or filament — never trust the raw path alone.

    Orca strips the "type" key from presets it writes itself, and a bare
    filename in the cwd has no directory to go by, so fall through: explicit
    type, then the id key only one kind carries, then the resolved location.
    """
    kind = data.get("type")
    if kind in ("process", "filament"):
        return kind
    if "filament_settings_id" in data:
        return "filament"
    if "print_settings_id" in data:
        return "process"
    parts = path.resolve().parts
    return "filament" if "filament" in parts else "process"


def check(path: Path):
    errors, warnings = [], []
    try:
        data = json.loads(path.read_text())
    except Exception as exc:
        return [f"not valid JSON: {exc}"], []

    stem = path.stem
    name = data.get("name")
    kind = infer_kind(data, path)

    # 1. The silent killer: no parseable "version" means Orca skips the file.
    version = data.get("version")
    if not version:
        errors.append('missing "version" — Orca silently skips presets without one')
    elif not SEMVER.match(str(version)):
        errors.append(f'"version" {version!r} is not parseable as a semver')

    # 2. Name must match the filename, or the preset shadows a different entry.
    if not name:
        errors.append('missing "name"')
    elif name != stem:
        errors.append(f'"name" {name!r} does not match filename {stem!r}')

    # 3. The id field Orca writes for itself must echo the name.
    id_key = "print_settings_id" if kind == "process" else "filament_settings_id"
    raw_id = data.get(id_key)
    got_id = raw_id[0] if isinstance(raw_id, list) and raw_id else raw_id
    if raw_id is None:
        errors.append(f'missing "{id_key}"')
    elif got_id != name:
        errors.append(f'"{id_key}" {got_id!r} does not match "name" {name!r}')

    # 4. inherits must name a system preset that exists, or be empty (flattened).
    inherits = data.get("inherits", "")
    table = SYS_PROCESS if kind == "process" else SYS_FILAMENT
    if inherits:
        if not table:
            warnings.append(f'inherits {inherits!r} not checked — no system profiles available')
        elif inherits not in table:
            errors.append(f'inherits {inherits!r}, which is not a system {kind} preset')
    else:
        warnings.append("no \"inherits\" — this is a flattened preset; it will not "
                        "pick up vendor profile updates")

    # 5. Without a matching printer the preset loads but never shows up.
    printers = data.get("compatible_printers") or []
    if not printers:
        warnings.append('no "compatible_printers" — visible under every printer')
    for printer in printers:
        if SYS_MACHINES and printer not in SYS_MACHINES:
            warnings.append(f'compatible_printers lists {printer!r}, no such machine profile')

    # 6. Value shape. Filament settings are per-extruder lists.
    for key, value in data.items():
        if key in FILAMENT_SCALARS:
            continue
        if kind == "filament":
            if key.endswith("_settings_id") or key == "compatible_printers":
                continue
            if not isinstance(value, list):
                errors.append(f'filament key "{key}" must be a list, got {type(value).__name__}')
        else:
            if key == "compatible_printers":
                continue
            if isinstance(value, (int, float, bool)):
                errors.append(f'process key "{key}" must be a string, got {type(value).__name__}')

    # 7. The .info sidecar carries sync metadata; base_id points at the parent.
    info = path.with_suffix(".info")
    if not info.exists():
        errors.append("missing .info sidecar")
    else:
        fields = {}
        for line in info.read_text().splitlines():
            if "=" in line:
                k, _, v = line.partition("=")
                fields[k.strip()] = v.strip()
        expected = table.get(inherits) if inherits else None
        base_id = fields.get("base_id") or None
        if expected and base_id != expected:
            warnings.append(f'.info base_id is {base_id!r}, parent {inherits!r} has '
                            f'setting_id {expected!r}')
        if not fields.get("updated_time"):
            warnings.append(".info has no updated_time")

    return errors, warnings


status = 0
for problem in load_problems:
    print(f"WARN  (environment) {problem}")
for arg in sys.argv[1:]:
    path = Path(arg)
    errors, warnings = check(path)
    if errors:
        status = 1
        print(f"FAIL  {path.name}")
        for e in errors:
            print(f"        ERROR   {e}")
    elif warnings:
        print(f"WARN  {path.name}")
    else:
        print(f"OK    {path.name}")
    for w in warnings:
        print(f"        WARN    {w}")
sys.exit(status)
