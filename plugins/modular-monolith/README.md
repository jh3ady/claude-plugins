# modular-monolith

A Claude Code plugin that helps structure an application as a modular
monolith, pragmatically: one deployable unit, modules with strictly
enforced boundaries, and isolated data, without sliding into a big ball of
mud or paying the microservices premium too early.

It stays generic on purpose: compose it with your own architecture rules
and your team or personal conventions.

## What it does

When you structure, review, or refactor application architecture, module
boundaries, or deployment topology, the bundled skill applies:

- The three invariants: public-API boundaries, deliberate inter-module
  communication, and per-module data isolation.
- Boundary enforcement in the TypeScript/Node ecosystem.
- The pragmatic rule: coarse modules first, let a module earn its
  independence, and match per-module sophistication to the actual need.
- Complementary patterns (DDD, hexagonal, CQRS) referenced, not imposed.

## Install

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install modular-monolith@jh3ady-claude-plugins
```

## Adapt to your context

This plugin is a baseline, not a dogma. Layer your own module rules and
team conventions in your own `CLAUDE.md` or a higher-priority skill. The
plugin does not impose them.

## License

Released under the [MIT License](LICENSE).
