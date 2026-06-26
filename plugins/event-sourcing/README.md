# event-sourcing

A Claude Code plugin that helps apply event sourcing pragmatically: persist the
full sequence of state-changing events in an append-only store as the system of
record, derive current state by replaying those events, and build read models
as projections, without forcing the pattern onto systems that only need plain
create, read, update, and delete.

Event sourcing is a persistence and data-management pattern, not a part of
domain-driven design. It has strong synergy with domain-driven design through
the event-sourced aggregate and domain events, so this plugin composes with the
`domain-driven-design` plugin, but it stands on its own and you can use it
without domain-driven design.

It stays generic on purpose: compose it with your own architecture rules and
your team or personal conventions.

## What it does

When you design, review, or refactor how a part of a system stores its state as
a history of events rather than as a current-state snapshot, the bundled skill
applies:

- The core idea: an append-only event store as the system of record, with
  current state derived by replaying events (rehydration), contrasted with
  storing only the latest state.
- Events as immutable, past-tense facts that capture intent, not just the
  resulting state.
- The event-sourced aggregate: raising and applying events, rehydration from a
  stream, optimistic concurrency, and given-when-then testing.
- Snapshots as a rebuildable optimisation, never the source of truth.
- Projections and read models as the query side, eventually consistent and
  rebuildable, with idempotent handlers.
- Schema evolution: tolerant readers, event versioning, upcasting, and
  compensating events, with in-place rewrites as a last resort.
- Pragmatic guardrails against applying event sourcing to simple CRUD, MVPs,
  strong-consistency read needs, or teams without event-driven experience.

## Relationship to other plugins

- `domain-driven-design`: an event-sourced aggregate is the tactical aggregate
  persisted as its domain events; the orange events of an EventStorming session
  become the events you store.
- `hexagonal-architecture`: the event store sits behind a secondary (driven)
  port; projections are driven adapters.
- CQRS (Command Query Responsibility Segregation) pairs naturally with event
  sourcing and is referenced here, but it is a distinct pattern and planned as
  its own future plugin.

## Install

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install event-sourcing@jh3ady-claude-plugins
```

## Adapt to your context

This plugin is a baseline, not a dogma. Layer your own event-store technology,
naming conventions, snapshot and versioning strategy, and projection layout in
your own `CLAUDE.md` or a higher-priority skill. The plugin does not impose
them.

## License

Released under the [MIT License](LICENSE).
