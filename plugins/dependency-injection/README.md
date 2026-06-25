# dependency-injection

A Claude Code plugin that helps wire dependencies pragmatically: supply an
object's collaborators from outside rather than constructing them inside,
with Pure DI (manual constructor injection) as the default and a DI container
treated as an option that must earn its keep.

It stays generic on purpose: compose it with your own container choice and
your team or personal conventions.

## What it does

When you wire dependencies, structure object construction, choose between
manual wiring and a DI container, or review for DI anti-patterns, the bundled
skill applies:

- Constructor injection by default, the composition root, and Pure DI first.
- Object lifetimes and the captive dependency trap.
- The pragmatic rule: no container until convention-based auto-wiring or a
  large object graph genuinely justifies one.
- The anti-pattern catalogue (service locator, control freak, over-injection),
  with the genuine debates surfaced rather than flattened.

## Install

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install dependency-injection@jh3ady-claude-plugins
```

## Adapt to your context

This plugin is a baseline, not a dogma. Layer your own container choice and
team conventions in your own `CLAUDE.md` or a higher-priority skill. The
plugin does not impose them.

## License

Released under the [MIT License](LICENSE).
