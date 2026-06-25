# solid-principles

A Claude Code plugin that applies the five SOLID principles (SRP, OCP,
LSP, ISP, DIP) to the code you write and review, pragmatically: it
recognizes the smell, proposes a focused refactoring, and keeps you from
over-engineering.

It stays generic on purpose: compose it with your own project conventions
and your team or personal rules.

## What it does

When you write, modify, review, or refactor production code, the bundled
skill applies:

- A recognizable symptom for each SOLID principle, mapped to a focused fix.
- Guardrails against speculative abstraction: introduce an abstraction when
  a real boundary or seam justifies it now (an architectural port, a testing
  seam, a contract to stabilize); do not introduce one purely to look SOLID.
- The pragmatic rule: match the level of sophistication to the actual need.

## Install

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install solid-principles@jh3ady-claude-plugins
```

## Adapt to your context

This plugin is a baseline grid of heuristics, not a dogma. Layer your own
architecture rules and team conventions in your own `CLAUDE.md` or a
higher-priority skill. The plugin does not impose them.

## License

Released under the [MIT License](LICENSE).
