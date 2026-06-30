---
name: cqrs
description: This skill should be used when separating the model that handles commands (writes) from the model that answers queries (reads), when designing command handlers and query handlers, when deciding whether the read path and the write path should diverge, when a read model or projection is shaped differently from the write model, or when reviewing a system that splits reads from writes, applying Command Query Responsibility Segregation (CQRS), even when the term "CQRS" is not used. Covers the command/query distinction promoted from method level (CQS) to model level, commands versus queries, command and query handlers, the write model versus read models and projections, the levels of separation from a shared store to separate stores, the consistency trade-off, and the relationship to event sourcing and domain-driven design, with TypeScript specifics. Make sure to consult this skill whenever someone mentions a read model, a write model, command handlers, query handlers, separating reads from writes, or shaping a query-optimised view differently from the domain model. Includes pragmatic guardrails against applying CQRS to simple CRUD and against treating it as a top-level architecture rather than a tactical pattern inside a single bounded context.
---

# CQRS

Command Query Responsibility Segregation separates the model that changes
state from the model that returns state. Greg Young, who named the pattern,
frames it at its smallest: "the creation of two objects where there was
previously only one", split according to whether the methods are commands or
queries. Instead of one model serving both writes and reads, you have a write
model that executes commands and a read model that answers queries.

CQRS is a small tactical pattern, not an architecture. Young is explicit that
"CQRS is not a top level architecture": it describes something inside a single
system or component, typically one bounded context, not the shape of a whole
application. Martin Fowler gives the matching caution: use CQRS "only on
specific portions of a system (a BoundedContext in DDD lingo) and not the
system as a whole", and "be very cautious about using CQRS". Apply it where a
genuine asymmetry between writes and reads justifies the second model, not by
reflex.

## CQS is the root, at the method level

CQRS grows from Bertrand Meyer's Command Query Separation (CQS): every method
is either a command that changes state and returns nothing, or a query that
returns data and causes no observable change. CQS is a principle about
individual methods on one object. CQRS promotes the same distinction up a
level, to two separate models or objects: one for the command methods, one for
the query methods. CQS is method-level; CQRS is model-level. That single step
up is the whole idea.

## Commands and queries

A **command** expresses an intention to change state. Name it for the business
task in the imperative (`PlaceOrder`, `ConfirmPayment`, `CancelReservation`),
not as a setter (`setStatus`). A command is handled, it mutates the write
model, and it returns no domain data. A **query** asks a question. It returns
data shaped for the caller (a Data Transfer Object, DTO, or read model), and it
never mutates state or carries domain logic. Keeping the two apart is what lets the read side and the
write side evolve and scale independently.

## The building blocks

Four roles cover most CQRS code:

- **Command handlers** receive a command, load the write model, run the
  business rule, and persist the change. One handler per command keeps each
  one small and intention-revealing.
- **The write model** enforces invariants. In a domain-driven design it is an
  aggregate with its repository (see `ddd-tactical-design`); in a simpler
  domain it can be a plain transactional service. It is optimised for
  consistency, not for reading.
- **Query handlers** answer a query by reading from a store shaped for that
  query and returning a DTO. They hold no domain logic.
- **Read models (projections)** are denormalised views built for the queries
  the application needs. They are derived and disposable: you can rebuild them
  from the write side.

```typescript
// The two sides are deliberately separate types. The command path returns no
// data; the query path returns a DTO and never mutates.
interface Command { readonly type: string; }
interface CommandHandler<C extends Command> {
  handle(command: C): Promise<void>;
}

// Result is a phantom type parameter: it carries the query's result type so the
// handler can be typed, even though the Query interface itself does not use it.
interface Query<Result> { readonly type: string; }
interface QueryHandler<Q extends Query<Result>, Result> {
  handle(query: Q): Promise<Result>;
}
```

## The levels of separation

