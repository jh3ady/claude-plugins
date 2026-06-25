# simplicity-principles

A Claude Code plugin that applies the simplicity cluster, KISS, DRY, and
YAGNI, to the code you write and review, pragmatically: it favors the
simplest design that meets the current need and surfaces the trade-offs
before you abstract.

It stays generic on purpose: compose it with your own project conventions
and your team or personal rules.

## What it does

When you write, modify, review, or refactor production code, the bundled
skill applies:

- KISS, DRY, and YAGNI as do-less heuristics with recognizable smells.
- The rule of three and the warning that duplication is cheaper than the
  wrong abstraction.
- The pragmatic rule: match the level of sophistication to the actual need.

## Install

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install simplicity-principles@jh3ady-claude-plugins
```

## Adapt to your context

This plugin is a baseline grid of heuristics, not a dogma. Layer your own
architecture rules and team conventions in your own `CLAUDE.md` or a
higher-priority skill. The plugin does not impose them.

## License

Released under the [MIT License](LICENSE).
