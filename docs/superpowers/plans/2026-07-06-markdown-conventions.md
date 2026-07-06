# Markdown conventions plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a public `markdown-conventions` plugin that pairs a composable markdown-formatting skill with a gated `PostToolUse` hook running the project's already-configured formatter.

**Architecture:** One plugin in the `jh3ady-claude-plugins` marketplace, in the `commit-conventions` family. A knowledge skill (`SKILL.md` + `references/`) governs how Claude writes markdown and defers to the project's configuration. A command hook (`hooks/format-markdown.sh`, wired through `hooks/hooks.json`) reformats each `.md`/`.markdown` file Claude edits, but only with a formatter the project already configures and installs; otherwise it is a silent no-op. The hook is advisory and always exits 0.

**Tech Stack:** Claude Code plugin manifest and hooks, POSIX `sh`, `jq` for hook input parsing, the project's own `dprint` / Prettier / `markdownlint-cli2` (never bundled). Authored through the `plugin-dev` skills.

## Global Constraints

Copied verbatim from the spec; every task's requirements implicitly include these.

- License: MIT. Version: `0.1.0`. Public repository `claude-plugins`.
- Family shape: lean `SKILL.md` carrying the decision procedure, depth pushed into `references/`, adjacent concepts cross-referenced rather than absorbed, framed as "a baseline standard, not an opinionated ruleset".
- Writing conventions: English; no em-dashes; no unjustified abbreviations; words in full (for example "configuration", "repository", "December"); standard acronyms are fine.
- Authoring method (spec-pinned): drive the build through `plugin-dev:plugin-structure` (layout and manifest), `plugin-dev:skill-development` (skill), `plugin-dev:hook-development` (hook); review with the `plugin-dev:skill-reviewer` agent and the `plugin-dev:plugin-validator` agent.
- Hook is advisory plumbing: never blocks, never fails the workflow, always exits 0. Any formatter error, missing dependency, or unexpected condition degrades to a discreet stderr log and exit 0.
- The plugin never installs or bundles a formatter; it only invokes one the project already provides (configured AND resolvable).
- Defer to the project's configuration everywhere: `.prettierrc*` (or a `prettier` key in `package.json`), `dprint.json`, `.markdownlint*` / `.markdownlint-cli2*`, `.editorconfig`.
- Formatter precedence when several are configured: a single one runs, in fixed order dprint, then Prettier, then markdownlint-cli2.
- Hook runtime parses stdin with `jq`; absent `jq` degrades to a clean no-op.
- The hook reformats only the single edited file, never the repository, and only paths inside the project working directory.
- Commit messages: gitmoji + Conventional Commits. No Claude attribution anywhere.

---

## File Structure

- `plugins/markdown-conventions/.claude-plugin/plugin.json` — plugin manifest (name, version, description, author, license, homepage, keywords).
- `plugins/markdown-conventions/LICENSE` — MIT, copied from a sibling plugin.
- `plugins/markdown-conventions/README.md` — user-facing description in the family voice.
- `plugins/markdown-conventions/skills/markdown-conventions/SKILL.md` — the skill's decision procedure.
- `plugins/markdown-conventions/skills/markdown-conventions/references/conventions.md` — rule-by-rule detail, markdownlint rule mapping, before/after examples.
- `plugins/markdown-conventions/hooks/hooks.json` — registers the `PostToolUse` command hook.
- `plugins/markdown-conventions/hooks/format-markdown.sh` — filter, detect, invoke, no-op.
- `plugins/markdown-conventions/tests/format-markdown.test.sh` — POSIX shell tests for the hook script.
- `.claude-plugin/marketplace.json` — add the `markdown-conventions` entry.

Shared description string, used identically in `plugin.json` and `marketplace.json`:

> Markdown formatting conventions applied pragmatically, deferring to the project: a composable baseline (CommonMark, the markdownlint rule set, Prettier defaults) for how Claude writes markdown, plus a PostToolUse hook that reformats each edited file with the formatter the project already configures (dprint, Prettier, or markdownlint-cli2) and stays inert when none is set. Composable with your own conventions.

