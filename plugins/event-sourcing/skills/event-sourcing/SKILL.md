---
name: event-sourcing
description: This skill should be used when designing, reviewing, or refactoring how a part of a system persists its state as a history of events rather than as a current-state snapshot, when working with an append-only event store, when an aggregate must be rebuilt by replaying its events, when building read models or projections from a stream of events, or when you need an audit trail, temporal queries, or the ability to reconstruct past state, applying event sourcing, even when the term "event sourcing" is not used. Covers the event store as the system of record, event-sourced aggregates and rehydration, optimistic concurrency, snapshots, projections and read models, schema versioning and upcasting, idempotency and ordering, compensating events, and the relationship to CQRS and domain-driven design, with TypeScript specifics. Make sure to consult this skill whenever someone mentions an event store, event streams, replaying events, projections, rehydrating an aggregate, or storing history instead of current state. Includes pragmatic guardrails against applying it to simple CRUD, MVPs, or systems that need strong read consistency.
---

# Event sourcing

Event sourcing stores the full sequence of state-changing events as the
authoritative record, and derives current state by replaying them. Martin
Fowler's definition: "Capture all changes to an application state as a sequence
of events." Instead of updating a row in place and keeping only the latest
value, you append an immutable event for every change, and "we can confidently
rebuild the system state by reprocessing the events at any time in the future."

Event sourcing is a persistence and data-management pattern, not a part of
domain-driven design. It has strong synergy with domain-driven design through
the event-sourced aggregate and domain events, which is why the two are
usually taught together, but its identity is independent: you can event-source
a subsystem without aggregates, a ubiquitous language, or bounded contexts.
Apply it where its benefits justify its real cost, not as a blanket mandate.

## The core idea: an event store as the system of record

Each entity has its own event stream: the ordered sequence of events that
records every change to it. The append-only event store holds these streams and
is the single source of truth. Current state is not stored; it is a derived,
cacheable artifact. To obtain the state of an entity you load its stream and
replay the events against an initial state. This process is called
**rehydration**. The standard analogy is an accountant's ledger or a
version-control history: you never erase a past entry, you append a correcting
one, and the current balance is the fold of everything that happened.

Two consequences follow and both are load-bearing. Writes are append-only, so
they avoid the read-modify-write lock contention of update-in-place systems.
And nothing is ever lost, so you get a complete audit trail and the ability to
reconstruct the state at any past point in time for free.

## Events capture intent, not just resulting state

An event is an immutable fact, named in the past tense, that describes something
that happened (`SeatsReserved`, `OrderPlaced`, `PaymentRefunded`). Design events
to capture the business intent behind a change, not only the new value.
`SeatsReserved { count: 2 }` tells you what happened; `RemainingSeatsChanged {
to: 42 }` only records a resulting state and reduces the store to a meaningless
change log. Intent-focused events give you meaningful audit trails and the
freedom to build new read models from history without touching the write side.
When event sourcing is used with domain-driven design, these are exactly the
domain events the aggregate already emits.

## The event-sourced aggregate

An event-sourced aggregate is an ordinary aggregate whose persistence strategy
is its own event stream. A command handler rehydrates the aggregate from its
stream, runs the business logic, and the aggregate **raises** new events rather
than mutating fields directly. Each raised event is **applied** through a pure
mutator (often `when(event)` or `apply(event)`) that updates in-memory state.
Rehydration is just applying the stored events in order; the same mutators serve
both the live command and the replay. Keep `apply` free of input/output and side
effects: it must produce identical state every time it replays.

Because no row is updated in place, conflicting writes are caught with
**optimistic concurrency**: the handler appends with the stream version it read,
and the store rejects the append if the stream has grown since. On rejection the
handler reloads, re-evaluates, and retries. This style of aggregate is naturally
tested **given-when-then**: given a set of prior events, when a command runs,
assert on the new events produced, with no database, queue, or projection in the
loop.

## Snapshots

If a stream grows long, replaying every event to rehydrate becomes costly. A
snapshot is a serialised copy of the aggregate's state at a point in the stream;
to rehydrate you load the most recent snapshot and replay only the events after
it. A snapshot is an **optimisation and a cache, never the source of truth**:
you must be able to delete every snapshot and rebuild state from the events
alone. Add snapshots when measurement shows replay is too slow, not by reflex.

## Projections and read models

Reading by replaying events is expensive and awkward, and there is no general
query language over a stream. So the query side is served by **projections**:
read models materialised by handling the event stream and writing into a
denormalised store shaped for the queries the application needs. Projections are
derived and disposable; you can drop a read model and rebuild it by replaying
from the start, which is what lets you add new read models from old history.

