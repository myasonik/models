#!/usr/bin/env bash
# UserPromptSubmit hook. If the prompt mentions clear or translucent
# filament, inject a reminder to run the print-audit clarity review.
set -uo pipefail
input="$(cat)"
if command -v jq >/dev/null 2>&1; then
    prompt="$(printf '%s' "$input" | jq -r '.prompt // empty' 2>/dev/null)"
else
    prompt="$input"
fi
if printf '%s' "$prompt" | grep -qiE '\b(clear|transparent|translucent|see-through|natural)\b.{0,40}\b(petg|pla|filament|print|pot|part|model)\b|\b(petg|pla|filament)\b.{0,20}\b(clear|transparent|translucent)\b'; then
    cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"The user mentioned clear or translucent filament. Run the print-audit skill's section D (clarity review) on the model before any other audit or export: wall-thickness.py by height, constant wall = whole number of line widths, no infill or gap fill inside walls, report the transition heights."}}
JSON
fi
exit 0
