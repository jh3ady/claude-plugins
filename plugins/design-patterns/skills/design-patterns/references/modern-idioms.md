# Modern idioms reference

The detailed reference behind the skill: force or smell, when not to apply,
minimal TypeScript form, and composition notes for each of the four modern
idioms that the 1994 Gang of Four catalogue predates.

Sources vary by idiom; see the Sources section at the end of this file.

---

## Null Object

The smell is scattered null or undefined guards protecting calls to an optional
collaborator. A component receives a logger, a notifier, or a formatter that may
or may not be present, and every call site wraps the invocation in
`if (logger) logger.info(...)` or an equivalent check. The guards are
repetitive, they clutter the calling code, and they make it easy to miss one.
The Null Object replaces the optional with a concrete object that satisfies the
same interface and does nothing, so the caller can invoke without branching.

Source: Fowler, *Refactoring* (1999).

### When not to apply

When absence is meaningful and a caller must react differently depending on
whether the collaborator is present. In that case the guard is not noise: it is
a real branch that carries business intent. Replacing it with a Null Object
erases the distinction and hides the branch, which can silently swallow a bug.
The Null Object is appropriate only when the no-op behaviour is genuinely
correct for every call site, not just convenient at one.

### Minimal form

```typescript
interface Logger {
  info(message: string):  void;
  warn(message: string):  void;
  error(message: string): void;
}

class ConsoleLogger implements Logger {
  info(message: string):  void { console.info(message);  }
  warn(message: string):  void { console.warn(message);  }
  error(message: string): void { console.error(message); }
}

// Null Object: satisfies the Logger interface without producing side-effects.
class NullLogger implements Logger {
  info(_message: string):  void {}
  warn(_message: string):  void {}
  error(_message: string): void {}
}

class ReportGenerator {
  constructor(private readonly logger: Logger) {}

  generate(): string {
    this.logger.info("starting report generation");
    // ... generation logic ...
    this.logger.info("report generation complete");
    return "report content";
  }
}

// In production pass ConsoleLogger; in tests or quiet contexts pass NullLogger.
// No null guard at the call site in either case.
const generator = new ReportGenerator(new NullLogger());
```

The collaborator type changes from `Logger | null` to `Logger`, which the
constructor receives unconditionally. The two concrete implementations
(ConsoleLogger and NullLogger) differ only in whether they produce side-effects;
the calling code never branches on presence.

### Composition

Null Object is the pattern-level answer to the smell that **`clean-code`**
describes as repeated null guards cluttering a collaborator's call sites. Where
clean-code advises against defensive guards that repeat throughout a class, Null
Object removes the need for them at the source. Apply it at the boundary where
the optional collaborator is injected; pass the result unconditionally from that
point forward.

---

## Result / Either

The smell is a function whose failure path is invisible in its type. A function
that throws on failure compels the caller to guess which calls may throw and to
read documentation or source to know which error types are possible. Success and
failure look identical at the call site; the type system offers no help. When a
failure is a recoverable, expected outcome rather than a truly exceptional event,
modelling it in the return type makes both paths explicit, and the type system
enforces that the caller handles both.

Source: common TypeScript practice.

### When not to apply

When the failure is truly exceptional, unrecoverable, or represents a
programming error, an exception is clearer and more idiomatic than a Result. Do
not thread a Result through every layer of an application dogmatically. A Result
forces the caller to unwrap before using the value; in layers that have no
meaningful failure handling to add, that unwrapping is ceremony that obscures
the happy path without contributing anything. Throw when the failure is
extraordinary; return a Result when the failure is an expected part of the
contract.

### Minimal form

```typescript
type Result<T, E> = { ok: true; value: T } | { ok: false; error: E };

function parsePositiveInteger(input: string): Result<number, string> {
  const n = parseInt(input, 10);
  if (isNaN(n) || n <= 0) {
    return { ok: false, error: `"${input}" is not a positive integer` };
  }
  return { ok: true, value: n };
}

const result = parsePositiveInteger("42");
if (result.ok) {
  // TypeScript narrows the union: result.value is number in this branch.
  console.log(result.value * 2);
} else {
  // TypeScript narrows: result.error is string in this branch.
  console.error(result.error);
}
```

The discriminated union on `ok` is the key. TypeScript narrows the type inside
each branch, so accessing `result.value` in the true branch and `result.error`
in the false branch is type-safe without a cast. The union member accessed in
each branch is the only one the narrowed type exposes.

