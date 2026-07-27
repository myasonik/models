#!/usr/bin/env bash

# Archive a model: move it under ARCHIVE/, fix its include depth, and delete
# artifacts that can be regenerated from the .scad sources.
#
# Regenerable = renders (.png) and exports (.stl) that some .scad in the folder
# can rebuild. An .stl or .png that a .scad *imports* is an input, not an
# output -- it is kept, because nothing in the repo can recreate it.
#
# Cross-platform: macOS, Linux, Windows (Git Bash / MSYS2)

set -uo pipefail

DRY_RUN=0
MODEL_NAME=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=1; shift ;;
        -h|--help) MODEL_NAME=""; break ;;
        -*) echo "Error: unknown option '$1'" >&2; exit 1 ;;
        *)  MODEL_NAME="$1"; shift ;;
    esac
done

if [[ -z "$MODEL_NAME" ]]; then
    cat <<'EOF'
Usage: archive-model.sh <model-name> [--dry-run]

Moves <model-name>/ to ARCHIVE/<model-name>/ and deletes the files that can be
regenerated from source: renders (.png) and exports (.stl).

Kept:
  .scad sources, SPEC.md, HISTORY.md, and any .stl/.png that a .scad in the
  folder import()s or surface()s. Those are flagged for review -- a kept file
  is either a genuine external input (which belongs in a skill, not here) or a
  self-export that should have been deleted.

Also rewrites relative include/use paths that escape the model folder, adding
one ../ to account for the extra directory level under ARCHIVE/.

If the model is already under ARCHIVE/, only the deletion pass runs.

  --dry-run   Report what would happen; change nothing.
EOF
    exit 1
fi

# Tab completion appends a slash to directory names, so `archive-model.sh foo/`
# is what a user actually types. Strip it before validating.
while [[ "$MODEL_NAME" == */ || "$MODEL_NAME" == *\\ ]]; do
    MODEL_NAME="${MODEL_NAME%[/\\]}"
done

if [[ -z "$MODEL_NAME" || "$MODEL_NAME" == *[/\\]* || "$MODEL_NAME" == .* ]]; then
    echo "Error: model name must be a plain name, not a path: '$MODEL_NAME'" >&2
    exit 1
fi

ARCHIVE_DIR="${ARCHIVE_DIR:-ARCHIVE}"

# ---------------------------------------------------------------- locate model

NEEDS_MOVE=0
if [[ -d "$MODEL_NAME" ]]; then
    if [[ -e "${ARCHIVE_DIR}/${MODEL_NAME}" ]]; then
        echo "Error: both '${MODEL_NAME}/' and '${ARCHIVE_DIR}/${MODEL_NAME}/' exist." >&2
        echo "Resolve the collision by hand; refusing to guess." >&2
        exit 1
    fi
    SRC="$MODEL_NAME"
    DEST="${ARCHIVE_DIR}/${MODEL_NAME}"
    NEEDS_MOVE=1
elif [[ -d "${ARCHIVE_DIR}/${MODEL_NAME}" ]]; then
    SRC="${ARCHIVE_DIR}/${MODEL_NAME}"
    DEST="$SRC"
    echo "Already archived -- running the deletion pass only."
else
    echo "Error: no such model '${MODEL_NAME}' (looked in ./ and ${ARCHIVE_DIR}/)" >&2
    exit 1
fi

echo "========================================"
echo "Archive model: $MODEL_NAME"
echo "========================================"
[[ $DRY_RUN -eq 1 ]] && echo "(dry run -- nothing will change)"
echo ""

# ------------------------------------------------- assets referenced by source
#
# Anything a .scad pulls in by name is a dependency of that .scad. Collect the
# basenames so the deletion pass can skip them.

PROTECTED=""
while IFS= read -r scad; do
    [[ -z "$scad" ]] && continue
    # import("foo.stl"), surface(file = "bar.png"), import(file="baz.stl")
    # Read line by line, never word-split: an imported filename may contain
    # spaces, and splitting it would leave the real file unprotected.
    while IFS= read -r r; do
        [[ -z "$r" ]] && continue
        PROTECTED="${PROTECTED}$(basename "$r")
"
    done < <(grep -oiE '(import|surface)[[:space:]]*\([^)]*"[^"]+"' "$scad" 2>/dev/null \
             | grep -oE '"[^"]+"' | tr -d '"')
done < <(find "$SRC" -type f -name '*.scad' 2>/dev/null)

PROTECTED=$(printf '%s' "$PROTECTED" | grep -v '^$' | sort -u)

if [[ -n "$PROTECTED" ]]; then
    echo "Referenced by .scad sources -- kept, and flagged for review below."
    echo ""
fi

is_protected() {
    [[ -z "$PROTECTED" ]] && return 1
    printf '%s\n' "$PROTECTED" | grep -qxF "$(basename "$1")"
}

# ------------------------------------------------------------------- move step

git_tracked() {
    git ls-files --error-unmatch "$1" >/dev/null 2>&1
}

