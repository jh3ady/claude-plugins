# jh3ady-markdown-conventions

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
