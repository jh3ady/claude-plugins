# Dependency injection reference

The detailed reference behind the skill: canonical definitions, injection styles,
composition root, Pure DI versus container, object lifetimes, anti-patterns, and
adjacent patterns.

Standards and sources:
- Mark Seemann and Steven van Deursen, *Dependency Injection Principles, Practices, and Patterns* (Manning 2019): https://www.manning.com/books/dependency-injection-principles-practices-patterns
- Mark Seemann, "Dependency Injection is passing an argument" (2017): https://blog.ploeh.dk/2017/01/27/dependency-injection-is-passing-an-argument/
- Mark Seemann, "Dependency Injection is Loose Coupling" (2010): https://blog.ploeh.dk/2010/04/07/DependencyInjectionisLooseCoupling/
- Martin Fowler, "Inversion of Control Containers and the Dependency Injection pattern" (2004): https://martinfowler.com/articles/injection.html
- Martin Fowler, "InversionOfControl" (bliki): https://martinfowler.com/bliki/InversionOfControl.html
- Mark Seemann, "Composition Root" (2011): https://blog.ploeh.dk/2011/07/28/CompositionRoot/
- Mark Seemann, "Register Resolve Release" (2010): https://blog.ploeh.dk/2010/09/29/TheRegisterResolveReleasepattern/
- Mark Seemann, "Pure DI" (2014): https://blog.ploeh.dk/2014/06/10/pure-di/
- Mark Seemann, "When to use a DI Container" (2012): https://blog.ploeh.dk/2012/11/06/WhentouseaDIContainer/
- Mark Seemann, "Captive Dependency" (2014): https://blog.ploeh.dk/2014/06/02/captive-dependency/
- Mark Seemann, "Service Locator is an Anti-Pattern" (2010): https://blog.ploeh.dk/2010/02/03/ServiceLocatorisanAnti-Pattern/
- Mark Seemann, "Service Locator violates Encapsulation" (2015): https://blog.ploeh.dk/2015/10/26/service-locator-violates-encapsulation/
- Mark Seemann, "Service Locator: roles vs mechanics" (2011): https://blog.ploeh.dk/2011/08/25/ServiceLocatorrolesvs.mechanics/
- Mark Seemann, "On Constructor Over-injection" (2018): https://blog.ploeh.dk/2018/08/27/on-constructor-over-injection/
- Mark Seemann, "Refactoring to Aggregate Services" (2010): https://blog.ploeh.dk/2010/02/02/RefactoringtoAggregateServices/
- Mark Seemann, "Interfaces are not abstractions" (2010): https://blog.ploeh.dk/2010/12/02/Interfacesarenotabstractions/
- Mark Seemann, "DI-Friendly Library" (2014): https://blog.ploeh.dk/2014/05/19/di-friendly-library/
- Derick Bailey, "Dependency Injection is NOT the same as the Dependency Inversion Principle" (2011): https://lostechies.com/derickbailey/2011/09/22/dependency-injection-is-not-the-same-as-the-dependency-inversion-principle/
- Jimmy Bogard, "Service Locator is not an Anti-Pattern" (2013): https://www.jimmybogard.com/service-locator-is-not-an-anti-pattern/
- Misko Hevery, "To 'new' or not to 'new'" (2008): https://testing.googleblog.com/2008/10/to-new-or-not-to-new.html
- Manning free content, lifestyle articles: https://freecontent.manning.com/the-transient-lifestyle/ , https://freecontent.manning.com/the-singleton-lifestyle/ , https://freecontent.manning.com/the-scoped-lifestyle/ , https://freecontent.manning.com/the-ambient-context-anti-pattern/
- NestJS providers: https://docs.nestjs.com/providers ; injection scopes: https://docs.nestjs.com/fundamentals/injection-scopes
- tsyringe (Microsoft): https://github.com/microsoft/tsyringe
- InversifyJS: https://github.com/inversify/InversifyJS
- Awilix: https://github.com/jeffijoe/awilix
- reflect-metadata: https://github.com/rbuckton/reflect-metadata
- TypeScript decorators handbook: https://www.typescriptlang.org/docs/handbook/decorators.html

---

## 1. Definition and origin