### Composition

Result / Either is the idiomatic TypeScript expression of the error-handling
discipline that **`clean-code`** describes: failures that are part of the
contract belong in the return type, not in a thrown exception that is invisible
to the caller. When domain operations produce typed domain errors (for example,
`InsufficientFundsError` or `ProductNotFoundError`), the error slot of the
Result is the natural home for them. Keep the error types specific; a
`Result<T, string>` is a starting point, not a destination.

---

## Specification

The smell is a boolean business rule duplicated across query filters, validation
functions, domain services, and test fixtures. Each copy must be kept in sync,
and the rule cannot be composed or reused without copy-paste. When the rule is
complex (multiple criteria combined with and, or, not) and recurs in more than
one place, making it an explicit object with a name, a clear `isSatisfiedBy`
entry point, and combinators that compose rules in domain terms is a net gain.

Source: Fowler, and Evans and Fowler on Specification.

### When not to apply

When the predicate is a one-off used in exactly one place, a plain function or
inline arrow is lighter and equally clear. Do not build the full combinator
algebra speculatively for a predicate that today has no combinators and no
second use site. The rule of three applies: the composition mechanics pay for
themselves when there are at least three places combining or reusing the rule.
Introducing the algebra for a single predicate is premature machinery.

### Minimal form

```typescript
interface Specification<T> {
  isSatisfiedBy(candidate: T): boolean;
  and(other: Specification<T>): Specification<T>;
  or(other: Specification<T>):  Specification<T>;
  not(): Specification<T>;
}

// Abstract base that implements the combinators in terms of isSatisfiedBy,
// so concrete specifications only need to override the one abstract method.
abstract class CompositeSpecification<T> implements Specification<T> {
  abstract isSatisfiedBy(candidate: T): boolean;

  and(other: Specification<T>): Specification<T> {
    return new AndSpecification(this, other);
  }

  or(other: Specification<T>): Specification<T> {
    return new OrSpecification(this, other);
  }

  not(): Specification<T> {
    return new NotSpecification(this);
  }
}

class AndSpecification<T> extends CompositeSpecification<T> {
  constructor(
    private readonly left:  Specification<T>,
    private readonly right: Specification<T>,
  ) { super(); }

  isSatisfiedBy(candidate: T): boolean {
    return this.left.isSatisfiedBy(candidate) &&
           this.right.isSatisfiedBy(candidate);
  }
}

class OrSpecification<T> extends CompositeSpecification<T> {
  constructor(
    private readonly left:  Specification<T>,
    private readonly right: Specification<T>,
  ) { super(); }

  isSatisfiedBy(candidate: T): boolean {
    return this.left.isSatisfiedBy(candidate) ||
           this.right.isSatisfiedBy(candidate);
  }
}

class NotSpecification<T> extends CompositeSpecification<T> {
  constructor(private readonly inner: Specification<T>) { super(); }

  isSatisfiedBy(candidate: T): boolean {
    return !this.inner.isSatisfiedBy(candidate);
  }
}

// Concrete specifications expressed in domain terms.
interface Product {
  inStock: boolean;
  price:   number;
}

class InStockSpecification extends CompositeSpecification<Product> {
  isSatisfiedBy(product: Product): boolean {
    return product.inStock;
  }
}

class AffordableSpecification extends CompositeSpecification<Product> {
  constructor(private readonly maxPrice: number) { super(); }

  isSatisfiedBy(product: Product): boolean {
    return product.price <= this.maxPrice;
  }
}

// Compose in domain terms: in stock AND priced at or under 50.
const availableAndAffordable =
  new InStockSpecification().and(new AffordableSpecification(50));

declare const products: Product[];
const results = products.filter(p => availableAndAffordable.isSatisfiedBy(p));
```

### Composition

Specification is a domain-layer pattern. This entry owns the generic
filter-composition mechanism: a predicate object with a named interface and
composable combinators. When a specification expresses domain eligibility
criteria inside an aggregate or bounded context (for example, a
`CustomerEligibleForCreditSpec` that enforces domain invariants), its placement,
naming, and relationship to the aggregate root are owned by
**`domain-driven-design`**. Point there for the domain-specific application;
this entry is the generic mechanism.

---

## Functional patterns