---

### Task 1: Plugin package shell and marketplace registration

**Files:**
- Create: `plugins/markdown-conventions/.claude-plugin/plugin.json`
- Create: `plugins/markdown-conventions/LICENSE`
- Create: `plugins/markdown-conventions/README.md`
- Modify: `.claude-plugin/marketplace.json` (append one array element)

**Interfaces:**
- Produces: a registered plugin named `markdown-conventions` at source `./plugins/markdown-conventions`, discoverable in the marketplace. Later tasks add `skills/` and `hooks/` under this directory.

- [ ] **Step 1: Read the plugin-structure guidance**

Invoke `plugin-dev:plugin-structure` and skim it to confirm the manifest shape (required `name`, plus `version`, `description`, `author`, `license`, `homepage`, `keywords`) matches what follows.

- [ ] **Step 2: Create the manifest**

Create `plugins/markdown-conventions/.claude-plugin/plugin.json`:

```json
{
  "name": "markdown-conventions",
  "version": "0.1.0",
  "description": "Markdown formatting conventions applied pragmatically, deferring to the project: a composable baseline (CommonMark, the markdownlint rule set, Prettier defaults) for how Claude writes markdown, plus a PostToolUse hook that reformats each edited file with the formatter the project already configures (dprint, Prettier, or markdownlint-cli2) and stays inert when none is set. Composable with your own conventions.",
  "author": {
    "name": "Jean-Denis VIDOT",
    "url": "https://github.com/jh3ady"
  },
  "license": "MIT",
  "homepage": "https://github.com/jh3ady/claude-plugins/tree/main/plugins/markdown-conventions",
  "keywords": [
    "markdown",
    "formatting",
    "prettier",
    "markdownlint",
    "dprint",
    "conventions"
  ]
}
```

- [ ] **Step 3: Add the MIT license**

Copy an existing plugin's license verbatim (identical MIT text and holder across the marketplace):

```bash
cp plugins/commit-conventions/LICENSE plugins/markdown-conventions/LICENSE
```

- [ ] **Step 4: Write the README**

Create `plugins/markdown-conventions/README.md`:

```markdown
# markdown-conventions

A Claude Code plugin for markdown formatting. It has two parts that work
together and impose nothing the project did not choose:

- A skill that shapes how Claude writes markdown, deferring to the project's
  own formatter configuration when one exists.
- A `PostToolUse` hook that reformats each markdown file Claude edits with the
  formatter the project already configures (dprint, Prettier, or
  markdownlint-cli2), and stays inert when the project configures none.

## What it does

When Claude writes or edits a `.md` or `.markdown` file, the skill applies a
composable baseline of formatting conventions (CommonMark, the markdownlint
rule set, and Prettier defaults), always yielding to the project's
configuration. Immediately after the edit, the hook runs the project's
configured formatter on that single file so the result is byte-exact.

The hook only reaches Claude's own edits, not edits made by hand in an editor.
It never blocks, never fails a workflow, and never installs a formatter: with
no formatter configured in the project, it does nothing.

## Configuration

Add a formatter to your project to make the enforcement deterministic:

- dprint: a `dprint.json` with a markdown plugin.
- Prettier: a `.prettierrc*` file or a `prettier` key in `package.json`.
- markdownlint-cli2: a `.markdownlint*` or `.markdownlint-cli2*` file.

If several are configured, one runs, in the order dprint, then Prettier, then
markdownlint-cli2. The hook parses its input with `jq`; without `jq` it is a
clean no-op.

## Composability

It stays generic on purpose: compose it with your own conventions (prose style,
line width, heading case) in your own `CLAUDE.md` or a higher-priority skill.
```

- [ ] **Step 5: Register the plugin in the marketplace**

