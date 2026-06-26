# hexagonal-architecture

A Claude Code plugin that helps apply hexagonal architecture (ports and
adapters) pragmatically: an application core isolated from its infrastructure,
dependencies pointing inward, and the world reaching the core only through
ports it owns, without sliding into over-engineering or forcing the full
apparatus onto simple CRUD.

It stays generic on purpose: compose it with your own architecture rules and
your team or personal conventions.

## What it does

When you structure, review, or refactor how business logic is isolated from
frameworks, databases, message brokers, external APIs, or the UI, the bundled
skill applies:

- The one rule: dependencies point inward, the core depends on nothing outside
  itself.
- Primary (driving) and secondary (driven) ports and adapters, and the mnemonic
  that keeps the dependency direction straight.
- Composition-root wiring and testing the core in isolation with in-memory
  adapters.
- The relationship to Onion and Clean Architecture: the same idea in different
  vocabularies.
- Pragmatic guardrails against over-porting, mapping fatigue, leaking framework
  types into the core, and applying the full hexagon to thin CRUD.

## Install

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install hexagonal-architecture@jh3ady-claude-plugins
```

## Adapt to your context

This plugin is a baseline, not a dogma. Layer your own port naming, folder
layout, mapping strategy, and team conventions in your own `CLAUDE.md` or a
higher-priority skill. The plugin does not impose them.

## License

Released under the [MIT License](LICENSE).