if [[ $NEEDS_MOVE -eq 1 ]]; then
    echo "Move: ${SRC}/ -> ${DEST}/"
    if [[ $DRY_RUN -eq 0 ]]; then
        mkdir -p "$ARCHIVE_DIR"
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1 && git_tracked "$SRC"; then
            git mv "$SRC" "$DEST" || { echo "Error: git mv failed" >&2; exit 1; }
        else
            mv "$SRC" "$DEST" || { echo "Error: mv failed" >&2; exit 1; }
        fi
    fi

    # One extra directory level means one more ../ on every escaping path.
    # Matches runs of ../ so <../.claude/...> and <../../x> both shift correctly.
    echo "Rewrite: adding one ../ to include/use paths that leave the folder"
    if [[ $DRY_RUN -eq 0 ]]; then
        while IFS= read -r scad; do
            [[ -z "$scad" ]] && continue
            sed -E -i.bak \
                -e 's@(^|[[:space:]])(include|use)([[:space:]]*)<((\.\./)+)@\1\2\3<../\4@g' \
                -e 's@"((\.\./)+)@"../\1@g' \
                "$scad"
            rm -f "${scad}.bak"
        done < <(find "$DEST" -type f -name '*.scad' 2>/dev/null)
    fi
    echo ""
fi

# --------------------------------------------------------------- deletion pass
#
# A dry run never performs the move, so DEST does not exist yet -- scan the
# source instead. Reporting "nothing to delete" because the destination is
# missing would make the safety flag lie in the dangerous direction.
SCAN_DIR="$DEST"
[[ $DRY_RUN -eq 1 ]] && SCAN_DIR="$SRC"

# "Regenerable" means some .scad can rebuild it. With no .scad in the folder,
# nothing can -- the renders and STLs are orphans and deleting them destroys
# the only copy. Refuse rather than quietly emptying the folder.
if ! find "$SCAN_DIR" -type f -name '*.scad' 2>/dev/null | grep -q .; then
    echo "Warning: no .scad sources found in ${SCAN_DIR}/."
    echo "Nothing here can be regenerated, so nothing will be deleted."
    echo "Archive the folder by hand if that is really what you want."
    echo ""
    echo "Location: ${DEST}/"
    exit 0
fi

DELETED=0
BYTES=0
KEPT_REF=0

while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    if is_protected "$f"; then
        KEPT_REF=$((KEPT_REF + 1))
        continue
    fi
    sz=$(wc -c < "$f" 2>/dev/null | tr -d ' ')
    [[ -z "$sz" ]] && sz=0
    BYTES=$((BYTES + sz))
    DELETED=$((DELETED + 1))
    echo "  delete  $f"
    if [[ $DRY_RUN -eq 0 ]]; then
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1 && git_tracked "$f"; then
            git rm -q -f "$f"
        else
            rm -f "$f"
        fi
    fi
done < <(find "$SCAN_DIR" -type f \( -name '*.png' -o -name '*.stl' \) 2>/dev/null | sort)

# Subdirectories that existed only to hold renders (e.g. renders/) are now
# empty. -mindepth 1 keeps the model's own folder: a model whose files were all
# regenerable would otherwise be deleted outright, while the summary below still
# claimed it was archived.
if [[ $DRY_RUN -eq 0 ]]; then
    find "$SCAN_DIR" -mindepth 1 -type d -empty -delete 2>/dev/null
fi

# ----------------------------------------------------------- review kept files
#
# A file kept only because a .scad imports it is one of two things, and the
# script cannot tell them apart:
#
#   1. A genuine external input (vendor mesh, scan, downloaded part). Nothing
#      recreates it -- but it does not belong in ARCHIVE/ either. Move it into
#      a skill and repoint the imports.
#   2. A self-export of one of this model's own sources, kept by accident.
#      Delete it; export-stl rebuilds it.
#
# Both need a human. Name the likely source when there is one.

build_review() {
    [[ -z "$PROTECTED" ]] && return 0
    while IFS= read -r base; do
        [[ -z "$base" ]] && continue
        path=$(find "$SCAN_DIR" -type f -name "$base" 2>/dev/null | head -1)
        # Empty means the import resolves outside the folder -- a skill asset,
        # which is exactly where inputs are supposed to live. Nothing to review.
        [[ -z "$path" ]] && continue
        stem="${base%.*}"
        echo "  $path"
        if [[ -f "${SCAN_DIR}/${stem}.scad" ]]; then
            echo "      -> ${stem}.scad exists: almost certainly a self-export. Delete it."
        else
            cands=$(find "$SCAN_DIR" -maxdepth 1 -name '*.scad' -exec basename {} \; 2>/dev/null \
                    | grep -v '^view_' | tr '\n' ' ')
            echo "      -> no ${stem}.scad. Either an external input, or an export of"
            echo "         one of: ${cands:-(none)}"
            echo "         External input? Move it to a skill and repoint the imports;"
            echo "         inputs do not belong in ${ARCHIVE_DIR}/."
        fi
    done <<< "$PROTECTED"
}

REVIEW=$(build_review)
if [[ -n "$REVIEW" ]]; then
    echo ""
    echo "----------------------------------------"
    echo "REVIEW -- files kept because a .scad imports them:"
    echo ""
    printf '%s\n' "$REVIEW"
fi

echo ""
echo "----------------------------------------"
if [[ $DELETED -eq 0 ]]; then
    echo "Nothing regenerable to delete."
else
    printf 'Deleted %d regenerable file(s), %d KB reclaimed.\n' "$DELETED" "$((BYTES / 1024))"
fi
[[ $KEPT_REF -gt 0 ]] && echo "Kept $KEPT_REF referenced file(s) -- see REVIEW above."
echo "Location: ${DEST}/"
[[ $DRY_RUN -eq 1 ]] && echo "(dry run -- nothing changed)"
exit 0
