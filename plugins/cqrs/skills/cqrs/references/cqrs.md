# CQRS reference

The detailed reference behind the `cqrs` skill: the origin in Bertrand Meyer's
Command Query Separation and Greg Young's naming of CQRS, the command/query
distinction at the model level, command and query handlers, the write model
and read models, a worked TypeScript example of both paths side by side, the
levels of separation and their trade-offs, how read models are kept up to date,
the consistency analysis, the relationship to event sourcing and domain-driven
design, and a pragmatic analysis of when not to apply the pattern, all with
attributed sources and internally consistent TypeScript examples.

Standards and sources:

- Greg Young, [CQRS, Task Based UIs, Event Sourcing agh!](https://gregfyoung.wordpress.com/2010/08/13/cqrs-task-based-uis-event-sourcing-agh/)
  (2010): the minimal definition, "the creation of two objects where there was
  previously only one", split by whether the methods are commands or queries.
- Greg Young, [CQRS](https://gregfyoung.wordpress.com/2012/03/02/cqrs/) (2012):
  the "small tactical pattern" framing and the list of what CQRS is not (not a
  top-level architecture, not event sourcing, does not require a message bus).
- Greg Young, [CQRS is not an Architecture](https://gregfyoung.wordpress.com/2012/09/09/cqrs-is-not-an-architecture/)
  (2012): CQRS describes something inside a single system or component, not an
  architectural style.
- Martin Fowler, [CQRS](https://martinfowler.com/bliki/CQRS.html) (2011): the
  attribution to Young, the BoundedContext scoping, the "be very cautious"
  caution, and the shared-database note.
- Bertrand Meyer, *Object-Oriented Software Construction* (1988, 1997): Command
  Query Separation, the method-level principle CQRS is promoted from.
- Microsoft, [CQRS pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/cqrs)
  (Azure Architecture Center): the two levels of separation (shared store and
  separate stores), the aggregate as the write model, the eventual-consistency
  analysis, and the when-not-to-use guidance.
- Microsoft patterns & practices, [CQRS Journey](https://github.com/microsoftarchive/cqrs-journey/blob/master/docs/Reference_02_CQRSIntroduction.markdown)
  (2012): the method-level CQS to object-level CQRS framing, quoting Young, and
  "applying the CQRS pattern does not mandate that you split the data store".
- Udi Dahan, [Clarified CQRS](https://udidahan.com/2009/12/09/clarified-cqrs/)
  (2009): task-based commands, the read side serving DTOs, and keeping reads
  free of domain logic.

A sourcing note: Young's canonical "CQRS Documents" PDF would not parse during
research and its minimal-definition wording was corroborated through the
Microsoft CQRS Journey reference that quotes it directly; the finer "levels"
ladder beyond the two Microsoft levels is community framing, not a primary
taxonomy.

---

## Table of contents

1. What CQRS is, and what it is not
2. From CQS to CQRS: method level to model level
3. Commands and queries
4. The write model
5. Command handlers
6. Read models and query handlers
7. Both paths side by side
8. The levels of separation
9. Keeping the read model up to date
10. Consistency
11. The relationship to event sourcing
12. The relationship to domain-driven design and hexagonal architecture
13. Buses, mediators, and what is out of scope
14. When not to apply

The running example throughout is an order-placement subsystem of a small
commerce application: customers place orders, and a back-office screen lists
order summaries. The write side enforces "an order must have at least one line
and a positive total"; the read side serves a flat summary for a list view.
The example deliberately uses a conventional current-state store, not event
sourcing, to show that CQRS stands on its own.

---

## 1. What CQRS is, and what it is not

CQRS separates the model that handles commands (state changes) from the model
that answers queries (reads). Greg Young, who named the pattern, reduces it to
its core: "the creation of two objects where there was previously only one",
where the split is decided by whether the methods are commands or queries.
Where a CRUD design has one model serving both writing and reading, CQRS has
two: a write model and a read model.

The framing that prevents most misuse is Young's own: CQRS is "a small tactical
pattern", and "CQRS is not a top level architecture". It describes "something
inside a single system or component", not the shape of a whole application.
Fowler reinforces this from the design side: "CQRS should only be used on
specific portions of a system (a BoundedContext in DDD lingo) and not the
system as a whole", and "you should be very cautious about using CQRS".

So the pattern is narrow on purpose. It earns its place where the way you write
data and the way you read it genuinely diverge: complex domain rules on the
write side, very different query shapes on the read side, or asymmetric load
where reads vastly outnumber writes. Without that asymmetry, two models are
overhead with no return.

## 2. From CQS to CQRS: method level to model level

CQRS descends from Bertrand Meyer's **Command Query Separation (CQS)**. Meyer's
rule is about individual methods on an object: every method is either a
**command** that changes observable state and returns nothing, or a **query**
that returns a value and has no side effects. Asking a question should not
change the answer.

CQRS takes that method-level distinction and promotes it to the **model** or
object level. As the Microsoft CQRS Journey puts it, Meyer's CQS works at the
level of "an object's methods", while "CQRS is simply the creation of two
objects where there was previously only one". The commands move to one model,
the queries to another.

```typescript
// CQS at the method level: one object, methods split by command vs query.
class Account {
  private balanceCents = 0;
  deposit(amountCents: number): void { this.balanceCents += amountCents; } // command
  get balance(): number { return this.balanceCents; }                      // query
}

// CQRS at the model level: the commands and the queries live in separate
// models, each free to have its own shape and its own storage.
```

That one step up the abstraction ladder is the entire conceptual content of
CQRS. Everything else (separate stores, projections, messaging) is an
implementation choice layered on top, not part of the definition.

## 3. Commands and queries

A **command** is a request to change state, named for the business intent it
expresses. Prefer task-based names in the imperative mood: `PlaceOrder`,
`ConfirmPayment`, `CancelReservation`. Udi Dahan's "Clarified CQRS" argues for
exactly this task-based shape, against anaemic `setX` messages that mirror
database columns. A command is validated and executed by a handler, mutates the
write model, and returns no domain data. At most it returns an acknowledgement
or an identifier (the strict Command Query Separation form returns nothing; an
id or acknowledgement is a pragmatic relaxation, modelled below as the
`Promise<void>` handler signature).

```typescript
// The two base marker types used throughout this reference. Result is a phantom
// type parameter on Query: it carries the query's result type for the handler,
// though the Query interface itself does not use it.
interface Command { readonly type: string; }
interface Query<Result> { readonly type: string; }

interface PlaceOrder extends Command {
  readonly type: "PlaceOrder";
  readonly orderId: string;
  readonly customerId: string;
  readonly lines: ReadonlyArray<{ sku: string; quantity: number; unitCents: number }>;
}
```

A **query** asks for data and returns it shaped for the caller, with no side
effects and no domain logic. Queries return DTOs or read-model rows, never
write-model aggregates. Keeping domain behaviour out of the query side is what
lets the read model be a flat, denormalised structure tuned for display.

```typescript
interface GetOrderSummaries extends Query<OrderSummary[]> {
  readonly type: "GetOrderSummaries";
  readonly customerId: string;
}

interface OrderSummary {
  readonly orderId: string;
  readonly customerId: string;
  readonly status: string;
  readonly totalCents: number;
  readonly placedAt: string;
}
```

## 4. The write model

The write model exists to enforce invariants, not to be read from. In a
domain-driven design it is an **aggregate** with a repository: a consistency
boundary with an identity, as defined in the `ddd-tactical-design` skill.
Microsoft's guidance makes the same point, noting the write model "might treat
a set of associated objects as a single unit for the purpose of data changes",
"known as an aggregate in domain-driven design terminology". In a simpler
domain the write model can be a plain transactional service; the essential
property is that all the business rules and consistency live here.

```typescript
// The write model. It guards the invariant and exposes no read-shaped getters
// for the query side to lean on; reads do not come through here.
class Order {
  private status: "placed" | "cancelled" = "placed";

  private constructor(
    readonly id: string,
    readonly customerId: string,
    private readonly lines: ReadonlyArray<{ sku: string; quantity: number; unitCents: number }>,
  ) {}

  static place(command: PlaceOrder): Order {
    if (command.lines.length === 0) {
      throw new Error("An order must have at least one line");
    }
    const total = command.lines.reduce((sum, l) => sum + l.quantity * l.unitCents, 0);
    if (total <= 0) {
      throw new Error("An order total must be positive");
    }
    return new Order(command.orderId, command.customerId, command.lines);
  }

  get totalCents(): number {
    return this.lines.reduce((sum, l) => sum + l.quantity * l.unitCents, 0);
  }
}

interface OrderRepository {
  save(order: Order): Promise<void>;
  load(orderId: string): Promise<Order | null>;
}
```

## 5. Command handlers

A **command handler** is a thin coordinator: receive the command, load or
create the write model, run the business rule, persist, and stop. One handler
per command type keeps each one small and named after the intent. The handler
does not return data for display; that is the query side's job.

```typescript
class PlaceOrderHandler implements CommandHandler<PlaceOrder> {
  constructor(private readonly orders: OrderRepository) {}

  async handle(command: PlaceOrder): Promise<void> {
    const order = Order.place(command); // invariant enforced in the write model
    await this.orders.save(order);
  }
}
```

The `CommandHandler` and `QueryHandler` interfaces are the same as in the
skill body:

```typescript
interface CommandHandler<C extends Command> { handle(command: C): Promise<void>; }
interface QueryHandler<Q extends Query<Result>, Result> { handle(query: Q): Promise<Result>; }
```

## 6. Read models and query handlers

The read side is built for queries, not for rules. A **read model** (a
projection) is a denormalised structure shaped for the screens or APIs that
consume it; a **query handler** reads from it and returns a DTO. Crucially the
read model holds no truth of its own: it is derived from the write side and can
be rebuilt. That is why it is safe to denormalise it freely.

```typescript
// The read side. It reads from a query-shaped store and returns DTOs. No
// aggregates, no invariants, no domain logic.
interface OrderSummaryStore {
  byCustomer(customerId: string): Promise<OrderSummary[]>;
  upsert(summary: OrderSummary): Promise<void>;
}

class GetOrderSummariesHandler
  implements QueryHandler<GetOrderSummaries, OrderSummary[]> {
  constructor(private readonly summaries: OrderSummaryStore) {}

  async handle(query: GetOrderSummaries): Promise<OrderSummary[]> {
    return this.summaries.byCustomer(query.customerId);
  }
}
```

## 7. Both paths side by side

The point of CQRS is visible when the two paths sit next to each other: they
share nothing but the domain concepts. The command path goes through the
aggregate and enforces rules; the query path goes straight to a read-optimised
store and returns a flat DTO. Neither depends on the other's internals.

```text
                 ┌─────────────────────────────────────────┐
   PlaceOrder ──▶│ PlaceOrderHandler ─▶ Order (write model) │──▶ write store
   (command)     └─────────────────────────────────────────┘
                                                     │
                              (read model kept in sync; see section 9)
                                                     ▼
 GetOrderSummaries ─▶ GetOrderSummariesHandler ─▶ OrderSummaryStore ─▶ OrderSummary[]
   (query)                                         (read model)        (DTOs)
```

At the foundational level the two stores in this picture are the same database,
read through different paths. At the advanced level they are physically
separate stores, and the arrow between them is the synchronisation discussed in
section 9.

## 8. The levels of separation

Microsoft's guidance names two levels, and the choice between them is the real
architectural decision in CQRS.

**Separate models on a shared data store (the foundational level).** One
database. The write side persists through aggregates; the read side queries the
same database through read-optimised paths, for example database views, a
read-only query service, or projections into separate tables in the same
schema. This adds no infrastructure and keeps reads strongly consistent. It is
where most systems that benefit from CQRS should stay.

**Separate models on different stores (the advanced level).** A write store
chosen for transactional consistency and a read store chosen for query
performance (a denormalised SQL schema, a document store, a search index),
synchronised after writes. This buys independent scaling of reads and writes
and read models tuned per use case, at the cost of synchronisation machinery
and eventual consistency.

A finer ladder is sometimes quoted (same model with separate command and query
methods, then separate models on the same store, then separate stores, then
event-sourced). It can be a useful mental picture, but only the two-level
shared-versus-separate framing comes from a primary source; treat the rest as
informal. The decision that carries real cost and benefit is shared store
versus separate stores.

## 9. Keeping the read model up to date

When the read model lives in a separate store, something must update it after a
write. The common strategies, in increasing order of decoupling:

- **Synchronous update in the same transaction or request.** After the write
  commits, update the read model immediately. Simple, and it keeps the read
  model close to consistent, but it couples the two sides and the write path
  pays the read-update cost.
- **Event-driven projection.** The write side publishes a domain event
  (`OrderPlaced`) and a projection handler updates the read model
  asynchronously. This decouples the sides and is the natural shape when CQRS
  is combined with event sourcing, where projections are rebuilt from the event
  stream. See the `event-sourcing` skill for the store, ordering, and
  idempotency details that the read side then inherits (at-least-once delivery
  means projection handlers must be idempotent).

```typescript
// Event-driven projection: the write side emits OrderPlaced, the projection
// keeps the read model current. Decoupled, asynchronous, eventually consistent.
interface OrderPlaced {
  readonly type: "OrderPlaced";
  readonly orderId: string;
  readonly customerId: string;
  readonly totalCents: number;
  readonly placedAt: string;
}

class OrderSummaryProjection {
  constructor(private readonly summaries: OrderSummaryStore) {}

  async on(event: OrderPlaced): Promise<void> {
    await this.summaries.upsert({
      orderId: event.orderId,
      customerId: event.customerId,
      status: "placed",
      totalCents: event.totalCents,
      placedAt: event.placedAt,
    });
  }
}
```

On a shared store you often need none of this: the read side can query the same
tables (or a database view over them) the write side just updated, and the
update is already consistent.

## 10. Consistency

A persistent misconception is that CQRS forces eventual consistency. It does
not. Eventual consistency is a consequence of a **separate or asynchronously
updated read store**, not of the command/query split itself.

- On a **shared store**, the read side can read the data the write side just
  committed, so reads can be **strongly consistent**.
- With a **separate read store** updated after the write, there is a window in
  which the read model is stale. Microsoft states it plainly: "when the read
  databases and write databases are separated, the read data might not show the
  most recent changes", and "this delay results in stale data".

So consistency is a deliberate choice that follows from the storage topology,
not a tax the pattern imposes. If a use case needs read-your-writes
consistency, design for it: read from the write side for that one case, read
from a shared store, or surface the staleness window in the user experience.
Choosing a separate read store means accepting eventual consistency and
building for it; it is not implied by deciding to separate commands from
queries.

## 11. The relationship to event sourcing

CQRS and event sourcing are distinct patterns that pair naturally, and the
relationship is **asymmetric**:

- **CQRS does not require event sourcing.** The running example uses a
  conventional current-state write model and no events at all. You can apply
  CQRS with ordinary aggregates persisted as rows.
- **Event sourcing effectively implies CQRS.** When state is stored as a stream
  of events, the event-sourced aggregates are the write model and the
  projections built from the stream are the read model, so the command/query
  split is already present. This is why the two are so often taught together.

The `event-sourcing` skill covers the write-side mechanics (the event store,
rehydration, optimistic concurrency, snapshots) and the projection mechanics
(idempotency, ordering, rebuildable read models). This skill covers the
command/query split in its own right, including the case where there is no
event store at all. Reach for `event-sourcing` when the write model is a stream
of events; stay here when it is not.

## 12. The relationship to domain-driven design and hexagonal architecture

**Domain-driven design.** CQRS is not part of DDD, but it composes cleanly with
it. The write model is naturally a tactical aggregate with a repository, guarded
by invariants (see `ddd-tactical-design`); the read model is outside the domain
model entirely, a denormalised view with no behaviour. Keeping queries out of
the aggregate is also what stops the aggregate from growing read-shaped getters
that distort its design.

**Hexagonal architecture.** A common and convenient way to wire CQRS is to treat
command handlers and query handlers as primary (driving) ports, with the write
store and the read store behind secondary (driven) ports, composed at the
composition root (see `hexagonal-architecture` and `dependency-injection`). This
pairing is a community convention, not doctrine: no canonical CQRS source
(Young, Fowler, Dahan, the Microsoft guidance) mandates a hexagonal structure.
Present it as your architectural choice, and do not claim CQRS requires it.

## 13. Buses, mediators, and what is out of scope

CQRS is frequently shown alongside a **command bus** or **mediator** that
dispatches each command to its handler, a **query bus** for queries, **message
brokers** for delivering events to projections, and **sagas** or process
managers for long-running coordination. These are useful, but they are delivery
and coordination machinery, not part of CQRS itself. Young is explicit that
"CQRS does not require a message bus". A direct method call from a controller to
a handler is a complete CQRS implementation.

This skill deliberately stops at the command/query split and its read and write
models. Add a bus, a mediator, or a broker when you have a concrete need (cross-
cutting handler middleware, asynchronous delivery, fan-out to many consumers),
and reach for the relevant messaging or event-sourcing material when you do, not
because CQRS is thought to demand it.

## 14. When not to apply

CQRS adds a second model, and a second model is overhead unless the asymmetry
between writing and reading repays it. The Microsoft guidance lists the cases
where it does not fit, and they are the cases to watch for.

CQRS fits when:

- The domain has rich, rule-heavy writes whose model is awkward to query
  directly.
- Read shapes differ substantially from the write shape, or many different read
  shapes are needed from the same data.
- Reads and writes have very different load or scaling profiles and benefit from
  scaling independently.
- The team can absorb the extra moving parts, and ideally the work is already
  event-driven so projections add little.

CQRS is a poor fit when:

- The domain is simple CRUD: the read shape and the write shape coincide and the
  rules are few. One model is simpler, and Fowler warns CQRS can be "a
  significant drag on productivity" where it is forced. The Microsoft guidance
  agrees it "might not be suitable when... a simple CRUD-style user interface and
  data access operations are sufficient".
- It is being considered as the top-level architecture of a whole application.
  Scope it to the one bounded context with the genuine asymmetry instead.
- The team would, in adopting it, also adopt separate stores, messaging, and
  event sourcing without needing them. That bundle is the dominant failure mode:
  the cost of the infrastructure is paid, but the benefit of the simple
  command/query split is all that was required.

The pragmatic default: most of a system is CRUD, so keep most of it CRUD. Apply
CQRS to the part where writes and reads truly diverge, start at the shared-store
level, and move to separate stores only when a measured need justifies the
synchronisation and the eventual consistency it brings.