CQRS is a spectrum, not a single recipe. Microsoft's guidance names two
levels, and the lower one is where most systems should stay:

- **Separate models on a shared data store** is the foundational level: one
  database, but distinct write and read paths (the write side through
  aggregates, the read side through query handlers returning DTOs, often via
  database views or read-optimised queries). No new infrastructure, and reads
  stay strongly consistent.
- **Separate models on different stores** is the advanced level: a write store
  optimised for consistency and a read store optimised for queries, kept in
  sync. This buys independent scaling and read performance at the cost of
  synchronisation and eventual consistency.

A finer community ladder (same model with separate methods, then separate
models same store, then separate stores, then event-sourced) is sometimes
quoted; treat it as informal framing, not a sourced taxonomy. The decision
that matters is shared store versus separate stores.

## Consistency: eventual only when the read store is separate

A widespread misconception is that CQRS forces eventual consistency. It does
not. Eventual consistency is a consequence of a **separate or asynchronously
updated read store**, not of the command/query split itself. On a shared store
the read side can be strongly consistent. Only when you move to a separate read
store, updated after the write commits, does a staleness window appear, and
then the system and its users must be designed to tolerate it. Choose the
consistency model deliberately; do not inherit eventual consistency as if the
pattern demanded it.

## Guardrails

- **Do not use CQRS for simple CRUD.** When the read shape and the write shape
  are the same and the domain has few rules, one model is simpler and clearer.
  Fowler warns CQRS can be "a significant drag on productivity" where it does
  not fit. Most of a system is CRUD; leave it that way.
- **CQRS is not a system-wide architecture.** Scope it to the one bounded
  context where the read/write asymmetry is real. Using it as the top-level
  shape of an application is the classic over-application.
- **CQRS is not "two databases plus a message bus plus event sourcing".** The
  core requires none of those. Applying CQRS "does not mandate that you split
  the data store", and it "does not require a message bus" (Young). Reaching
  for separate stores, messaging, or event sourcing when all you needed was to
  separate command code from query code is the dominant failure mode.
- **Introduce separation incrementally.** Start at the shared-store level and
  move to separate stores only when measured read load, query complexity, or
  scaling needs justify the synchronisation cost.

## Relationship to other skills

- **`event-sourcing`**: CQRS and event sourcing pair naturally but are
  distinct, and the relationship is asymmetric. CQRS does not require event
  sourcing: you can apply it with a conventional current-state write model. But
  event sourcing effectively implies CQRS, because the event store is the write
  model and projections are the read model. Consult that skill for the event
  store, rehydration, and projection mechanics.
- **`ddd-tactical-design`** (in the `domain-driven-design` plugin): the write
  model is typically an aggregate guarding its consistency boundary, with a
  repository. Consult it for modelling the write side.
- **`hexagonal-architecture`**: a common way to wire CQRS is command and query
  handlers as primary (driving) ports, with the write store and read store
  behind secondary (driven) ports. This pairing is a convention, not doctrine:
  no canonical CQRS source mandates it. Consult that skill for the structural
  wiring.
- **Command and query buses, mediators, message brokers, and sagas** are
  optional delivery and coordination machinery often seen around CQRS. They are
  not part of the core pattern and are out of scope here; add them only when a
  concrete need justifies them.

## Adapt to your context

This skill stays generic on purpose. Layer your own conventions on top: your
command and query bus or mediator (or none), how read models are kept in sync,
your storage choices for each side, and your DTO and naming conventions.
Declare those in your own `CLAUDE.md` or a higher-priority skill, which
overrides this baseline. This skill does not impose them.

## Reference

For the canonical definitions with sources, the CQS-to-CQRS history, the
command and query handler details, the write model and read model with a worked
TypeScript example of both paths side by side, the levels of separation and
their trade-offs, how read models are kept up to date, the consistency
analysis, the relationship to event sourcing and domain-driven design, and the
full when-not-to-use analysis, read `references/cqrs.md`.