Edit `.claude-plugin/marketplace.json`. The `plugins` array currently ends with the `secure-coding` object. Add a comma after that object's closing brace and append this element as the new last item:

```json
    {
      "name": "markdown-conventions",
      "source": "./plugins/markdown-conventions",
      "description": "Markdown formatting conventions applied pragmatically, deferring to the project: a composable baseline (CommonMark, the markdownlint rule set, Prettier defaults) for how Claude writes markdown, plus a PostToolUse hook that reformats each edited file with the formatter the project already configures (dprint, Prettier, or markdownlint-cli2) and stays inert when none is set. Composable with your own conventions.",
      "version": "0.1.0"
    }
```

- [ ] **Step 6: Verify both JSON files parse and the entry is registered**

Run:
```bash
jq . plugins/markdown-conventions/.claude-plugin/plugin.json >/dev/null && echo "plugin.json OK"
jq -e '.plugins[] | select(.name == "markdown-conventions") | .source == "./plugins/markdown-conventions"' .claude-plugin/marketplace.json && echo "registered OK"
```
Expected: `plugin.json OK`, then `true` and `registered OK`.

- [ ] **Step 7: Commit**

```bash
git add plugins/markdown-conventions/.claude-plugin/plugin.json plugins/markdown-conventions/LICENSE plugins/markdown-conventions/README.md .claude-plugin/marketplace.json
git commit -m "✨ feat(markdown-conventions): scaffold plugin package and register it"
```

---

### Task 2: The markdown conventions skill

**Files:**
- Create: `plugins/markdown-conventions/skills/markdown-conventions/SKILL.md`
- Create: `plugins/markdown-conventions/skills/markdown-conventions/references/conventions.md`

**Interfaces:**
- Consumes: the plugin directory from Task 1.
- Produces: a skill named `markdown-conventions` whose `SKILL.md` frontmatter carries `name` and `description`, with detail in `references/conventions.md`.

- [ ] **Step 1: Read the skill-development guidance**

Invoke `plugin-dev:skill-development` and confirm the anatomy (required `SKILL.md` with `name` + `description` frontmatter, optional `references/`), the progressive-disclosure principle (lean `SKILL.md`, depth in references, no duplication between them), and the third-person description style ("This skill should be used when...").

- [ ] **Step 2: Write SKILL.md**

Create `plugins/markdown-conventions/skills/markdown-conventions/SKILL.md`:

```markdown
---
name: markdown-conventions
description: This skill should be used whenever writing or editing markdown (documentation, READMEs, specifications, changelogs, or markdown-formatted comments), even when conventions are not explicitly mentioned, applying a composable baseline of markdown formatting conventions (CommonMark, the markdownlint rule set, and Prettier defaults) and deferring to the project's own formatter configuration when present.
---

# Markdown conventions

A reusable standard for how markdown is formatted. Apply it by default. This
skill is the baseline standard, not an opinionated ruleset: compose it with
your own context (see "Adapt to your context" below).

## Defer to the project first

Before applying any default below, look for the project's own configuration and
follow it when it exists:

- A formatter configuration: `.prettierrc*` (or a `prettier` key in
  `package.json`), `dprint.json`, or `.markdownlint*` / `.markdownlint-cli2*`.
- An `.editorconfig` (indentation, final newline, trailing whitespace).

The project's configuration always wins over the defaults here. These
conventions only fill the gaps the project leaves unspecified.

## Default profile (when the project specifies nothing)

- Headings: ATX style (`#`), one space after the hashes, one blank line before
  and after. A single top-level heading per document.
- Blank lines: exactly one between block elements; none at the top of the file;
  a single trailing newline at the end.
- Lists: one consistent unordered marker throughout a document (`-` by
  default); ordered lists numbered `1.`, `2.`, `3.`; nested items indented by
  two spaces.
- Code: fenced blocks with a language tag, never indented code blocks; inline
  code in backticks.
- Emphasis: consistent markers (`**bold**`, `_italic_`); never emphasis in
  place of a heading.
