# Encapsulation: reference

Deeper mechanics for the "Encapsulation" category in the `refactoring-catalog`
skill. The skill body holds the one-line summaries; this file holds intent,
triggering signal, condensed mechanics, inverse where one exists, and
TypeScript examples for the most structural moves in the group.

Encapsulation is Fowler's preferred tool for managing the first step of most
larger refactorings: you cannot safely move a piece of data or behaviour until
you control how everything accesses it. The moves in this chapter build that
control (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 7).

## Table of contents

1. [Encapsulate Record](#1-encapsulate-record)
2. [Encapsulate Collection](#2-encapsulate-collection)
3. [Replace Primitive with Object](#3-replace-primitive-with-object)
4. [Replace Temp with Query](#4-replace-temp-with-query)
5. [Extract Class](#5-extract-class)
6. [Inline Class](#6-inline-class)
7. [Hide Delegate](#7-hide-delegate)
8. [Remove Middle Man](#8-remove-middle-man)
9. [Substitute Algorithm](#9-substitute-algorithm)
10. [Sources](#10-sources)

---

## 1. Encapsulate Record

**Aliases:** Replace Record with Data Class.

**Intent and motivation.** A plain data record (a JavaScript object literal,
a TypeScript interface value, or a struct) exposes its internal structure to
all readers and writers. Any code anywhere can reach in and change any field.
Wrapping the record in a class converts each field access into a method call.
That single change creates a boundary: future modifications to the internal
representation (splitting a field, adding validation, computing a field on
demand) can be made inside the class without touching the consumers. Encapsulate
Record is frequently the first step of larger refactorings that need to move or
hide data (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 7).

**Triggering signal.** A plain object is passed across module boundaries and
mutated from many places; derived values are computed from the same raw fields
in several locations; or a larger refactoring (such as Move Field or Extract
Class) requires a controlled access point as its prerequisite.

**Mechanics.**
1. Apply Encapsulate Variable to the record variable if it is accessible
   outside its declaring module.
2. Create a class that holds the record data in a private field.
3. Add getter methods for each field that external code reads.
4. Add setter methods for fields that external code writes, or keep them absent
   to make the record immutable from the outside.
5. Update the getter of the encapsulated variable to return an instance of the
   new class rather than the raw record.
6. For each external access to the raw record, replace it with the class
   accessors.
7. Run the tests.

### Example

```typescript
// Before: plain object accessed directly.
// Any module can write: customer.discountRate = 0; with no control.
interface CustomerData {
  name: string;
  discountRate: number;
}
let customer: CustomerData = { name: "Alice", discountRate: 0.1 };
```

```typescript
// After: Customer class controls all access and mutation.
class Customer {
  private _name: string;
  private _discountRate: number;

  constructor(data: { name: string; discountRate: number }) {
    this._name = data.name;
    this._discountRate = data.discountRate;
  }

  get name(): string {
    return this._name;
  }

  get discountRate(): number {
    return this._discountRate;
  }

  // Mutation is intentional and named, not arbitrary.
  becomePreferred(): void {
    this._discountRate += 0.03;
  }
}

const customer = new Customer({ name: "Alice", discountRate: 0.1 });
// customer.discountRate = 0; // TypeScript error: no setter exposed.
customer.becomePreferred(); // explicit, named, intentional operation.
```

The class boundary means that internal representation changes (such as storing
the discount as a basis-points integer rather than a fraction) require changes
only inside the class, not at every consumer.

---

## 2. Encapsulate Collection

**Intent and motivation.** A getter that returns a live reference to a
collection lets callers add and remove items without the owning class knowing.
The class cannot enforce invariants (such as "no duplicate entries" or "the
list is sorted"), and changes made through the reference do not trigger any
notification. Replacing the direct reference with add and remove methods, and
returning a read-only copy or view from the getter, restores control (Fowler,
*Refactoring*, 2nd ed., 2018, Chapter 7).

**Triggering signal.** A class has a getter for a mutable array or set and
external code pushes to, pops from, or splices that array directly; tests for
the owning class pass or fail depending on mutations made by collaborating
code; or a class invariant over the collection's membership is not enforced.

**Mechanics.**
1. Apply Encapsulate Variable if the collection is not already accessed through
   a getter and setter.
2. Add an `add` method that appends a validated item to the collection.
3. Add a `remove` method that removes an item.
4. Modify the getter to return a read-only copy (a spread or `Object.freeze`
   in TypeScript, or a `ReadonlyArray` type) rather than the live reference.
5. Find every call site that was adding or removing items via the getter's
   return value and redirect each to the new `add` or `remove` method.
6. Run the tests.

---

## 3. Replace Primitive with Object

**Aliases:** Replace Data Value with Object, Replace Type Code with Class.

**Intent and motivation.** Simple data starts its life as a primitive: a
string for a customer tier, a number for a temperature, a pair of strings for
a postal address. As requirements grow, logic that belongs to the concept
(validation, comparison, formatting) accumulates at the call sites rather than
in one place. Promoting the primitive to a class gathers that logic into one
location, gives the concept a name in the type system, and prevents invalid
values from being created (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 7).

**Triggering signal.** A primitive value is validated or formatted the same
way in several places; a comparison between two primitives requires knowledge
of domain ordering rules that is copied in multiple functions; or a string or
number acts as a type code with a fixed set of legal values.

**Mechanics.**
1. Apply Encapsulate Variable on the field or parameter if it is not already
   encapsulated.
2. Create a new class for the primitive value. Give it a single constructor
   parameter and a private field for the value.
3. Add a `toString` (or equivalent display accessor) to the new class.
4. Run the tests to verify the class is well-formed.
5. Change the private field in the original class from the primitive type to
   the new class. Update the constructor to construct the new class.
6. Change the getter to return the class instance (or its string form if
   callers relied on `toString` implicitly).
7. Run the tests.
8. Move domain behaviour (validation, ordering, formatting) into the new class.
   Update callers to use the class's methods rather than inline logic.

### Example

```typescript
// Before: order priority is a raw string.
// Ordering logic is duplicated at every comparison site.
class Order {
  constructor(readonly priority: string) {}
}

// Caller must know the ordering rule to compare priorities:
const urgent = orders.filter(
  o => o.priority === "high" || o.priority === "rush",
);
```

```typescript
// After: Priority is a full class that owns the ordering rule.
class Priority {
  private static readonly LEVELS: ReadonlyArray<string> = [
    "low",
    "normal",
    "high",
    "rush",
  ];

  constructor(private readonly value: string) {
    if (!Priority.LEVELS.includes(value)) {
      throw new Error(`Unknown priority: "${value}"`);
    }
  }

  higherThan(other: Priority): boolean {
    return (
      Priority.LEVELS.indexOf(this.value) >
      Priority.LEVELS.indexOf(other.value)
    );
  }

  toString(): string {
    return this.value;
  }
}

class Order {
  readonly priority: Priority;

  constructor(priority: string) {
    this.priority = new Priority(priority);
  }
}

// Caller delegates the ordering rule to Priority:
const normalThreshold = new Priority("normal");
const urgent = orders.filter(o => o.priority.higherThan(normalThreshold));
```

`Priority` validates at construction time, so an `Order` with `priority =
new Priority("critical")` throws immediately rather than silently propagating
an invalid string through the system.

---

## 4. Replace Temp with Query

**Intent and motivation.** A temporary variable captures a computed value so
it can be used more than once without repeating the computation. But it also
adds a local name that the reader must track and forces the computation to be
in a specific location relative to its uses. Replacing the temporary with a
method call moves the computation out of the function's body and into a
queryable form. The function becomes shorter, the derived value is always
up to date, and the query method is reusable from other contexts (Fowler,
*Refactoring*, 2nd ed., 2018, Chapter 7).

**Triggering signal.** A temporary variable is assigned once from an
expression with no side effects, and that expression could meaningfully be
understood as a property of the class; or a long function would become
significantly shorter if its temporaries were moved to query methods.

**Mechanics.**
1. Verify that the variable is assigned exactly once (or that all assignments
   compute the same value under all paths).
2. Verify that the right-hand side expression has no side effects.
3. Extract the right-hand side expression into a method.
4. Replace the variable declaration and assignment with a call to the new
   method (or inline the variable if it is used only once).
5. Run the tests.

---

## 5. Extract Class

**Intent and motivation.** As a class grows, it accumulates responsibilities
that are related but belong to distinct sub-concepts. A class that holds both
personal data and telephone formatting is doing two jobs. Each job has its own
data and its own operations; they should live in separate classes. Extract
Class is the move that creates that separation, producing a smaller original
class and a new class that owns the extracted responsibility (Fowler,
*Refactoring*, 2nd ed., 2018, Chapter 7).

**Triggering signal.** A cluster of fields and methods in a class could be
summarised as a distinct concept that has a natural name; those fields and
methods interact with each other more than with the rest of the class; or
the class has grown large enough that understanding it requires separating
its concerns mentally.

**Mechanics.**
1. Decide which responsibilities and data to move.
2. Create a new class to hold them.
3. Create an instance of the new class in the constructor of the original
   class and store it in a private field.
4. Apply Move Field and Move Function for each item being extracted.
5. Decide whether to expose the new class directly (via a getter) or to keep
   it hidden behind delegating methods on the original class.
6. Run the tests.

**Inverse:** Inline Class.

### Example

```typescript
// Before: Person holds both personal data and telephone data.
// The formatted telephone number mixes two concepts in one class.
class Person {
  constructor(
    private _name: string,
    private _officeAreaCode: string,
    private _officeNumber: string,
  ) {}

  get name(): string { return this._name; }
  get officeAreaCode(): string { return this._officeAreaCode; }
  get officeNumber(): string { return this._officeNumber; }

  get telephoneNumber(): string {
    return `(${this._officeAreaCode}) ${this._officeNumber}`;
  }
}
```

```typescript
// After: telephone responsibility lives in TelephoneNumber.
// Person delegates the formatting rather than owning it.

class TelephoneNumber {
  constructor(
    readonly areaCode: string,
    readonly number: string,
  ) {}

  get formatted(): string {
    return `(${this.areaCode}) ${this.number}`;
  }
}

class Person {
  private readonly _officeTelephone: TelephoneNumber;

  constructor(
    private readonly _name: string,
    officeAreaCode: string,
    officeNumber: string,
  ) {
    this._officeTelephone = new TelephoneNumber(officeAreaCode, officeNumber);
  }

  get name(): string { return this._name; }

  // Backwards-compatible delegation: callers of telephoneNumber see no change.
  get telephoneNumber(): string { return this._officeTelephone.formatted; }

  // New accessor: callers can also reach TelephoneNumber directly if needed.
  get officeTelephone(): TelephoneNumber { return this._officeTelephone; }
}
```

`TelephoneNumber` can now be reused for mobile numbers, home numbers, and fax
numbers. Its formatting and validation logic lives in one class rather than
being copied per number type.

---

## 6. Inline Class

**Intent and motivation.** After a series of refactorings, a class may shrink
to the point where it holds barely any state and offers no behaviour beyond
simple delegation. An empty abstraction adds navigation cost without adding
understanding. Inline Class merges the near-empty class into its collaborator,
simplifying the design. It is also useful as a preparation step when you want
to redistribute responsibilities between two classes: first inline them into
one, then re-extract with a better decomposition (Fowler, *Refactoring*, 2nd
ed., 2018, Chapter 7).

**Triggering signal.** A class exists almost entirely to delegate to one other
class; it has only one or two methods and barely any state; or you need to
merge two classes before re-splitting them along different lines.

**Mechanics.**
1. Declare all the public methods of the class being inlined as methods on the
   absorbing class. Their bodies delegate to the instance of the class being
   inlined.
2. Run the tests.
3. Redirect all uses of the methods on the small class to use the new methods
   on the absorbing class.
4. Run the tests after each redirection.
5. Move each field and method from the small class into the absorbing class,
   eliminating the delegation step.
6. Delete the small class.
7. Run the tests.

**Inverse:** Extract Class.

---

## 7. Hide Delegate

**Intent and motivation.** When a client navigates through a server object to
reach a delegate, the client is coupled to both. If the delegate's type or the
chain of access changes, the client must change too. Adding a delegating method
on the server object removes the client's knowledge of the delegate: the client
asks the server, the server asks the delegate, and the client is shielded from
any change in the delegation chain. This is the principle of least knowledge,
also called the Law of Demeter (Fowler, *Refactoring*, 2nd ed., 2018,
Chapter 7).

**Triggering signal.** Client code accesses a server object and then
immediately calls a method on the returned object (`server.getDelegate().doSomething()`);
message chains appear in more than one place; or a change to the delegate's
interface requires updating client code rather than just the server.

**Mechanics.**
1. For each method of the delegate that clients call through the server, create
   a delegating method on the server that calls through to the delegate.
2. Run the tests.
3. Update each client that was accessing the delegate directly to use the new
   delegating method on the server instead.
4. Run the tests after each update.
5. If no client now accesses the delegate directly, remove the getter for the
   delegate on the server.
6. Run the tests.

**Inverse:** Remove Middle Man.

### Example

```typescript
// Before: Client must know that Person has a Department,
// and that Department has a Manager. A change to Department breaks clients.
class Department {
  constructor(
    readonly chargeCode: string,
    readonly manager: Person,
  ) {}
}

class Person {
  constructor(
    readonly name: string,
    private _department: Department,
  ) {}

  get department(): Department { return this._department; }
}

// Client: navigates through Department to reach Manager.
const manager = employee.department.manager;
```

```typescript
// After: Person exposes a manager getter; Department is hidden.
class Person {
  constructor(
    readonly name: string,
    private readonly _department: Department,
  ) {}

  // Delegating method: the delegation chain is encapsulated here.
  get manager(): Person {
    return this._department.manager;
  }
}

// Client: no longer couples to Department.
const manager = employee.manager;
```

The `department` getter is removed once no client needs it. If `Department`
later restructures its manager field, only `Person.manager` needs to change,
not every client.

---

## 8. Remove Middle Man

**Intent and motivation.** Hide Delegate is valuable when the delegation
is protecting the client from complexity. But when every method on a server
class does nothing but forward a call to the delegate, the server adds
navigation cost without adding clarity: the caller must go through the server
to reach the delegate even though the server contributes nothing. Remove Middle
Man exposes the delegate directly, eliminating the worthless forwarding layer
(Fowler, *Refactoring*, 2nd ed., 2018, Chapter 7).

**Triggering signal.** Half or more of the server's methods are simple
one-line delegates to the same internal object; the server's interface has
grown to mirror the delegate's interface almost entirely; or the delegation
methods are being added faster than they are justified.

**Mechanics.**
1. Create a getter on the server for the delegate.
2. For each delegating method on the server, update callers to call the
   delegate's method directly through the new getter.
3. Remove each delegating method as its callers are updated.
4. Run the tests after each removal.

**Inverse:** Hide Delegate.

---

## 9. Substitute Algorithm

**Intent and motivation.** Sometimes the clearest way to improve code is to
replace the algorithm entirely rather than refactor it incrementally. A new
library function, a different data structure, or simply a better approach may
make the existing implementation obsolete. Substitute Algorithm replaces the
body of a function with a new implementation while preserving the same
interface and observable output (Fowler, *Refactoring*, 2nd ed., 2018,
Chapter 7).

**Triggering signal.** A function is correct but its implementation is hard
to read, maintain, or extend; a cleaner algorithm exists (such as a
language-built-in, a library call, or a well-known pattern) that expresses the
same logic more directly; or the existing algorithm is about to be extended in
a way that would be much simpler with a different underlying approach.

**Mechanics.**
1. Refactor the current algorithm into the clearest form possible before
   replacing it. Substitute Algorithm is easier to verify when the old version
   and the new version are both at their cleanest.
2. Prepare tests that cover all paths and edge cases through the current
   implementation.
3. Write the new algorithm and replace the function body.
4. Run the tests. If all tests pass, the substitution is complete.
5. If any test fails, compare the old and new algorithms against each failing
   input to locate the behavioural difference. Debug the new algorithm rather
   than restoring the old one.

---

## 10. Sources

Martin Fowler (with Kent Beck), *Refactoring: Improving the Design of Existing
Code*, 2nd ed. (Addison-Wesley, 2018). Chapter 7: "Encapsulation", pages
162-200. The mechanics in this file are condensed and paraphrased; they are not
the book text verbatim. Page numbers cited in the chapter cross-reference above
correspond to the first printing.