This is where event sourcing meets CQRS (Command Query Responsibility
Segregation): the event-sourced aggregates are the write model and the
projections are the read model. The two patterns pair naturally but are
distinct, and CQRS is covered on its own (see Relationship to other skills).
Projections are **eventually consistent**: a delay exists between appending an
event and updating the read model, and the system must be designed for that
window.

Because event delivery to projection handlers is typically at-least-once, a
handler can see the same event more than once, so **projection handlers must be
idempotent**: track the last processed sequence number per consumer and skip
duplicates, or write state mutations that are safe to repeat. Without this,
read models drift and side effects such as emails or payments fire twice.

## Schema evolution: never edit a stored event

The event store is permanent, so you never rewrite a stored event. When the
shape of an event must change, evolve it on the read path, in increasing order
of cost:

- **Tolerant reader**: ignore unknown fields and default missing ones. This
  absorbs additive, non-breaking changes with no transformation.
- **Event versioning**: stamp each event with a version, and select handling
  logic by version.
- **Upcasting**: register transformations that convert an old event schema to
  the current one during deserialisation. Upcasters chain, so application code
  only ever sees the latest version, and the stored events stay untouched.
  Greg Young's rule: a new version must be convertible from the old one; if it
  is not, it is not a new version but a new event.
- **In-place migration**: rewriting stored events to a new schema. This breaks
  immutability and the audit trail; treat it as a last resort.

To correct data (as opposed to schema), append a **compensating event** that
reverses or adjusts a prior one (a `ReservationCanceled` after a
`SeatsReserved`). The original stays in the stream and the compensation records
that it was undone, which is itself part of the history.

## Guardrails

- Event sourcing is a complex pattern with significant trade-offs. It changes
  how you store data, handle concurrency, evolve schemas, and query state, and
  it is costly to migrate into or out of. For most systems and most parts of a
  system, plain current-state storage is the right default.
- It is not all-or-nothing. Apply it to the parts that benefit (a payment
  ledger, an order pipeline, anything needing audit or temporal queries) and
  keep CRUD for the rest (user profiles, configuration, reference data).
- Avoid it for: straightforward CRUD with no audit or replay need; prototypes,
  MVPs, and short-lived systems where the upfront investment never pays back;
  systems that need strong read consistency and real-time views, since eventual
  consistency is inherent; mostly static or reference data; and teams without
  event-driven experience, where the unfamiliarity invites costly anti-patterns.
- An event store is not a message broker. Brokers such as Kafka lack per-entity
  stream queries and optimistic concurrency; they distribute events well but do
  not replace the store.
- The append-only store is in tension with the right to be forgotten. Keep
  personal data out of events and reference it by identifier, or use
  crypto-shredding (encrypt per subject, delete the key) so the event structure
  survives deletion of the data.

## Relationship to other skills

- **`ddd-tactical-design`** (in the `domain-driven-design` plugin): the
  event-sourced aggregate is the tactical aggregate persisted as its own domain
  events. That skill defines the aggregate, its consistency boundary, and domain
  events; this skill changes how that aggregate is stored. Consult it for the
  modelling of aggregates and events.
- **`ddd-event-storming`**: the orange domain events discovered on the workshop
  timeline are the events you store. EventStorming is a natural way to find them.
- **`hexagonal-architecture`**: the event store sits behind a secondary (driven)
  port (an event-sourced repository interface owned by the core); its
  implementation and the projection writers are driven adapters. Consult that
  skill for the structural wiring.
- **`dependency-injection`**: the event store and projection dependencies are
  declared as interfaces and injected at the composition root.
- **`cqrs`**: the command/query split that event sourcing pairs with. The
  relationship is asymmetric: event sourcing effectively implies CQRS (the
  event store is the write model, projections are the read model), but CQRS
  does not require event sourcing. Consult that skill for the command/query
  split in its own right; this skill covers the event-sourcing half.
- **`design-patterns`**: a snapshot is the Memento pattern applied to the event
  store, and projections are driven by an Observer-style subscription to the
  event stream. The generic mechanisms live in `design-patterns`; this skill
  applies them to the store.

## Adapt to your context

This skill stays generic on purpose. Layer your own conventions on top: your
event-store technology, event naming and envelope format, snapshot frequency,
versioning and upcasting strategy, and projection layout. Declare those in your
own `CLAUDE.md` or a higher-priority skill, which overrides this baseline. This
skill does not impose them.

## Reference

For the canonical definitions with sources, the event store and stream model,
detailed event-sourced aggregate and rehydration code, optimistic concurrency,
snapshots, projections and read models, the schema-evolution and upcasting
strategies, idempotency and ordering, compensating events, and the pragmatic
when-not-to-use analysis, all with TypeScript examples, read
`references/event-sourcing.md`.