- Whitespace: no trailing spaces (except a deliberate hard break); spaces, not
  tabs, for indentation.
- Line wrapping: do not hard-wrap prose by default; let it reflow. If the
  project sets a print width, follow it.
- Tables: pipe tables with a header separator row; column alignment optional.
- Links: prefer inline links; use reference links when the same target repeats.

For the rule-by-rule detail, the mapping to markdownlint rule numbers, and
before and after examples, read `references/conventions.md`.

## Enforcement hook

This plugin also ships a `PostToolUse` hook. After Claude edits a `.md` or
`.markdown` file, the hook runs the formatter the project already configures
(dprint, Prettier, or markdownlint-cli2, in that order) on that single file. It
does nothing when the project configures no formatter, so it never imposes a
style the project did not choose. The hook only reaches Claude's own edits, not
edits made by hand in an editor; this skill governs the rest.

## Adapt to your context

This skill stays generic on purpose. Layer your own conventions on top:

- Add a formatter configuration to your project to make the enforcement
  deterministic.
- Add team or personal rules (prose style, line width, heading case) in your
  own `CLAUDE.md` or a higher-priority skill. This skill does not impose them.
```

- [ ] **Step 3: Write references/conventions.md**

Create `plugins/markdown-conventions/skills/markdown-conventions/references/conventions.md`:

```markdown
# Markdown conventions: detail and examples

This reference expands the default profile in `SKILL.md`. It applies only where
the project's own configuration is silent; the project's configuration always
wins.

## Grounding

- CommonMark is the parsing baseline: prefer constructs that render
  unambiguously under CommonMark.
- The markdownlint rule set (rules `MD001` to `MD059`) is the recognised style
  vocabulary. The mapping below names the relevant rules so a project using
  markdownlint sees the same intent.
- Prettier's markdown defaults are the reflow reference for spacing, list
  markers, and emphasis.

## Rule-by-rule, with markdownlint mapping

### Headings

- ATX style, `#` followed by a single space (`MD018`, `MD019`, `MD023`).
- One blank line before and after a heading (`MD022`).
- A single top-level heading per document, and no skipped levels (`MD025`,
  `MD001`).
- No trailing punctuation such as a colon in a heading (`MD026`).

Before:
```
##Title
Text immediately after.
```
After:
```
## Title

Text immediately after.
```

### Lists

- One consistent unordered marker per document, `-` by default (`MD004`).
- Ordered lists numbered `1.`, `2.`, `3.` (`MD029`).
- Nested items indented by two spaces (`MD007`).
- One space after the marker (`MD030`).

Before:
```
* First
+ Second
    - Nested
```
After:
```
- First
- Second
  - Nested
```

### Code

- Fenced code blocks with a language tag, not indented blocks (`MD046`,
  `MD040`).
- A blank line before and after a fenced block (`MD031`).

Before:
```
    const x = 1
```
After:
````
```ts
const x = 1
```
````

### Emphasis and whitespace

- Consistent emphasis markers (`MD049`, `MD050`).
- No trailing spaces, except a deliberate two-space hard break (`MD009`).
- No hard tabs for indentation (`MD010`).
- A single final newline (`MD047`).

### Line wrapping

- Do not hard-wrap prose by default (leave `MD013` line length off unless the
  project enables it). If the project sets a print width or line-length rule,
  follow it exactly.

### Tables

- Pipe tables with a header separator row. Column alignment is optional; keep it
  consistent within a table.

Before:
```
Name|Role
Ada|Engineer
```
After:
```
| Name | Role     |
| ---- | -------- |
| Ada  | Engineer |
```

### Links

- Prefer inline links. Use reference-style links when the same target is
  repeated, to keep the prose readable.

## Relationship to sibling plugins

- Commit message bodies are markdown-adjacent but owned by `commit-conventions`.
- Pull and merge request review comments are owned by `review-conventions`.

