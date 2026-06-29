# Legacy Code Changes: Reference

Deeper background for the `legacy-code-changes` skill. The skill body holds
the working rules; this file holds the canonical definitions, the trade-off
analyses, and the worked examples, with sources.

## Table of contents

1. [What legacy code is and the change dilemma](#1-what-legacy-code-is-and-the-change-dilemma)
2. [The Legacy Code Change Algorithm](#2-the-legacy-code-change-algorithm)
3. [Seams and enabling points](#3-seams-and-enabling-points)
4. [Characterization tests](#4-characterization-tests)
5. [Reasoning about effects](#5-reasoning-about-effects)
6. [Working when time is short](#6-working-when-time-is-short)
7. [When this is overkill](#7-when-this-is-overkill)
8. [Sources](#8-sources)

---

## 1. What legacy code is and the change dilemma

Feathers defines legacy code precisely: it is code without tests. Not old code,
not badly written code, not code no one understands. Those properties often
accompany the absence of tests, but they are not the definition. A codebase can
be recent, well-structured, and readable and still be legacy if it has no
automated tests, because tests are what allow you to change code confidently
(Feathers, *Working Effectively with Legacy Code*, 2004, Preface).

The practical consequence is a dilemma. To change code safely you want tests in
place before you touch anything. But in untested code, the very structure that
needs tests makes writing them hard: classes construct their own heavy
collaborators, modules call out to databases or file systems, global state is
shared without ceremony. To write tests, you need to change the code. To change
the code safely, you need tests. Neither step can happen first in an obvious way.

### Why edit-and-pray fails

The instinctive response to this situation is **edit-and-pray**: read the code
carefully, make the change you think is right, run the application, and hope
nothing breaks. The problem is that careful reading cannot substitute for
automated detection. The human eye misses the caller three files away, the
side-effect through shared state, the subtle conditional that makes the change
wrong in one path. Edit-and-pray produces fear, which produces conservative
behaviour, which produces code that slowly accumulates workarounds rather than
improving over time.

### The resolution: deliberate sequencing

The resolution Feathers proposes is deliberate sequencing. Before making any
substantive change to behaviour, make a set of **conservative, mechanical
changes** whose sole purpose is to open up space for tests. These changes must
not alter observable behaviour: they merely create new attachment points so that
tests can reach the code. Only after those tests exist does the actual change
proceed, with tests as a safety net (Feathers 2004, Chapters 1 and 2).

**When not to apply this section:** if you are adding a new feature in a
greenfield module with no existing state to reason about, the change dilemma
does not apply. Start with TDD from the outset rather than working backwards
from characterization tests.

---

## 2. The Legacy Code Change Algorithm

Feathers' five-step algorithm is the backbone of every safe change in untested
code (Feathers 2004, Chapter 2). Each step has a distinct purpose, and they must
not be collapsed.

### The five steps

1. **Identify change points.** Find exactly where in the code the change must
   go. This bounds the work and prevents the scope from spreading.
2. **Find test points.** Identify places where you can write tests that will
   detect whether the change does what you intend and whether it breaks anything
   adjacent. Test points are not always at the change point itself; they may be
   further up the call chain.
3. **Break dependencies.** Apply mechanical techniques to get the code into a
   test harness: extract an interface, introduce a seam, parameterize a
   constructor. This step changes structure, not behaviour. The sibling skill
   `legacy-dependency-breaking` is the catalogue for this step.
4. **Write tests.** Write characterization tests to pin the current behaviour,
   then write tests for the intended change. Characterization tests go first.
5. **Make changes and refactor.** Change the code under the safety net of the
   tests, then refactor with confidence.

### Worked walkthrough

Consider a class that calculates invoice totals but hard-codes its own database
connection, making it impossible to test in isolation.

```typescript
// Before: hard-coded dependency, no seam for a test to attach to.
class InvoiceCalculator {
  private connection: DatabaseConnection;

  constructor() {
    this.connection = new DatabaseConnection("production-db");
  }

  total(customerId: string): number {
    const rows = this.connection.query(
      "SELECT amount FROM orders WHERE customer_id = ?",
      [customerId],
    );
    return rows.reduce((sum: number, row: { amount: number }) => sum + row.amount, 0);
  }
}
```

**Step 1 (identify change point).** The requirement is to apply a 10% loyalty
discount for customers flagged as premium. The change point is the `total`
method.

**Step 2 (find test points).** The return value of `total` is what the test
must assert. But the constructor instantiates `DatabaseConnection` directly, so
no test can run `total` without a real database. The test point is reachable
only after step 3.

**Step 3 (break dependencies).** Parameterize the constructor. Extract an
interface for the data access concern and accept it as a parameter.

```typescript
interface OrderStore {
  getAmounts(customerId: string): number[];
}

class InvoiceCalculator {
  constructor(private readonly store: OrderStore) {}

  total(customerId: string): number {
    return this.store
      .getAmounts(customerId)
      .reduce((sum, amount) => sum + amount, 0);
  }
}
```

The change is purely structural: the observable behaviour of the class is
identical when the real `DatabaseConnection` is passed as the `OrderStore`
implementation.

**Step 4 (write tests).** First, a characterization test to pin what the code
actually does before any behaviour change.

```typescript
class StubOrderStore implements OrderStore {
  constructor(private readonly amounts: number[]) {}
  getAmounts(_customerId: string): number[] {
    return this.amounts;
  }
}

test("total sums all order amounts", () => {
  const calculator = new InvoiceCalculator(new StubOrderStore([100, 250, 75]));
  expect(calculator.total("cust-1")).toBe(425);
});
```

Then a failing test for the intended change (the discount). To make the test
file compile before step 5 adds the real implementation, add a minimal stub to
`InvoiceCalculator` so the failure is an assertion failure rather than a type
error:

```typescript
// Minimal stub: makes the file compile. Returns the unmodified total (425),
// not the discounted value (382), so the test below fails on the assertion
// as intended; the bar stays red until step 5.
totalForPremium(customerId: string): number {
  return this.total(customerId);
}
```

```typescript
test("total applies 10% discount for premium customers", () => {
  const calculator = new InvoiceCalculator(new StubOrderStore([100, 250, 75]));
  expect(calculator.totalForPremium("cust-1")).toBe(382); // 425 * 0.9, floored
});
```

**Step 5 (make changes and refactor).** Add the premium logic to make the new
test pass; confirm the characterization test still passes; refactor if the
implementation warrants it.

**When not to apply this section's ceremony:** when you can place the test
directly without breaking any dependencies (the code already accepts its
collaborators through its surface), skip steps 2 and 3 and move straight to
writing tests.

---

## 3. Seams and enabling points

A **seam** is a place where you can alter the behaviour of a program without
editing in that place (Feathers 2004, Chapter 4). Every seam has an **enabling
point**: the location where you decide which behaviour will be in effect. The
enabling point is the site where you swap behaviours; the seam is the place in
the code where the swap takes effect.

Without seams a codebase is monolithic: every dependency is baked in, every
path is fixed. The dependency-breaking techniques are, fundamentally, techniques
for introducing seams where none existed.

### Object seams

The primary seam type in object-oriented code. Polymorphism makes them
possible: pass in a different implementation through a constructor parameter or
a method argument, and the behaviour changes without touching the class under
test. The enabling point is wherever the collaborator is supplied, typically the
constructor call or a factory.

Object seams should be the first instinct in TypeScript. The language's
structural typing makes them especially easy to introduce: any object that
satisfies an interface is a valid substitution, with no need for inheritance.

```typescript
// Before: no seam. The class controls its own mailer.
class OrderProcessor {
  process(order: Order): void {
    const mailer = new SmtpMailer("smtp.example.com");
    mailer.send(order.customerEmail, "Your order was received");
  }
}

// After: object seam introduced. The enabling point is the constructor.
interface Mailer {
  send(to: string, message: string): void;
}

class OrderProcessor {
  constructor(private readonly mailer: Mailer) {}

  process(order: Order): void {
    this.mailer.send(order.customerEmail, "Your order was received");
  }
}

// Production code supplies the real mailer at the enabling point:
const processor = new OrderProcessor(new SmtpMailer("smtp.example.com"));

// A test supplies a spy at the enabling point:
const sent: Array<{ to: string; message: string }> = [];
const spyMailer: Mailer = {
  send(to, message) {
    sent.push({ to, message });
  },
};
const testProcessor = new OrderProcessor(spyMailer);
```

### Link seams

Arise in compiled or bundled contexts where you can substitute an alternative
module at link or build time. The enabling point is the build configuration. In
a Node environment this might mean resolving a different module path in test
versus production builds. Use link seams when the code you need to replace
cannot easily be reached through an object seam.

### Preprocessing seams

Use conditional compilation or environment-driven imports to substitute
behaviour. The enabling point is an environment variable or preprocessor
directive. Rarely appropriate in TypeScript; prefer object seams.

**When not to apply seam introduction:** when the collaborator is cheap,
in-process, and deterministic, injecting it as a seam may add accidental
complexity without benefit. Domain value objects, pure functions, and small
utility classes typically do not need to be extracted behind an interface.

---

## 4. Characterization tests

A characterization test documents what the code actually does, not what it
should do. Its purpose is to pin the current behaviour so that subsequent
changes do not accidentally modify something that was not intended (Feathers
2004, Chapter 13).

Characterization tests differ from TDD tests in direction. A TDD test is written
first to describe **intended** behaviour that does not yet exist; it starts red
and is made green by new code. A characterization test is written against
**existing** code to record what that code actually produces; it starts by
observing, then locks the observation in. As Beck's TDD discipline
(*Test-Driven Development: By Example*, 2002) shows, the discipline of
test-first only works when you are creating new behaviour. Characterization
works the other way: code exists, tests do not.

### The discovery loop

1. Write a test with a guessed assertion based on your reading of the code.
2. Run the test. If it fails, the failure message tells you the real value. If
   it passes unexpectedly, the guess happened to be right, or there is an
   interesting edge case worth investigating.
3. Update the assertion to encode the observed value. The test now characterizes
   the actual behaviour and will fail if that behaviour ever changes
   unintentionally.

```typescript
// The function under investigation. Behaviour is not immediately obvious
// for the "no matching code" path.
function applyDiscount(price: number, code: string): number {
  if (code === "SUMMER") return Math.floor(price * 0.9);
  if (code === "VIP") return Math.floor(price * 0.8);
  return price;
}

// Step 1: guess a value and write the test.
test("applyDiscount with an unknown code", () => {
  expect(applyDiscount(100, "UNKNOWN")).toBe(0); // guessed
});
// Test fails: expected 0, received 100.

// Step 2: the failure reveals the actual value. Update the assertion.
test("applyDiscount with an unknown code returns the original price", () => {
  expect(applyDiscount(100, "UNKNOWN")).toBe(100); // observed actual behaviour
});
// Test passes. The characterization is locked in.

// Step 3: lock in all paths you will touch.
test("SUMMER code applies a 10% floor discount", () => {
  expect(applyDiscount(99, "SUMMER")).toBe(89); // Math.floor(99 * 0.9) = 89
});

test("VIP code applies a 20% floor discount", () => {
  expect(applyDiscount(99, "VIP")).toBe(79); // Math.floor(99 * 0.8) = 79
});
```

### Pinning bugs, not correcting them

Characterization tests pin bugs alongside correct behaviour. If the discovery
loop reveals something that is obviously wrong, the right response is to encode
the current (wrong) behaviour anyway, note the defect in a comment or a ticket,
and address it separately through the full change algorithm with its own
dedicated tests. Silently fixing a bug inside a characterization test corrupts
the safety net: you no longer know whether the rest of the characterization
reflects the code as it was, because you changed it while you were observing it.

**When not to apply characterization tests:** do not characterize behaviour you
are about to delete. If a path will be removed entirely, writing tests for it
consumes time with no return. Characterize what you are keeping or changing; let
the deleted code disappear without a paper trail.

---

## 5. Reasoning about effects

Before changing a line of code, reason about how that change propagates. This
prevents surprises and tells you which behaviours are actually at risk.

### Effect sketching

**Effect sketching** is the practice of tracing the chain of consequences from a
proposed change outward through the codebase (Feathers 2004, Chapter 11). Start
at the change point and ask: what can be directly affected? Then ask the same
question of each affected thing, continuing until the chain reaches either a
visible output or a caller you control with tests.

```typescript
class PricingEngine {
  private baseRate: number = 10;
  private multiplier: number = 1;

  setMultiplier(value: number): void {
    this.multiplier = value;
  }

  unitPrice(): number {
    return this.baseRate * this.multiplier;
  }

  invoiceTotal(quantity: number): number {
    return this.unitPrice() * quantity;
  }
}

// Effect sketch for a change to `multiplier`:
//   multiplier (field)
//     -> unitPrice() reads multiplier
//       -> invoiceTotal() calls unitPrice()
//
// The full effect propagates to invoiceTotal(). A test on invoiceTotal()
// covers the entire chain with a single assertion.
```

Sketching before writing tests prevents the common error of testing only the
immediate output and missing a downstream caller that reads a shared field. The
sketch is not a formal diagram; a rough list on paper or a comment block is
sufficient.

### Pinch points

A **pinch point** is a narrow place in the effect chain where many upstream
effects funnel through a small interface (Feathers 2004, Chapter 11). A pinch
point is a high-leverage place to write tests: one test there covers a wide arc
of behaviour without requiring a test for each individual path that feeds into
it.

Identifying a pinch point is part of step 2 (find test points) in the algorithm.
When the effect sketch shows multiple independent paths all converging on a
single method or output, that method is a pinch point. Writing tests there first
gives you coverage breadth quickly, which is valuable when time is short.

### Sensing versus separation

Two distinct problems cause untested code to resist a test harness (Feathers
2004, Chapter 3):

- **Sensing:** you cannot observe the values the code computes. The method does
  work and produces a result, but that result is buried in a private field, sent
  to an external system, or written to a log you cannot read in a test. You can
  get the code to run; you just cannot see what it produced.
- **Separation:** you cannot get the code into a test harness at all. The class
  constructor opens a database connection, requires a running server, touches the
  file system, or depends on global state you cannot replicate in isolation.

Identifying which problem you face determines which dependency-breaking
technique to reach for. Sensing problems are resolved by introducing an
observable output: extract a return value, inject a recording collaborator,
expose a result through a new interface. Separation problems are resolved by
making the expensive collaborator substitutable: parameterize the constructor,
extract an interface, use a factory method that can be overridden in a subclass.
Some techniques address both; see the sibling skill `legacy-dependency-breaking`
for the full catalogue.

**When not to apply effect reasoning:** if the change is purely additive (new
code in a new, isolated module with no shared state) and you have full test
coverage of what already exists, an effect sketch adds ceremony without benefit.
Effect reasoning earns its cost when the code is tangled and the propagation
path is non-obvious.

---

## 6. Working when time is short

The full algorithm is the right default, but pressure is real. When a change
must ship quickly and getting the existing code fully under test would take days,
there is a safer middle path: add new, tested code beside the old rather than
editing untested code in place (Feathers 2004, Chapter 6).

### Sprout versus edit-in-place

**Sprout** grows new behaviour in a new, isolated method or class, tested
independently. The existing code is left untouched; it is modified only to
delegate to the new method or class. The new code starts clean and is developed
with TDD from the outset. The existing tangle does not grow.

**Wrap** intercepts calls to or from the existing method. A new method (Wrap
Method) or class (Wrap Class) surrounds the original, adding tested logic before
or after the call without changing the original method's implementation.

```typescript
// Existing function: 200 lines of tangled, untested logic.
// Do not edit it. Do not try to get it under test right now.
function generateReport(data: Record<string, unknown>[]): string {
  // ... existing implementation ...
  return "<report>" + data.map((row) => JSON.stringify(row)).join("") + "</report>";
}

// Sprout: new behaviour in a new, independently tested function.
function buildReportHeader(title: string, generatedAt: Date): string {
  return `<header title="${title}" generated="${generatedAt.toISOString()}" />`;
}
// Test buildReportHeader with TDD. Then call it from generateReport
// by adding exactly one line to the existing function, changing no existing logic.

// Wrap Method: intercept at the call site, add tested logic around the original.
function generateReportWithHeader(
  title: string,
  generatedAt: Date,
  data: Record<string, unknown>[],
): string {
  return buildReportHeader(title, generatedAt) + generateReport(data);
}
// generateReportWithHeader is fully tested; generateReport is unchanged.
```

### The risk ladder

The risk of a change scales with the amount of untested code it touches. From
lowest to highest risk:

1. New code in a new file or module, not touching existing code.
2. Sprout: a new method called by one new line in existing code.
3. Wrap: a new wrapper calling the existing method without modifying it.
4. Changes inside an existing method, covered by characterization tests.
5. Changes inside an existing method, no tests.

When time is short, stay as high on the ladder as the requirement allows.
Sprout and Wrap are not compromises; they are the correct tool when the
requirement is genuinely additive.

For the full catalogue of techniques (Sprout Method, Sprout Class, Wrap Method,
Wrap Class, Extract Interface, Subclass and Override Method, Parameterize
Constructor, Extract and Override Factory Method, and the rest), see the sibling
skill `legacy-dependency-breaking`.

**When not to apply Sprout or Wrap:** if the change is a correction to existing
logic rather than a new additive behaviour, Sprout and Wrap cannot sidestep the
need to get that existing logic under test. A bug in the existing code cannot
be fixed by sprouting new code beside it; the fix must go inside the existing
code, which requires the characterization and dependency-breaking steps.

---

## 7. When this is overkill

The algorithm and its supporting practices exist to manage the risk of changing
code that has no safety net. When that risk is absent, the ceremony is
unjustified.

**Code already under test.** If a module is already covered by a coherent test
suite, the change dilemma does not apply. Write a new failing test for the
intended behaviour, implement it, and let the existing tests guard against
regression. This is standard TDD (Beck, *Test-Driven Development: By Example*,
2002), not legacy work.

**A trivial CRUD slice with no logic.** A route handler that reads a record from
a repository, maps it to a response DTO, and returns it carries essentially no
risk of surprising effect propagation. Writing characterization tests for a
pure pass-through adds cost with no meaningful coverage gain.

**Behaviour you are about to delete.** Characterizing a code path you are
removing is pure waste. If the deletion is the change, verify that removing
the code causes no callers to break (by searching references and running
existing tests), then delete it. Do not write tests for what will not exist.

**The feature is entirely new and isolated.** New modules with no shared state
and no existing callers need TDD, not characterization. The characterization
loop runs when the code already exists and must not be misunderstood; it has
nothing to observe when the code is not yet written.

The signal that the algorithm is warranted is the combination of existing code,
no tests, and a need to change behaviour. When any of those three is absent,
reach for the simpler tool.

---

## 8. Sources

- Michael Feathers, *Working Effectively with Legacy Code* (Prentice Hall,
  2004): the source for all algorithm steps, seam types, characterization tests,
  effect sketching, pinch points, sensing versus separation, and Sprout and
  Wrap. Chapter 2 for the algorithm; Chapter 3 for sensing and separation;
  Chapter 4 for seams; Chapter 6 for Sprout and Wrap; Chapter 11 for effect
  sketching and pinch points; Chapter 13 for characterization tests.
  Paraphrased throughout; no page numbers cited.
- Kent Beck, *Test-Driven Development: By Example* (Addison-Wesley, 2002): the
  canonical reference for TDD's red-green-refactor loop and for what
  characterization tests are not (tests for intended behaviour that does not yet
  exist). The two disciplines compose: this skill covers getting into the
  harness; Beck's loop resumes once the code is under test.
- Martin Fowler, *Refactoring: Improving the Design of Existing Code* (2nd ed.,
  Addison-Wesley, 2018): the catalogue of safe, behaviour-preserving
  transformations that the refactor step draws on. Fowler's "Refactoring" entry:
  https://martinfowler.com/tags/refactoring.html
