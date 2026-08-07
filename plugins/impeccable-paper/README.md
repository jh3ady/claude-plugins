# impeccable-paper

A Claude Code plugin that adapts the Impeccable design craft to Paper
(paper.design): design-director quality standards, visual-world commitment,
critique with heuristic scoring, and refinement playbooks, all driven through
the Paper MCP server on the canvas instead of code.

## What it does

When you design, review, or refine anything in Paper, the bundled skill
applies:

- A quality floor (contrast, spacing, typography, states, layer hygiene) and
  a refuse list of AI-default design patterns, verified against measured
  values from the canvas, not eyeballed screenshots.
- A visual-world commitment flow for new surfaces: derive directions from the
  audience's culture, present them for choice, record the decision as a
  contract on the canvas, and build fully committed.
- Canvas-native commands: `craft`, `shape`, `variants`, `adapt`, `critique`,
  `audit`, `polish`, `bolder`, `quieter`, `distill`, `layout`, `typeset`,
  `colorize`, `delight`, `clarify`, and `export`.
- A disciplined way of driving the Paper MCP tools: read before write,
  surgical patches over destructive rewrites, batched edits, and bounded
  verification rounds.

## Prerequisites

The skill talks to Paper through the Paper MCP server:

1. Install the [Paper Desktop app](https://paper.design/downloads) and open a
   file (this starts the MCP server locally).
2. Connect Claude Code to it, either through the official Paper plugin:

   ```bash
   /plugin marketplace add paper-design/agent-plugins
   /plugin install paper-desktop@paper
   ```

   or manually:

   ```bash
   claude mcp add paper --transport http http://127.0.0.1:29979/mcp --scope user
   ```

This plugin does not register the MCP server itself, so it composes cleanly
with the official `paper-desktop` plugin (whose `design-to-code` skill is the
recommended handoff for turning finished frames into production code).

## Install

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install impeccable-paper@jh3ady-claude-plugins
```

## Relationship to Impeccable

This plugin is an adaptation of the
[Impeccable](https://impeccable.style) design skill, which targets frontend
code. The design philosophy, quality floor, and command vocabulary come from
Impeccable (Apache 2.0); the workflow is rebuilt for the Paper canvas and its
MCP tools. For designing in code, use Impeccable itself; for designing in
Paper, use this plugin.

## License

Released under the [Apache 2.0 License](LICENSE). Adapted from the Impeccable
design skill, also Apache 2.0.