This skill does not restate those; it formats the markdown, they own the
wording.
```

- [ ] **Step 4: Verify the skill frontmatter and references file**

Run:
```bash
head -4 plugins/markdown-conventions/skills/markdown-conventions/SKILL.md | grep -q '^name: markdown-conventions' && echo "name OK"
grep -q '^description: This skill should be used' plugins/markdown-conventions/skills/markdown-conventions/SKILL.md && echo "description OK"
test -f plugins/markdown-conventions/skills/markdown-conventions/references/conventions.md && echo "references OK"
```
Expected: `name OK`, `description OK`, `references OK`.

- [ ] **Step 5: Review the skill with the skill-reviewer agent**

Dispatch the `plugin-dev:skill-reviewer` agent on `plugins/markdown-conventions/skills/markdown-conventions/`. Apply any trigger-quality or description improvements it raises that do not contradict the Global Constraints. Re-run Step 4 if you edit the frontmatter.

- [ ] **Step 6: Commit**

```bash
git add plugins/markdown-conventions/skills
git commit -m "✨ feat(markdown-conventions): add the markdown conventions skill"
```

---

### Task 3: Hook script guards (filtering and no-op)

Build the hook script's front half first: read input, filter by extension and project boundary, and no-op safely. Detection and formatter invocation come in Task 4. This task is TDD: the test harness is written first and must fail before the script exists.

**Files:**
- Create: `plugins/markdown-conventions/tests/format-markdown.test.sh`
- Create: `plugins/markdown-conventions/hooks/format-markdown.sh`

**Interfaces:**
- Produces: `hooks/format-markdown.sh`, a POSIX `sh` script that reads a `PostToolUse` JSON payload from stdin, honours `CLAUDE_PROJECT_DIR` and `MARKDOWN_CONVENTIONS_DRY_RUN`, and always exits 0. In dry-run mode it prints one line `"<formatter> <absolute-path>"` when it would format, and prints nothing when it no-ops. Task 4 extends the same file with the detection block; Task 5 wires it through `hooks.json`.

- [ ] **Step 1: Read the hook-development guidance**

Invoke `plugin-dev:hook-development` and confirm: plugin hooks live in `hooks/hooks.json` (wrapper format), `PostToolUse` receives `tool_input.file_path` on stdin, `${CLAUDE_PLUGIN_ROOT}` gives a portable path, exit 0 means success, and command hooks default to a 60 second timeout. Note the guidance to quote every variable.

- [ ] **Step 2: Write the failing test harness (guards only)**

Create `plugins/markdown-conventions/tests/format-markdown.test.sh`:

```sh
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
```

- [ ] **Step 3: Run the tests to verify they fail**

Run: `sh plugins/markdown-conventions/tests/format-markdown.test.sh`
Expected: FAIL (the hook script does not exist yet, so `sh "$HOOK"` errors and assertions do not all pass). The final line reports at least one failure and the script exits non-zero.

- [ ] **Step 4: Write the guard half of the hook script**

Create `plugins/markdown-conventions/hooks/format-markdown.sh`:

```sh
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
```

- [ ] **Step 5: Run the tests to verify the guards pass**

Run: `sh plugins/markdown-conventions/tests/format-markdown.test.sh`
Expected: all five guard assertions print `ok`, final line `5 passed, 0 failed`, exit status 0.

- [ ] **Step 6: Commit**

```bash
git add plugins/markdown-conventions/hooks/format-markdown.sh plugins/markdown-conventions/tests/format-markdown.test.sh
git commit -m "✨ feat(markdown-conventions): add hook input guards and no-op behaviour"
```

---

### Task 4: Formatter detection and precedence

Extend the hook script with detection of a configured-and-resolvable formatter and the fixed precedence dprint, then Prettier, then markdownlint-cli2. Tests use stub executables on `PATH` so precedence is verified without installing real formatters.

**Files:**
- Modify: `plugins/markdown-conventions/hooks/format-markdown.sh` (replace the Task 4 placeholder comment with the detection block)
- Modify: `plugins/markdown-conventions/tests/format-markdown.test.sh` (append detection tests)

**Interfaces:**
- Consumes: the `run` helper, `abs_path`, and `project_dir` from Task 3.
- Produces: dry-run output `"dprint <path>"`, `"prettier <path>"`, or `"markdownlint-cli2 <path>"` according to configuration and precedence; empty output when a formatter is configured but not resolvable.

- [ ] **Step 1: Add a stub-executable helper and the failing detection tests**

In `plugins/markdown-conventions/tests/format-markdown.test.sh`, add this helper just after the `run_hook` function:

```sh
# Create a directory holding no-op stub executables for the named tools.
make_stubs() { # tool [tool...]  -> prints the bin dir
  bin=$(mktemp -d)
  for t in "$@"; do
    printf '#!/bin/sh\nexit 0\n' > "$bin/$t"
    chmod +x "$bin/$t"
  done
  printf '%s' "$bin"
}
```

Then add these assertions just before the final `printf '\n%d passed...` line:

