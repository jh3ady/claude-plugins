#!/bin/sh
# Tests for hooks/format-markdown.sh.
# Run: sh plugins/markdown-conventions/tests/format-markdown.test.sh
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
HOOK="$HERE/../hooks/format-markdown.sh"

pass=0
fail=0

assert_eq() { # description expected actual
  if [ "$2" = "$3" ]; then
    pass=$((pass + 1))
    printf 'ok   - %s\n' "$1"
  else
    fail=$((fail + 1))
    printf 'FAIL - %s\n       expected: [%s]\n       actual:   [%s]\n' "$1" "$2" "$3"
  fi
}

# Run the hook in dry-run mode. Args: <project_dir> <file_path> [extra PATH dir]
run_hook() { # project_dir file_path path_prepend
  proj="$1"; fp="$2"; extra_path="${3:-}"
  payload=$(printf '{"tool_input":{"file_path":"%s"},"cwd":"%s"}' "$fp" "$proj")
  if [ -n "$extra_path" ]; then
    printf '%s' "$payload" | MARKDOWN_CONVENTIONS_DRY_RUN=1 CLAUDE_PROJECT_DIR="$proj" PATH="$extra_path:$PATH" sh "$HOOK" 2>/dev/null
  else
    printf '%s' "$payload" | MARKDOWN_CONVENTIONS_DRY_RUN=1 CLAUDE_PROJECT_DIR="$proj" sh "$HOOK" 2>/dev/null
  fi
}

# --- guard tests ---

# A markdown file in a project with no formatter configured -> no output.
proj=$(mktemp -d)
: > "$proj/notes.md"
out=$(run_hook "$proj" "$proj/notes.md")
assert_eq "no formatter configured -> no-op" "" "$out"
rm -rf "$proj"

# A non-markdown file -> ignored even if a formatter is configured.
proj=$(mktemp -d)
: > "$proj/dprint.json"
: > "$proj/script.ts"
out=$(run_hook "$proj" "$proj/script.ts")
assert_eq "non-markdown file -> ignored" "" "$out"
rm -rf "$proj"

# A path outside the project directory -> ignored.
proj=$(mktemp -d)
outside=$(mktemp -d)
: > "$proj/dprint.json"
: > "$outside/x.md"
out=$(run_hook "$proj" "$outside/x.md")
assert_eq "path outside project -> ignored" "" "$out"
rm -rf "$proj" "$outside"

# A path containing .. -> ignored.
proj=$(mktemp -d)
: > "$proj/dprint.json"
: > "$proj/x.md"
out=$(run_hook "$proj" "$proj/../x.md")
assert_eq "path traversal -> ignored" "" "$out"
rm -rf "$proj"

# A missing file -> ignored.
proj=$(mktemp -d)
: > "$proj/dprint.json"
out=$(run_hook "$proj" "$proj/does-not-exist.md")
assert_eq "missing file -> ignored" "" "$out"
rm -rf "$proj"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
