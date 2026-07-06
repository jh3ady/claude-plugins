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

# Task 4 inserts the formatter detection block here.

# Nothing configured (or configured but not installed) -> no-op.
finish