```sh
# --- detection and precedence tests ---

# Prettier configured via .prettierrc and installed -> prettier runs.
proj=$(mktemp -d); bin=$(make_stubs prettier)
: > "$proj/.prettierrc"; : > "$proj/doc.md"
out=$(run_hook "$proj" "$proj/doc.md" "$bin")
assert_eq "prettier config + binary -> prettier" "prettier $proj/doc.md" "$out"
rm -rf "$proj" "$bin"

# Prettier configured via a package.json prettier key -> prettier runs.
proj=$(mktemp -d); bin=$(make_stubs prettier)
printf '{"prettier":{}}\n' > "$proj/package.json"; : > "$proj/doc.md"
out=$(run_hook "$proj" "$proj/doc.md" "$bin")
assert_eq "package.json prettier key -> prettier" "prettier $proj/doc.md" "$out"
rm -rf "$proj" "$bin"

# dprint configured and installed -> dprint runs.
proj=$(mktemp -d); bin=$(make_stubs dprint)
: > "$proj/dprint.json"; : > "$proj/doc.md"
out=$(run_hook "$proj" "$proj/doc.md" "$bin")
assert_eq "dprint config + binary -> dprint" "dprint $proj/doc.md" "$out"
rm -rf "$proj" "$bin"

# markdownlint-cli2 configured and installed -> markdownlint-cli2 runs.
proj=$(mktemp -d); bin=$(make_stubs markdownlint-cli2)
: > "$proj/.markdownlint.json"; : > "$proj/doc.md"
out=$(run_hook "$proj" "$proj/doc.md" "$bin")
assert_eq "markdownlint config + binary -> markdownlint-cli2" "markdownlint-cli2 $proj/doc.md" "$out"
rm -rf "$proj" "$bin"

# All three configured and installed -> precedence picks dprint.
proj=$(mktemp -d); bin=$(make_stubs dprint prettier markdownlint-cli2)
: > "$proj/dprint.json"; : > "$proj/.prettierrc"; : > "$proj/.markdownlint.json"; : > "$proj/doc.md"
out=$(run_hook "$proj" "$proj/doc.md" "$bin")
assert_eq "all configured -> dprint wins" "dprint $proj/doc.md" "$out"
rm -rf "$proj" "$bin"

# Prettier and markdownlint configured -> precedence picks prettier.
proj=$(mktemp -d); bin=$(make_stubs prettier markdownlint-cli2)
: > "$proj/.prettierrc"; : > "$proj/.markdownlint.json"; : > "$proj/doc.md"
out=$(run_hook "$proj" "$proj/doc.md" "$bin")
assert_eq "prettier + markdownlint -> prettier wins" "prettier $proj/doc.md" "$out"
rm -rf "$proj" "$bin"

# Configured but NOT installed (no stub on PATH) -> no-op.
proj=$(mktemp -d)
: > "$proj/.prettierrc"; : > "$proj/doc.md"
out=$(run_hook "$proj" "$proj/doc.md")
assert_eq "configured but not installed -> no-op" "" "$out"
rm -rf "$proj"
```

