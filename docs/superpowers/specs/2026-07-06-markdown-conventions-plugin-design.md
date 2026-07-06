# Markdown conventions plugin: design

- Date: 2026-07-06
- Status: draft (design and spec authored under delegation, pending user review)
- Author: Jean-Denis VIDOT

## Context and goal

The `jh3ady-claude-plugins` marketplace ships a consistent family of
engineering-principle plugins (`commit-conventions`, `review-conventions`,
`solid-principles`, `simplicity-principles`, `clean-code`, `simple-design`,
`object-calisthenics`, `modular-monolith`, `dependency-injection`,
`hexagonal-architecture`, `domain-driven-design`, `event-sourcing`, `cqrs`,
`screaming-architecture`, `test-driven-development`, `legacy-code`,
`refactoring`, `design-patterns`, `testing-strategy`, `secure-coding`). They
share one pattern: a generic, composable skill presented as a pragmatic
baseline rather than a dogma, with a lean `SKILL.md`, depth pushed into
`references/`, and adjacent concepts cross-referenced rather than absorbed.
Every plugin so far is skill-only knowledge: Claude reads the skill and
produces conforming output itself. None ships executable tooling.

This work adds one plugin: `markdown-conventions`. It carries the discipline of
writing well-formed markdown, framed like `commit-conventions` and
`review-conventions`: a composable baseline standard that defers to the
project's own configuration. It is the first plugin in the family to pair the
knowledge with an optional, deliberately gated enforcement hook.

### Why public, and why here

The idea began as "a hook that reformats a markdown file every time one is
modified in a project, in whichever plugin it fits". Two placements were
weighed:

- `claude-plugins-private` (personal and business plugins, forks or vendored
  third-party tooling). A formatting hook wraps a third-party binary and could
  encode personal taste, which pointed here at first.
- `claude-plugins` (public, MIT). The marketplace already offers *standards as
  frameworks* (`commit-conventions` encodes gitmoji + Conventional Commits,
  `review-conventions` encodes Conventional Comments). A markdown convention is
  the same kind of citizen: a de-facto public standard, generic, deferring to
  the project's own configuration, encoding no personal taste.

The public placement was chosen. The decisive property is that the plugin
imposes nothing of its author's preference: the skill presents a composable
baseline that yields to any project configuration, and the hook does nothing
unless the project has already opted into a formatter. That neutrality is what
makes it a public, MIT, shareable member of the `commit-conventions` family
rather than a personal tool.

### The correction that shapes the design

A Claude Code `PostToolUse` hook fires only after Claude's own tool calls
(`Write`, `Edit`, `MultiEdit`). It does not observe edits a human makes in an
editor. So the hook does not "catch every markdown edit in the project"; it
guarantees the project formatter's exact output after each of Claude's own
markdown edits. This bounds the hook's role and clarifies the division of
labour below.

## Scope

One plugin, `markdown-conventions`, bundling one skill (`markdown-conventions`)
and one `PostToolUse` hook.

Division of labour between the two surfaces:

- The **skill** governs how Claude *writes* markdown: the composable formatting
  conventions, with an explicit instruction to defer to the project's
  configuration when present.
- The **hook** guarantees the *exact* output of the project's configured
  formatter after each of Claude's markdown edits, independent of how faithfully
  the prose followed the conventions. It is deterministic over the scope of
  "Claude's own edits" and silently inert everywhere else.

The two are complementary, not redundant: the skill shapes intent everywhere
(including hosts with no formatter and edits the hook cannot see, such as
guidance Claude gives a human); the hook makes the result byte-exact where a
formatter exists.

### Boundary (focused, with references out)

In scope:

- `SKILL.md`: the composable baseline of markdown formatting conventions,
  framed like its siblings as "a baseline standard, not an opinionated
  ruleset", with an explicit rule to defer to the project's configuration
  (`.prettierrc*`, `.markdownlint*` / `.markdownlint-cli2*`, `dprint.json`,
  `.editorconfig`) whenever it exists.
- `references/conventions.md`: the grounded detail. CommonMark as the parsing
  baseline, the markdownlint rule set (MD0xx) as the recognised style rules,
  and Prettier's markdown defaults as the reflow reference, with worked
  before/after examples.
- `hooks/hooks.json` + `hooks/format-markdown.sh`: the gated enforcement hook.

Out of scope (deferred, not built):

- Any bundled or vendored formatter binary. The plugin never installs a
  formatter; it only invokes one the project already provides.
- Personal writing-convention enforcement (English-only, no em-dashes, no
  abbreviations). That is author-specific and, if ever built, belongs in
  `claude-plugins-private`, not here.
- Content linting beyond formatting (prose style, link checking, spelling).
- Reformatting non-markdown files.
- Reformatting the whole repository. The hook only touches the single file
  Claude just edited.

## The skill

Standard family shape: a lean `SKILL.md` carrying the decision procedure, depth
pushed into `references/conventions.md`.

`SKILL.md` frontmatter `description` triggers whenever Claude writes or edits
markdown (documentation, READMEs, specs, comments in markdown), even when
conventions are not explicitly mentioned, mirroring the trigger phrasing of
`commit-conventions`.

Core content of `SKILL.md`:

- The composable-baseline framing and the "defer to project configuration"
  rule, stated up front and first in priority: if the project configures a
  formatter or an `.editorconfig`, that configuration wins over every default
  below.
- A compact, widely-agreed default profile for when the project configures
  nothing: ATX headings with a single space, one blank line around headings and
  block elements, consistent unordered-list marker, consistent ordered-list
  numbering, fenced code blocks with language tags, reference-consistent
  emphasis markers, trailing-whitespace and final-newline hygiene, and a stated
  line-wrapping stance (prose wrapping left to the project; the default is not
  to hard-wrap unless the project asks).
