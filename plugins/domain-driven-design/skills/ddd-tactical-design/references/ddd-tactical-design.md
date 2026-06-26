# DDD tactical design reference

The detailed reference behind the `ddd-tactical-design` skill: canonical definitions
for entities, value objects, aggregates, domain events, repositories, domain services,
factories, and modules; Vernon's four aggregate design rules with a worked example;
the anemic domain model anti-pattern; and a pragmatic analysis of when not to apply
the full building-block set, all with attributed sources and internally consistent
TypeScript examples.

Standards and sources:

- Eric Evans, *Domain-Driven Design: Tackling Complexity in the Heart of Software*
  (2003): the foundational text introducing the tactical building blocks.
- Eric Evans, *Domain-Driven Design Reference: Definitions and Pattern Summaries*
  (2015,
  [domainlanguage.com](https://www.domainlanguage.com/wp-content/uploads/2016/05/DDD_Reference_2015-03.pdf)):
  the condensed, freely available reference, including domain events as a first-class
  building block.
- Vaughn Vernon, *Implementing Domain-Driven Design* (2013): the comprehensive
  implementation guide for all tactical building blocks.
- Vaughn Vernon, *Effective Aggregate Design* (2011,
  [dddcommunity.org](https://dddcommunity.org/wp-content/uploads/files/pdf_articles/Vernon_2011_1.pdf)):
  the three-part article series articulating the four aggregate design rules.
- Martin Fowler, [ValueObject](https://martinfowler.com/bliki/ValueObject.html) and
  [EvansClassification](https://martinfowler.com/bliki/EvansClassification.html)
  bliki entries: community-standard short definitions of the two fundamental object
  categories.
- Martin Fowler, [DDD_Aggregate](https://martinfowler.com/bliki/DDD_Aggregate.html)
  bliki entry: the concise aggregate and aggregate root definition.
- Martin Fowler, [AnemicDomainModel](https://martinfowler.com/bliki/AnemicDomainModel.html)
  bliki entry: the anemic domain model classified as an anti-pattern.
- Martin Fowler, [DomainEvent](https://martinfowler.com/eaaDev/DomainEvent.html)
  (eaaDev): domain events in the context of enterprise application patterns.
- Vlad Khononov, *Learning Domain-Driven Design* (2021,
  [vladikk.com](https://vladikk.com/)): the modern restatement of tactical building
  blocks and the heuristics for matching them to subdomain classifications.

---

## 1. Entity: identity, equality, and lifecycle

### Definition

An entity is a domain concept whose identity persists through time and state changes.
The identity distinguishes one entity instance from all others, even when their
attributes are identical: two customers with the same name and address are not the
same customer if they hold different identifiers. Two references to the same identifier
point to the same customer regardless of how the attributes have changed since
creation.

Evans establishes entities as one of the two fundamental object categories in domain
modelling, alongside value objects (Evans, Domain-Driven Design (2003); see also
Fowler, EvansClassification). Three consequences follow from this definition:

**Equality is identity-based.** Comparing two entity instances means comparing their
identifiers, not their attributes. Giving entities attribute-based equality is a
common misconception and leads to subtle bugs when the same entity appears in two
states at once (one freshly loaded from storage, one modified in memory).

**The identifier is stable.** It does not change with the state of the entity. A
`CustomerId` assigned at creation remains the same identifier after the customer
changes name, address, email, or loyalty tier.

**Lifecycle is tracked.** An entity is created, modified over time, and eventually
deleted or archived. The identity persists through all those transitions. The domain
model should express state transitions as explicit methods, not as external attribute
assignments, so that invariants and business rules are enforced at the point of
change.

The identifier may be a system-assigned UUID, a domain-assigned value such as an
invoice number meaningful to the business, or a natural key such as an employee badge
number. The choice must be explicit, stable, and meaningful to the domain rather than
an implementation artefact. Branded string types in TypeScript make identifiers
structurally distinct from one another and from bare strings, so that passing an
`OrderId` where a `CustomerId` is expected fails at compile time.

### TypeScript example

```typescript
// CustomerId is a branded string type: a string at runtime, but statically
// distinct from a bare string and from any other identifier type.
type CustomerId = string & { readonly _brand: 'CustomerId' };

class Customer {
    constructor(
        readonly id: CustomerId,
        private name: string,
        private loyaltyTier: 'STANDARD' | 'GOLD'
    ) {
    }

    get tier(): 'STANDARD' | 'GOLD' {
        return this.loyaltyTier;
    }

    rename(newName: string): void {
        if (!newName.trim()) throw new Error('Name cannot be blank');
        this.name = newName;
    }

    upgrade(): void {
        this.loyaltyTier = 'GOLD';
    }

    // Identity equality: two Customer instances are the same entity if and only if
    // their identifiers match. Attribute values are irrelevant to equality.
    equals(other: Customer): boolean {
        return this.id === other.id;
    }
}
```

### When not to apply

Not every persistent object with a database row identifier is an entity worth
modelling as one in the domain. A look-up row in a reference table, a configuration
record that is loaded once and never mutated, or any concept that domain experts never
distinguish by identity ("give me that specific tax band") may be a simple value read
from storage rather than a tracked entity with a lifecycle.

---

## 2. Value object: value equality and immutability

### Definition

A value object is a domain concept defined entirely by its attributes. There is no
meaningful identity beyond those attributes: two `Money` instances representing fifty
euros are interchangeable. The client code does not care which specific instance it
holds; it cares only about the value represented.

Fowler consolidates the community definition: value objects are objects whose equality
is determined by the value of their properties rather than by any conceptual identity;
even compound structures such as money amounts and date ranges qualify as value objects
when they carry no independent identity
(Fowler, [ValueObject](https://martinfowler.com/bliki/ValueObject.html)).

Three properties define a value object:

**Value equality.** Two instances with identical attributes are equal, regardless of
whether they are the same runtime object.
`new Money(50, 'EUR').equals(new Money(50, 'EUR'))` returns `true`.

**Immutability.** A value object never changes after construction. Operations that
would change its value produce a new instance instead. `add` on `Money` returns a
new `Money` rather than mutating the receiver, eliminating a class of aliasing bugs
entirely.

**Side-effect-free operations.** Methods on a value object depend only on the
instance's own attributes and their parameters. They do not modify external state and
they return new value objects or plain values.

Use value objects aggressively. The instinct to make every concept that will be stored
an entity is a common source of unnecessary complexity. A postal address, a price, a
date range, a telephone number, an email address, a geographic coordinate: all of
these are typically value objects, and modelling them as such makes the domain model
expressive and concise.

### TypeScript example

```typescript
class Money {
    constructor(
        readonly amount: number,
        readonly currency: string
    ) {
        if (amount < 0) throw new Error('Amount cannot be negative');
        if (!currency.trim()) throw new Error('Currency cannot be blank');
    }

    add(other: Money): Money {
        if (other.currency !== this.currency) {
            throw new Error(`Currency mismatch: ${this.currency} vs ${other.currency}`);
        }
        return new Money(this.amount + other.amount, this.currency);
    }

    multiply(factor: number): Money {
        if (factor < 0) throw new Error('Factor cannot be negative');
        return new Money(this.amount * factor, this.currency);
    }

    equals(other: Money): boolean {
        return this.amount === other.amount && this.currency === other.currency;
    }
}

// Usage:
// const price = new Money(50, 'EUR');
// const tax   = new Money(10, 'EUR');
// const total = price.add(tax);   // new Money(60, 'EUR'); price and tax unchanged
// price.equals(new Money(50, 'EUR')); // true
```

`Money` enforces its own invariants in the constructor. Any `Money` instance in the
system is valid by construction, without relying on callers to remember validation
rules.

### When not to apply

A value object is overkill for a field with no invariant and no behaviour. A plain
`string` status flag stored in a database column and passed through the system
unchanged does not benefit from a class with an `equals` method. Introduce the wrapper
only when the concept carries behaviour, an invariant to enforce, or a meaningful
equality comparison that differs from JavaScript's default reference comparison.

---

## 3. Aggregate and aggregate root

### Definition

An aggregate is a cluster of entities and value objects treated as a single unit for
the purpose of data changes. One entity in the cluster is the aggregate root; all
external references to any object in the cluster must go through the root. The
aggregate boundary is simultaneously the consistency boundary and the transaction
boundary.

Evans introduces aggregates to address the challenge that enforcing consistency across
a large, interconnected object graph is practically impossible: the consistency rules
are unclear, the locking scope is ambiguous, and concurrent access causes contention
(Evans, Domain-Driven Design (2003)). An aggregate answers the question "what set of
objects must be consistent at the end of a transaction?" with a deliberate,
domain-driven answer. Fowler's bliki entry gives the core rule concisely: an aggregate
is a cluster of domain objects treated as a single unit, with one component designated
as the aggregate root; all references from outside the aggregate pass through the root,
which is responsible for ensuring the integrity of the aggregate as a whole
(Fowler, [DDD_Aggregate](https://martinfowler.com/bliki/DDD_Aggregate.html)).

### Vernon's four rules

Vernon's three-part series "Effective Aggregate Design" (2011) distils the practical
rules for drawing aggregate boundaries correctly:

**Rule 1: Model true invariants in the consistency boundary.** If a business rule
must hold atomically across a set of objects, those objects belong in the same
aggregate. If the rule can be satisfied eventually, they do not. The aggregate
boundary should be as small as the true invariants allow; anything larger is an
unnecessary grouping.

**Rule 2: Design small aggregates.** A large aggregate invites contention: saving or
loading it locks more data than any single operation needs. Small aggregates reduce
transaction cost, improve throughput under concurrent load, and make the true
invariants easier to identify and enforce. Default to the smallest possible boundary
and grow only when a real invariant forces it.

**Rule 3: Reference other aggregates by identity, not by direct object reference.**
Holding an object reference to another aggregate root silently couples the
consistency boundaries and makes it tempting to mutate the referenced aggregate
through the reference. Holding only an identifier keeps boundaries explicit and
prevents loading an entire object graph by traversal.

**Rule 4: Use eventual consistency outside the boundary.** When a change in one
aggregate must trigger a change in another, do it through a domain event and a
separate transaction, not by including both aggregates in one transaction. One
transaction, one aggregate.

(Vernon, Effective Aggregate Design (2011))

### Worked example

The `Order` aggregate below demonstrates all four rules in a single bounded context:

- `Order` is the aggregate root. All mutations to the `OrderLine` entities inside the
  boundary go through `Order`, never directly.
- `OrderLine` is a child entity within the aggregate. It has its own identity (for
  equality within the collection) but is not independently addressable from outside.
- `customerId: CustomerId` holds a reference to the `Customer` aggregate by identity
  only (rule 3). No `Customer` object lives inside `Order`.
- `place()` guards the invariant "an order must have at least one line item before it
  can be placed" and emits a domain event so that cross-aggregate reactions can happen
  in a separate transaction (rule 4). See section 4 for the full domain event
  discussion.

```typescript
type OrderId = string & { readonly _brand: 'OrderId' };
type OrderLineId = string & { readonly _brand: 'OrderLineId' };
type ProductId = string & { readonly _brand: 'ProductId' };

// DomainEvent is the base marker interface for all domain events; see section 4.
interface DomainEvent {
    readonly type: string;
}

// OrderPlaced is declared here so Order.place() can construct it type-safely.
// Section 4 introduces domain events as a first-class building block and
// annotates this interface in full.
interface OrderPlaced extends DomainEvent {
    readonly type: 'OrderPlaced';
    readonly orderId: OrderId;
    readonly customerId: CustomerId;
    readonly placedAt: Date;
}

// OrderLine is a child entity within the Order aggregate boundary.
// External code cannot access or mutate OrderLine instances directly.
class OrderLine {
    constructor(
        readonly id: OrderLineId,
        readonly productId: ProductId,
        readonly quantity: number,
        readonly unitPrice: Money      // Money defined in section 2
    ) {
        if (quantity < 1) throw new Error('Quantity must be at least 1');
    }

    get total(): Money {
        return this.unitPrice.multiply(this.quantity);
    }

    // Entity equality: by identity, not by attributes.
    equals(other: OrderLine): boolean {
        return this.id === other.id;
    }
}

// Order is the aggregate root and the sole entry point for state changes within
// the order boundary.
class Order {
    private readonly _lines: OrderLine[] = [];
    private readonly _events: DomainEvent[] = [];

    constructor(
        readonly id: OrderId,
        readonly customerId: CustomerId   // CustomerId defined in section 1; identity only
    ) {
    }

    addLine(line: OrderLine): void {
        // Invariant: no two line items may reference the same product within one order.
        if (this._lines.some(l => l.productId === line.productId)) {
            throw new Error(`Product ${line.productId} already exists in this order`);
        }
        this._lines.push(line);
    }

    place(): void {
        // Invariant: an order must contain at least one line item before placement.
        if (this._lines.length === 0) {
            throw new Error('Cannot place an order with no line items');
        }
        // Emit a domain event; cross-aggregate side-effects happen in a separate
        // transaction driven by an event handler, not here (Vernon's rule 4).
        const event: OrderPlaced = {
            type: 'OrderPlaced',
            orderId: this.id,
            customerId: this.customerId,
            placedAt: new Date()
        };
        this._events.push(event);
    }

    get total(): Money {
        // Simplified: assumes all line items share the same currency.
        return this._lines.reduce((sum, l) => sum.add(l.total), new Money(0, 'EUR'));
    }

    // Extract and clear pending events for dispatch by the application layer.
    pullEvents(): DomainEvent[] {
        const events = [...this._events];
        this._events.length = 0;
        return events;
    }
}
```

### When not to apply

Not every cluster of related objects should be an aggregate. If two objects simply
appear together in a query result but share no invariant that must hold atomically,
grouping them in one aggregate adds locking cost and boundary complexity without any
consistency benefit. Resist the urge to aggregate by "things that belong together"
and aggregate only by "things that must change together safely."

---

## 4. Domain event

### Definition

A domain event represents something significant that happened in the domain, something
the domain experts care about and that other parts of the system may need to react to.
It is named in the past tense and in the ubiquitous language: `OrderPlaced`,
`PaymentRefunded`, `CustomerUpgraded`. The event is immutable: it records what
happened and when, and it does not change after creation.

Domain events appear in the DDD Reference as a first-class tactical building block
(Evans, DDD Reference (2015)). Vernon uses them as the mechanism for cross-aggregate
communication and eventual consistency (Vernon, Implementing Domain-Driven Design
(2013)), and Fowler traces the enterprise-application pattern back to the need to
capture and propagate significant state changes in a decoupled way (Fowler,
[DomainEvent](https://martinfowler.com/eaaDev/DomainEvent.html)).

The aggregate root collects domain events as part of its state mutation (as shown in
section 3's `Order.place()`). The application service retrieves them after saving the
aggregate and publishes them to whichever bus or handler is configured at the
composition root. This keeps the domain layer free of infrastructure concerns: the
aggregate emits events as plain value objects; it does not publish to a bus.

### TypeScript example

`OrderPlaced` is declared in section 3 alongside the `Order` aggregate so that
`Order.place()` can construct it type-safely. It is restated here with full
annotation as the worked example for this section:

```typescript
// OrderPlaced is emitted by Order.place() and collected via Order.pullEvents().
// All fields are readonly: a domain event is a record of the past; it cannot change.
interface OrderPlaced extends DomainEvent {
    readonly type: 'OrderPlaced';
    readonly orderId: OrderId;       // OrderId defined in section 3
    readonly customerId: CustomerId; // CustomerId defined in section 1
    readonly placedAt: Date;
}
```

The event carries the information a handler needs to act without querying the
emitting aggregate again. Fields are plain identifiers and value types, not object
references, so the event can cross process boundaries without additional serialisation
concerns.

### Relationship to CQRS and event sourcing

CQRS (Command Query Responsibility Segregation) and event sourcing are separate
patterns that frequently appear alongside domain events, but they are distinct
concerns. Domain events are a tactical building block in the domain layer: an
aggregate emits them to signal state changes. CQRS separates the write model from the
read model. Event sourcing persists the aggregate's history as a sequence of events
rather than as a current-state snapshot. Either pattern may use domain events, but
neither is required to use them, and domain events do not require either. Both CQRS
and event sourcing are planned as future plugins; they are out of scope here.

### When not to apply

Not every state change in the system warrants a domain event. If no other part of the
system reacts to a change, and if the change carries no business significance beyond
updating a field, a domain event adds indirection without value. Emit events for the
things domain experts would discuss ("the order was placed", "the payment was
refunded") and not for every setter.

---

## 5. Repository

### Definition

A repository provides collection-like access to aggregate roots, abstracting the
mechanics of storage so that the domain layer can retrieve and persist aggregates
without depending on any persistence technology. From the domain's perspective, a
repository behaves like an in-memory collection: you can find aggregates by
identity or by domain-specific criteria, and you can save them back. The storage
engine, the query language, and the mapping strategy are invisible to the domain.

Evans establishes the repository concept as the mechanism that allows the domain model
to speak in domain terms while infrastructure handles the storage details (Evans,
Domain-Driven Design (2003)). Three rules follow:

**One repository per aggregate root.** A repository is not a generic persistence
helper; it serves one specific aggregate root. You do not create a repository for
`OrderLine` because `OrderLine` is only accessible through `Order`, and `Order` is
the root that is saved and retrieved.

**Express the interface in the ubiquitous language.** Repository methods name domain
concepts, not persistence operations. `findUnpaidByCustomer` is a domain method;
`selectFromOrdersWhereStatusEqualsUnpaidAndCustomerIdEquals` is a query leaking into
the interface.

**A repository is not a DAO.** A data access object (DAO) is a thin wrapper around a
persistence technology; its interface mirrors the database operations. A repository
interface belongs to the domain layer and is defined there; the infrastructure
provides an implementation. The distinction is direction of dependency: the domain
owns the repository interface, and the infrastructure depends on it, not the other way
around.

This is why the `hexagonal-architecture` skill classifies a repository interface as a
secondary (driven) port: the core declares what it needs; an infrastructure adapter
implements it. See the `hexagonal-architecture` skill and reference for the structural
wiring.

A repository also differs from a factory. A factory creates a new instance that did
not previously exist; a repository retrieves an existing instance. The two are
complementary and should not be merged.

### TypeScript example

```typescript
// OrderRepository is a secondary (driven) port: the interface is defined in the
// domain layer and implemented in the infrastructure layer. The implementation
// (backed by a database, an ORM, or an in-memory store) is chosen at the
// composition root and injected into application services.
interface OrderRepository {
    findById(id: OrderId): Promise<Order | null>;

    findByCustomer(customerId: CustomerId): Promise<Order[]>;

    findUnpaid(): Promise<Order[]>;

    save(order: Order): Promise<void>;
}

// Usage in application code (see also section 6):
// const order = await orderRepository.findById(id);
// if (!order) throw new Error('Order not found');
// order.place();
// await orderRepository.save(order);
```

The method names (`findByCustomer`, `findUnpaid`) come from the ubiquitous language.
They express what the domain needs to know, not how storage is queried.

### When not to apply

If an aggregate root is always created and consumed within a single unit of work,
never retrieved in isolation, and never the target of an independent query, a
repository adds infrastructure for a retrieval pattern that never occurs. In practice
this is rare for true aggregate roots, but it is common for supporting subdomain
objects where plain CRUD is sufficient.

---

## 6. Domain service versus application service

### Definition and distinction

Not all domain logic belongs on a single entity or value object. When a concept
involves multiple aggregates, or when computing a domain answer requires input that
does not naturally sit on any single object, a domain service is the right home.

A domain service is:

- **Stateless.** It holds no mutable state of its own; its behaviour depends only on
  its parameters.
- **Named for a domain concept.** `LoyaltyDiscountService`, not `DiscountHelper` or
  `OrderProcessor`.
- **Expressed in the domain layer.** It depends on domain objects (aggregates, value
  objects, other domain services) and on nothing from the infrastructure layer.

An application service is fundamentally different. It orchestrates a use case: it
loads aggregates from repositories, invokes domain services and domain logic, saves
the results, and publishes domain events. An application service contains no business
rule itself. If you find a business rule in an application service, it has leaked from
the domain. Evans describes the distinction explicitly (Evans, Domain-Driven Design
(2003)), and Fowler's EvansClassification bliki entry maps the two service types
clearly (Fowler, [EvansClassification](https://martinfowler.com/bliki/EvansClassification.html)).

The practical test: if you removed the application service and drove the domain
directly from a test, would the business rule still be enforced? Yes, because it lives
in the aggregate or the domain service. If the rule disappeared, it was in the
application service and it should not have been.

### TypeScript example

```typescript
// --- Domain service ---
// LoyaltyDiscountService encapsulates domain logic that spans two aggregates:
// it needs the Order total (from the Order aggregate) and the customer's loyalty
// tier (from the Customer aggregate, defined in section 1).
// It is stateless and holds no infrastructure dependency.
class LoyaltyDiscountService {
    computeDiscount(order: Order, customer: Customer): Money {
        const rate = customer.tier === 'GOLD' ? 0.15 : 0;
        return order.total.multiply(rate);  // Money defined in section 2
    }
}
```

```typescript
// --- Application service ---
// PlaceOrderUseCase orchestrates the PlaceOrder use case: load, delegate to the
// domain, save, publish events. No business rule lives here.

interface PlaceOrderCommand {
    readonly orderId: OrderId;
}

interface EventBus {
    publish(event: DomainEvent): Promise<void>;
}

class PlaceOrderUseCase {
    constructor(
        private readonly orders: OrderRepository,        // secondary port; see section 5
        private readonly eventBus: EventBus
    ) {
    }

    async execute(command: PlaceOrderCommand): Promise<void> {
        const order = await this.orders.findById(command.orderId);
        if (!order) throw new Error('Order not found');

        // A discount-applying use case would load the Customer and call LoyaltyDiscountService here; PlaceOrder deliberately carries no such rule.
        // The business rule "an order must have at least one line item" is enforced
        // inside order.place(), not here.
        order.place();

        await this.orders.save(order);

        for (const event of order.pullEvents()) {
            await this.eventBus.publish(event);
        }
    }
}
```

The contrast is deliberate: `order.place()` contains the business rule and raises an
error on violation; `PlaceOrderUseCase.execute` contains no domain logic and would
not know how to enforce it.

### When not to apply

Do not reach for a domain service merely because two aggregates appear in the same
use case. If the logic can be expressed entirely within one aggregate, it belongs
there. A domain service is justified only when the logic genuinely spans concepts that
no single aggregate should own.

Similarly, an application service that is nothing but boilerplate (load, call one
method, save) may not need to be a formal class. A module-level function or a thin
controller method can serve the same purpose without adding a named type.

---

## 7. Factory

### Definition

A factory encapsulates the construction logic required to create a valid, consistent
entity, value object, or whole aggregate when that construction is too complex or too
important for a plain constructor. Complexity may arise from multi-step initialisation,
from enforcing atomic creation invariants across several objects, or from translating
input data (a command object, a set of cart items) into a valid aggregate state.

Evans establishes factories as a dedicated tactical building block when construction
logic is non-trivial (Evans, Domain-Driven Design (2003)). Khononov restates the
practical guideline: a factory should be introduced only when construction requires
logic that is inappropriate for the constructor itself (Khononov, Learning DDD (2021)).

Two distinctions to hold clearly:

- **Factory versus constructor.** When a plain constructor suffices to create a valid
  instance, do not add a factory (YAGNI). The factory earns its place only when
  construction is complex enough to need encapsulation.
- **Factory versus repository.** A factory creates a new instance that did not
  previously exist; a repository retrieves an existing one. Never use a factory to
  retrieve stored aggregates, and never build creation logic into a repository.

### TypeScript example

```typescript
interface CartItem {
    productId: ProductId;  // ProductId defined in section 3
    quantity: number;
    unitPrice: Money;      // Money defined in section 2
}

// OrderFactory.create assembles a valid Order from a set of cart items in a
// single atomic operation. It generates identifiers, delegates to the aggregate's
// own addLine guard (which enforces the no-duplicate-product invariant), and
// returns an order that is valid by construction.
class OrderFactory {
    static create(customerId: CustomerId, items: CartItem[]): Order {
        if (items.length === 0) {
            throw new Error('Cannot create an order from an empty cart');
        }

        const orderId = crypto.randomUUID() as OrderId;
        const order = new Order(orderId, customerId);

        for (const item of items) {
            const lineId = crypto.randomUUID() as OrderLineId;
            order.addLine(
                new OrderLine(lineId, item.productId, item.quantity, item.unitPrice)
            );
        }

        // The returned order is in a valid, assembled state.
        // No caller has to remember to add lines or sequence construction steps.
        return order;
    }
}
```

`crypto.randomUUID()` is available in Node.js 14.17+ and all modern browsers. In
environments without it, substitute any UUID generation that fits the deployment
context.

### When not to apply

A factory is overkill when the aggregate's own constructor can enforce all creation
invariants directly. Adding a factory layer for a two-line constructor is indirection
without abstraction. Prefer the constructor until the construction complexity justifies
the additional type.

---

## 8. Modules

### Definition

A module is a named, cohesive, low-coupling partition of the domain model. Modules
organise the building blocks of a bounded context into conceptual groups that domain
experts recognise and reason about together. The name of each module belongs to the
ubiquitous language: `ordering`, `pricing`, `fulfilment`, not `services`, `helpers`,
or `utils`.

Evans introduces modules as a mechanism to manage complexity within a bounded context
(Evans, Domain-Driven Design (2003)). The coupling and cohesion criteria are standard
object-oriented principles, but the naming criterion is distinctive: naming modules
after technical concerns rather than domain concepts is a sign that the ubiquitous
language has not been reflected in the code's structure.

Two guidelines follow:

**Group by domain concept, not by technical layer.** A module named `OrderAggregate`
groups the things the domain expert calls "the order domain": the `Order` root,
`OrderLine`, `OrderPlaced`, and the `OrderRepository` interface. A folder structure
that groups all `*Service` files together and all `*Repository` files together
reflects a technical taxonomy, not a domain one.

**Keep modules low-coupling.** Objects in one module should not hold direct object
references to objects in another module. Use identifiers for cross-module reference,
the same principle Vernon recommends for cross-aggregate reference. This makes each
module's consistency boundary explicit and makes the context map within the bounded
context readable.

### TypeScript example

```typescript
// ordering/index.ts -- public surface of the ordering module.
//
// Internal structure:
//   ordering/
//     Order.ts           (aggregate root; section 3)
//     OrderLine.ts       (child entity; section 3)
//     events/
//       OrderPlaced.ts   (domain event; section 4)
//     OrderRepository.ts (secondary port; section 5)
//
// All exported names belong to the ubiquitous language of the ordering subdomain.
// Consumers import from this barrel and never reach into the internal folder structure.

export type { OrderId, OrderLineId } from './Order';
export { Order } from './Order';
export { OrderLine } from './OrderLine';
export type { OrderPlaced } from './events/OrderPlaced';
export type { OrderRepository } from './OrderRepository';

// Example consumer (in a sibling module such as fulfilment):
//   import { Order, OrderRepository } from '../ordering';
//
// Internal reorganisation (renaming a file, extracting a subdirectory) does not
// break external importers as long as the barrel re-exports remain stable.
```

The barrel pattern is a direct expression of the module guideline: one named export
surface per domain concept grouping. A consumer importing `{ Order, OrderRepository }`
from `'../ordering'` is coupling to the module boundary, not to a file path. Changing
the internal structure does not break external code.

### When not to apply

In a small bounded context with a handful of aggregates, explicit module boundaries
add folder structure and naming ceremony without a payoff in navigability or
discipline. Introduce formal module separation when the bounded context grows large
enough that navigating it without conceptual partitions becomes difficult, or when
different teams own different parts of the model.

---

## 9. Pragmatic cautions and misconceptions

The following pitfalls appear repeatedly in codebases that use tactical DDD vocabulary
without applying the underlying principles.

### The anemic domain model

The anemic domain model is an anti-pattern in which domain objects are data bags
(plain fields, getters, setters) and all business logic lives in service objects.
Fowler classifies it as an anti-pattern explicitly:

> "The fundamental horror of this anti-pattern is that it's so contrary to the basic
> idea of object-oriented design; which is to combine data and process together."
> (Fowler, [AnemicDomainModel](https://martinfowler.com/bliki/AnemicDomainModel.html))

An anemic model pays the full cost of DDD's object structure (extra types, mappings,
indirection) while surrendering the main benefit (business rules enforced by the
objects that own the data they govern). The fix is to push behaviour into entities and
value objects: `order.place()` instead of `orderService.place(order)`.

### Large aggregates

The instinct to group everything that "belongs to" an order into one `Order` aggregate
is almost always wrong. A large aggregate invites contention under concurrent access,
increases transaction cost, and hides the true invariants by grouping objects that do
not actually need to change together. Vernon's second rule is the corrective: default
to small and grow only when a real invariant forces a larger boundary (Vernon,
Effective Aggregate Design (2011)).

### Not every entity is an aggregate root

An entity that lives inside an aggregate boundary is not an aggregate root. Promoting
every entity to aggregate root status means providing a repository for it and allowing
external access to it directly, which breaks the consistency boundary. Promote an
entity to aggregate root only when it must own a consistency boundary independently.

### Not every aggregate root needs a repository

A repository exists to retrieve an aggregate root that was previously stored. If an
aggregate root is only ever created within a unit of work and never independently
retrieved, a repository for it is premature infrastructure. Add the repository when
retrieval is a genuine use case, not by reflex.

### Repository is not a DAO

A data access object wraps a persistence technology and provides CRUD operations
shaped by the storage engine. A repository interface belongs to the domain layer and
is shaped by domain needs. Naming a class `OrderRepository` does not make it a
DDD repository if it exposes SQL-shaped methods, accepts raw persistence types, or
lives in the infrastructure layer without a corresponding domain interface. The
direction of dependency is the test: the domain layer declares the interface; the
infrastructure layer implements it.

### Full tactical machinery is overkill for CRUD slices

Tactical DDD is designed for complex domains with rich invariants, non-trivial object
lifecycles, and rules that the domain expert can articulate. Applied to a slice that
is substantially data entry, a list view, and a save operation, the full building-block
set adds layers, mappings, and types that serve no domain purpose. As the `SKILL.md`
notes and as the `ddd-strategic-design` reference elaborates, tactical depth belongs
in the core subdomain. Supporting subdomains deserve simpler treatment, and generic
subdomains belong to off-the-shelf solutions. Match the investment to the actual
invariant surface; do not apply aggregates, domain events, and factories to concepts
the domain expert describes in a single sentence with no exceptions.

---

## Sources

- Eric Evans, *Domain-Driven Design: Tackling Complexity in the Heart of Software*,
  Addison-Wesley, 2003.
- Eric Evans, *Domain-Driven Design Reference: Definitions and Pattern Summaries*,
    2015.
  [https://www.domainlanguage.com/wp-content/uploads/2016/05/DDD_Reference_2015-03.pdf](https://www.domainlanguage.com/wp-content/uploads/2016/05/DDD_Reference_2015-03.pdf)
- Vaughn Vernon, *Implementing Domain-Driven Design*, Addison-Wesley, 2013.
- Vaughn Vernon, *Effective Aggregate Design* (three-part article series), DDD
  Community, 2011.
  [https://dddcommunity.org/wp-content/uploads/files/pdf_articles/Vernon_2011_1.pdf](https://dddcommunity.org/wp-content/uploads/files/pdf_articles/Vernon_2011_1.pdf)
- Martin Fowler, *ValueObject*, martinfowler.com.
  [https://martinfowler.com/bliki/ValueObject.html](https://martinfowler.com/bliki/ValueObject.html)
- Martin Fowler, *EvansClassification*, martinfowler.com.
  [https://martinfowler.com/bliki/EvansClassification.html](https://martinfowler.com/bliki/EvansClassification.html)
- Martin Fowler, *DDD_Aggregate*, martinfowler.com.
  [https://martinfowler.com/bliki/DDD_Aggregate.html](https://martinfowler.com/bliki/DDD_Aggregate.html)
- Martin Fowler, *AnemicDomainModel*, martinfowler.com.
  [https://martinfowler.com/bliki/AnemicDomainModel.html](https://martinfowler.com/bliki/AnemicDomainModel.html)
- Martin Fowler, *DomainEvent*, martinfowler.com.
  [https://martinfowler.com/eaaDev/DomainEvent.html](https://martinfowler.com/eaaDev/DomainEvent.html)
- Vlad Khononov, *Learning Domain-Driven Design*, O'Reilly, 2021.
  [https://vladikk.com/](https://vladikk.com/)
