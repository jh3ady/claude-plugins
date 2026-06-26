# Event sourcing reference

The detailed reference behind the `event-sourcing` skill: canonical definitions
for the event store and event streams, the event-sourced aggregate and
rehydration, optimistic concurrency, snapshots, projections and read models, the
relationship to CQRS, schema versioning and upcasting, idempotency and ordering,
compensating events, given-when-then testing, and a pragmatic analysis of when
not to apply the pattern, all with attributed sources and internally consistent
TypeScript examples.

Standards and sources:

- Martin Fowler, [Event Sourcing](https://martinfowler.com/eaaDev/EventSourcing.html)
  (eaaDev, 2005): the foundational essay, the definition "capture all changes to
  an application state as a sequence of events", the accountant's-ledger and
  version-control analogies, and the external-systems and external-queries
  cautions.
- Microsoft, [Event Sourcing pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/event-sourcing)
  (Azure Architecture Center): the append-only store as system of record,
  rehydration, the CQRS overview diagram, snapshots, the problems-and-
  considerations catalogue (eventual consistency, versioning, ordering,
  idempotency, the event-store-is-not-a-broker caveat), and the when-to-use and
  when-not-to-use analysis.
- Greg Young, [Versioning in an Event Sourced System](https://leanpub.com/esversioning/read)
  (2017): the schema-evolution strategies, the tolerant reader, upcasting, and
  the rule that a new version of an event must be convertible from the old one.
- Vaughn Vernon, *Implementing Domain-Driven Design* (2013) and *Effective
  Aggregate Design* (2011,
  [dddcommunity.org](https://dddcommunity.org/wp-content/uploads/files/pdf_articles/Vernon_2011_1.pdf)):
  the event-sourced aggregate, the consistency boundary, and the use of domain
  events to signal state changes.
- Greg Young, [CQRS Documents](https://cqrs.files.wordpress.com/2010/11/cqrs_documents.pdf)
  (2010): the command-query split that event sourcing pairs with, and the read
  model as a derived projection.

---

## Table of contents

1. What event sourcing is
2. The event store and event streams
3. Events: immutable facts that capture intent
4. The event-sourced aggregate
5. The event store port and optimistic concurrency
6. The command handler and the event-sourced repository
7. Snapshots
8. Projections and read models
9. The relationship to CQRS
10. Schema evolution and versioning
11. Idempotency and ordering
12. Compensating events
13. Testing given-when-then
14. When not to apply

The running example throughout is a conference seat-reservation subsystem: a
`SeatAvailability` aggregate that tracks how many seats remain for a conference
and emits events when seats are reserved or a reservation is cancelled. It is
the same example used in the Microsoft reference, chosen because the invariant
(do not oversell) is real and small.

---

## 1. What event sourcing is

Event sourcing captures every change to application state as an immutable event
and stores the sequence of those events as the authoritative record. Martin
Fowler's definition is "capture all changes to an application state as a
sequence of events", with the corollary that "all changes to the domain objects
are initiated by the event objects". You do not store the current state and
overwrite it; you append a new event for each change.

Current state is therefore derived, not stored. As Fowler puts it, you can
"discard the application state completely and rebuild it by re-running the events
from the event log", and you can "determine the application state at any point in
time". The two analogies that make this concrete:

- **The accountant's ledger.** An accountant never erases an entry. A mistake is
  corrected by appending a compensating entry, and the balance is the sum of all
  entries. Fowler notes the strong synergy between accounting and event sourcing,
  both in their audit requirements and in their implementation.
- **Version control.** The commit log is the event store and the working copy is
  the derived current state, rebuilt by replaying commits.

Event sourcing is a persistence pattern. It is independent of domain-driven
design: you can event-source a subsystem with no aggregates or ubiquitous
language. The synergy is real but optional, and it runs entirely through the
event-sourced aggregate (section 4) and domain events.

Fowler's own caution is worth keeping in front of you: event sourcing "is not a
natural choice and to use it means that you expect to get some form of return".
Adopt it for the return (audit, temporal queries, replay, decoupled
integration), not for its own sake.

## 2. The event store and event streams

The event store is an append-only store that serves as the **system of record**:
the authoritative source of truth about state. Each entity has its own **event
stream**, the ordered sequence of events that records every change to that
entity, keyed by the entity identifier.

```typescript
// A stored event as it lives in the store: a domain event wrapped in an
// envelope carrying the metadata the store and its readers need.
interface StoredEvent<Payload = unknown> {
  readonly streamId: string;      // which entity, for example "seat-availability/conf-42"
  readonly streamVersion: number; // position in the stream, 0-based and gapless
  readonly type: string;          // for example "SeatsReserved"
  readonly schemaVersion: number; // see section 10
  readonly occurredAt: string;    // ISO-8601 timestamp
  readonly payload: Payload;      // the event's own fields
}
```

Two properties of the store do the heavy lifting:

- **Append-only writes** avoid the read-modify-write cycles and row-level locks
  of update-in-place systems, so they reduce write contention under load.
- **Nothing is ever lost.** The full history yields a complete audit trail and
  the ability to reconstruct state at any past point in time, neither of which a
  current-state store can provide after the fact.

An event store can be a purpose-built database for append-only streams or a
relational or document database with an append-only table. Purpose-built stores
provide per-stream reads, optimistic concurrency, and snapshots out of the box;
on a relational database you build those yourself. Because each entity has its
own stream, event stores partition naturally by entity identifier.

**An event store is not a message broker.** Brokers such as Apache Kafka
typically lack per-entity stream queries and optimistic concurrency. They work
well as a distribution layer that fans events out to projections and external
consumers, but they are not a substitute for the store.

## 3. Events: immutable facts that capture intent

An event is an immutable object, named in the past tense, that describes
something that happened together with the data needed to describe it.

```typescript
interface SeatsReserved {
  readonly conferenceId: string;
  readonly reservationId: string;
  readonly seats: number;
}

interface ReservationCancelled {
  readonly conferenceId: string;
  readonly reservationId: string;
}
```

Design events to capture **intent**, not merely the resulting state. Microsoft's
guidance is explicit: an event that records "two seats were reserved" is more
valuable than one that records "remaining seats changed to 42". The first tells
you what happened and why; the second is a state snapshot that reduces the store
to a change log with no business meaning. Intent-focused events give richer
projections, meaningful audit trails, and the freedom to build new read models
from old history without changing the write side.

When event sourcing is combined with domain-driven design, these events are the
domain events the aggregate already raises. See the `ddd-tactical-design` skill
for naming events in the ubiquitous language and in the past tense.

## 4. The event-sourced aggregate

An event-sourced aggregate is an ordinary aggregate (a consistency boundary with
an identity, as defined in `ddd-tactical-design`) whose persistence strategy is
its own event stream. Three moves define it:

- It **raises** events instead of mutating fields directly. A command method
  validates the invariant, then records an event.
- It **applies** each event through a pure mutator that updates in-memory state.
  The same mutator runs for a freshly raised event and for an event replayed
  from the store.
- It **rehydrates** by applying the stored events in order from an initial
  state.

```typescript
type SeatEvent = (SeatsReserved & { type: "SeatsReserved" })
  | (ReservationCancelled & { type: "ReservationCancelled" });

class SeatAvailability {
  private constructor(readonly conferenceId: string) {}

  private totalSeats = 0;
  private reserved = new Map<string, number>(); // reservationId -> seats
  private version = -1;                          // last applied stream version
  private readonly uncommitted: SeatEvent[] = [];

  // Rebuild from history. The store hands back events in order; we fold them.
  static rehydrate(conferenceId: string, history: SeatEvent[]): SeatAvailability {
    const aggregate = new SeatAvailability(conferenceId);
    for (const event of history) aggregate.apply(event, false);
    return aggregate;
  }

  private get remaining(): number {
    let used = 0;
    for (const seats of this.reserved.values()) used += seats;
    return this.totalSeats - used;
  }

  // Command: validate the invariant, then raise an event. No state mutation here.
  reserve(reservationId: string, seats: number): void {
    if (this.reserved.has(reservationId)) return; // idempotent command
    if (seats > this.remaining) {
      throw new Error(`Cannot reserve ${seats} seats; only ${this.remaining} remain`);
    }
    this.raise({ type: "SeatsReserved", conferenceId: this.conferenceId, reservationId, seats });
  }

  cancel(reservationId: string): void {
    if (!this.reserved.has(reservationId)) return;
    this.raise({ type: "ReservationCancelled", conferenceId: this.conferenceId, reservationId });
  }

  private raise(event: SeatEvent): void {
    this.apply(event, true);
  }

  // The single mutator. Pure: no input/output, no side effects, deterministic.
  // `isNew` distinguishes a freshly raised event (to be persisted) from a replay.
  private apply(event: SeatEvent, isNew: boolean): void {
    switch (event.type) {
      case "SeatsReserved":
        this.reserved.set(event.reservationId, event.seats);
        break;
      case "ReservationCancelled":
        this.reserved.delete(event.reservationId);
        break;
    }
    this.version += 1;
    if (isNew) this.uncommitted.push(event);
  }

  pullUncommittedEvents(): readonly SeatEvent[] {
    return [...this.uncommitted];
  }

  get streamVersion(): number {
    return this.version;
  }
}
```

The contract that makes this safe: **`apply` must be free of input/output and
side effects and must be deterministic**, because it runs on every replay. Side
effects (sending an email, calling a payment gateway) belong in command handlers
or projection handlers, never in `apply`. The Microsoft reference makes the same
point from the other direction: replaying events must not re-trigger the actions
that the original events caused, or, as Fowler warns, "things will go wrong
because those external systems do not know the difference between real processing
and replays".

The total-seats configuration is elided above for brevity; in a full model a
`SeatsConfigured` event would set `totalSeats`, applied like any other.

## 5. The event store port and optimistic concurrency

The aggregate must not depend on any storage technology. Define the store as a
port (an interface the core owns, in the sense of the `hexagonal-architecture`
skill) and implement it in infrastructure.

```typescript
class ConcurrencyError extends Error {}

interface EventStore {
  // Read a stream in order. Optionally start after a version (used with snapshots).
  readStream(streamId: string, afterVersion?: number): Promise<StoredEvent[]>;

  // Append new events, asserting the version the writer last saw. If the stream
  // has grown past expectedVersion, reject with ConcurrencyError.
  appendToStream(
    streamId: string,
    expectedVersion: number,
    events: readonly unknown[],
  ): Promise<void>;
}
```

Because no row is updated in place, two handlers that load the same stream
concurrently both act on the same state. **Optimistic concurrency** resolves the
race: each handler appends with the version it read, and the store rejects the
append if the stream changed in the meantime. The Microsoft reference describes
exactly this: two handlers each see five remaining seats and both try to accept a
reservation; the store rejects the second append, and that handler reloads,
re-evaluates, and retries. The expected-version check is what enforces the
aggregate's invariant under concurrency.

## 6. The command handler and the event-sourced repository

A thin repository hides the load-and-save dance behind a collection-like
interface, as in `ddd-tactical-design`, but backed by the event store.

```typescript
class SeatAvailabilityRepository {
  constructor(private readonly store: EventStore) {}

  private streamId(conferenceId: string): string {
    return `seat-availability/${conferenceId}`;
  }

  async load(conferenceId: string): Promise<SeatAvailability> {
    const history = await this.store.readStream(this.streamId(conferenceId));
    return SeatAvailability.rehydrate(
      conferenceId,
      history.map((stored) => stored.payload as SeatEvent),
    );
  }

  async save(aggregate: SeatAvailability, expectedVersion: number): Promise<void> {
    const events = aggregate.pullUncommittedEvents();
    if (events.length === 0) return;
    await this.store.appendToStream(
      this.streamId(aggregate.conferenceId),
      expectedVersion,
      events,
    );
  }
}

// The command handler loads, runs business logic, and saves, retrying on a
// concurrency conflict. The retry is safe because reserve() is validated against
// freshly reloaded state each time.
class ReserveSeatsHandler {
  constructor(private readonly repository: SeatAvailabilityRepository) {}

  async handle(command: { conferenceId: string; reservationId: string; seats: number }): Promise<void> {
    for (let attempt = 0; attempt < 3; attempt++) {
      const aggregate = await this.repository.load(command.conferenceId);
      const expectedVersion = aggregate.streamVersion;
      aggregate.reserve(command.reservationId, command.seats);
      try {
        await this.repository.save(aggregate, expectedVersion);
        return;
      } catch (error) {
        if (error instanceof ConcurrencyError) continue; // reload and retry
        throw error;
      }
    }
    throw new Error("Could not reserve seats after repeated concurrency conflicts");
  }
}
```

## 7. Snapshots

When a stream grows long, replaying every event to rehydrate becomes costly in
time and compute. A **snapshot** is a serialised copy of the aggregate's state at
a specific stream version. To rehydrate, load the most recent snapshot and replay
only the events after it.

```typescript
interface Snapshot<State> {
  readonly streamId: string;
  readonly version: number; // the stream version the snapshot reflects
  readonly state: State;
}

interface SnapshotStore<State> {
  latest(streamId: string): Promise<Snapshot<State> | null>;
  save(snapshot: Snapshot<State>): Promise<void>;
}

// Rehydrate from the latest snapshot plus the tail of events after it.
async function loadWithSnapshot(
  store: EventStore,
  snapshots: SnapshotStore<SeatState>,
  streamId: string,
): Promise<SeatAvailability> {
  const snapshot = await snapshots.latest(streamId);
  const fromVersion = snapshot?.version ?? -1;
  const tail = await store.readStream(streamId, fromVersion);
  return SeatAvailability.fromSnapshot(snapshot?.state, tail.map((e) => e.payload as SeatEvent));
}
```

The non-negotiable rule: **a snapshot is an optimisation and a cache, never the
source of truth.** You must be able to delete every snapshot and rebuild state
from the events alone, and you must be able to regenerate snapshots from the
stream at any time. Take snapshots every N events, choosing N to balance the
storage cost of snapshots against the replay time they save. Add them when
measurement shows replay is too slow, not pre-emptively.

A subtle versioning hazard: a snapshot is serialised aggregate state, so a change
to the aggregate's shape can invalidate old snapshots. Version snapshots
independently and be ready to discard and rebuild them, which is cheap precisely
because the events remain the source of truth.

## 8. Projections and read models

Reading state by replaying events is expensive, and there is no general query
language over a stream; the only primitive is "read the events for this entity".
So queries are served by **projections**: read models built by handling the event
stream and writing into a store shaped for the queries the application needs.

```typescript
// A denormalised read model for a dashboard of conference availability.
interface AvailabilityReadModel {
  upsert(row: { conferenceId: string; remaining: number }): Promise<void>;
  get(conferenceId: string): Promise<{ conferenceId: string; remaining: number } | null>;
}

// The checkpoint store records the last stream position this projection processed,
// which is what makes the handler idempotent under at-least-once delivery.
interface Checkpoint {
  lastProcessed(projection: string): Promise<number>;
  advance(projection: string, position: number): Promise<void>;
}

class AvailabilityProjection {
  constructor(
    private readonly readModel: AvailabilityReadModel,
    private readonly checkpoint: Checkpoint,
  ) {}

  async handle(event: StoredEvent<SeatEvent>, globalPosition: number): Promise<void> {
    // Skip anything we have already seen: duplicates must not double-count.
    if (globalPosition <= (await this.checkpoint.lastProcessed("availability"))) return;

    const current = await this.readModel.get(event.payload.conferenceId);
    const remaining = current?.remaining ?? 0;
    switch (event.payload.type) {
      case "SeatsReserved":
        await this.readModel.upsert({
          conferenceId: event.payload.conferenceId,
          remaining: remaining - event.payload.seats,
        });
        break;
      case "ReservationCancelled":
        // A full projection would look up the reservation's seat count; elided.
        break;
    }
    await this.checkpoint.advance("availability", globalPosition);
  }
}
```

Key properties of projections:

- **Derived and disposable.** A read model holds no truth of its own. You can
  drop it and rebuild it by replaying from the start, which is exactly what lets
  you introduce a new read model over old history.
- **Eventually consistent.** There is a delay between appending an event and
  updating the read model. The system, and its users, must tolerate that window.
  If a use case needs read-your-writes consistency, design for it explicitly (for
  example by reading the write model for that one case) rather than assuming the
  projection is instantly current.
- **Idempotent.** See section 11.

## 9. The relationship to CQRS

CQRS (Command Query Responsibility Segregation) separates the model that handles
commands (writes) from the model that answers queries (reads). Event sourcing and
CQRS are independent patterns that pair naturally: in the combination, the
event-sourced aggregates are the write model and the projections are the read
model. Microsoft's overview diagram shows exactly this shape, with command
handlers appending to the event store and event handlers updating a read-only
store.

The pairing is common but neither pattern requires the other. You can apply CQRS
with a conventional current-state write model and no events, and you can
event-source a write model without a separate read side if replay-based reads are
fast enough. This skill covers the event-sourcing half and references the read
side as projections; CQRS in its own right (the command/query split, command and
query handlers, read-model design, the levels of separation, and the consistency
trade-offs) is covered by the `cqrs` skill.

## 10. Schema evolution and versioning

The event store is permanent, so **you never rewrite a stored event.** When the
shape of an event must change, handle it on the read path. Greg Young's framing,
echoed by the Microsoft reference, gives four strategies in increasing order of
cost; use them alone or in combination.

- **Tolerant reader.** Design consumers to ignore unknown fields and default
  missing ones. This absorbs additive, non-breaking changes (a new optional
  field) with no transformation of stored events.
- **Event versioning.** Stamp each event with a version, in the envelope or in
  the type name, and select handling logic by version.
- **Upcasting.** Register transformation functions that convert an older event
  schema to the current one during deserialisation. Upcasters chain, so the
  application only ever handles the latest version while the stored events stay
  untouched.

```typescript
// Each upcaster lifts one version to the next. Chaining them means the rest of
// the system only ever sees the newest shape.
type Upcaster = (event: StoredEvent) => StoredEvent;

const upcasters: Record<string, Upcaster> = {
  // v1 SeatsReserved had no reservationId; synthesise a deterministic one so the
  // upgraded event is still convertible from the original, per Young's rule.
  "SeatsReserved:1": (event) => ({
    ...event,
    schemaVersion: 2,
    payload: {
      ...(event.payload as Record<string, unknown>),
      reservationId: `legacy-${event.streamId}-${event.streamVersion}`,
    },
  }),
};

function upcast(event: StoredEvent): StoredEvent {
  let current = event;
  let key = `${current.type}:${current.schemaVersion}`;
  while (upcasters[key]) {
    current = upcasters[key](current);
    key = `${current.type}:${current.schemaVersion}`;
  }
  return current;
}
```

- **In-place migration.** Rewriting stored events to a new schema directly in the
  store. This breaks immutability and undermines the audit trail; treat it as a
  last resort, reserved for cases the read-path strategies cannot handle.

Young's governing rule: **a new version of an event must be convertible from the
old version. If it is not convertible, it is not a new version of the event; it
is a new event.** Adding fields does not create a versioning conflict; removing
or repurposing fields does, and that is the signal you are really introducing a
new event type rather than evolving an existing one.

## 11. Idempotency and ordering

**Ordering.** Within a single stream, events are strictly ordered by stream
version, and the aggregate's invariant depends on that order. Across streams,
ordering is looser; if a projection or process spans entities, do not assume a
global order beyond what the store guarantees. A monotonic global position or a
per-event sequence number, plus the per-stream version, is usually enough.

**Idempotency.** Delivery of events to consumers is typically at-least-once, so a
projection or process manager can receive the same event more than once. Handlers
must therefore be **idempotent**: processing a duplicate must not change the
outcome. Two standard techniques, both shown in the projection of section 8:

- Track the last processed position per consumer and skip anything at or below
  it.
- Or make the state mutation inherently safe to repeat (a set assignment rather
  than an increment).

Without idempotency, read models drift from the stream and side effects such as
payments or notifications fire more than once. Be mindful too of **circular
logic**: if handling one event raises another that ultimately re-triggers the
first, the system can loop. Break such cycles deliberately.

## 12. Compensating events

Because events are immutable, you do not delete or edit one to undo or correct a
change. You append a **compensating event** that reverses or adjusts a prior one:
a `ReservationCancelled` compensates a `SeatsReserved`. The original event stays
in the stream and the compensation records that it was undone, so the correction
is itself part of the auditable history. This is the ledger discipline from
section 1 applied to mistakes and reversals.

A bug deserves special mention: if faulty code writes incorrect events, those
events persist. Fixing the code does not fix history, so you correct the data
with compensating events, or, if the problem is the schema rather than the data,
with upcasters (section 10).

## 13. Testing given-when-then

Event-sourced aggregates suit a specific, fast testing style: set up prior
events, issue a command, and assert on the new events produced. This exercises
the business logic with no database, queue, or projection.

```typescript
function given(history: SeatEvent[]): SeatAvailability {
  return SeatAvailability.rehydrate("conf-42", history);
}

test("reserving within capacity emits SeatsReserved", () => {
  // given a conference with capacity and one prior reservation
  const aggregate = given([
    { type: "SeatsReserved", conferenceId: "conf-42", reservationId: "r1", seats: 3 },
  ]);

  // when a second reservation is made
  aggregate.reserve("r2", 2);

  // then exactly one new event is produced, describing what happened
  expect(aggregate.pullUncommittedEvents()).toEqual([
    { type: "SeatsReserved", conferenceId: "conf-42", reservationId: "r2", seats: 2 },
  ]);
});

test("reserving beyond capacity is rejected and emits nothing", () => {
  const aggregate = given([
    { type: "SeatsReserved", conferenceId: "conf-42", reservationId: "r1", seats: 9 },
  ]); // assume total capacity 10

  expect(() => aggregate.reserve("r2", 5)).toThrow();
  expect(aggregate.pullUncommittedEvents()).toEqual([]);
});
```

This given-when-then style covers the write model thoroughly. You still need
integration tests for the parts that touch infrastructure: projection handlers
(including idempotency on duplicate delivery), snapshot rehydration, and the
schema-evolution and upcasting paths. That extra testing surface, compared with a
CRUD system, is part of the pattern's cost.

## 14. When not to apply

Event sourcing is a complex pattern with significant trade-offs. It changes how
you store data, handle concurrency, evolve schemas, and query state, and it is
costly to migrate into or out of. The Microsoft reference is blunt: for most
systems and most parts of a system, traditional current-state data management is
sufficient. Adopt event sourcing where its benefits, principally auditability and
historical reconstruction, justify the complexity.

The pattern fits when:

- You want to capture intent, purpose, or reason in the data, not just the latest
  values.
- You must minimise or avoid conflicting updates to the same data.
- You need an audit log, the ability to replay to restore or roll back state, or
  temporal queries over history.
- The application already treats events as a natural feature, so event sourcing
  adds little extra work.
- You need to decouple recording a change from the tasks that react to it.

It is a poor fit when:

- The system is straightforward CRUD with no need for audit, replay, or
  historical reconstruction. The operational overhead of an event store is not
  justified for current-state reads and writes.
- It is a prototype, an MVP, or a short-lived system, where the upfront
  investment in event design, schema-evolution strategy, and projection
  infrastructure rarely pays back.
- The system needs strong consistency and real-time views, since eventual
  consistency between the store and projections is inherent.
- The data is mostly static or reference data (lookup tables, catalogues) that
  changes infrequently and gains nothing from a change history.
- The team has no event-driven experience. Event sourcing changes how you test,
  debug, and operate a system, and adopting it without the foundations invites
  anti-patterns that are costly to reverse.

It is not an all-or-nothing decision. Apply event sourcing selectively to the
parts that benefit most (a payment ledger, an order-processing pipeline) and keep
plain CRUD where the complexity is not justified (profile management, application
configuration).

**Personal data and the right to be forgotten.** The append-only, immutable
store is in tension with regulations that require deleting personal data, since
deleting events outright breaks stream integrity. Two established approaches:
keep personal data outside the event store and reference it by identifier so it
can be deleted independently; or use crypto-shredding, encrypting personal data
in events under a per-subject key and deleting the key to render the data
unrecoverable while leaving the event structure intact. Design for this tension
from the start rather than retrofitting it.
