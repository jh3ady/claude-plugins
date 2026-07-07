#!/bin/sh
# markdown-conventions: reformat a markdown file Claude just edited, using the
# formatter the project already configures. No configured formatter -> no-op.
# Advisory only: never blocks, always exits 0.
set -u

log() { printf 'markdown-conventions: %s\n' "$1" >&2; }
finish() { exit 0; }

# Need jq to read the PostToolUse payload; degrade to no-op without it.
command -v jq >/dev/null 2>&1 || { log "jq not found, skipping"; finish; }

# Read the payload from stdin and pull the edited path.
input="$(cat)"
file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
[ -n "$file_path" ] || finish

# Only markdown files.
case "$file_path" in
  *.md|*.markdown) ;;
  *) finish ;;
esac

# Reject path traversal outright.
case "$file_path" in
  *..*) finish ;;
esac

# Resolve the project root and the file's absolute path.
project_dir="${CLAUDE_PROJECT_DIR:-$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)}"
[ -n "$project_dir" ] || project_dir="$PWD"
project_dir="${project_dir%/}"

case "$file_path" in
  /*) abs_path="$file_path" ;;
  *)  abs_path="$project_dir/$file_path" ;;
esac

# The file must exist and live inside the project directory.
[ -f "$abs_path" ] || finish
case "$abs_path" in
  "$project_dir"/*) ;;
  *) finish ;;
esac

DRY_RUN="${MARKDOWN_CONVENTIONS_DRY_RUN:-0}"

# run: execute (or, in dry-run, announce) the chosen formatter, then stop.
run() { # label command [args...]
  label="$1"; shift
  if [ "$DRY_RUN" = "1" ]; then
    printf '%s %s\n' "$label" "$abs_path"
    finish
  fi
  log "running $label on $abs_path"
  "$@" >/dev/null 2>&1 || log "$label exited non-zero, ignored"
  finish
}

# Signal (dry-run only) that all guards passed and selection is reached.
[ "$DRY_RUN" = "1" ] && printf 'markdown-conventions: guards passed\n' >&2

# Pick and run the first configured-and-resolvable formatter, in fixed order:
# dprint, then Prettier, then markdownlint-cli2.

# --- dprint ---
if [ -f "$project_dir/dprint.json" ] || [ -f "$project_dir/.dprint.json" ] \
   || [ -f "$project_dir/dprint.jsonc" ] || [ -f "$project_dir/.dprint.jsonc" ]; then
  if command -v dprint >/dev/null 2>&1; then
    run dprint dprint fmt "$abs_path"
  fi
fi

# --- Prettier ---
prettier_configured=0
for f in .prettierrc .prettierrc.json .prettierrc.jsonc .prettierrc.yml .prettierrc.yaml \
         .prettierrc.json5 .prettierrc.js .prettierrc.cjs .prettierrc.mjs .prettierrc.toml \
         prettier.config.js prettier.config.cjs prettier.config.mjs; do
  if [ -f "$project_dir/$f" ]; then prettier_configured=1; break; fi
done
if [ "$prettier_configured" = "0" ] && [ -f "$project_dir/package.json" ]; then
  if jq -e '(.prettier != null) or (.devDependencies.prettier != null) or (.dependencies.prettier != null)' \
       "$project_dir/package.json" >/dev/null 2>&1; then
    prettier_configured=1
  fi
fi
if [ "$prettier_configured" = "1" ]; then
  if [ -x "$project_dir/node_modules/.bin/prettier" ]; then
    run prettier "$project_dir/node_modules/.bin/prettier" --write "$abs_path"
  elif command -v prettier >/dev/null 2>&1; then
    run prettier prettier --write "$abs_path"
  fi
fi

# --- markdownlint-cli2 ---
mdl_configured=0
for f in .markdownlint-cli2.jsonc .markdownlint-cli2.yaml .markdownlint-cli2.cjs .markdownlint-cli2.mjs \
         .markdownlint.json .markdownlint.jsonc .markdownlint.yaml .markdownlint.yml .markdownlint.cjs; do
  if [ -f "$project_dir/$f" ]; then mdl_configured=1; break; fi
done
if [ "$mdl_configured" = "0" ] && [ -f "$project_dir/package.json" ]; then
  if jq -e '(.devDependencies["markdownlint-cli2"] != null) or (.dependencies["markdownlint-cli2"] != null)' \
       "$project_dir/package.json" >/dev/null 2>&1; then
    mdl_configured=1
  fi
fi
if [ "$mdl_configured" = "1" ]; then
  if [ -x "$project_dir/node_modules/.bin/markdownlint-cli2" ]; then
    run markdownlint-cli2 "$project_dir/node_modules/.bin/markdownlint-cli2" --fix "$abs_path"
  elif command -v markdownlint-cli2 >/dev/null 2>&1; then
    run markdownlint-cli2 markdownlint-cli2 --fix "$abs_path"
  fi
fi

# Nothing configured (or configured but not installed) -> no-op.
finish
