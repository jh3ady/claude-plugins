# Simplifying conditional logic: reference

Deeper mechanics for the "Simplifying conditional logic" category in the
`refactoring-catalog` skill. The skill body holds the one-line summaries;
this file holds intent, triggering signal, condensed mechanics, inverse where
one exists, and TypeScript examples for the most structural moves in the group.

Conditional logic is the primary source of complexity in most codebases.
Nested `if` chains, repeated type-dispatch switches, and implicit assumptions
buried in branch conditions all make code difficult to read, test, and extend.
The moves in this chapter reshape conditionals so that intent is expressed
directly and branches can be understood independently (Fowler, *Refactoring*,
2nd ed., 2018, Chapter 10).

## Table of contents

1. [Decompose Conditional](#1-decompose-conditional)
2. [Consolidate Conditional Expression](#2-consolidate-conditional-expression)
3. [Replace Nested Conditional with Guard Clauses](#3-replace-nested-conditional-with-guard-clauses)
4. [Replace Conditional with Polymorphism](#4-replace-conditional-with-polymorphism)
5. [Introduce Special Case](#5-introduce-special-case)
6. [Introduce Assertion](#6-introduce-assertion)
7. [Sources](#7-sources)

---

## 1. Decompose Conditional

**Intent and motivation.** A complex conditional expression asks the reader to
decode both the question being asked (the condition) and the consequences of
each answer (the branches) at the same time. Extracting the condition and each
branch into named functions separates those two concerns: the reader first
understands what is being decided, then can read each outcome independently
without re-decoding the condition (Fowler, *Refactoring*, 2nd ed., 2018,
Chapter 10).

**Triggering signal.** A conditional whose condition is a multi-term boolean
expression; branches that contain more than one or two statements; or a
condition and its branches that would each benefit from a descriptive name that
the current code does not provide.

**Mechanics.**
1. Apply Extract Function to the condition, giving it a name that expresses
   the question being asked.
2. Apply Extract Function to each branch, giving each a name that expresses
   the consequence being taken.
3. Replace the original `if` statement with the extracted condition and branch
   calls.
4. Run the tests.

### Example

```typescript
// Before: the reader must parse the date range condition and the charge
// formula in the same mental step. Neither has a name.
const SUMMER_START = new Date("2024-06-01");
const SUMMER_END   = new Date("2024-08-31");
const summerRate   = 1.2;
const winterRate   = 0.8;
const winterServiceCharge = 5;

function charge(date: Date, quantity: number): number {
  if (date < SUMMER_START || date > SUMMER_END) {
    return quantity * winterRate + winterServiceCharge;
  } else {
    return quantity * summerRate;
  }
}
```

```typescript
// After: isSummer names the question; summerCharge and winterCharge name
// the consequences. Each can be read and tested in isolation.
function isSummer(date: Date): boolean {
  return date >= SUMMER_START && date <= SUMMER_END;
}

function summerCharge(quantity: number): number {
  return quantity * summerRate;
}

function winterCharge(quantity: number): number {
  return quantity * winterRate + winterServiceCharge;
}

function charge(date: Date, quantity: number): number {
  return isSummer(date) ? summerCharge(quantity) : winterCharge(quantity);
}
```

For any `date` and `quantity`, both versions return the same number.
`isSummer(date)` is `true` when `date >= SUMMER_START && date <= SUMMER_END`,
which is the negation of the original `date < SUMMER_START || date > SUMMER_END`,
so each branch is invoked for the same set of inputs.

---

## 2. Consolidate Conditional Expression

**Intent and motivation.** When a sequence of independent checks all lead to
the same action or return value, the sequence is a single logical check
expressed in fragments. Consolidating the fragments into one expression makes
the intent visible, reduces duplication, and creates a single location to which
Extract Function can be applied to give the combined check a name (Fowler,
*Refactoring*, 2nd ed., 2018, Chapter 10).

**Triggering signal.** Two or more consecutive `if` statements whose bodies
are identical; a series of guards that all return the same value; or a
condition that could be expressed more clearly as a single boolean expression
using `&&` or `||` rather than as separate `if` statements.

**Mechanics.**
1. Verify that none of the conditions have side effects. If they do, use
   Separate Query from Modifier first.
2. Combine the separate condition checks into a single expression using the
   appropriate logical operator (`||` for "any of these", `&&` for "all of
   these").
3. Apply Extract Function to the combined condition if a meaningful name can
   be given to it.
4. Run the tests.

---

## 3. Replace Nested Conditional with Guard Clauses

**Intent and motivation.** A function that uses nested `if-else` branches for
both its special cases and its normal path hides the normal path inside the
structure. A guard clause is an early return for a special case; it gets that
case out of the way immediately and leaves the normal path at the top level,
unindented and easy to follow. The pattern works best when the special cases
are edge conditions or error states that the reader should note and dismiss
quickly (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 10).

**Triggering signal.** A function has a deeply nested conditional structure
where the bulk of the logic lives inside one branch of a top-level `if`; every
code path in the function ends with an explicit `return`; or the function
begins with a series of exceptional conditions that each lead to a distinct
short result before the main computation begins.

**Mechanics.**
1. Identify each special-case check that is nested. Convert the outermost one
   first by inverting the condition and adding an early `return`.
2. Run the tests.
3. Repeat for each remaining nested conditional, working from the outside in.
4. If any guard clause shares logic with the one before it, consider using
   Consolidate Conditional Expression to merge them.
5. Run the tests after each conversion.

### Example

```typescript
// Before: the normal case is buried inside two nested else branches.
// Reading the function requires tracking the full conditional tree.
interface Employee {
  isSeparated: boolean;
  isRetired: boolean;
  baseSalary: number;
}

function payAmount(employee: Employee): number {
  let result: number;
  if (employee.isSeparated) {
    result = 0;
  } else {
    if (employee.isRetired) {
      result = Math.floor(employee.baseSalary * 0.6);
    } else {
      result = employee.baseSalary;
    }
  }
  return result;
}
```

```typescript
// After: guard clauses dispatch the special cases early.
// The normal case is at the top level and requires no context from the guards.
function payAmount(employee: Employee): number {
  if (employee.isSeparated) return 0;
  if (employee.isRetired)   return Math.floor(employee.baseSalary * 0.6);
  return employee.baseSalary;
}
```

For every combination of `isSeparated` and `isRetired`, both versions return
the same value. The `result` variable and the nested structure are gone; the
function has three short paths and no shared mutable state between them.

---

## 4. Replace Conditional with Polymorphism

**Intent and motivation.** A `switch` or chain of `if-else` that dispatches
on an object's type or category is a responsibility that belongs in the types
themselves, not in the caller. When the same dispatch pattern recurs in
multiple functions, every new type requires changes in every function. Moving
the type-specific behaviour into subclasses or strategy objects means each type
owns its variation, a new type is added by creating one new class, and the
calling code needs no conditional at all (Fowler, *Refactoring*, 2nd ed., 2018,
Chapter 10).

**Triggering signal.** A `switch` or `if-else` chain dispatches on a type code
or string tag; the same type-dispatch pattern is repeated in multiple functions;
or each branch of the conditional is substantial enough to be its own method.

**Mechanics.**
1. If the conditional logic is not already in a class, apply Combine Functions
   into Class or create a factory to produce the appropriate class instance for
   each type.
2. Extract the conditional into a method, using Extract Function if needed.
3. For each branch, create a subclass that overrides the extracted method with
   the branch's logic.
4. Select the correct subclass at the point where instances are created (a
   factory function or a registry).
5. Remove the original conditional once all branches have been moved into
   subclasses.
6. Run the tests.

### Example

```typescript
// Before: plumage dispatches on a string type code with a switch.
// Adding a new bird type requires editing this function.
interface BirdData {
  type: string;
  numberOfCoconuts: number;
  voltage: number;
}

function plumage(bird: BirdData): string {
  switch (bird.type) {
    case "EuropeanSwallow":
      return "average";
    case "AfricanSwallow":
      return bird.numberOfCoconuts > 2 ? "tired" : "average";
    case "NorwegianBlueParrot":
      return bird.voltage > 100 ? "scorched" : "beautiful";
    default:
      return "unknown";
  }
}
```

```typescript
// After: each bird type owns its plumage description.
// Adding a new type means adding a new class, not editing plumage().
abstract class Bird {
  abstract plumage(): string;
}

class EuropeanSwallow extends Bird {
  plumage(): string { return "average"; }
}

class AfricanSwallow extends Bird {
  constructor(private readonly numberOfCoconuts: number) { super(); }
  plumage(): string {
    return this.numberOfCoconuts > 2 ? "tired" : "average";
  }
}

class NorwegianBlueParrot extends Bird {
  constructor(private readonly voltage: number) { super(); }
  plumage(): string {
    return this.voltage > 100 ? "scorched" : "beautiful";
  }
}

function createBird(data: BirdData): Bird {
  switch (data.type) {
    case "EuropeanSwallow":
      return new EuropeanSwallow();
    case "AfricanSwallow":
      return new AfricanSwallow(data.numberOfCoconuts);
    case "NorwegianBlueParrot":
      return new NorwegianBlueParrot(data.voltage);
    default:
      throw new Error(`Unknown bird type: ${data.type}`);
  }
}

// Call site: createBird(data).plumage()
```

For any valid `BirdData`, `createBird(data).plumage()` returns the same string
as the original `plumage(data)`. The switch now exists only in `createBird`
and only for construction; all type-specific logic lives in the subclasses.

---

## 5. Introduce Special Case

**Aliases:** Introduce Null Object (the most common specialisation of this move
in the 1st edition and in the pattern literature).

**Intent and motivation.** When a special value such as `null`, `undefined`, or
a sentinel triggers the same handling in many places throughout the codebase,
that common handling is a duplicated responsibility. Encapsulating the special
value in an object that provides the expected interface with the common
behaviour built in removes all the scattered checks and lets callers treat
the special case the same way they treat normal cases (Fowler, *Refactoring*,
2nd ed., 2018, Chapter 10).

**Triggering signal.** The same `null` check (or equivalent sentinel check)
appears in many callers, each doing the same default action; code that returns
or receives a value is riddled with `if (x === null) return defaultValue`
guards; or a concept like "unknown customer" or "no result" has behaviour that
belongs in a dedicated object rather than at every call site.

**Mechanics.**
1. Add a method to the class that tests whether the current instance is the
   special case (for example, `isUnknown(): boolean`).
2. Create a special-case class that extends or implements the same interface
   with the common default behaviour for each method.
3. Apply Introduce Assertion or add tests to verify that all callers receive
   the special-case class where they previously received the sentinel.
4. Update the producer of the sentinel to return an instance of the
   special-case class instead.
5. Replace each conditional check on the sentinel with a call to the class's
   method or simply remove the check if the special-case class's method already
   returns the default.
6. Run the tests.

---

## 6. Introduce Assertion

**Intent and motivation.** Every non-trivial function rests on assumptions about
its inputs, its context, or the state of the system. Those assumptions are often
invisible: they live in the developer's mental model, in comments, or in error
messages that only appear at runtime. An assertion makes the assumption
executable: it is a `console.assert`, a thrown error, or a dedicated assertion
call that fires immediately when the assumption is violated. Assertions document
what must be true, catch violations close to their origin, and make the code
self-validating during development (Fowler, *Refactoring*, 2nd ed., 2018,
Chapter 10).

**Triggering signal.** A comment states that a value must be positive, a
parameter must be non-null, or a collection must be non-empty, but the code
does not check; a function silently produces a wrong result when a precondition
is not met; or a piece of code only works correctly under a specific assumption
that is not enforced anywhere.

**Mechanics.**
1. Identify the assumption the code relies on.
2. Add an assertion at the point where the assumption must hold. Prefer
   throwing a clearly named error to a silent `console.assert` so that
   violations are visible in production if needed.
3. Do not add assertions for conditions that the normal flow of the program
   can legitimately violate. Assertions document invariants; they are not
   substitutes for error handling.
4. Run the tests, including tests that intentionally violate the assumption to
   confirm the assertion fires.

---

## 7. Sources

Martin Fowler (with Kent Beck), *Refactoring: Improving the Design of Existing
Code*, 2nd ed. (Addison-Wesley, 2018). Chapter 10: "Simplifying Conditional
Logic", pages 259-304. The mechanics in this file are condensed and paraphrased;
they are not the book text verbatim. Page numbers cited in the chapter
cross-reference above correspond to the first printing.

Web validation: chapter 10 move list (Decompose Conditional, Consolidate
Conditional Expression, Replace Nested Conditional with Guard Clauses, Replace
Conditional with Polymorphism, Introduce Special Case, Introduce Assertion)
confirmed against https://refactoring.com/catalog/ and corroborated by the
summary at https://geekcodeparadise.com/2022/04/refactoring-chapter-10-simplifying-conditional-logic/
and the O'Reilly online edition at
https://www.oreilly.com/library/view/refactoring-improving-the/9780134757681/ch10.xhtml.
