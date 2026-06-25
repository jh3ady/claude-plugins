# clean-code

A Claude Code plugin that applies clean code craftsmanship to the code you
write and review, pragmatically: clear names, small focused functions,
intent-revealing comments, and disciplined error handling, without
dogmatic fragmentation.

It stays generic on purpose: compose it with your own project conventions
and your team or personal rules.

## What it does

When you write, modify, review, or refactor production code, the bundled
skill applies:

- Naming, function size and shape, comments, and error handling heuristics.
- A recognizable smell for each area, mapped to a focused fix.
- The pragmatic rule: match the level of sophistication to the actual need.

## Install

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install clean-code@jh3ady-claude-plugins
```

## Adapt to your context

This plugin is a baseline grid of heuristics, not a dogma. Layer your own
style guide and team conventions in your own `CLAUDE.md` or a
higher-priority skill. The plugin does not impose them.

## License

Released under the [MIT License](LICENSE).