- A pointer to `references/conventions.md` for the rule-by-rule detail and
  examples, and cross-references out to sibling plugins where relevant
  (`commit-conventions` for commit bodies, `review-conventions` for review
  comments) rather than absorbing them.

## The hook

### Trigger and filter

- Event: `PostToolUse`.
- Matcher: `Write|Edit|MultiEdit`.
- File filter: act only when the edited path is inside the project working
  directory and ends in `.md` or `.markdown`. Any other path or extension is an
  immediate no-op, exit 0.

### Detection (the heart of "respects the project's configuration")

The hook acts only when the project has a formatter both **configured** and
**resolvable** (installed / on `PATH` or in the project's local binaries).
Configured-but-not-installed is treated as not-configured: no-op, exit 0. No
formatter configured: no-op, exit 0. The plugin never installs anything.

Recognised formatters and their configuration signals:

- **dprint**: `dprint.json` / `.dprint.json` (or `.jsonc`) declaring a markdown
  plugin; invoked as `dprint fmt <file>`.
- **Prettier**: `.prettierrc*` in any supported form, or a `prettier` key in
  `package.json`, or `prettier` in the project's dependencies; invoked via the
  project-local binary when present, otherwise a resolvable `prettier`, as
  `prettier --write <file>`.
- **markdownlint-cli2**: `.markdownlint-cli2.*` or `.markdownlint.*`, or
  `markdownlint-cli2` in the project's dependencies; invoked as
  `markdownlint-cli2 --fix <file>`.

### Precedence when several are configured

A single formatter runs, chosen by a fixed order: **dprint, then Prettier, then
markdownlint-cli2**. Rationale: prefer a dedicated markdown formatter (dprint),
then the general-purpose formatter (Prettier), and fall back to
markdownlint-cli2 last because it is primarily a linter whose `--fix` is a
secondary capability. Running a single tool avoids the ping-pong two formatters
can produce on the same file.

(Revisit candidate: the author was away when this was settled. Alternatives
considered were "Prettier first" and "chain all configured formatters". Fixed
single-tool order was chosen as the predictable default; open to change on
review.)

### Invocation scope and robustness

- Reformats only the single edited file, never the repository.
- Never blocks or fails the workflow. Any formatter error, missing dependency,
  or unexpected condition results in a discreet log line and exit 0. The hook is
  advisory plumbing, never a gate.
- Lets each formatter honour its own ignore files (for example Prettier's
  `.prettierignore`): if the tool declines to format the file, that is the
  correct outcome and the hook does not override it.

### Hook runtime

`hooks/format-markdown.sh`, a POSIX `sh` script, reads the `PostToolUse` JSON
from stdin and extracts the edited file path with `jq`. `jq` is light, common
on developer machines, and idiomatic for Claude Code hooks. If `jq` is not
resolvable, the hook no-ops cleanly (discreet log, exit 0) rather than failing.
The script path is referenced from `hooks.json` via `${CLAUDE_PLUGIN_ROOT}`.

(Revisit candidate: the author was away when this was settled. Alternatives
were a Node script, always present for the Node-based formatters but a heavy
implicit dependency for a dprint-only project, and a `python3` script. `jq` was
chosen as the lightest common default; open to change on review.)

## Plugin structure

```
plugins/markdown-conventions/
├── .claude-plugin/plugin.json
├── hooks/
│   ├── hooks.json                 # PostToolUse Write|Edit|MultiEdit -> format-markdown.sh
│   └── format-markdown.sh         # filter + detect + invoke, no-op when nothing configured
├── skills/markdown-conventions/
│   ├── SKILL.md
│   └── references/conventions.md
├── LICENSE                        # MIT
└── README.md
```

Plus a new entry in `.claude-plugin/marketplace.json`:

```json
{
  "name": "markdown-conventions",
  "source": "./plugins/markdown-conventions",
  "description": "...",
  "version": "0.1.0"
}
```

`plugin.json` follows the family shape (name, version `0.1.0`, description,
author, MIT license, homepage under
`https://github.com/jh3ady/claude-plugins/tree/main/plugins/markdown-conventions`,
keywords such as `markdown`, `formatting`, `prettier`, `markdownlint`,
`dprint`).

## Testing

The skill is validated by review against the family conventions (trigger
phrasing, composable-baseline framing, lean `SKILL.md` with depth in
`references/`), as with the sibling plugins.

The hook is validated against its detection and safety matrix:

- Prettier configured and installed, `.md` edited -> file reformatted with
  `prettier --write`.
- dprint configured with a markdown plugin, `.md` edited -> `dprint fmt`.
- markdownlint-cli2 configured, `.md` edited -> `markdownlint-cli2 --fix`.
- Several configured together -> only the precedence winner runs.
- No formatter configured -> no-op, exit 0, file untouched.
- Formatter configured but not installed -> no-op, exit 0.
- Non-markdown file edited -> ignored, exit 0.
- Path outside the project working directory -> ignored, exit 0.
- `jq` unavailable -> no-op, exit 0, no failure surfaced.
- Formatter exits non-zero -> discreet log, exit 0, workflow not blocked.
- File excluded by the formatter's own ignore file -> left untouched.

## Consequences

- Introduces the first executable tooling surface into the public marketplace.
  This is a deliberate, bounded expansion: the hook is inert unless the project
  opts in through its own configuration, so the marketplace's "imposes nothing"
  character is preserved.
- Establishes a reusable shape for future convention plugins that pair
  knowledge with gated, project-deferring enforcement.
- `jq` becomes a soft host expectation for the hook path only; its absence
  degrades to a clean no-op, never a failure.