The smell is a class hierarchy erected to solve a problem that a function
parameter or a closure would solve with a fraction of the machinery. The Gang of
Four drew classes because Java and C++ did not have first-class functions. In
TypeScript, a Strategy is frequently a typed function parameter; a Command is
frequently a closure that captures its context at construction time; immutable
data transformations often replace stateful objects entirely. The overhead of an
interface, a class, and an instantiation is real; it pays for itself only when
the pattern genuinely needs state across calls, explicit typing for many
collaborators, or lifecycle coordination.

Source: common practice.

### When not to apply

When the function or closure form genuinely requires state that persists across
calls, when many collaborators share the same interface and polymorphic dispatch
is valuable, or when lifecycle concerns (construction order, disposal, explicit
identity) make an object the right unit. The function form is lighter but not
universal. Choose it when the benefit is genuine concision; do not choose it to
avoid writing a class when the class form is actually clearer.

### Minimal form

```typescript
// --- Strategy as a function parameter ---

// No interface or class required; the function type is the contract.
type SortStrategy<T> = (items: ReadonlyArray<T>) => T[];

function sortItems<T>(items: ReadonlyArray<T>, sort: SortStrategy<T>): T[] {
  return sort(items);
}

// Pass an arrow directly; no class instantiation needed.
const sorted = sortItems([3, 1, 2], xs => [...xs].sort((a, b) => a - b));

// Class form: justified when the strategy carries persistent configuration or
// when many collaborators must share the same named interface.
interface SortStrategyObject<T> {
  sort(items: ReadonlyArray<T>): T[];
}
```

```typescript
// --- Command as a closure ---

// The closure captures its dependencies at construction time and IS the command.
function makeDeleteCommand(
  repository: { delete(id: string): Promise<void> },
  id: string,
): () => Promise<void> {
  return () => repository.delete(id); // closes over repository and id
}

declare const userRepository: { delete(id: string): Promise<void> };
const deleteUser = makeDeleteCommand(userRepository, "user-42");
deleteUser(); // returns Promise<void>; await it in an async context

// Class form: justified when the command must implement a shared Command
// interface, carry undo logic as a second method, or integrate with a command
// bus that requires an object with a known shape.
interface Command {
  execute(): Promise<void>;
}

class DeleteCommand implements Command {
  constructor(
    private readonly repository: { delete(id: string): Promise<void> },
    private readonly id: string,
  ) {}

  execute(): Promise<void> {
    return this.repository.delete(this.id);
  }
}
```

```typescript
// --- Immutability ---

// Produce a new value rather than mutating in place.
interface Config {
  readonly host:  string;
  readonly port:  number;
  readonly debug: boolean;
}

function withDebug(config: Config): Config {
  return { ...config, debug: true };
}
// The original config is untouched; the caller receives a new object.
```

The three sub-examples share a theme: default to a function or a value
transformation; draw a class only when it adds something the function form
cannot provide. This is the minimal-form principle from the SKILL.md decision
reflex applied directly.

### Composition

Functional patterns reinforce the "reach for the minimal form" thread that runs
through the SKILL.md decision reflex and through **`references/structural.md`**
(the Decorator entry there already shows the higher-order function wrapping form
as the idiomatic TypeScript choice over the class form). When a domain event
handler or a command bus requires an explicit object, the class form remains
available; the point is not to avoid classes categorically but to default to the
lighter form until the class earns its place.

---

## Modern idioms and the decision reflex

These four idioms occupy a specific position in the design vocabulary: each is
frequently the minimal form that a classic Gang of Four pattern over-engineers
for the same job. Null Object is lighter than a null-guard repeated at every
call site. Result/Either is lighter than a checked exception hierarchy when the
failure is expected and recoverable. Specification is lighter than a full
Visitor or Chain of Responsibility when the only need is composable boolean
filtering. Functional patterns are lighter than Strategy and Command class
hierarchies when no state or lifecycle management is needed. The decision reflex
from SKILL.md applies here as much as to the GoF catalogue: name the problem
first, reach for the minimal form that solves it, and draw the heavier machinery
only when the lighter form runs out.

---

## Sources

- Fowler, Martin, *Refactoring: Improving the Design of Existing Code* (1999):
  source for Null Object.
- Evans, Eric, and Fowler, Martin, on the Specification pattern: source for
  Specification.
- Common TypeScript practice: Result/Either and functional patterns (higher-order
  functions, closures, immutability) reflect idiomatic TypeScript usage; no
  single canonical text is cited.