Dependency injection (DI) is the practice of supplying an object's collaborators
from the outside rather than letting it construct them. Seemann states it plainly:
"Dependency injection is, in a sense, only a specific way for objects to take
arguments" and "passing an argument."
([Seemann, 2017](https://blog.ploeh.dk/2017/01/27/dependency-injection-is-passing-an-argument/))

The book Seemann co-authored with van Deursen widens the definition to "a set of
software design principles and patterns that enable you to develop loosely coupled
code."
([Seemann and van Deursen, Manning 2019](https://www.manning.com/books/dependency-injection-principles-practices-patterns))

The term itself was introduced in 2004 by consensus among Martin Fowler and other
IoC advocates. The motivation was practical: "Inversion of Control is too generic
a term, and thus people find it confusing... we settled on the name Dependency
Injection." Fowler coordinated that naming decision; DI was not single-handedly
invented by any one person.
([Fowler, 2004](https://martinfowler.com/articles/injection.html))

Dependency injection only needs a collaborator to inject. It imposes no particular
architecture: layered, hexagonal, and domain-driven designs are all compatible
with DI, and none of them is required by it. The mechanics examples in this
reference use plain, behavior-only services such as `Clock`, `Logger`, `Notifier`,
and `Hasher` on purpose, so the mechanism is visible without presupposing any
architectural pattern. A Repository and a Gateway appear later (sections 2 and 8):
those are Fowler Patterns of Enterprise Application Architecture, shown
illustratively as the subject of their sections, not as requirements of DI.

### TypeScript example

```typescript
// WITHOUT DI: the class constructs its own collaborator (the "control freak").
// Untestable in isolation; coupled to the concrete type; time cannot be faked.

interface Clock {
  now(): Date;
}

class SystemClock implements Clock {
  now(): Date {
    return new Date();
  }
}

class OrderService {
  private readonly clock: Clock;

  constructor() {
    this.clock = new SystemClock(); // hard-coded; cannot swap, cannot fake in tests
  }

  placedAt(): Date {
    return this.clock.now();
  }
}
```

```typescript
// WITH DI (Pure DI, constructor injection): the dependency arrives from outside.
// The caller decides which implementation to pass; the class stays stable.

class OrderService {
  constructor(private readonly clock: Clock) {}

  placedAt(): Date {
    return this.clock.now();
  }
}

// Wired at the composition root:
// const service = new OrderService(new SystemClock());
// In tests, time is deterministic:
// const service = new OrderService({ now: () => new Date("2026-01-01T00:00:00Z") });
```

### When not to apply

A class with no real collaborators, such as a pure value computation or a
self-contained utility, does not need injection. Adding constructor parameters
for the sake of form is ceremony without benefit. Apply DI where collaborators
are real, swappable, or need to be seamed for testing.

---

## 2. DI versus IoC versus DIP

These three terms are frequently conflated. They are distinct.

**Inversion of Control (IoC)** is the broad principle: rather than your code
calling a framework, the framework calls your code. Fowler describes it as "the
Hollywood principle: 'Don't call us, we'll call you.'" IoC covers event loops,
template methods, plugin systems, and many other patterns. DI is only one
concrete style of IoC.
([Fowler, InversionOfControl](https://martinfowler.com/bliki/InversionOfControl.html))

**Dependency Inversion Principle (DIP)** is SOLID's "D": "High-level modules
should not depend upon low-level modules. Both should depend upon abstractions.
Abstractions should not depend upon details. Details should depend upon
abstractions." (Robert C. Martin, C++ Report June 1996.) DIP is a design
principle about ownership: the high-level policy module owns the abstraction, and
the low-level detail depends on it, not the other way around. DIP is covered in
depth in the `solid-principles` reference; this document does not redefine it.

**Dependency injection (DI)** is the narrow technique of supplying dependencies
from outside.

Two corrections worth keeping explicit:

- "DI equals DIP" is false. DI is a mechanism; DIP is an architectural principle
  about the direction of dependencies and who owns the abstraction. You can
  practice DI without achieving DIP: if the high-level module still depends on a
  low-level abstraction that it does not own, DIP is violated regardless of how
  the dependency arrives.
  ([Bailey, 2011](https://lostechies.com/derickbailey/2011/09/22/dependency-injection-is-not-the-same-as-the-dependency-inversion-principle/))

- "DI equals IoC" is false. IoC is the parent category; DI is one member of it.

DI is a common technique for keeping code in line with DIP, but the two are not
the same thing.
([Wikipedia, Dependency injection](https://en.wikipedia.org/wiki/Dependency_injection))

### TypeScript example

The example below uses a Repository deliberately, because the topic here is DIP,
the canonical example of which is a high-level policy owning a persistence
abstraction. The domain/infrastructure split shown is the DIP concern (who owns
the abstraction, which way the dependency points), explored in full in the
`solid-principles` reference. It is not how DI must be structured: DI itself needs
no layers, as the `Clock` example in section 1 shows.

```typescript
// DI without DIP: the abstraction is owned by the infrastructure layer.
// OrderService (high-level) depends on DatabaseRepository (infrastructure-defined).
// This uses DI but does not achieve DIP because the high-level module
// does not own the abstraction.

import { DatabaseRepository } from "@infra/database-repository"; // infra-owned

class OrderService {
  constructor(private readonly repo: DatabaseRepository) {}
}
```

```typescript
// DI with DIP: the abstraction is defined in the domain (high-level policy).
// Infrastructure implements it; the dependency arrow points toward the domain.

// domain/order-repository.ts  - owned by the high-level domain
export interface OrderRepository {
  findById(id: string): Promise<Order | null>;
}

// infrastructure/sql-order-repository.ts  - depends on the domain interface
export class SqlOrderRepository implements OrderRepository {
  findById(id: string): Promise<Order | null> { /* ... */ }
}

// OrderService depends on the interface it owns, achieving DIP.
class OrderService {
  constructor(private readonly repo: OrderRepository) {} // domain-owned interface
}
```

### When not to apply

Extracting an interface and injecting it achieves DI. It does not by itself
achieve DIP unless the high-level policy module is the one that defines and owns
the abstraction. If you add an interface purely because it "looks like DIP" but
the interface is defined in the infrastructure layer, the direction of the
dependency has not changed.

---

## 3. Injection styles

There are two independent taxonomies of injection styles. They must not be merged
into one list, because they use different terminology for overlapping concepts.

**Fowler's taxonomy** (2004): Constructor injection, Setter injection, Interface
injection. (Interface injection, where an interface declares the setter the
injector calls, is rare in practice and absent from Seemann's taxonomy.)
([Fowler, 2004](https://martinfowler.com/articles/injection.html))

**Seemann's taxonomy** (book): Constructor injection, Property injection, Method
injection, Ambient Context.
(Seemann and van Deursen, Manning 2019; "Property" in Seemann corresponds to
"Setter" in Fowler.)

### Constructor injection (the default)

Declare required dependencies as constructor parameters. This guarantees that
required dependencies are present at construction: the object is ready to use
the moment it exists. Seemann: "Favour the Constructor Injection pattern over
other injection patterns, because of its simplicity and degree of encapsulation."
([Seemann, 2014](https://blog.ploeh.dk/2014/05/19/di-friendly-library/))
Fowler: "My preference is to start with constructor injection."

Use constructor injection for all required collaborators. It eliminates temporal
coupling (the risk of calling a method before a dependency is assigned) and
supports immutability.

### Property/setter injection (optional dependencies only)

Declare an optional dependency as a settable property (or setter method). The
class provides a sensible local default; callers may override it. Use only when
a dependency is genuinely optional and a meaningful default exists. Overuse turns
dependencies into hidden requirements.

### Method injection (per-call dependency)

Pass the dependency as a parameter to the method that needs it, rather than to
the constructor. Use when the dependency varies per call or per operation, for
example a command handler that receives its execution context at call time.

### TypeScript example

```typescript
// Constructor injection: required dependencies arrive at construction.
// The class cannot be instantiated without them. Neutral collaborators: Clock, Notifier.

class ReminderService {
  constructor(
    private readonly clock: Clock,        // required
    private readonly notifier: Notifier,  // required
  ) {}

  remind(userId: string): void {
    const at = this.clock.now();
    this.notifier.send(userId, `Reminder issued at ${at.toISOString()}`);
  }
}
```

```typescript
// Property injection: an optional dependency with a sensible default.
// The class works without the caller setting it; the logger is a no-op by default.

class TaskRunner {
  logger: Logger = { info: () => {} }; // optional; no-op default, overridable

  run(task: string): void {
    this.logger.info(`Running ${task}`);
    // ... do the work; the logger is genuinely optional
  }
}

// Caller overrides the logger when one is available:
// const runner = new TaskRunner();
// runner.logger = new ConsoleLogger();
```

```typescript
// Method injection: dependency varies per call.
// The cancellation token is supplied per invocation, not held as state.

class BatchProcessor {
  process(items: readonly string[], cancellation: CancellationToken): void {
    for (const item of items) {
      if (cancellation.isCancelled()) return; // per-call dependency
      // ... handle item
    }
  }
}
```

### When not to apply

Do not use property injection for a dependency the class cannot function without.
If the property is left at its default and the default is not useful, you have a
temporal coupling problem. Use constructor injection for anything required.

---

## 4. Composition root

The composition root is the single location in an application where all
components are wired into an object graph. Seemann: "A Composition Root is a
(preferably) unique location in an application where modules are composed
together." It should be "as close as possible to the application's entry point."
([Seemann, 2011](https://blog.ploeh.dk/2011/07/28/CompositionRoot/))

Three rules govern the composition root:

1. **One per application.** "Each application/process requires only a single
   Composition Root. It doesn't matter how complex the application is."
   ([Seemann, 2011](https://blog.ploeh.dk/2011/07/28/CompositionRoot/))

2. **Confine the container.** "A DI Container should only be referenced from the
   Composition Root. All other modules should have no reference to the container."
   This structural rule is the primary defense against the service locator
   anti-pattern.
   ([Seemann, 2011](https://blog.ploeh.dk/2011/07/28/CompositionRoot/))

3. **Register Resolve Release.** The only three things to do with a container:
   register components, resolve the root object, and release when done. No other
   module should call resolve directly.
   ([Seemann, 2010](https://blog.ploeh.dk/2010/09/29/TheRegisterResolveReleasepattern/))

### TypeScript example (Pure DI composition root)

```typescript
// main.ts  - the application entry point; the composition root

import { SystemClock } from "./system-clock";
import { ConsoleLogger } from "./console-logger";
import { ReminderService } from "./reminder-service";
import { createServer } from "./server";

function main(): void {
  // All wiring happens here; nothing else in the application knows about it.
  const clock = new SystemClock();
  const logger = new ConsoleLogger();
  const reminderService = new ReminderService(clock, logger); // depends on both

  const server = createServer(reminderService);
  server.listen(3000);
}

main();
```

No import of a DI container appears anywhere except in the composition root. All
other modules are plain classes that receive their dependencies through
constructors.

### When not to apply

Libraries and frameworks should not have a composition root. "Only applications
should have Composition Roots. Libraries and frameworks shouldn't."
([Seemann, 2011](https://blog.ploeh.dk/2011/07/28/CompositionRoot/)) A library
that wires its own object graph internally couples itself to specific
implementations and prevents callers from substituting alternatives.

---

## 5. Pure DI versus a container

**Pure DI** means wiring the object graph by hand with ordinary constructor calls,
no container library involved. Seemann coined the name in 2014, replacing the
older "Poor Man's DI" label, which carried an unfair connotation of inadequacy.
([Seemann, 2014](https://blog.ploeh.dk/2014/06/10/pure-di/))

Pure DI has concrete strengths:
- Fully type-checked. The compiler catches missing or wrong-type dependencies.
- Compile-time feedback: "fastest feedback about correctness."
- Simple and debuggable; the graph is ordinary code.

Its cost is that every constructor change requires a corresponding edit in the
composition root.

**A DI container** auto-wires components by convention or by explicit
registration. It earns its keep primarily through Convention over Configuration
on a large graph, where auto-registration dramatically reduces the maintenance
burden of manual wiring. The trade-off is that it loses compile-time safety: a
misconfigured registration becomes a runtime error, not a compile error. Seemann's
rule: "Don't use a DI Container just to use one."
([Seemann, 2012](https://blog.ploeh.dk/2012/11/06/WhentouseaDIContainer/))

Pure DI is the default. A container is a tool that earns its place on a large
graph with many components.

### TypeScript runtime constraint

TypeScript types and interfaces are erased at runtime
(https://www.typescriptlang.org/docs/handbook/2/everyday-types.html). A container
cannot use an interface as a token because the interface does not exist at runtime.
Token-based injection is required: use a class reference, a string constant, a
`Symbol`, or an `InjectionToken` as the key.

Most TypeScript containers rely on the legacy `experimentalDecorators` plus
`emitDecoratorMetadata` flags, which cause the TypeScript compiler to emit
`design:paramtypes` metadata via `reflect-metadata`
(https://github.com/rbuckton/reflect-metadata). This metadata is what allows
auto-wiring by type. The TC39 Stage 3 decorator proposal does not emit
`design:paramtypes`, which is why NestJS, tsyringe, and InversifyJS still require
the legacy compiler flags and cannot yet use TC39 Stage 3 decorators for
auto-wiring.

### TypeScript containers (referenced with trade-offs, not tutorialized)

- **NestJS built-in DI**: module-scoped providers, constructor injection by
  default, singleton scope with opt-in REQUEST and TRANSIENT scopes. Non-class
  tokens require custom providers and `@Inject`.
  (https://docs.nestjs.com/providers , https://docs.nestjs.com/fundamentals/injection-scopes)

- **tsyringe (Microsoft)**: lightweight, decorator-based (`@injectable`,
  `@inject`, `container.resolve`). Requires `reflect-metadata` and legacy
  compiler flags.
  (https://github.com/microsoft/tsyringe)

- **InversifyJS**: decorator-based with Symbol identifiers following the
  TYPES pattern. Requires `reflect-metadata` and legacy flags.
  (https://github.com/inversify/InversifyJS)

- **Awilix**: no decorators, no `reflect-metadata`. Proxy mode resolves by
  destructured parameter names; Classic mode resolves by positional parameter
  names. Caveat: "Don't use CLASSIC if you minify your code!" because minification
  renames parameters and breaks resolution by name.
  (https://github.com/jeffijoe/awilix)

### TypeScript example

```typescript
// PURE DI: the same graph wired by hand.
// No library import. Fully type-safe. Compile-time errors if a dependency
// changes or is missing. Neutral collaborators: Clock, Hasher.

import { SystemClock } from "./system-clock";
import { BcryptHasher } from "./bcrypt-hasher";
import { SignupService } from "./signup-service";

// Pure DI: manual wiring, no magic, no tokens.
const clock = new SystemClock();
const hasher = new BcryptHasher();
const signupService = new SignupService(clock, hasher);
```

```typescript
// CONTAINER SKETCH (tsyringe): the same graph, auto-wired.
// A token is required because the Clock interface is erased at runtime;
// a string, Symbol, abstract class, or InjectionToken stands in for it.
// Loses compile-time feedback on misconfiguration; gains auto-registration.

import "reflect-metadata";
import { container, injectable, inject } from "tsyringe";

const CLOCK_TOKEN = "Clock"; // interfaces cannot be tokens; this string can

@injectable()
class SystemClock implements Clock { /* ... */ }

@injectable()
class BcryptHasher implements Hasher { /* ... */ }

@injectable()
class SignupService {
  constructor(
    @inject(CLOCK_TOKEN) private readonly clock: Clock,
    private readonly hasher: BcryptHasher,
  ) {}
}

// Registration at the composition root:
container.register(CLOCK_TOKEN, { useClass: SystemClock });
const signupService = container.resolve(SignupService);
```

### When not to apply

A small or medium application does not need a container. The added configuration
surface, the runtime-only feedback, and the decorator/metadata complexity are
costs without matching payoff when the graph is small enough to wire by hand.

---

## 6. Object lifetimes

Every component registered with a container (or deliberately managed in Pure DI)
has a lifetime that determines how long an instance lives before it is released.
Seemann's book uses the term "lifestyle"; the .NET ecosystem uses "lifetime."
They describe the same three options.

**Transient**: a new instance is created every time the component is requested.
No shared state; safe under concurrency.
(https://freecontent.manning.com/the-transient-lifestyle/)

**Singleton**: one instance is created for the lifetime of the container (the
application). All callers share the same instance. Note: this is distinct from
the Singleton design pattern, which adds a global static accessor and its
attendant problems. A singleton lifetime in DI is managed by the container or
the composition root; there is no static accessor.
(https://freecontent.manning.com/the-singleton-lifestyle/)

**Scoped**: one instance per scope, typically per web request. All components
resolved within the same scope share the instance; a new instance is created for
each scope.
(https://freecontent.manning.com/the-scoped-lifestyle/)

### Captive dependency

A captive dependency occurs when a longer-lived component holds a reference to a
shorter-lived one past its intended release. The canonical case: a singleton
captures a scoped (per-request) dependency at construction time. Because the
singleton lives for the application lifetime, the scoped dependency is never
released between requests; it is effectively promoted to singleton lifetime.
Under concurrency, multiple requests share the same instance of what should have
been a per-request collaborator, which can produce data corruption or incorrect
behavior.
([Seemann, 2014](https://blog.ploeh.dk/2014/06/02/captive-dependency/))

### TypeScript example

```typescript
// PROBLEM: singleton capturing a scoped dependency.
// RequestContext is per-request (scoped). RequestLogger is singleton.
// Every request after the first shares the same RequestContext instance.

class RequestContext {
  readonly requestId = crypto.randomUUID(); // should be unique per request
}

class RequestLogger {
  // The RequestContext captured here is the one from the FIRST request.
  // All subsequent requests log the same (wrong) requestId.
  constructor(private readonly context: RequestContext) {} // captive: scoped inside singleton

  log(message: string): void {
    console.log(`[${this.context.requestId}] ${message}`);
  }
}
```

```typescript
// FIX: pass the per-request dependency through method parameters,
// or make RequestLogger scoped as well.

class RequestLogger {
  log(message: string, context: RequestContext): void {
    // RequestContext is passed per call, not held as state.
    console.log(`[${context.requestId}] ${message}`);
  }
}
```

### When not to apply

A stateless, side-effect-free service with no mutable fields is safe as a
singleton regardless of concurrency. A concern arises only when the component
holds mutable state or depends on a shorter-lived collaborator.

---

## 7. Anti-patterns

### Service locator

A service locator is a global registry from which components pull their
dependencies by calling a resolve method. Seemann classifies it as an anti-pattern:
it hides a class's dependencies, turning compile-time errors into run-time errors,
and it violates encapsulation.
([Seemann, 2010](https://blog.ploeh.dk/2010/02/03/ServiceLocatorisanAnti-Pattern/) ,
[Seemann, 2015](https://blog.ploeh.dk/2015/10/26/service-locator-violates-encapsulation/))

This position is contested. Fowler treats service locator and DI as two legitimate
alternatives for injecting dependencies, with a mild preference for DI.
([Fowler, 2004](https://martinfowler.com/articles/injection.html)) Jimmy Bogard
rebuts the anti-pattern label directly, arguing that the criticisms apply to
misuse rather than the pattern itself.
([Bogard, 2013](https://www.jimmybogard.com/service-locator-is-not-an-anti-pattern/))

The default position in this reference is: prefer injection over a service
locator; confine the container to the composition root. A DI container is not
inherently a service locator, but it becomes one when called from outside the
composition root.
([Seemann, 2011](https://blog.ploeh.dk/2011/08/25/ServiceLocatorrolesvs.mechanics/))

The Seemann versus Fowler/Bogard disagreement is real and not fully resolved.
Present it as such.

### Control freak

A class that constructs its own dependencies using `new` (or via static
factories) instead of having them injected. This is the opposite of IoC and the
most common DI anti-pattern. The class controls the creation of its collaborators,
making it impossible to substitute alternatives without modifying the class.

### Constrained construction

An implicit constraint that requires a specific constructor signature, usually
imposed by a late-binding mechanism that instantiates types from a configuration
file at runtime. When the mechanism demands a no-argument constructor (or a fixed
signature), it prevents the class from declaring its dependencies explicitly. The
result is that dependencies must be obtained by other means, typically a service
locator call inside the body.

### Ambient context

A static or global accessor that provides a dependency (for example,
`TimeProvider.Current` or `Logger.Instance`). The dependency is hidden from the
public API, which makes it impossible for callers to see, substitute, or test it
without modifying global state. Ambient context causes temporal coupling and
complicates parallel test execution.
(https://freecontent.manning.com/the-ambient-context-anti-pattern/)

### Injecting the container itself

Passing the container as a dependency to a class is a manifestation of the
service locator pattern. The container "must never be allowed to leak outside the
Composition Root."
([Seemann, 2011](https://blog.ploeh.dk/2011/07/28/CompositionRoot/))
A class that holds a container can resolve any dependency it wants, making its
actual requirements invisible to its callers.

### Constructor over-injection

Having too many constructor parameters is a code smell, not an anti-pattern.
Seemann is explicit: "Constructor Over-injection is a code smell, not an
anti-pattern" and it "tends to be a symptom that a class is doing too much:
violating the Single Responsibility Principle."
([Seemann, 2018](https://blog.ploeh.dk/2018/08/27/on-constructor-over-injection/))

A heuristic: more than three or four constructor parameters is a signal worth
investigating. The correct response is to refactor responsibilities, extracting
cohesive clusters into Facade Services or Aggregate Services.
([Seemann, 2010](https://blog.ploeh.dk/2010/02/02/RefactoringtoAggregateServices/))
Switching injection styles (for example, moving to property injection to hide the
count) or wrapping parameters in a single parameter object ("deodorant") does not
address the underlying SRP violation; it masks it.

### TypeScript example

```typescript
// SERVICE LOCATOR call site: dependencies are hidden inside the method body.
// The class signature reveals nothing about what it needs (here a Clock and a Logger).

class Greeter {
  greet(name: string): string {
    // Dependencies fetched from a global locator; invisible to callers.
    const clock = serviceLocator.resolve<Clock>("Clock");
    const logger = serviceLocator.resolve<Logger>("Logger");
    logger.info(`Greeting ${name}`);
    return `Hello ${name}, the time is ${clock.now().toISOString()}`;
  }
}
```

```typescript
// INJECTION: dependencies declared in the constructor.
// Callers can see and supply exactly what is needed.
// A missing dependency is a compile-time error (Pure DI) or a clear
// startup-time error (container).

class Greeter {
  constructor(
    private readonly clock: Clock,
    private readonly logger: Logger,
  ) {}

  greet(name: string): string {
    this.logger.info(`Greeting ${name}`);
    return `Hello ${name}, the time is ${this.clock.now().toISOString()}`;
  }
}
```

### When not to apply

These are well-defined anti-patterns with a specific exception for constructor
over-injection, which is a code smell. The exception to be aware of: Fowler and
Bogard's disagreement on service locator means the classification is not
universally settled. Document and justify any deliberate use of a locator pattern
if the team decides to use one; do not use it by accident.

---

## 8. Adjacent patterns

### DIP (Dependency Inversion Principle)

DI is a common mechanism for achieving DIP, but the two are distinct (see
section 2). DIP is covered in depth in the `solid-principles` reference, which
should be consulted for the full definition, canonical examples, and its
"when not to apply" guidance.

### Hexagonal architecture (ports and adapters)

In hexagonal architecture (Cockburn), the application core defines ports
(interfaces) and adapters implement them. DI is the wiring mechanism: at the
composition root, concrete adapters are injected into the core through the ports.
DI makes this wiring possible but is not the architecture itself. "A wiring
mechanism, not an architecture." Alistair Cockburn's original hexagonal
architecture description does not even mention DI.
(https://en.wikipedia.org/wiki/Hexagonal_architecture_(software))

### Composition root in a modular monolith

A modular monolith has one composition root per application, not one per module.
Each module exposes a registration fragment, a function or object that registers
that module's components with the container or wires them into the Pure DI graph.
The application-level composition root calls each module's registration fragment.
This keeps module internals encapsulated while letting the composition root remain
the single place where the graph is assembled.
([Seemann, 2015](https://blog.ploeh.dk/2015/01/06/composition-root-reuse/))
See also the `modular-monolith` reference for boundary design and data isolation.

### Strategy pattern

Injecting a strategy (GoF) is one form of DI: the strategy is a collaborator
that is supplied from outside, and different strategies can be substituted at the
composition root or per call. DI is broader; it injects any collaborator, not
only those that vary algorithms. Strategy is narrower: it specifically captures
the "interchangeable algorithm" intent.

### Injectables versus newables (Hevery)

Misko Hevery draws a useful line between two kinds of objects:

- **Injectables**: services and collaborators with behavior. These should be
  injected; they never create newables as part of their own construction.
- **Newables**: value objects and entities. These are created with `new` at
  the point of use. They carry data, not long-lived infrastructure.

The rules: "Newables must not depend on injectables" and "Injectables must not
hold newables as state."
([Hevery, 2008](https://testing.googleblog.com/2008/10/to-new-or-not-to-new.html))

A concrete example: `Order` is a newable; `OrderRepository` is an injectable.
`OrderRepository` must not hold a reference to a specific `Order` instance as
a field. `Order` must not depend on `OrderRepository` to load itself.

### Single-implementation interface and over-abstraction (RAP)

Introducing an interface that has only one implementation and serves no
architectural boundary purpose is over-abstraction. Seemann: "Having only one
implementation of a given interface is a code smell."
([Seemann, 2010](https://blog.ploeh.dk/2010/12/02/Interfacesarenotabstractions/))

The Reused Abstractions Principle (RAP), coined by Jason Gorman and popularized
by Seemann, states that a genuine abstraction is one that multiple implementations
can satisfy meaningfully. An interface with a single implementation and no seam
reason (no test double, no architectural port, no variant in sight) is
indirection without abstraction. This connects directly to the DIP guardrail in
the `solid-principles` reference: the deciding question is whether the interface
serves a real boundary, not how many implementations exist today.

### TypeScript example: injectables versus newables and the composition root

```typescript
// Order is a NEWABLE: a value object created at the point of use.
// It carries data; it does not depend on services.

class Order {
  constructor(
    readonly id: string,
    readonly customerId: string,
    readonly items: readonly OrderItem[],
  ) {}
}
```

```typescript
// OrderService is an INJECTABLE: it holds infrastructure dependencies
// and acts on newables passed to it, but never holds a specific Order as state.

class OrderService {
  constructor(
    private readonly orderRepository: OrderRepository, // injectable
    private readonly paymentGateway: PaymentGateway,   // injectable
  ) {}

  async placeOrder(customerId: string, items: OrderItem[]): Promise<Order> {
    const order = new Order(crypto.randomUUID(), customerId, items); // newable created here
    await this.orderRepository.save(order);
    await this.paymentGateway.charge(order.customerId, items);
    return order;
  }
}
```

```typescript
// Composition root: module registration fragments wired together.
// Each module returns its own slice; the root assembles the graph.

function wireOrdersModule(db: DatabaseConnection): OrderController {
  const orderRepository = new SqlOrderRepository(db);
  const paymentGateway = new StripePaymentGateway(process.env.STRIPE_KEY!);
  const orderService = new OrderService(orderRepository, paymentGateway);
  return new OrderController(orderService);
}
```

### When not to apply

Do not introduce a Strategy abstraction solely to make a class "injectable." If
there is only one algorithm and no variant is expected, the interface adds
indirection without benefit. Similarly, do not add an injectable seam for a value
object whose only consumer is the local class. Apply the injectable/newable
distinction where it reduces coupling to infrastructure; do not apply it as a
blanket rule that treats every `new` as suspect.

---

## Pragmatism

DI is a means to an end: loosely coupled code that is testable, replaceable, and
easy to reason about. The full toolkit (container, lifetimes, named tokens,
decorator metadata) earns its place only on graphs large enough to make manual
wiring a genuine burden.

A small application with a handful of classes is best served by Pure DI: a few
constructor calls in `main.ts`, no framework, full compile-time safety. A
large application with dozens of modules may benefit from convention-based
auto-registration, accepting the trade-off of runtime-only misconfiguration
feedback.

Match the level of sophistication to the actual need. DI without a composition
root, or a container used outside the composition root, loses most of the
structural benefits that make DI valuable in the first place.
