# cqrs

A Claude Code plugin that helps apply Command Query Responsibility Segregation
(CQRS) pragmatically: separate the model that handles commands (writes) from
the model that answers queries (reads), without forcing a second model onto
systems that only need plain create, read, update, and delete.

CQRS is a small tactical pattern, not an architecture. It belongs inside a
single bounded context where the way you write data and the way you read it
genuinely diverge, not as the top-level shape of a whole application. This
plugin keeps that framing front and centre and guards against the pattern's
most common misuse.

It stays generic on purpose: compose it with your own architecture rules and
your team or personal conventions.

## What it does

When you separate a write model from a read model, design command and query
handlers, decide whether the read path and the write path should diverge, or
review a system that splits reads from writes, the bundled skill applies:

- The minimal definition: the command/query distinction promoted from the
  method level (Meyer's Command Query Separation) to the model level (Greg
  Young's CQRS), "two objects where there was previously only one".
- Commands as intention-revealing, task-based requests that change state and
  return no data; queries that return DTOs and never mutate.
- The building blocks: command handlers, the write model (an aggregate with its
  repository, or a plain transactional service), query handlers, and read
  models (projections).
- The levels of separation: separate models on a shared store (the foundational
  level) and separate models on different stores (the advanced level).
- The consistency trade-off: eventual consistency is a consequence of a
  separate or asynchronous read store, not of the command/query split itself.
- Pragmatic guardrails against applying CQRS to simple CRUD, against treating it
  as a system-wide architecture, and against conflating it with "two databases
  plus a message bus plus event sourcing".

## Relationship to other plugins

- `event-sourcing`: CQRS and event sourcing pair naturally but are distinct, and
  the relationship is asymmetric. CQRS does not require event sourcing; event
  sourcing effectively implies CQRS (the event store is the write model,
  projections are the read model).
- `domain-driven-design`: the write model is typically a tactical aggregate with
  its repository; the read model sits outside the domain model as a
  denormalised view.
- `hexagonal-architecture`: a common way to wire CQRS is command and query
  handlers as primary ports with the write and read stores behind secondary
  ports. This is a convention, not a requirement of CQRS.

## Install

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install cqrs@jh3ady-claude-plugins
```

## Adapt to your context

This plugin is a baseline, not a dogma. Layer your own command and query bus or
mediator (or none), your read-model synchronisation strategy, your storage
choices for each side, and your DTO and naming conventions in your own
`CLAUDE.md` or a higher-priority skill. The plugin does not impose them.

## License

Released under the [MIT License](LICENSE).
