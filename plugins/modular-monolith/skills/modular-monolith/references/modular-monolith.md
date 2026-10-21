# Modular monolith reference

The detailed reference behind the skill: canonical definitions, boundary design
rules, the role of the host, enforcement techniques, communication patterns,
data isolation rules, trade-off analysis, extraction guidance, and anti-pattern
catalogue.

Standards and sources:
- Kamil Grzybek, [Modular Monolith: A Primer](https://www.kamilgrzybek.com/blog/posts/modular-monolith-primer): canonical definition and design principles.
- Kamil Grzybek, [modular-monolith-with-ddd](https://github.com/kgrzybek/modular-monolith-with-ddd): reference implementation with a thin API host.
- Sam Newman, *Monolith to Microservices*, O'Reilly 2019; [QCon London 2020 talk](https://www.infoq.com/news/2020/05/monolith-decomposition-newman/): taxonomy and extraction strategies.
- Simon Brown, [QCon London, March 2015](https://simonbrown.je/modular-monolith/): the "well-structured monolith" challenge.
- Martin Fowler, [Microservice Trade-Offs](https://martinfowler.com/articles/microservice-trade-offs.html) and [MicroservicePremium](https://martinfowler.com/bliki/MicroservicePremium.html): cost-benefit framing.
- Martin Fowler, [MonolithFirst](https://martinfowler.com/bliki/MonolithFirst.html): the monolith-first argument.
- Shopify Engineering, [Deconstructing the Monolith](https://shopify.engineering/deconstructing-monolith-designing-software-maximizes-developer-productivity) (2019).
- Spring Modulith, [Fundamentals](https://docs.spring.io/spring-modulith/reference/fundamentals.html): module vocabulary and the main package as host.
- Milan Jovanovic, [The Modular Monolith Boundary I Couldn't Take Back](https://www.milanjovanovic.tech/blog/the-modular-monolith-boundary-i-couldnt-take-back): communication guardrail.
- Brian Foote and Joseph Yoder, [Big Ball of Mud](https://www.laputan.org/mud/), PLoP 1997.
- Nx, [enforce-module-boundaries](https://nx.dev/docs/features/enforce-module-boundaries); dependency-cruiser, [rules reference](https://github.com/sverweij/dependency-cruiser/blob/main/doc/rules-reference.md); pnpm, [workspaces](https://pnpm.io/workspaces).

---

## 1. Definition and taxonomy

A monolith is "a system that has exactly one deployment unit" (Grzybek,
[Modular Monolith: A Primer](https://www.kamilgrzybek.com/blog/posts/modular-monolith-primer)).
"Modular Monolith architecture is an explicit name for a Monolith system
designed in a modular way." The word "monolith" does not imply poor design:
"Monolith architecture does not imply that the system is poor designed, not
modular or bad."

Shopify captures the practical definition: "A modular monolith is a system
where all of the code powers a single application and there are strictly
enforced boundaries between different domains."
([Shopify Engineering, 2019](https://shopify.engineering/deconstructing-monolith-designing-software-maximizes-developer-productivity))

Sam Newman identifies three distinct forms of the monolith (Newman,
[QCon London 2020](https://www.infoq.com/news/2020/05/monolith-decomposition-newman/)):

- **Single-process monolith.** All code in one process, talking to one database.
  No internal structure required.
- **Modular monolith.** "A single process consisting of separate modules, each
  of which can be worked on independently, but which still need to be combined
  for deployment." Strong boundaries, single deploy.
- **Distributed monolith.** "Many services, but everything has to be deployed
  at the same time." The worst of both worlds: all the operational complexity
  of a distributed system with none of the deployment independence.

The symmetry is instructive. Brian Foote and Joseph Yoder defined the "Big Ball
of Mud" (PLoP 1997, [https://www.laputan.org/mud/](https://www.laputan.org/mud/))
as "a casually, even haphazardly, structured system." It stands to the
single-process monolith as the distributed monolith stands to microservices:
both are the failure mode of their respective hosting model.

Simon Brown puts the challenge directly: "if you can't build a well-structured
monolith, what makes you think microservices is the answer?"
([QCon London, March 2015](https://simonbrown.je/modular-monolith/))

### When not to apply this framing

The taxonomy is descriptive, not prescriptive. A small internal tool with two
contributors has no need of named modules. Impose the modular label and the
boundaries that follow only when the system is large enough that informal
coordination would erode structure.

---

## 2. Boundary design

Modules are vertical slices of a business capability, not horizontal
technical layers. Grzybek organizes his reference implementation around
capabilities such as Meetings, Payments, and Registrations, and is explicit
that "the application of layers should not be a global decision for a given
module, each use case should be considered separately."
([Domain-centric design](https://www.kamilgrzybek.com/blog/posts/modular-monolith-domain-centric-design))

A module exposes a public API (its provided interface: exported types,
functions, and published events) and hides all internal implementation
details. Other modules declare a required interface by depending solely on
the public API, never on internals. Spring Modulith formalizes this
vocabulary: provided interface, internal implementation, required interface.
([Spring Modulith Fundamentals](https://docs.spring.io/spring-modulith/reference/fundamentals.html))

Encapsulation is not separable from modularity: "everything that we share
outside becomes the public API of the module. Therefore, encapsulation is an
inseparable element of modularity." (Grzybek, Primer)

### Shared technical code and the shared kernel

Code that several modules need but no module owns has a place of its own,
distinct from both the modules and the host. Two different things answer to
that description, and they must not be confused.

**Building blocks** are technical: the abstractions every module may use
(an event publisher, a unit of work, a clock, a result type) and the plumbing
behind them. Grzybek's reference implementation keeps them in a
`BuildingBlocks` folder beside its modules
([modular-monolith-with-ddd](https://github.com/kgrzybek/modular-monolith-with-ddd)).
Three rules keep them harmless:

- They hold no business rule and no business concept. An entity, an
  aggregate, or a rule found there belongs to a specific module.
- They depend on no module and never on the host. The dependency direction is
  host, then modules, then building blocks; a building block that imports a
  module turns into a hidden hub.
- They are injected, never reached as ambient singletons. A module receives an
  event publisher or a connection through its assembly function; it does not
  import a global instance, which the host could not swap and a test could not
  substitute.

A **shared kernel** is a business decision, not a technical one: in
Domain-Driven Design, a small, explicitly agreed subset of the domain model
co-owned by two named modules, changed only with both sides' consent. It is
legitimate when chosen deliberately and kept small, and the coordination it
costs is the reason it stays rare. Its full treatment as a context-mapping
pattern belongs to the `ddd-strategic-design` skill. A `shared/` folder that
every module feeds with business types is neither: it is the dumping ground of
section 9.

### TypeScript example

```typescript
// payments/index.ts  - the ONLY public entry point for the payments module

export type { PaymentsApi } from "./payments-api";  // the public API (provided interface)
export type { ChargeRequest, ChargeResult } from "./types";
export type { PaymentsModuleDependencies } from "./payments-module"; // what the module needs
export { createPaymentsModule } from "./payments-module"; // assembles the module

// Everything else is internal (NOT re-exported):
// ./handlers/stripe-handler.ts
// ./domain/payment-entity.ts
// ./infrastructure/payments-repository.ts
```

```typescript
// payments/payments-api.ts  - the provided interface and its internal implementation

import { ChargeRequest, ChargeResult } from "./types";
import { StripeHandler } from "./handlers/stripe-handler"; // internal import

// The public API is an interface: the contract other modules depend on.
export interface PaymentsApi {
  charge(request: ChargeRequest): Promise<ChargeResult>;
}

// Exported for payments-module.ts only: the barrel does not re-export it.
export class PaymentsService implements PaymentsApi {
  constructor(private readonly handler: StripeHandler) {}

  async charge(request: ChargeRequest): Promise<ChargeResult> {
    return this.handler.processCharge(request);
  }
}
```

```typescript
// payments/payments-module.ts  - the assembly function the host calls

import { PaymentsApi, PaymentsService } from "./payments-api";
import { StripeHandler } from "./handlers/stripe-handler";

// Only what lies outside the module: typed configuration, shared resources,
// other modules' public APIs. Never one of the module's own internal classes.
export interface PaymentsModuleDependencies {
  stripe: { secretKey: string };
}

export const createPaymentsModule = (
  dependencies: PaymentsModuleDependencies,
): { api: PaymentsApi } => {
  // Internals are built here, inside the boundary, never by the caller.
  const handler = new StripeHandler(dependencies.stripe.secretKey);
  return { api: new PaymentsService(handler) };
};
```

Consumers depend on the `PaymentsApi` interface from `"@myapp/payments"` (the
barrel), never on `"@myapp/payments/handlers/stripe-handler"`. The assembly
function follows the same rule: it asks only for what lies outside the module
and builds every internal itself. A factory that takes an internal class as a
parameter forces its caller to reach past the barrel, which defeats the
boundary it was meant to expose. Configuration arrives typed; the module never
reads the environment (see section 3).

### When not to apply

Do not split a coherent capability into anemic technical layers: a `controllers/`
module, a `services/` module, and a `repositories/` module that all represent
the same domain capability are not modular boundaries, they are an accidental
decomposition that scatters a single concern across three places.

---

## 3. The host

The host is the application entry point: the code that starts the process and
assembles the modules into one running system. Spring Modulith makes it
structural: "The application's main package is the one that the main
application class resides in", and "each direct sub-package of the main package
is considered an application module package."
([Spring Modulith Fundamentals](https://docs.spring.io/spring-modulith/reference/fundamentals.html))
Grzybek's reference implementation describes its host as a "Very thin ASP.NET
MVC Core REST API application", states that the "API contains no application
logic", and that the "API as a host needs to initialize each module and each
module has an initialization method."
([modular-monolith-with-ddd](https://github.com/kgrzybek/modular-monolith-with-ddd))

The host owns no business capability. It is one more consumer of the modules'
public APIs, bound by the same boundary rule as any module, never a module that
knows the others.

What belongs in the host:

- **Process lifecycle**: startup, graceful shutdown, health checks.
- **Configuration**: read from the environment and validated once, at startup,
  then handed to each module as typed values. A module never reads the
  environment itself.
- **Shared technical resources**: database connections (one per module when
  each module has its own database role), the logger, the clock, the
  in-process event bus implementation. Each module still owns its schema,
  its migrations, and its transactions; the host only triggers the migrations
  each module owns.
- **Transport-wide concerns**: authentication, request context (correlation
  identifier, tenant), mapping application errors to the protocol (HTTP status
  codes, message acknowledgements), observability.
- **Assembly**: each module is created through its public API, and a module
  receives the public APIs of the modules it depends on from the host. The
  dependencies between modules become explicit in one place.

What never belongs in the host:

- A business rule or a use case.
- Persistence: no repository, no query against a module's tables.
- Orchestration of writes across modules. A process that spans modules belongs
  to a module, a dedicated process manager when it coordinates several.
- Resource-level authorization. The host establishes who is calling and may
  gate a request on a coarse permission (Grzybek checks permissions at the
  controller level); whether this caller may act on this resource is a rule of
  the owning module.

The dependency direction is fixed: the host depends on modules, modules never
depend on the host. A practical test: replace the host with another one (a CLI,
a worker, a test harness); not a single business rule may be lost.

How the object graph is wired at startup is the composition root, covered by
the `dependency-injection` skill; the ports it injects into a module are the
`hexagonal-architecture` skill's concern. This section only fixes what the host
is allowed to hold.

### TypeScript example: a thin host and its enforcement

```typescript
// src/host/main.ts - the host: starts the process and assembles the modules.
// It reaches each module through its public index.ts and holds no business rule.

import { createOrdersModule } from "@myapp/orders";
import { createPaymentsModule } from "@myapp/payments";
import { loadConfiguration } from "./configuration";
import { createDatabasePool } from "./database";
import { startHttpServer } from "./http-server";

// Fails fast at startup when a variable is missing or invalid.
const configuration = loadConfiguration(process.env);
const database = createDatabasePool(configuration.database);

const payments = createPaymentsModule({ stripe: configuration.stripe });
// The dependency between modules is explicit here: orders receives the
// payments public API and never reaches into payments.
const orders = createOrdersModule({ database, payments: payments.api });

startHttpServer(configuration.http, [payments, orders]);
```

```javascript
// .dependency-cruiser.cjs - keep the host outside the modules
module.exports = {
  forbidden: [
    {
      name: "no-module-to-host",
      severity: "error",
      comment: "Modules never depend on the host; the host depends on modules.",
      from: { path: "^src/modules/" },
      to: { path: "^src/host/" },
    },
    {
      name: "host-through-public-api-only",
      severity: "error",
      comment: "The host reaches a module only through its public index.ts.",
      from: { path: "^src/host/" },
      to: {
        path: "^src/modules/",
        pathNot: ["^src/modules/[^/]+/index\\.ts$"],
      },
    },
  ],
};
```

### When not to apply

A small application with a single module does not need a dedicated host
directory: its `main.ts` is the host. Thin means no business rule, not no code:
configuration validation, error mapping, and observability carry real weight
and stay in the host rather than being pushed into every module. Composing reads
from several modules for one screen (a backend-for-frontend endpoint) is a
legitimate host job as long as it only aggregates and maps, applying no business
rule.

---

## 4. Enforcement in TypeScript / Node

TypeScript has no cross-file `internal` or package-private keyword.
`private`, `protected`, and `public` are class-member modifiers only.
Cross-file encapsulation is always tooling-enforced, never compiler-enforced.
([TypeScript issue #5228](https://github.com/microsoft/TypeScript/issues/5228))

The enforcement options form a ladder from weakest to strongest:

**1. Barrel `index.ts` as the public entry point (convention).** Re-export only
the public surface; leave internals unexported. This is a social contract, not
a hard boundary. Costs include bundler slowdown, broken tree-shaking via
`export *`, and hidden circular dependencies.

**2. Lint rules (structural enforcement).** Two tools cover different setups:

- `@nx/enforce-module-boundaries` tags each library and enforces
  `depConstraints` so that, for example, `scope:admin` can only depend on
  `scope:shared` and `scope:admin`. Deep imports are forbidden by rule; only
  the library `index.ts` is a valid entry point. Circular dependencies are
  flagged. ([Nx docs](https://nx.dev/docs/features/enforce-module-boundaries))
- `dependency-cruiser` (framework-agnostic, no monorepo required) expresses
  forbidden rules with from/to path regexes. A capture group in `from.path`
  is referenced as `$1` inside `to.pathNot`, so a single rule can allow
  intra-module imports while forbidding any cross-module import that does not
  go through the target module's public `index.ts`.
  ([dependency-cruiser rules reference](https://github.com/sverweij/dependency-cruiser/blob/main/doc/rules-reference.md))

**3. Separate pnpm workspace packages with `workspace:*` (strongest).** pnpm's
non-hoisted, symlinked `node_modules` means a package can only resolve
dependencies it explicitly declares. An undeclared cross-package import fails
at resolution, not just at lint time. This is a hard, resolution-level boundary.
([pnpm workspaces](https://pnpm.io/workspaces))

### Correction: TypeScript project references are build orchestration, not encapsulation

TypeScript `composite` mode and project references control build order and
incremental compilation. They do NOT block reach-in imports. A file in module
A can import directly from module B's internals even when project references
are configured. Do not rely on project references to enforce module boundaries.
([TypeScript handbook, project references](https://www.typescriptlang.org/docs/handbook/project-references.html))

### TypeScript example: dependency-cruiser forbidden rule and Nx constraint

```javascript
// .dependency-cruiser.cjs - forbid reaching past another module's public index
module.exports = {
  forbidden: [
    {
      name: "no-cross-module-internals",
      severity: "error",
      comment: "A module may import another module only through its index.ts barrel.",
      from: { path: "^src/modules/([^/]+)/" },
      to: {
        path: "^src/modules/([^/]+)/",
        // $1 is from's capture: allow all intra-module imports,
        // and allow any module's public index.ts entry point.
        pathNot: ["^src/modules/$1/", "^src/modules/[^/]+/index\\.ts$"],
      },
    },
    {
      name: "no-building-blocks-to-module",
      severity: "error",
      comment: "Building blocks depend on no module and never on the host.",
      from: { path: "^src/building-blocks/" },
      to: { path: "^src/(modules|host)/" },
    },
  ],
};
```

```jsonc
// .eslintrc.json - Nx enforce-module-boundaries constraint.
// Tag each library in its project.json (e.g. "tags": ["scope:payments"]),
// then express the allowed dependency directions here:
{
  "rules": {
    "@nx/enforce-module-boundaries": [
      "error",
      {
        "depConstraints": [
          {
            "sourceTag": "scope:payments",
            "onlyDependOnLibsWithTags": ["scope:shared", "scope:payments"]
          }
        ]
      }
    ]
  }
}
```

### When not to apply

For a single application without a monorepo, pnpm workspace packages add
operational complexity that is not warranted. A `dependency-cruiser` forbidden
rule plus code review is sufficient. For a proof-of-concept or a solo project,
barrel `index.ts` convention is usually enough.

---

## 5. Inter-module communication

The default is a direct synchronous call to another module's public API.
This is explicit, type-safe, easy to trace, and requires no infrastructure.

In-process events (a lightweight EventEmitter, an in-memory bus, or a
domain-event dispatcher) belong in the design when you deliberately want
decoupling or eventual consistency across a boundary, not as the routine
default. Milan Jovanovic learned this through experience: defaulting to async
events created hidden coupling. "It passed for good event-driven design, and
it was actually the coupling I wanted to avoid, wearing a disguise."
"Eventual consistency across a boundary is a bet. Make that bet on purpose,
not by default."
([Jovanovic, The Modular Monolith Boundary I Couldn't Take Back](https://www.milanjovanovic.tech/blog/the-modular-monolith-boundary-i-couldnt-take-back))

Never reach into another module's internals on either path. An anti-corruption
layer is a reasonable addition on a synchronous boundary when the calling
module should not mirror the domain concepts of the called module; for its full treatment as a Domain-Driven Design context-mapping pattern, see the `ddd-strategic-design` skill.
([Grzybek, Integration Styles](https://www.kamilgrzybek.com/blog/posts/modular-monolith-integration-styles))

**Inside a hexagonal module.** "Direct call" fixes the mechanism, a synchronous
in-process call, not the layer the call starts from. When the calling module is
structured as ports and adapters, the other module is a secondary actor like a
database or an external service: the caller's core declares a secondary port in
its own terms, a driven adapter in the caller's infrastructure implements it by
calling the other module's public API, and the host hands that public API to
the caller's assembly function (section 3). The core never imports a contract
it does not own, and the adapter is where translation happens; when the two
models diverge substantially, that adapter grows into the anti-corruption layer
above. The port earns its place on the in-memory double alone. Depending on the
other module's public API straight from the core remains legitimate when it is
deliberate: a conformist relationship in Domain-Driven Design terms, where the
caller adopts the called module's model instead of translating it, worth it
when translation would only rename fields. Decide it per dependency, not by
default. A module without a hexagonal core (a CRUD module) simply depends on the
public API, as in Option A below.

**Contested axis.** Grzybek's reference implementation mandates async events
between modules. Jovanovic's experience recommends direct calls as the default.
Both camps agree the choice must be deliberate. Present both, choose with intent.

### TypeScript example: direct call versus in-process event

```typescript
// OPTION A: direct synchronous call to the payments module's public API
// Simple, explicit, easy to trace. Use this by default.

import type { PaymentsApi } from "@myapp/payments";

export class OrderService {
  constructor(private readonly paymentsApi: PaymentsApi) {}

  async placeOrder(order: Order): Promise<void> {
    const result = await this.paymentsApi.charge({
      amount: order.totalCents,
      customerId: order.customerId,
    });
    // React to the result synchronously. The charge commits in the payments
    // module's own transaction, never in orders' (section 6).
  }
}
```

```typescript
// OPTION A inside a hexagonal module: the same direct call, started from a
// driven adapter behind a port the orders core owns.

// orders/application/payment-gateway.ts - the secondary port, in orders' terms.
import { Order } from "../domain/order";

export type PaymentOutcome = "accepted" | "declined";

export interface PaymentGateway {
  chargeFor(order: Order): Promise<PaymentOutcome>;
}
```

```typescript
// orders/infrastructure/payments-module-gateway.ts - the driven adapter, the
// only file in orders that knows the payments contract.

import type { PaymentsApi } from "@myapp/payments";
import { PaymentGateway, PaymentOutcome } from "../application/payment-gateway";
import { Order } from "../domain/order";

export class PaymentsModuleGateway implements PaymentGateway {
  constructor(private readonly paymentsApi: PaymentsApi) {}

  async chargeFor(order: Order): Promise<PaymentOutcome> {
    const result = await this.paymentsApi.charge({
      amount: order.totalCents,
      customerId: order.customerId,
    });
    return result.succeeded ? "accepted" : "declined";
  }
}

// createOrdersModule (section 3) wraps the payments public API it receives
// from the host: new PlaceOrder(new PaymentsModuleGateway(dependencies.payments))
```

```typescript
// OPTION B: in-process event when you want deliberate decoupling
// Use only when you intend eventual consistency or want to invert the dependency.

import type { EventPublisher, UnitOfWork } from "@myapp/building-blocks";
import { OrderPlaced } from "./events/order-placed"; // re-exported by the orders barrel

// Injected, not imported: the event infrastructure reaches the module through
// its assembly function, so the host can swap it and a test can substitute it.
export class OrderService {
  constructor(
    private readonly unitOfWork: UnitOfWork,
    private readonly orderRepository: OrderRepository,
    private readonly events: EventPublisher,
  ) {}

  async placeOrder(order: Order): Promise<void> {
    await this.unitOfWork.run(async () => {
      await this.orderRepository.save(order);
      // Written to the orders outbox in the same transaction as the order; a
      // relay delivers it to subscribers (payments) after commit, so a crash
      // between the two writes cannot lose it.
      await this.events.publish(new OrderPlaced(order.id, order.totalCents));
    });
    // Trade-off: orders no longer learns of a payment failure in the same call.
  }
}
```

Choose Option A unless you have a specific reason for eventual consistency,
a desire to invert the dependency direction, or a need for the orders module
to remain unaware of which downstream modules consume its events.

### When not to apply

Do not publish in-process events simply because it "feels more decoupled."

Do not pick the direct call for atomicity either: neither option gives it
across modules, because a direct call commits in the called module's own
transaction too (section 6). If two steps must succeed or fail together, the
boundary is in the wrong place and both belong in the same module. Otherwise,
plan for partial failure on either path. After a direct call, handle the
failure synchronously, with a compensating action and idempotent retries. With
an event, publish it through an outbox so it commits in the same transaction as
the state change that caused it, and coordinate the steps that may need undoing
with a saga. The event path costs more machinery, which is why it is not the
default.

---

## 6. Data isolation

The invariant is logical data ownership, not any single storage mechanism.
Each module owns its data: no other module reads or writes it except through
the owning module's public API. Grzybek states the target form: "Each Module
has its own data in a separate schema, shared data is not allowed"; "it is not
possible nor desirable to create a transaction which spans more than one
module."
([kgrzybek/modular-monolith-with-ddd](https://github.com/kgrzybek/modular-monolith-with-ddd))

The rules that follow hold regardless of the storage mechanism:
- One module owns each table; no other module reads or writes it directly.
- No cross-module foreign keys.
- No SQL joins across module boundaries.
- No transaction spanning two modules.
- Cross-module data is obtained by calling the other module's public API,
  then reading the returned data in-process.

**Enforcement mechanisms, strongest to weakest.** Pick by isolation need and
operational maturity, not by dogma:
- **Database per module**: strongest isolation, highest operational cost, the
  natural pre-extraction shape.
- **Schema per module** (one physical database): the canonical compromise, and
  what most references show. Cheap to run, and it can migrate to separate
  databases later. Give each module its own database role, granted only on its
  schema, and the database itself rejects a cross-module read or write; this
  requires the host to hand each module its own connection rather than a
  shared one.
- **Table ownership by convention** (a single owning module per table,
  enforced by review and tooling): the weakest, but often the only reachable
  step in a legacy database that cannot be re-partitioned yet. Preserve the
  logical-ownership rule even when the physical schema is shared.

**Multi-tenant note.** Tenancy occupies one isolation axis, and module
ownership takes whichever axis is left:
- **Tenancy on the schema axis** (schema-per-tenant, one database): module
  ownership moves down to the table level, one owning module per table inside
  each tenant schema. This is a clean realization of the invariant, not a
  compromise. Enforcement is necessarily convention-level (one tenant schema
  holds several modules' tables, so the database will not block a cross-module
  read), so review and tooling carry the boundary.
- **Tenancy on the database axis** (database-per-tenant): the schema axis is
  free, so schema-per-module applies as usual inside each tenant database.

A database per module (with a schema per tenant inside each) is a heavier
alternative, worth it only when a particular module needs stronger physical
isolation. The invariant (one owner per table, others through its API) is
unchanged; only where ownership is expressed moves.

**Contested axis (sourced).** Grzybek defaults to one database with a schema
per module; Newman recommends considering multiple databases from the start
when strong isolation is required. Both require logical isolation; physical
separation is a deliberate decision, not a default.

### TypeScript example: schema ownership and cross-module data via API

```typescript
// orders-repository.ts - uses only the orders schema
import type { Pool } from "pg";

export class OrdersRepository {
  // The orders module's own connection, handed over by the host. Under a role
  // granted only on the orders schema, a cross-schema query fails at the
  // database instead of relying on review.
  constructor(private readonly database: Pool) {}

  async findById(orderId: string): Promise<Order | null> {
    // queries only the orders schema; no join to payments.invoices
    const { rows } = await this.database.query(
      "SELECT id, customer_id, total_cents FROM orders.orders WHERE id = $1",
      [orderId],
    );
    return rows[0] ? toOrder(rows[0]) : null; // map at the edge
  }
}
```

```typescript
// orders-service.ts - reads customer data via the customers module's API,
// never via a cross-schema JOIN

import type { CustomersApi } from "@myapp/customers";

export class OrdersService {
  constructor(
    private readonly ordersRepo: OrdersRepository,
    private readonly customersApi: CustomersApi,
  ) {}

  async getOrderSummary(orderId: string): Promise<OrderSummary | null> {
    const order = await this.ordersRepo.findById(orderId);
    if (!order) return null;

    // Correct: call the customers module's public API
    const customer = await this.customersApi.findById(order.customerId);

    // Incorrect (never do this; under a per-module role the database refuses it):
    // const customer = await database.query("SELECT * FROM customers.accounts WHERE id = $1", [...])

    return buildSummary(order, customer);
  }
}
```

### When not to apply

When a query genuinely spans two business capabilities and performance is
critical (large-scale reporting, audit exports), a dedicated read model or
a reporting module that integrates data from multiple module APIs is preferable
to relaxing the isolation rule. Keep the write path isolated even when the
read path aggregates.

A legacy database that cannot be re-partitioned yet is a transition state, not
a counter-example. Apply the weakest mechanism you can reach (table ownership
by convention), retire shared tables and columns owned by more than one module
over time (a column whose ownership is split between modules is an anti-pattern,
not a supported variant), and treat clear ownership as the direction of travel.

This section states the baseline standard. A project with a deliberate,
constraint-driven data model (a multi-tenant tenancy axis, a mandated shared
reference table, a legacy ownership scheme) should declare that deviation in
its project `CLAUDE.md` or a higher-priority skill, which overrides this
baseline. The invariant to preserve in every case is logical ownership: one
module owns each piece of data, and others reach it through its public API.

---

## 7. Trade-offs and when to use

### What a modular monolith keeps

Fowler enumerates the monolith's real advantages
([Microservice Trade-Offs](https://martinfowler.com/articles/microservice-trade-offs.html)):

- **ACID consistency.** "With a monolith, you can update a bunch of things
  together in a single transaction. Microservices require multiple resources
  to update, and distributed transactions are frowned on (for good reason)."
- **Strong consistency.** "Maintaining strong consistency is extremely difficult
  for a distributed system, which means everyone has to manage eventual
  consistency."
- **No network or serialization cost.** In-process calls are orders of magnitude
  cheaper than HTTP or message-queue round trips.
- **Easier refactoring.** "Any refactoring of functionality between services is
  much harder than it is in a monolith."
  ([Fowler, MonolithFirst](https://martinfowler.com/bliki/MonolithFirst.html))
- **Complexity is relocated, not eliminated.** "Complexity isn't eliminated,
  it's merely shifted around to the interconnections between services."

### Costs

- Single deployment unit: one module's failure or resource usage affects the
  entire process.
- Single scaling unit: you cannot independently scale one high-traffic module
  without scaling everything.
- Bounded erosion risk: without diligent enforcement, module boundaries rot
  under deadline pressure.

### Default position

Newman recommends a modular monolith with well-isolated data for most new
systems: "microservices should not be the default choice." Fowler is equally
direct via MicroservicePremium: "don't even consider microservices unless you
have a system that's too complex to manage as a monolith."
([MicroservicePremium](https://martinfowler.com/bliki/MicroservicePremium.html))

Fowler also notes that "almost all the successful microservice stories have
started with a monolith that got too big and was broken up."
([MonolithFirst](https://martinfowler.com/bliki/MonolithFirst.html))

A credible counter-position exists: Stefan Tilkov argues in "Don't start with
a monolith" that choosing microservices from the start can be correct when
the domain is well understood and the team already has strong distributed
systems capability. This is a minority position in practice but not wrong in
its context.

### Justifying drivers for microservices

Move to microservices when the cost of the modular monolith's constraints
becomes demonstrably higher than the operational overhead of distribution:
- Large-team coordination: independent deployment cadence eliminates
  cross-team release dependencies.
- Independent scaling: a single high-throughput module needs dedicated
  infrastructure.
- Polyglot requirements: a module genuinely benefits from a different runtime
  or language.
- Regulatory isolation: a boundary must carry a compliance or security perimeter.

### When not to apply this default

The modular monolith is not the answer for a well-understood domain with an
experienced distributed-systems team that has demonstrated the ability to
keep service boundaries clean. Match the architecture to the demonstrated
organizational capability, not to a principle applied blindly.

---

## 8. Extraction to microservice

A well-designed modular monolith with isolated data is the best starting point
for extraction. Well-bounded modules with schema-per-module isolation are
natural seams.

The recommended pattern is the Strangler Fig (Newman): intercept calls to old
functionality, redirect them to the new extracted service, then remove the
original module from the monolith. Move one or two modules first to validate
the operational model before committing to a broader decomposition.

The common mistake is lift-and-shift: extracting a module along the existing
code boundaries without first ensuring data isolation and boundary cleanliness.
This produces a distributed monolith. Extraction must follow business domain
seams, not code file boundaries.
([vFunction, distributed monolith causes](https://vfunction.com/blog/distributed-monolith-architecture/))

The process is a sliding scale, not a one-time migration: "incrementally
excavate individual microservices from the monolith."
([InfoQ, Monolith versus Microservices](https://www.infoq.com/articles/monolith-versus-microservices/))

### TypeScript example: Strangler Fig intercept at the module boundary

```typescript
// OrdersService calls the payments module through its public API: the PaymentsApi
// interface exported from the barrel. It depends on that interface, not on the
// internal implementation, which is exactly what keeps it stable during extraction.

import type { PaymentsApi } from "@myapp/payments";

export class OrdersService {
  constructor(private readonly payments: PaymentsApi) {}

  async placeOrder(order: Order): Promise<void> {
    await this.payments.charge({ amount: order.totalCents, customerId: order.customerId });
  }
}
```

```typescript
// Strangler Fig step: a second implementation of the same public API, talking HTTP.
// OrdersService does not change, because it already depends on the PaymentsApi
// interface. Because the public API is an interface (not a concrete class), a new
// implementation can satisfy it without inheriting anything internal.

import type { PaymentsApi, ChargeRequest, ChargeResult } from "@myapp/payments";

export class HttpPaymentsApi implements PaymentsApi {
  constructor(private readonly baseUrl: string) {}

  async charge(request: ChargeRequest): Promise<ChargeResult> {
    const response = await fetch(`${this.baseUrl}/charges`, {
      method: "POST",
      body: JSON.stringify(request),
      headers: { "Content-Type": "application/json" },
    });
    return response.json() as Promise<ChargeResult>;
  }
}

// Swap the in-process implementation for the HTTP one in the host (section 3);
// the orders module, OrdersService included, is untouched:
// const orders = createOrdersModule({
//   database,
//   payments: new HttpPaymentsApi(configuration.payments.serviceUrl),
// });
```

The in-process payments implementation is removed from the monolith only after
the external service is validated in production. The calling code is unchanged.

### When not to apply

Do not extract a module that does not yet have isolated data. Attempting to
extract a module that shares tables or joins with other modules requires
data migration and schema splitting first. Fix the data boundary inside the
monolith before crossing the network boundary.

---

## 9. Anti-patterns

### Shared database tables across modules

A table owned by two modules is an implicit contract that bypasses the public
API. Schema changes ripple silently to every module that reads or writes the
table. The canonical fix: assign clear ownership; other modules fetch via the
owning module's API.

### "Common" dumping ground

A `common/`, `shared/`, or `utils/` module that accumulates business logic
becomes a dependency of every other module, creating a hidden hub. Keep shared
code minimal and containing only pure utilities or value types with no business
rules. Any entity or aggregate that appears in `common/` is a sign that it
belongs to a specific module. Do not excuse such a folder as a "shared kernel":
a shared kernel is a small business model deliberately co-owned by two named
modules (section 2), not a place every module feeds.

### Circular module dependencies

Module A imports from module B, which imports from module A. This signals
either that the two modules are really one coherent capability and should be
merged, or that a third module should be extracted to hold the shared concept.
Dependency-cruiser and Nx both detect circular dependencies.

### Distributed monolith

Services that must all be deployed together because they share a database,
synchronous call chains, or strongly coupled configurations are a distributed
monolith. This is structurally equivalent to a single-process monolith but
adds network latency and operational overhead without gaining deployment
independence.

### Modules organized by technical layer

A `controllers/` module, a `services/` module, and a `repositories/` module
that span the entire domain are not modular boundaries. They fragment a single
business capability across three places and force cross-module changes for
every feature. Organize modules by business domain, then apply layers inside
a module only where the complexity warrants them.

### Leaking internals

Exporting internal types, entities, or implementation details from the barrel
`index.ts` erodes the boundary. If a consumer needs an internal type, the
public API is incomplete: extend the provided interface rather than leaking the
internal.

### God host

The host gradually takes over what modules should own: it calls use cases of
several modules in sequence and applies rules between the calls, queries module
tables directly for a dashboard, or exposes services that modules import back.
It becomes an unbounded module that knows every other module, and the
dependency direction inverts the moment a module imports from it. The fix: move
each rule to the module that owns it, give a cross-module process to a module,
and move technical code that modules share out of the host into its own
package.

### TypeScript example: layer-organized modules (anti-pattern) vs domain-organized modules (correct)

```typescript
// ANTI-PATTERN: modules organized by technical layer
// A new "create order" feature requires changes in three modules.

// src/modules/controllers/order-controller.ts  - touches orders domain
// src/modules/services/order-service.ts        - touches orders domain
// src/modules/repositories/order-repository.ts - touches orders domain
```

```typescript
// CORRECT: modules organized by business domain
// A new "create order" feature lives entirely within one module.

// src/modules/orders/index.ts          - public API
// src/modules/orders/order-service.ts  - internal
// src/modules/orders/order-repo.ts     - internal
// src/modules/orders/order.entity.ts   - internal
```

### When not to apply

These are smells, not absolute prohibitions. Not every `common/` or `shared/`
directory is a dumping ground: pure value types, stateless utilities, and
framework adapters with no business rules legitimately live there. Likewise, a
deliberate, documented shared read model (a reporting projection that several
modules feed, owned by one module) is not the "shared tables" anti-pattern; the
anti-pattern is two modules silently writing the same operational table. Judge
each case by ownership and the presence of business rules, not by the directory
name alone.

---

## Pragmatism

A modular monolith is an architecture that must be earned through diligent
boundary enforcement. The value of the boundaries is proportional to the size
of the team and the complexity of the domain.

A small system with two contributors does not need named modules with strict
enforcement tooling. A growing system with multiple teams working in parallel
needs the discipline documented here: vertical slice boundaries, isolated data,
tooling-enforced imports, and deliberate communication choices.

Per Jovanovic: "A module boundary is a guess, so treat it like one. Start with
fewer, coarser modules. Let a module earn its independence."
([Jovanovic](https://www.milanjovanovic.tech/blog/the-modular-monolith-boundary-i-couldnt-take-back))

Per Grzybek: "One [module] may have a more complicated domain, the other may
only implement CRUD operations. The application architecture for these modules
will be different." Do not apply heavy DDD tactical patterns to simple CRUD
modules. The `ddd-tactical-design` skill makes the same point. Match the sophistication of each module to its actual complexity.

Match the level of enforcement to the actual need.