- [ ] **Step 2: Run the tests to verify the new detection tests fail**

Run: `sh plugins/markdown-conventions/tests/format-markdown.test.sh`
Expected: the five guard tests still pass; the seven new detection assertions FAIL (the script has no detection block yet, so it no-ops and prints nothing). Final line reports 5 passed, 7 failed and a non-zero exit.

- [ ] **Step 3: Insert the detection block into the hook script**

In `plugins/markdown-conventions/hooks/format-markdown.sh`, replace the line:

```sh
# Task 4 inserts the formatter detection block here.
```

with:

```sh
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
```

- [ ] **Step 4: Run the full test suite to verify everything passes**

Run: `sh plugins/markdown-conventions/tests/format-markdown.test.sh`
Expected: all assertions print `ok`, final line `12 passed, 0 failed`, exit status 0.

- [ ] **Step 5: Commit**

```bash
git add plugins/markdown-conventions/hooks/format-markdown.sh plugins/markdown-conventions/tests/format-markdown.test.sh
git commit -m "✨ feat(markdown-conventions): detect the project formatter and apply precedence"
```

---

### Task 5: Wire the hook and validate the plugin

Register the hook through `hooks/hooks.json`, prove the real (non-dry-run) invocation path with a recording stub, and run the plugin validator.

**Files:**
- Create: `plugins/markdown-conventions/hooks/hooks.json`
- Modify: `plugins/markdown-conventions/tests/format-markdown.test.sh` (append one real-invocation test)

**Interfaces:**
- Consumes: `hooks/format-markdown.sh` from Tasks 3 and 4.
- Produces: a `PostToolUse` hook, matcher `Write|Edit|MultiEdit`, invoking the script via `${CLAUDE_PLUGIN_ROOT}`.

- [ ] **Step 1: Write hooks.json**

Create `plugins/markdown-conventions/hooks/hooks.json`:

```json
{
  "description": "After Claude edits a markdown file, reformat it with the formatter the project already configures (dprint, Prettier, or markdownlint-cli2). No configured formatter means no action.",
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "sh \"${CLAUDE_PLUGIN_ROOT}/hooks/format-markdown.sh\"",
            "timeout": 15
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 2: Add a failing real-invocation test**

The dry-run tests never execute a formatter. Add one test that runs the script for real against a recording stub, to prove the invocation wiring (not just the dry-run announcement). In `plugins/markdown-conventions/tests/format-markdown.test.sh`, add just before the final `printf '\n%d passed...` line:

```sh
# --- real invocation (no dry-run) ---

# With DRY_RUN off, the chosen formatter is actually executed on the file.
proj=$(mktemp -d)
bin=$(mktemp -d)
marker="$proj/formatted.marker"
# A prettier stub that records the file path it was asked to format.
printf '#!/bin/sh\necho "$3" > "%s"\n' "$marker" > "$bin/prettier"
chmod +x "$bin/prettier"
: > "$proj/.prettierrc"
: > "$proj/doc.md"
payload=$(printf '{"tool_input":{"file_path":"%s"},"cwd":"%s"}' "$proj/doc.md" "$proj")
printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$proj" PATH="$bin:$PATH" sh "$HOOK" 2>/dev/null
recorded=$(cat "$marker" 2>/dev/null || printf 'MISSING')
assert_eq "real invocation runs prettier --write on the file" "$proj/doc.md" "$recorded"
rm -rf "$proj" "$bin"
```

Note: the stub echoes `$3`, which is the third argument of `prettier --write <path>` (`--write` is `$1`, the path is `$2`)... verify by counting: the script calls `run prettier prettier --write "$abs_path"`, so inside the stub `$1=--write`, `$2=<abs_path>`. Use `$2`, not `$3`. Write the stub as:

