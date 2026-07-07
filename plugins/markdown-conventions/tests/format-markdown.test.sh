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

assert_contains() { # description needle haystack
  case "$3" in
    *"$2"*) pass=$((pass + 1)); printf 'ok   - %s\n' "$1" ;;
    *) fail=$((fail + 1)); printf 'FAIL - %s\n       needle:   [%s]\n       haystack: [%s]\n' "$1" "$2" "$3" ;;
  esac
}

assert_not_contains() { # description needle haystack
  case "$3" in
    *"$2"*) fail=$((fail + 1)); printf 'FAIL - %s\n       unexpected needle: [%s]\n       haystack:          [%s]\n' "$1" "$2" "$3" ;;
    *) pass=$((pass + 1)); printf 'ok   - %s\n' "$1" ;;
  esac
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

# Run the hook in dry-run mode and capture STDERR only.
run_hook_stderr() { # project_dir file_path
  proj="$1"; fp="$2"
  payload=$(printf '{"tool_input":{"file_path":"%s"},"cwd":"%s"}' "$fp" "$proj")
  printf '%s' "$payload" | MARKDOWN_CONVENTIONS_DRY_RUN=1 CLAUDE_PROJECT_DIR="$proj" sh "$HOOK" 2>&1 1>/dev/null
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

# A path containing .. that resolves to a real in-project file -> ignored.
# The .. must resolve inside the project so only the traversal guard (not the
# existence or boundary check) can reject it.
proj=$(mktemp -d)
mkdir "$proj/sub"
: > "$proj/notes.md"
out=$(run_hook "$proj" "$proj/sub/../notes.md")
assert_eq "path traversal -> ignored" "" "$out"
rm -rf "$proj"

# A missing file -> ignored.
proj=$(mktemp -d)
: > "$proj/dprint.json"
out=$(run_hook "$proj" "$proj/does-not-exist.md")
assert_eq "missing file -> ignored" "" "$out"
rm -rf "$proj"

# --- guard discrimination via the "guards passed" marker (stderr, dry-run) ---

# A valid markdown file inside the project reaches selection (positive control).
proj=$(mktemp -d)
: > "$proj/notes.md"
err=$(run_hook_stderr "$proj" "$proj/notes.md")
assert_contains "valid markdown reaches selection" "guards passed" "$err"
rm -rf "$proj"

# A non-markdown file is stopped before selection.
proj=$(mktemp -d)
: > "$proj/script.ts"
err=$(run_hook_stderr "$proj" "$proj/script.ts")
assert_not_contains "non-markdown stopped before selection" "guards passed" "$err"
rm -rf "$proj"

# A path outside the project is stopped before selection.
proj=$(mktemp -d); outside=$(mktemp -d)
: > "$outside/x.md"
err=$(run_hook_stderr "$proj" "$outside/x.md")
assert_not_contains "outside path stopped before selection" "guards passed" "$err"
rm -rf "$proj" "$outside"

# A traversal path that resolves to a real in-project file is stopped before
# selection. The .. resolves inside the project, so only the traversal guard
# can reject it -- this genuinely discriminates that guard.
proj=$(mktemp -d)
mkdir "$proj/sub"
: > "$proj/notes.md"
err=$(run_hook_stderr "$proj" "$proj/sub/../notes.md")
assert_not_contains "traversal stopped before selection" "guards passed" "$err"
rm -rf "$proj"

# A missing file is stopped before selection.
proj=$(mktemp -d)
err=$(run_hook_stderr "$proj" "$proj/does-not-exist.md")
assert_not_contains "missing file stopped before selection" "guards passed" "$err"
rm -rf "$proj"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
