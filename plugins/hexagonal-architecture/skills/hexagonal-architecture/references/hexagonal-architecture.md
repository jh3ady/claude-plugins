# Hexagonal architecture reference

The detailed reference behind the skill: canonical definitions, the dependency
rule, port and adapter modelling, composition-root wiring, testing in
isolation, the relationship to Onion and Clean Architecture, the anti-pattern
catalogue, and the pragmatic when-not-to-use analysis, all with TypeScript
examples.

Standards and sources:
- Alistair Cockburn, [Hexagonal Architecture](https://alistair.cockburn.us/hexagonal-architecture) (a.k.a. Ports and Adapters, original paper 2005): the canonical definition, intent, and vocabulary.
- Alistair Cockburn and Juan Manuel Garrido de Paz, *Hexagonal Architecture Explained* (2024): the book-length treatment; Garrido de Paz's [companion explainer](https://jmgarridopaz.github.io/content/hexagonalarchitecture.html), [interview with Cockburn](https://jmgarridopaz.github.io/content/interviewalistair.html), and [The right boundary](https://jmgarridopaz.github.io/content/therightboundary.html) on adapters versus anti-corruption layers.
- Eric Evans, [Domain-Driven Design Reference](https://www.domainlanguage.com/wp-content/uploads/2016/05/DDD_Reference_2015-03.pdf): the anti-corruption layer definition.
- Microsoft, [Anti-Corruption Layer pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/anti-corruption-layer): the anti-corruption layer as a translating facade or adapter.
- Jeffrey Palermo, [The Onion Architecture: part 1](https://jeffreypalermo.com/2008/07/the-onion-architecture-part-1/) (2008): the concentric-layers framing and the "database is external" rule.
- Robert C. Martin, [The Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) (2012): the named Dependency Rule and the four-ring model.
- Mark Seemann, [Layers, Onions, Ports, Adapters: it's all the same](https://blog.ploeh.dk/2013/12/03/layers-onions-ports-adapters-its-all-the-same/) (2013): the unification via dependency inversion.
- Herberto Graça, [DDD, Hexagonal, Onion, Clean, CQRS, ... How I put it all together](https://herbertograca.com/2017/11/16/explicit-architecture-01-ddd-hexagonal-onion-clean-cqrs-how-i-put-it-all-together/) (2017): the synthesis.
- Khalil Stemmler, [Clean Node.js Architecture](https://khalilstemmler.com/articles/enterprise-typescript-nodejs/clean-nodejs-architecture/) and [Repository, DTO, Mapper](https://khalilstemmler.com/articles/typescript-domain-driven-design/repository-dto-mapper/): TypeScript modelling.
- Alex Rusin, [A Guide to Ports & Adapters](https://blog.alexrusin.com/future-proof-your-code-a-guide-to-ports-adapters-hexagonal-architecture/): composition-root wiring in TypeScript.
- Sairyss, [Domain-Driven Hexagon](https://github.com/Sairyss/domain-driven-hexagon); Bitloops, [ddd-hexagonal-cqrs-es-eda](https://github.com/bitloops/ddd-hexagonal-cqrs-es-eda): reference TypeScript/NestJS codebases.
- Victor Rentea, [Overengineering in Onion/Hexagonal Architectures](https://victorrentea.ro/blog/overengineering-in-onion-hexagonal-architectures/): the mapping-cost critique.
- Albert Llousas, [Hexagonal Architecture: Common pitfalls](https://medium.com/@allousas/hexagonal-architecture-common-pitfalls-f155e12388a3); DEV Community, [Hexagonal Architecture in the Real World](https://dev.to/elpic/hexagonal-architecture-in-the-real-world-trade-offs-pitfalls-and-when-not-to-use-it-4a2p): pitfalls and when-not-to-use.

---

## 1. Definition and intent

Hexagonal architecture, which Cockburn renamed "Ports and Adapters" in 2005, has
a single stated goal
([Cockburn, Hexagonal Architecture](https://alistair.cockburn.us/hexagonal-architecture)):

> "Allow an application to equally be driven by users, programs, automated test
> or batch scripts, and to be developed and tested in isolation from its
> eventual run-time devices and databases."

The hexagon shape carries no meaning. It is a drawing convention, chosen so the
diagram has room for the ports and adapters that a flat layered drawing cannot
show:

> "The hexagon is not a hexagon because the number six is important, but rather
> to allow the people doing the drawing to have room to insert ports and
> adapters as they need, not being constrained by a one-dimensional layered
> drawing."

The mechanism is a technology-agnostic core surrounded by adapters that
translate at the edge:

> "As events arrive from the outside world at a port, a technology-specific
> adapter converts it into a usable procedure call or message and passes it to
> the application. The application is blissfully ignorant of the nature of the
> input device."

The invariant that holds the whole pattern together is a leakage rule:

> "The rule to obey is that code pertaining to the inside part should not leak
> into the outside part."

### When not to apply this framing

The pattern protects a domain. A slice with no domain to speak of (a thin
read-through, a configuration screen, a report that is one query) has nothing
to isolate, and the hexagon adds indirection with no payoff. Apply the framing
where business rules exist and change independently of the technology around
them.

---

## 2. The dependency rule

Every member of this family of architectures reduces to one rule: source code
dependencies point inward, toward the domain, never outward. Martin names it
directly ([The Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)):

> "The overriding rule that makes this architecture work is *The Dependency
> Rule*. This rule says that *source code dependencies* can only point
> *inwards*."

> "Nothing in an inner circle can know anything at all about something in an
> outer circle."

Palermo states the same constraint for Onion
([The Onion Architecture: part 1](https://jeffreypalermo.com/2008/07/the-onion-architecture-part-1/)):

> "all coupling is toward the center."

> "The database is not the center. It is external."

The mechanism that makes an inward-only rule possible, when the core genuinely
needs a database or a network call, is the dependency inversion principle. The
core declares an interface (a port) describing what it needs; infrastructure
implements that interface. The dependency that would naturally run from core to
database is inverted: now the database adapter depends on the core's interface.
Mark Seemann puts the equivalence plainly
([Layers, Onions, Ports, Adapters](https://blog.ploeh.dk/2013/12/03/layers-onions-ports-adapters-its-all-the-same/)):

> "If you apply the Dependency Inversion Principle to Layered Architecture, you
> end up with Ports and Adapters."

This skill does not redefine the dependency inversion principle or dependency
injection; see the `solid-principles` and `dependency-injection` skills.
Hexagonal is the architecture-scale application of both.

---

## 3. Ports and adapters in detail

A **port** is an interface the core owns, named for the purpose of the
conversation it represents, not for any technology
([Cockburn](https://alistair.cockburn.us/hexagonal-architecture)):

> "The protocol for a port is given by the purpose of the conversation between
> the two devices."

An **adapter** sits at the edge and translates:

> "For each external device there is an adapter that converts the API definition
> to the signals needed by that device and vice versa."

The two sides of the hexagon are not symmetric in dependency direction, only in
how they connect. Cockburn distinguishes them by who drives whom
([Hexagonal Architecture](https://alistair.cockburn.us/hexagonal-architecture)):

- A **primary (driving) port** is what the core exposes so a primary actor can
  drive it, typically a use case. The **driving adapter** (an HTTP controller, a
  CLI command, a test) calls that port. A primary actor "drives the application
  (takes it out of quiescent state to perform one of its advertised
  functions)."
- A **secondary (driven) port** is what the core requires from a secondary
  actor, typically a repository or an external-service gateway. The **driven
  adapter** (an ORM repository, an HTTP client, a message publisher) implements
  that port. A secondary actor is "one that the application drives, either to
  get answers from or to merely notify."

The mnemonic that prevents the usual confusion: a driving adapter **calls** a
port, a driven adapter **implements** a port. Get that right and the inward
dependency direction follows automatically, because the core only ever depends
on interfaces it itself declares.

### TypeScript example: a secondary (driven) port and its adapters

```typescript
// core/ports/user-repository.ts
// A secondary (driven) port: the interface the core REQUIRES. It is named for
// the domain need, not for the database. The core owns this file.

import { User } from "../domain/user";

export interface UserRepository {
  findById(id: string): Promise<User | null>;
  save(user: User): Promise<void>;
}
```

```typescript
// infrastructure/persistence/prisma-user-repository.ts
// A driven adapter: it IMPLEMENTS the port. All ORM concerns live here and are
// mapped to the domain model at the boundary. Nothing leaks inward.

import { PrismaClient } from "@prisma/client";
import { User } from "../../core/domain/user";
import { UserRepository } from "../../core/ports/user-repository";

export class PrismaUserRepository implements UserRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async findById(id: string): Promise<User | null> {
    const row = await this.prisma.user.findUnique({ where: { id } });
    return row ? new User(row.id, row.email) : null; // map at the edge
  }

  async save(user: User): Promise<void> {
    await this.prisma.user.upsert({
      where: { id: user.id },
      create: { id: user.id, email: user.email },
      update: { email: user.email },
    });
  }
}
```

### TypeScript example: a primary (driving) port and its adapter

```typescript
// core/ports/register-user.ts
// A primary (driving) port: the use case the core EXPOSES. The driving adapter
// will call this. Depending on an interface here lets the controller stay
// ignorant of the concrete use-case implementation.

export interface RegisterUserCommand {
  email: string;
}

export interface RegisterUser {
  execute(command: RegisterUserCommand): Promise<{ id: string }>;
}
```

```typescript
// infrastructure/http/user-controller.ts
// A driving adapter: it CALLS the port. It translates an HTTP request into a
// technology-agnostic command and the result back into an HTTP response. No
// business rule lives here.

import type { Request, Response } from "express";
import { RegisterUser } from "../../core/ports/register-user";

export class UserController {
  constructor(private readonly registerUser: RegisterUser) {}

  async register(req: Request, res: Response): Promise<void> {
    const result = await this.registerUser.execute({ email: req.body.email });
    res.status(201).json(result);
  }
}
```

A common, legitimate simplification on the driving side: many TypeScript
codebases let the use-case class itself be the primary port rather than
defining a separate interface for it, because there is rarely a second
implementation of a use case. The driven side almost always keeps its interface
(there is a real adapter plus a test double), so the asymmetry is principled,
not sloppy. Flag it as a deliberate choice, not an oversight.

### Adapters and the anti-corruption layer

A secondary port that integrates with an external system, a legacy system, or
another bounded context is where a Domain-Driven Design anti-corruption layer
comes into play. Evans defines the anti-corruption layer as an "isolating layer
to provide clients with functionality in terms of their own domain model" that
"talks to the other system through its existing interface, requiring little or
no modification to the other system"
([Evans, Domain-Driven Design Reference](https://www.domainlanguage.com/wp-content/uploads/2016/05/DDD_Reference_2015-03.pdf)).
The invariant it enforces is the one hexagonal already demands: when the actor on
the far side of a secondary port speaks a foreign model, that model is
translated into the domain's own vocabulary before it crosses the port inward,
so it never leaks past the boundary. That is the leakage rule of section 1, and
skipping it is the external-domain-mirroring anti-pattern of section 8.

Where the translating code physically sits is a genuine point of difference, not
a settled fact, so do not state it as one. Microsoft frames the anti-corruption
layer as adapter-shaped, living in infrastructure: "Implement a facade or
adapter layer between different subsystems that don't share the same semantics.
This layer translates requests that one subsystem makes to the other subsystem"
([Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/patterns/anti-corruption-layer)).
Juan Manuel Garrido de Paz, Cockburn's co-author, places it differently: in
strict hexagonal terms a driven adapter "just sends/retrieves the information
to/from the driven actor using a technology", while the model-translation work
"is logic that belongs to the inside of the hexagon", and so "the ACL concept
from DDD is wider than the driven adapter concept from Hexagonal Architecture"
([Garrido de Paz, The right boundary](https://jmgarridopaz.github.io/content/therightboundary.html)).
Both agree on the invariant (the foreign model is translated at the boundary);
they disagree on whether that code lives in the adapter or inside the hexagon.
Pick a placement deliberately, and do not assume the adapter and the
anti-corruption layer are the same thing.

Two consequences follow:

- An adapter over your own model (a persistence adapter for your own database, a
  thin controller exposing your own types) is a technology and serialization
  boundary, not an anti-corruption layer: there is no foreign domain model to
  defend against. The anti-corruption layer exists specifically to protect your
  model from another model.
- Cockburn's adapter is a technology translator (signals, protocols, API
  formats); Evans' anti-corruption layer is a model translator. The two
  vocabularies grew up in parallel, and the connection is drawn by later
  DDD-plus-hexagonal practitioners, not by Cockburn. Treat the secondary port as
  the seam where anti-corruption translation belongs when a foreign model is
  involved, without assuming every adapter is one. The full anti-corruption
  layer and the rest of Domain-Driven Design's context-mapping vocabulary are
  outside this skill's scope.

### When not to apply

Do not invent a port whose only purpose is to mirror an external API or a
database table one-for-one. A port should "fit the Domain needs, not simply
mimic the tools APIs"
([Sairyss, Domain-Driven Hexagon](https://github.com/Sairyss/domain-driven-hexagon)).
A port that is a thin rename of `PrismaClient` buys nothing.

---

## 4. The application core

Inside the hexagon, two responsibilities are usually distinguished, and Onion
and Clean both formalize the split:

- The **domain**: entities, value objects, and domain services that hold the
  business rules. It depends on nothing, not even the application layer around
  it.
- The **application** (use cases): orchestration that drives the domain and
  talks to the world through ports. It depends on the domain and on port
  interfaces, never on adapters.

Palermo's Onion places the interfaces in the inner rings and the
implementations outside ([The Onion Architecture: part 1](https://jeffreypalermo.com/2008/07/the-onion-architecture-part-1/)):

> "The first layer around the Domain Model is typically where we would find
> interfaces that provide object saving and retrieving behavior ... Out on the
> edges we see UI, Infrastructure, and Tests."

The practical TypeScript rule, in Khalil Stemmler's words
([Clean Node.js Architecture](https://khalilstemmler.com/articles/enterprise-typescript-nodejs/clean-nodejs-architecture/)):

> "Domain Layer code can't depend on Infrastructure Layer code. But
> Infrastructure Layer Code *can depend* on Domain Layer code (because it goes
> inwards)."

> "When we follow this rule, we're essentially following the Dependency
> Inversion rule from the SOLID Principles."

### When not to apply

The domain/application split earns its keep when orchestration is non-trivial.
For a use case that is a single repository call wrapped in validation, folding
the two together is fine. A separate application layer that only forwards to the
domain is the indirection-without-abstraction smell covered in section 8.

---

## 5. Composition root and wiring

The core never constructs its own adapters. Concrete adapters are selected and
injected in one place, the composition root, at application startup. This is
dependency injection as the wiring mechanism; hexagonal decides *what* is wired
(ports), and the composition root is *where*. See the `dependency-injection`
skill for the mechanism in depth; this section shows only the architectural
seam.

### TypeScript example: composition root

```typescript
// main.ts - the composition root. The ONLY place that names concrete adapters.
// Swapping an implementation here changes nothing in the core.

import { PrismaClient } from "@prisma/client";
import { PrismaUserRepository } from "./infrastructure/persistence/prisma-user-repository";
import { RegisterUserUseCase } from "./core/application/register-user-use-case";
import { UserController } from "./infrastructure/http/user-controller";

const prisma = new PrismaClient();

// Driven adapter chosen here and injected into the core as the port type.
const userRepository = new PrismaUserRepository(prisma);

// The use case (core) depends only on the UserRepository port.
const registerUser = new RegisterUserUseCase(userRepository);

// Driving adapter wired to the primary port.
const userController = new UserController(registerUser);
```

The payoff is concrete: "We just swapped out our entire email infrastructure
without touching a single line of business logic in our Use Cases or
Controllers"
([Rusin, A Guide to Ports & Adapters](https://blog.alexrusin.com/future-proof-your-code-a-guide-to-ports-adapters-hexagonal-architecture/)).
Whether the wiring is manual (Pure DI) or done by a container (NestJS providers,
for example) is orthogonal; the architectural requirement is only that the core
depends on ports and the root supplies adapters.

---

## 6. Testing in isolation

Testing the core without its real infrastructure is the pattern's original
motivation, not a bonus. Because the core depends only on ports, a test
substitutes an in-memory adapter for the real one and exercises the business
logic with no database and no network. Sairyss states the practical effect
([Domain-Driven Hexagon](https://github.com/Sairyss/domain-driven-hexagon)):

> "Mock implementations can be passed to ports while testing. Mocking makes your
> tests faster and independent of the environment."

### TypeScript example: in-memory driven adapter for tests

```typescript
// test/in-memory-user-repository.ts
// A second adapter for the SAME port, used only in tests. This is exactly the
// "second adapter" that justifies the port existing.

import { User } from "../core/domain/user";
import { UserRepository } from "../core/ports/user-repository";

export class InMemoryUserRepository implements UserRepository {
  private readonly users = new Map<string, User>();

  async findById(id: string): Promise<User | null> {
    return this.users.get(id) ?? null;
  }

  async save(user: User): Promise<void> {
    this.users.set(user.id, user);
  }
}

// The use case is tested with no Prisma, no database, no container:
// const useCase = new RegisterUserUseCase(new InMemoryUserRepository());
```

### When not to apply

If a port has exactly one production adapter and you never write the in-memory
double, you have paid the interface cost for a flexibility you never use. The
in-memory test adapter is what usually makes the second adapter real; if you
will not write it and there is no second production implementation, reconsider
whether the port should exist (section 9).

---

## 7. Relationship to Onion and Clean Architecture

Hexagonal, Onion, and Clean are three names for the same idea expressed in
different vocabularies. Martin, defining Clean, lists Hexagonal and Onion as its
direct predecessors and states the relationship explicitly
([The Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)):

> "Though these architectures all vary somewhat in their details, they are very
> similar."

> "They all have the same objective, which is the separation of concerns."

Each produces a system that is "Independent of Frameworks", "Testable",
"Independent of UI", "Independent of Database", and "Independent of any external
agency." The genuine differences are emphasis and granularity, not principle:

- **Hexagonal (Cockburn)**: stresses the symmetric driving/driven adapters
  around a single core boundary. Minimal vocabulary: ports and adapters.
- **Onion (Palermo)**: adds explicit concentric DDD layers inside the core
  (domain model, domain services, application services) and the rule that
  interfaces live in the inner rings, implementations on the edges. Graça notes
  it "picks up the DDD layers and incorporates them into the Ports & Adapters
  Architecture"
  ([Graça](https://herbertograca.com/2017/11/16/explicit-architecture-01-ddd-hexagonal-onion-clean-cqrs-how-i-put-it-all-together/)).
- **Clean (Martin)**: adds the named Dependency Rule and a four-ring model
  (Entities, Use Cases, Interface Adapters, Frameworks & Drivers).

For the purpose of this skill, a request framed in any of these terms is the
same problem: isolate the domain, point dependencies inward, translate at the
edge. Do not treat a switch of vocabulary as a switch of architecture.

---

## 8. Anti-patterns

### Leaking framework or ORM types into the core

An ORM entity, a framework request object, or a transport DTO imported into the
domain quietly reverses the one rule: the core now depends outward. Map at the
adapter boundary instead, translating persistence and transport shapes to and
from domain objects (the repository/DTO/mapper pattern,
[Stemmler](https://khalilstemmler.com/articles/typescript-domain-driven-design/repository-dto-mapper/)).
This is the most common way a nominally hexagonal codebase stops being one.

### Ports that mirror the database or an external API

A port shaped like the tool it wraps, rather than the domain need it serves, is
"external domain mirroring"
([Llousas](https://medium.com/@allousas/hexagonal-architecture-common-pitfalls-f155e12388a3)).
A related smell is database-driven development, where "designing the database
schema as the initial step can lead to the application being mainly shaped by
database considerations." The port should express what the domain wants, not
what the storage offers. When the tool is an external system with its own model,
the fix is precisely an anti-corruption layer at the port boundary (section 3):
translate the foreign model into the domain's terms rather than letting it
dictate them.

### Over-porting: a port for every dependency

Creating an interface for every external call, regardless of whether a second
adapter will ever exist, is ceremony. The test is concrete
([DEV, Hexagonal Architecture in the Real World](https://dev.to/elpic/hexagonal-architecture-in-the-real-world-trade-offs-pitfalls-and-when-not-to-use-it-4a2p)):

> "The test for 'should this be a port?' is: will there ever be a second
> adapter? If the answer is no, you're creating ceremony, not flexibility."

A real production adapter plus an in-memory test double counts as two; a single
adapter with no second on the horizon does not.

### Mapping fatigue and indirection without abstraction

Domain model, persistence model, and DTO, with mappers between each pair,
multiply the work for every field. Victor Rentea's critique is the sharpest
([Overengineering in Onion/Hexagonal Architectures](https://victorrentea.ro/blog/overengineering-in-onion-hexagonal-architectures/)):

> "every field they add later to a data structure has to be added now to 3 data
> structures"

> "It's one of the most expensive decisions to take, as it effectively
> increases the code 4x or more for CRUD operations."

One-line pass-through methods that forward a call without adding behaviour are
"indirection without abstraction ... it does not add any new semantic." Keep the
layers and mappers you can justify by an actual difference in shape or rule, not
by reflex.

### Business logic in adapters

A controller that decides, a repository that enforces a rule, or a mapper that
computes is logic that escaped the core. The core holds the rules; adapters only
translate. Logic in an adapter cannot be tested in isolation and is invisible to
the next adapter.

### Use cases calling use cases into a tangle

Use cases that call other use cases produce "a tangled chain of calls"
([Llousas](https://medium.com/@allousas/hexagonal-architecture-common-pitfalls-f155e12388a3)),
where the dependency graph of the application layer becomes a maze. Extract the
shared behaviour into a domain service the use cases share, rather than chaining
orchestration.

### When not to apply

These are smells, not absolute prohibitions. A deliberate, documented mapper
between a genuinely different persistence shape and the domain is not "mapping
fatigue"; it is the boundary doing its job. A port with a single production
adapter is justified the moment you write the in-memory test double. Judge each
case by whether the abstraction carries a real difference in shape, rule, or
substitutability, not by the presence of an interface alone.

---

## 9. When not to use it

The pattern has a real cost, and credible practitioners argue it is overkill for
a large class of applications. The DEV "real world" analysis gives an explicit
skip list
([Hexagonal Architecture in the Real World](https://dev.to/elpic/hexagonal-architecture-in-the-real-world-trade-offs-pitfalls-and-when-not-to-use-it-4a2p)):

> "Skip it (or defer it) if: You're building CRUD — data in, data out, minimal
> logic; The domain is still being discovered; Every port has exactly one
> adapter and no second is planned; You're wrapping a framework with strong data
> layer opinions; The team is small and junior — onboarding time matters more
> than purity; This is a prototype or MVP with a likely rewrite horizon."

The underlying question is whether there is a domain worth protecting:

> "If your domain model is just dataclasses with no methods — data in, data out,
> nothing in between — there's no domain worth protecting."

Rentea adds the cost framing and a caution about how these patterns are sold
([Overengineering in Onion/Hexagonal Architectures](https://victorrentea.ro/blog/overengineering-in-onion-hexagonal-architectures/)):

> "Powerful influencers have promoted these architectures without stressing
> enough that they are (overly) complex, exhaustive blueprints"

He also notes the testing benefit can invert under over-abstraction: "Testing
such silly methods with mocks would lead to 5x times larger test code than
tested code", with the guiding heuristic that "when testing is hard, the
production design can be improved."

A frequent middle case deserves its own answer: you suspect from the start that
a real domain exists, but an early MVP has not revealed its shape yet. The skip
list above places "the domain is still being discovered" in the defer bucket,
and that is right, but defer the apparatus, not the invariant. The one rule (the
dependency rule, concretely: no framework, ORM, or transport types in the
business logic) is nearly free to hold from the first commit and expensive to
retrofit once those types have spread through the code, so hold it from day one.
The cost lives in the apparatus (a port for every dependency, separate domain,
persistence, and DTO models with mappers between them), so defer that until the
domain crystallizes, then introduce ports and layers slice by slice as each one
earns it. Keeping the invariant cheap from the start is exactly what makes a
later move to the full hexagon a refactor rather than a rewrite. In practice on
an MVP: keep business rules in plain functions and objects with no framework
imports even before you formalize any port, and extract ports when a second
adapter (commonly the in-memory test double) becomes real.

### Adapt to your context

This section states the baseline. A project with a deliberate convention (a
mandated mapper layer, a fixed folder taxonomy, a rule about which slices use
the full hexagon versus plain layering) should declare that in its project
`CLAUDE.md` or a higher-priority skill, which overrides this baseline. The
invariant to preserve wherever a domain exists, or is plausibly coming, is the
dependency rule: the core depends on nothing outward, and the outside reaches it
only through ports it owns.

---

## Pragmatism

Hexagonal architecture is the architecture-scale expression of dependency
inversion: a core that owns its interfaces, an outside that implements them, and
a strict inward-only dependency direction. Cockburn's intent, isolation of the
application from its devices and databases so it can be driven and tested by
anything, is worth holding onto even when the full apparatus is not.

Match the apparatus to the domain. A slice with rich, changing business rules
that must survive a framework migration and be tested without a database is
exactly what the hexagon is for. A slice that moves data in and out with no
rules in between is not, and forcing ports, layers, and mappers onto it is the
over-engineering the critics rightly call out.

Where a domain exists, keep the one rule and set every other dial to the actual
need.