```sh
printf '#!/bin/sh\necho "$2" > "%s"\n' "$marker" > "$bin/prettier"
```

- [ ] **Step 3: Run the tests to verify the new test fails, then passes**

Run: `sh plugins/markdown-conventions/tests/format-markdown.test.sh`
Expected first (if you momentarily used `$3`): the real-invocation assertion FAILS showing an empty or wrong recorded path. After fixing the stub to `$2`, re-run.
Expected final: all assertions `ok`, final line `13 passed, 0 failed`, exit status 0.

- [ ] **Step 4: Validate the hooks.json parses**

Run:
```bash
jq -e '.hooks.PostToolUse[0].matcher == "Write|Edit|MultiEdit"' plugins/markdown-conventions/hooks/hooks.json && echo "hooks.json OK"
```
Expected: `true` then `hooks.json OK`.

- [ ] **Step 5: Validate the whole plugin with the plugin-validator agent**

Dispatch the `plugin-dev:plugin-validator` agent on `plugins/markdown-conventions/`. Address any structural issue it reports (manifest fields, file layout, hook configuration) without violating the Global Constraints, then re-run the affected verification step above.

- [ ] **Step 6: Commit**

```bash
git add plugins/markdown-conventions/hooks/hooks.json plugins/markdown-conventions/tests/format-markdown.test.sh
git commit -m "✨ feat(markdown-conventions): wire the PostToolUse hook and cover real invocation"
```

---

### Task 6: Mark the spec implemented

**Files:**
- Modify: `docs/superpowers/specs/2026-07-06-markdown-conventions-plugin-design.md:3`

**Interfaces:** none.

- [ ] **Step 1: Update the spec status**

In `docs/superpowers/specs/2026-07-06-markdown-conventions-plugin-design.md`, change the status line from:

```
- Status: draft (design and spec authored under delegation, pending user review)
```
to:
```
- Status: implemented
```

- [ ] **Step 2: Commit**

```bash
git add docs/superpowers/specs/2026-07-06-markdown-conventions-plugin-design.md
git commit -m "📝 docs(markdown-conventions): mark the spec implemented"
```

---

## Self-Review

**1. Spec coverage:**
- Placement in `claude-plugins`, family shape, MIT, version `0.1.0` -> Task 1.
- Skill (`SKILL.md` + `references/`), defer-to-project rule, default profile -> Task 2.
- Hook trigger/filter (`PostToolUse`, `Write|Edit|MultiEdit`, `.md`/`.markdown`, inside project) -> Task 3 (guards) and Task 5 (wiring).
- Detection (dprint / Prettier / markdownlint-cli2, configured AND resolvable), precedence, single file, robustness/no-op, jq runtime -> Task 4, guards in Task 3.
- Implementation via plugin-dev skills and validation via agents -> Steps in Tasks 1, 2, 5.
- Testing matrix (every row of the spec's Testing section) -> Tasks 3, 4, 5 assertions.
- Marketplace entry -> Task 1. Spec status flip -> Task 6.

**2. Placeholder scan:** No "TBD"/"TODO"/"handle edge cases" left; every code step carries full content. The single "Task 4 inserts... here" line is a real, intentional seam that Task 4 Step 3 replaces with the actual block.

**3. Type consistency:** The `run <label> <command...>` helper, `abs_path`, `project_dir`, `DRY_RUN`, and `MARKDOWN_CONVENTIONS_DRY_RUN` names are consistent across Tasks 3, 4, and 5. Dry-run output format `"<label> <abs_path>"` matches every test assertion. The real-invocation stub reads `$2` (the path after `--write`), matching `run prettier prettier --write "$abs_path"`.

**Two settled-by-default decisions (author was away):** hook runtime = `jq`; precedence = dprint > Prettier > markdownlint-cli2. Both are flagged as revisit candidates in the spec; changing either touches only Task 4's detection block and its tests.
