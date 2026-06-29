# Screaming Architecture reference

The detailed reference behind the skill: the canonical essay and its quotes, the
building-blueprint analogy, frameworks and delivery mechanisms as details, the
testability corollary, package-by-feature versus package-by-layer with its
history, vertical slice architecture, the composition with hexagonal, clean, and
onion architecture, the relationship to domain-driven design and the modular
monolith, worked folder-tree examples across back-end and front-end stacks, and
the pragmatic when-not-to-use analysis.

Standards and sources:
- Robert C. Martin, [Screaming Architecture](https://blog.cleancoder.com/uncle-bob/2011/09/30/Screaming-Architecture.html) (2011): the original essay that named the idea.
- Robert C. Martin, *Clean Architecture: A Craftsman's Guide to Software Structure and Design* (2017), chapter 21 "Screaming Architecture": the book-length restatement.
- Robert C. Martin, [The Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) (2012): the dependency rule that this heuristic is usually paired with.
- Simon Brown, [Package by component and architecturally-aligned testing](https://dzone.com/articles/package-component-and): package-by-layer, package-by-feature, and package-by-component.
- Herberto Graca, [Packaging code: Package by layer, package by feature, package by component](https://herbertograca.com/2017/08/31/packaging-code/) (2017): the comparison and history.
- Jimmy Bogard, [Vertical Slice Architecture](https://www.jimmybogard.com/vertical-slice-architecture/): organise by feature, "minimize coupling between slices, and maximize coupling in a slice".
- Milan Jovanovic, [Screaming Architecture](https://www.milanjovanovic.tech/blog/screaming-architecture) and [Vertical Slice Architecture](https://www.milanjovanovic.tech/blog/vertical-slice-architecture): worked .NET folder-tree examples.
- Profydev, [Screaming Architecture - Evolution of a React folder structure](https://dev.to/profydev/screaming-architecture-evolution-of-a-react-folder-structure-4g25): a front-end worked example.

---

## Table of contents

1. Definition and intent
2. The building-blueprint analogy
3. Frameworks, the web, and the database as details
4. The testability corollary
5. Package by feature versus package by layer
6. Package by component
7. Vertical slice architecture
8. Composition with hexagonal, clean, and onion architecture
9. Relationship to domain-driven design and the modular monolith
10. Worked example: a back-end service
11. Worked example: a front-end application
12. Guardrails and when not to use it
13. Common misunderstandings

---

## 1. Definition and intent

Screaming Architecture is the idea that the top-level organisation of a codebase
should make the system's purpose obvious. Martin frames it as a question you ask
of any project
([Martin, Screaming Architecture](https://blog.cleancoder.com/uncle-bob/2011/09/30/Screaming-Architecture.html)):

> "What does the architecture of your application scream? When you look at the
> top level directory structure, and the source files in the highest level
> package; do they scream: Health Care System, or Accounting System, or
> Inventory Management System? Or do they scream: Rails, or Spring/Hibernate, or
> ASP?"

The intent is grounded in a point Martin draws from Ivar Jacobson and quotes in
the essay: "software architectures are structures that support the use cases of
the system." The architecture's first job is to make those use cases visible. Everything else (the framework, the
delivery mechanism, the database) is subordinate to that.

This is a heuristic about what the structure communicates. It is not a layering
rule and not a dependency rule. It tells you how to name and group things at the
top so the domain is legible; it leans on other patterns (section 8) for the
direction of dependencies.

## 2. The building-blueprint analogy

Martin reaches for architecture in the literal sense. The plans of a library
announce what the building is for:

> "If [the plans] were for a library, you'd probably see a grand entrance, an
> area for check-in-out clerks, reading areas, small conference rooms, and
> gallery after gallery capable of holding bookshelves for all the books in the
> library. That architecture would scream: Library."

A software system's plans should do the same. If the top-level structure of a
health-care system looked at a glance like a health-care system, a new
programmer would orient themselves immediately, before learning a single thing
about the framework underneath. The blueprint screams the use cases; the
building materials (brick, steel, or in software, Rails or Spring) are an
implementation detail of how those use cases are realised.

## 3. Frameworks, the web, and the database as details

The corollary Martin draws repeatedly is that the tools must not dictate the
shape:

> "Architectures are not (or should not) be about frameworks. Architectures
> should not be supplied by frameworks. Frameworks are tools to be used, not
> architectures to be conformed to."

He extends this to delivery and storage:

> "The Web is a delivery mechanism, and your application architecture should
> treat it as such. The fact that your application is delivered over the web is a
> detail and should not dominate your system structure."

The advice for adopting a framework is deliberately wary:

> "Look at each framework with a jaded eye. View it skeptically. Yes, it might
> help, but at what cost? Ask yourself how you should use it, and how you should
> protect yourself from it. Think about how you can preserve the use-case
> emphasis of your architecture. Develop a strategy that prevents the framework
> from taking over that architecture."

The practical reading: a folder named `controllers/` at the root commits the top
level to the web delivery mechanism; a folder named `repositories/` commits it
to the persistence mechanism. Neither names a use case. The frameworks are still
present and still used, but they belong at the edges, not at the front door.

## 4. The testability corollary

Martin offers a concrete test for whether the domain or the framework owns the
architecture:

> "If your system architecture is all about the use cases, and if you have kept
> your frameworks at arm's length, then you should be able to unit-test all
> those use cases without any of the frameworks in place. You shouldn't need the
> web server running to run your tests. You shouldn't need the database connected
> to run your tests. Your business objects should be plain old objects that have
> no dependencies on frameworks."

If a use case can only be exercised with the web server up and the database
connected, the framework has taken over: the use case is entangled with the
delivery and persistence mechanisms instead of standing on its own. The ability
to test use cases as plain objects is the same isolation goal that hexagonal
architecture pursues with ports and adapters (section 8). Screaming Architecture
gives the structural symptom; hexagonal gives the mechanism.

## 5. Package by feature versus package by layer

The actionable form of "scream the domain" is the long-standing choice between
two packaging strategies
([Graca, Packaging code](https://herbertograca.com/2017/08/31/packaging-code/)).

**Package by layer** groups classes by their technical role:

```
src/
  controllers/
    BookingController
    PaymentController
  services/
    BookingService
    PaymentService
  repositories/
    BookingRepository
    PaymentRepository
  models/
    Booking
    Payment
```

Every capability is smeared across all four folders. Cohesion inside each folder
is low (a `services/` folder mixes unrelated concerns), and coupling between
folders is high (one change to "booking" touches four directories). The layout
screams the stack.

**Package by feature** groups classes by the capability they serve:

```
src/
  bookings/
    BookingController
    BookingService
    BookingRepository
    Booking
  payments/
    PaymentController
    PaymentService
    PaymentRepository
    Payment
```

Now a capability lives in one place. Cohesion within a feature is high, coupling
between features is low, and the top level reads as the domain. This is the
property a modular monolith relies on for its module boundaries (see
`modular-monolith`), and it is the structural side of the screaming-architecture
heuristic.

The community consensus, for medium-to-large systems, favours package by
feature; package by layer survives mostly in small projects and in framework
tutorials, where its uniformity is a teaching convenience rather than an
architectural choice.

## 6. Package by component

Simon Brown's package-by-component is a middle path
([Brown, Package by component](https://dzone.com/articles/package-component-and)).
A "component" is a coarse-grained, in-process grouping that bundles a feature's
public interface with its implementation behind it, exposing a narrow surface
and hiding the layered internals. It is explicitly not separately deployed: it
is the in-process seam you could later extract into a service. It keeps the
feature-screams-the-domain benefit of package-by-feature while enforcing a clean
public boundary per component, which makes "architecturally aligned testing"
(testing at the component boundary) natural. It maps closely onto the
public-API-per-module discipline in `modular-monolith`; treat it as the same
instinct expressed at the packaging level.

## 7. Vertical slice architecture

Vertical slice architecture (Jimmy Bogard) is package-by-feature taken to the
level of the individual request
([Bogard, Vertical Slice Architecture](https://www.jimmybogard.com/vertical-slice-architecture/)).
Instead of horizontal layers shared across the whole application, each feature
is a self-contained slice running from the entry point down to data access:

```
src/
  features/
    bookings/
      CancelBooking/
        CancelBookingEndpoint
        CancelBookingCommand
        CancelBookingHandler
        CancelBookingValidator
      ConfirmBooking/
        ...
    payments/
      CapturePayment/
        ...
```

Bogard's design rule is "minimize coupling between slices, and maximize coupling
in a slice": you deliberately accept tight cohesion inside one feature in
exchange for near-zero coupling to the others, so a feature can change, grow, or
be deleted without rippling outward. The structure reads as a literal catalogue
of the system's use cases, which is Screaming Architecture at its most explicit.
It pairs naturally with CQRS (see `cqrs`), where each slice is one command or
one query handler. Note the trade-off: cross-cutting concerns and shared logic
need a deliberate home so they are not duplicated across every slice.

## 8. Composition with hexagonal, clean, and onion architecture

Screaming Architecture answers "what does the structure say?"; hexagonal, clean,
and onion architecture answer "which way do dependencies point?". They are
orthogonal and combine cleanly.

Martin's own *Clean Architecture* presents them together: the domain sits at the
centre with dependencies pointing inward (the inward-dependency rule named by
clean architecture, the same idea hexagonal expresses with ports and adapters;
see `hexagonal-architecture`), and the directory structure should announce the
domain rather than the delivery mechanism (the screaming-architecture chapter).
The usual combination is to scream the domain at the top level and layer within
each capability:

```
modules/
  ticketing/
    application/      # use cases (primary ports / command handlers)
    domain/           # entities, value objects, invariants
    infrastructure/   # adapters: persistence, messaging, HTTP
  payments/
    application/
    domain/
    infrastructure/
```

The first level screams "ticketing, payments"; the second level applies the
dependency rule inside each. The two patterns reinforce each other: keeping the
framework at arm's length (hexagonal) is what makes a domain-first top level
honest, and a domain-first top level is what makes the dependency rule visible.

Onion architecture (Jeffrey Palermo) and clean architecture are, for this
purpose, the same dependency-direction idea in different vocabularies; see
`hexagonal-architecture` for the comparison. Screaming Architecture composes with
any of them.

## 9. Relationship to domain-driven design and the modular monolith

Screaming Architecture is the structural expression of the ubiquitous language
(see `ddd-strategic-design`). When the top-level modules carry the names the
domain experts use, the codebase reflects the language of the business rather
than the language of the stack. The mapping is usually:

- top-level modules to bounded contexts or subdomains;
- second-level folders to aggregates or to use cases (commands and queries);
- the names throughout to the ubiquitous-language terms.

If reading the folder tree requires a translation table from technical names to
business concepts, the structure is not screaming and the ubiquitous language is
not being honoured.

For the modular monolith (see `modular-monolith`), the screaming top level *is*
the module boundary: one deployable unit, divided into modules named for
business capabilities, each with a public API and isolated internals. Screaming
Architecture supplies the naming and grouping discipline; the modular monolith
supplies the boundary-enforcement discipline. Together they make a monolith that
reads as a set of capabilities rather than a layered ball of code, and that can
later be extracted into services along the lines the structure already screams.

## 10. Worked example: a back-end service

A reservations system, structured so the top level screams the domain and the
dependency rule holds within each module:

```
src/
  modules/
    reservations/
      application/
        make-reservation/
          MakeReservationCommand.ts
          MakeReservationHandler.ts
        cancel-reservation/
          CancelReservationCommand.ts
          CancelReservationHandler.ts
      domain/
        Reservation.ts
        ReservationStatus.ts
        ReservationRepository.ts        # port (interface)
      infrastructure/
        PostgresReservationRepository.ts # adapter
        ReservationHttpController.ts     # adapter (delivery)
    pricing/
      application/
      domain/
      infrastructure/
    notifications/
      application/
      domain/
      infrastructure/
  shared/
    kernel/                              # genuinely cross-cutting domain types
    infrastructure/                      # framework wiring, configuration
  main.ts                                # composition root
```

What this communicates at a glance: the system is about reservations, pricing,
and notifications. The web controller and the PostgreSQL repository are visibly
adapters inside `infrastructure/`, not top-level citizens, so the delivery and
persistence mechanisms read as the details they are. The `shared/` folder exists
but is subordinate (section 12). The `main.ts` composition root wires the
adapters to the ports (see `dependency-injection` and `hexagonal-architecture`).

## 11. Worked example: a front-end application

Screaming Architecture applies just as directly to a front-end codebase
([Profydev, Evolution of a React folder structure](https://dev.to/profydev/screaming-architecture-evolution-of-a-react-folder-structure-4g25)).
A common anti-pattern groups files by technical type:

```
src/
  components/
  hooks/
  contexts/
  services/
  utils/
```

This screams "React app", not what the app does. A feature-first layout screams
the product:

```
src/
  features/
    dashboard/
      components/
      hooks/
      api/
    billing/
      components/
      hooks/
      api/
    onboarding/
      components/
      hooks/
      api/
  shared/
    ui/            # design-system primitives reused everywhere
    lib/           # generic helpers
  app/             # routing, providers, top-level composition
```

Each feature owns its components, hooks, and data access. The reusable
design-system primitives and generic helpers live in `shared/`, which is real
and useful but kept subordinate to the features (section 12). The structure
reads as "dashboard, billing, onboarding", which is what the product is.

## 12. Guardrails and when not to use it

- **Do not over-fragment a small or CRUD-heavy project.** A feature folder
  holding a single file, repeated across a dozen near-identical capabilities, is
  ceremony, not communication. The payoff of a screaming structure grows with
  the size and complexity of the domain. On a thin CRUD application a flat or
  lightly grouped layout is clearer and honest about what the system is. Apply
  the rule of three (see `simplicity-principles`) before extracting a slice.
- **It is a communication heuristic, not the dependency rule.** A domain-named
  folder does not make dependencies point inward. If the domain still imports the
  ORM and the HTTP framework, the structure screams the domain while the code
  obeys the framework. Use `hexagonal-architecture` or clean architecture for the
  dependency direction; use this skill for what the names reveal.
- **Frameworks are used, not banished.** The goal is that the framework does not
  own the top-level shape or leak into the core, not that you reinvent it. Keep
  it at the edges, in adapters and the composition root.
- **Shared and technical folders are allowed, kept subordinate.** Every real
  system needs a home for cross-cutting code: a shared kernel, infrastructure
  wiring, configuration, design-system primitives. That is fine as long as the
  business capabilities dominate the top level. When `shared/`, `common/`,
  `utils/`, and `helpers/` are the loudest folders, the structure has stopped
  screaming and started mumbling.
- **Do not rename without reorganising.** Relabelling `services/` to
  `domain-services/`, or `utils/` to `domain/`, changes the words but not the
  structure. Screaming Architecture is about where code physically lives and how
  cohesive each grouping is.
- **Beware the cost of moving an existing codebase.** Reorganising a large,
  layered codebase into feature folders is a real and risky refactor. Do it
  incrementally, capability by capability, behind passing tests, rather than as a
  single sweeping move; and only where the legibility payoff justifies the churn.

The honest summary: Screaming Architecture is close to free on a greenfield
project of any real size, because choosing feature-first names costs nothing up
front. Its value is lowest on small CRUD systems (where there is little domain to
scream) and its adoption cost is highest on large existing layered systems
(where the reorganisation is expensive). Judge accordingly.

## 13. Common misunderstandings

- **"Screaming Architecture is a kind of clean architecture."** No. It is one
  chapter and one heuristic within Martin's broader clean-architecture writing,
  concerned only with what the top-level structure communicates. Clean
  architecture's dependency rule is a separate idea; the two are combined, not
  identical.
- **"It means no technical folders at all."** No. It means business capabilities
  dominate the top level and technical or shared folders stay subordinate, not
  that they are forbidden.
- **"It forbids frameworks."** No. Frameworks are tools used at the edges. The
  rule is that they must not dictate the top-level shape or invade the core.
- **"Package by feature always beats package by layer."** Not always. For a small
  CRUD application with few files, package by layer (or a flat structure) is
  simpler and the screaming benefit is marginal. The advantage of feature-first
  grows with domain size and complexity.
- **"It is mainly a back-end concern."** No. The same heuristic improves
  front-end codebases (section 11), infrastructure-as-code layouts, and any
  project with a directory tree a newcomer must read.
