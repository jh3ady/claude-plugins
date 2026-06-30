# Organizing data: reference

Deeper mechanics for the "Organizing data" category in the
`refactoring-catalog` skill. The skill body holds the one-line summaries;
this file holds intent, triggering signal, condensed mechanics, inverse where
one exists, and TypeScript examples for the most structural moves in the group.

Organizing data addresses naming, scoping, and representation. Poorly named
variables, fields reused for multiple purposes, mutable objects treated as
values, and fields whose content can always be derived all introduce subtle
bugs or make code harder to reason about. The moves in this chapter bring the
structure of data into alignment with its actual meaning (Fowler, *Refactoring*,
2nd ed., 2018, Chapter 9).

## Table of contents

1. [Split Variable](#1-split-variable)
2. [Rename Field](#2-rename-field)
3. [Replace Derived Variable with Query](#3-replace-derived-variable-with-query)
4. [Change Reference to Value](#4-change-reference-to-value)
5. [Change Value to Reference](#5-change-value-to-reference)
6. [Sources](#6-sources)

---

## 1. Split Variable

**Aliases:** Split Temp (common informal name); Remove Assignments to Parameters
(1st edition name for the related case of re-assigning a parameter).

**Intent and motivation.** A variable that is assigned more than once and used
for more than one purpose is doing two jobs under one name. Each assignment
overwrites the earlier state, forcing the reader to track which "version" of
the variable is active at each point in the function. Splitting the variable
into one variable per purpose gives each a clear name and makes it a `const`,
which communicates to both reader and compiler that the value never changes
after its single assignment (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 9).

**Triggering signal.** A variable is assigned in two separate places in the
same function and the two assignments represent different things; a loop or
accumulator variable is also used outside the loop for an unrelated purpose;
or a parameter is reassigned inside the function body for a different use than
the original parameter value.

**Mechanics.**
1. Change the name of the variable at its first declaration and assignment.
   Declare it as `const` if it is only read after this first assignment.
2. Rename all uses of the variable up to the second assignment to use the new
   name.
3. Run the tests.
4. Repeat for the second assignment: declare a new variable with a name that
   reflects its second purpose; replace uses up to the third assignment (or to
   the end of scope) with the new name.
5. Continue until each use of the original name has been replaced and the
   original variable declaration can be removed.
6. Run the tests.

### Example

```typescript
// Before: temp is used first to hold the perimeter, then overwritten
// to hold the area. A reader tracking temp must notice the reassignment.
function printDimensions(height: number, width: number): void {
  let temp = 2 * (height + width);
  console.log(`Perimeter: ${temp}`);
  temp = height * width;
  console.log(`Area: ${temp}`);
}
```

```typescript
// After: each variable is a const with a name that reflects its purpose.
// A reader no longer needs to track a reassignment to understand the function.
function printDimensions(height: number, width: number): void {
  const perimeter = 2 * (height + width);
  console.log(`Perimeter: ${perimeter}`);
  const area = height * width;
  console.log(`Area: ${area}`);
}
```

Both versions print exactly the same two lines for any `height` and `width`.
`perimeter` is `2 * (height + width)` in both; `area` is `height * width` in
both. The only change is that the reassignment is gone and each variable is now
a `const` with a meaningful name.

---

## 2. Rename Field

**Intent and motivation.** A field name is a compressed description of what the
field holds. A name that is ambiguous, abbreviated, or no longer matches the
domain understanding is a persistent source of misreading. Rename Field updates
the name wherever the field is declared and accessed, including any serialised
form or API response that uses the name. For widely used fields, the migration
approach lets callers update gradually (Fowler, *Refactoring*, 2nd ed., 2018,
Chapter 9).

**Triggering signal.** A field name does not communicate what the field holds;
the name is an abbreviation where the full word would be clearer; the name
reflects an earlier model that no longer matches the domain; or a field name
conflicts with the domain language used by the team.

**Mechanics.**
1. If the record is a simple data structure with no methods, rename the field
   in the class or interface and use your editor's rename-symbol tool to update
   all references in one step.
2. If the record is a class with controlled accessors, add a new getter and
   setter with the desired name. Have them delegate to the old getter and
   setter. Update callers one by one to use the new names. Once all callers are
   updated, rename the underlying field and remove the old accessors.
3. Run the tests after each update.

---

## 3. Replace Derived Variable with Query

**Intent and motivation.** A variable that is kept in sync with other data is
a source of inconsistency: any code path that modifies the source data without
updating the derived variable leaves the codebase in an invalid state. Removing
the variable and computing the derived value on demand from a method eliminates
the synchronisation obligation. The result is always consistent because it is
always freshly computed (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 9).

**Triggering signal.** A field is updated in multiple places to track a value
that can be computed from other fields; the field is a simple aggregation
(such as a total or a count) that is incremented and decremented alongside
mutations to a collection; or a bug is traced to a missed update of a derived
field.

**Mechanics.**
1. Identify all assignments to the variable and verify that each computes the
   same derived value from the same source data.
2. Create a query method that computes the value from the source data.
3. Apply Introduce Assertion to verify that the existing variable and the new
   query method produce the same result at every mutation point. Run the tests
   with the assertions active.
4. Replace reads of the variable with calls to the query method.
5. Remove the variable and its update assignments.
6. Run the tests.

---

## 4. Change Reference to Value

**Intent and motivation.** When multiple parts of the system share a mutable
reference to the same object, a mutation by one consumer is visible to all
others. This implicit coupling makes the object hard to reason about and hard
to test in isolation. Treating the object as a value, rather than as a shared
reference, means each consumer holds its own copy and mutations are replaced by
creating a new object with the updated state. Value objects are naturally
immutable, thread-safe, and trivial to test (Fowler, *Refactoring*, 2nd ed.,
2018, Chapter 9).

**Triggering signal.** A mutable inner object is shared across multiple
consumers; a change to the object through one consumer unexpectedly affects
another consumer; or a class represents a conceptual value (a money amount, a
date range, a coordinate) rather than a mutable entity.

**Mechanics.**
1. Remove any setter methods on the inner object. If that causes compilation
   errors, address each caller by replacing the setter call with a constructor
   call that creates a new instance.
2. Run the tests.
3. Add an `equals` method (and, in TypeScript, consider implementing a
   value-equality helper) so consumers can compare two instances by content
   rather than by reference.
4. Run the tests.

**Inverse:** Change Value to Reference.

### Example

```typescript
// Before: Money is a mutable reference type. Two consumers sharing the same
// Money instance can observe each other's mutations unexpectedly.
class Money {
  constructor(
    private _amount: number,
    readonly currency: string,
  ) {}

  get amount(): number { return this._amount; }

  setAmount(value: number): void {
    this._amount = value; // mutation is visible to all holders of this reference
  }
}

class Product {
  constructor(private _price: Money) {}

  get price(): Money { return this._price; } // returns the live mutable reference

  applyDiscount(percent: number): void {
    this._price.setAmount(this._price.amount * (1 - percent / 100));
  }
}
```

```typescript
// After: Money is an immutable value type. Operations return a new instance.
// Sharing a Money value is safe because nothing can mutate it after construction.
class Money {
  constructor(
    readonly amount: number,
    readonly currency: string,
  ) {}

  withAmount(newAmount: number): Money {
    return new Money(newAmount, this.currency);
  }

  equals(other: Money): boolean {
    return this.amount === other.amount && this.currency === other.currency;
  }
}

class Product {
  constructor(private _price: Money) {}

  get price(): Money { return this._price; }

  applyDiscount(percent: number): void {
    // replace the reference rather than mutate the object
    this._price = this._price.withAmount(
      this._price.amount * (1 - percent / 100),
    );
  }
}
```

After the refactoring, `applyDiscount(10)` on a `Product` with
`price = new Money(100, "USD")` produces `price.amount === 90`. A second
`Product` constructed from the same initial `Money` value is unaffected because
`Money` is now immutable. The observable contract of `applyDiscount` is
unchanged.

---

## 5. Change Value to Reference

**Intent and motivation.** When the same conceptual entity (for example, a
customer record or an order) exists as multiple independent copies in memory,
changes to one copy do not propagate to the others. If those copies are meant
to represent the same entity, they drift out of sync. Turning the copies into
references to a single shared instance ensures that all consumers always see
the same state. This typically requires a repository or registry to store the
canonical instance and hand it out on demand (Fowler, *Refactoring*, 2nd ed.,
2018, Chapter 9).

**Triggering signal.** Multiple in-memory copies of what is conceptually the
same entity exist and must stay in sync; updating one copy requires finding and
updating all others; or an entity has a natural identity (such as a database
primary key) and value equality is therefore insufficient.

**Mechanics.**
1. Create a registry (a `Map` or a repository class) that stores and retrieves
   the canonical instance of each entity by its identity key.
2. Change the constructor of the value class to be private or to delegate to
   the registry, so new instances can only be obtained through the registry.
3. Update all creation sites to call the registry's factory or lookup method
   rather than constructing instances directly.
4. Run the tests.

**Inverse:** Change Reference to Value.

---

## 6. Sources

Martin Fowler (with Kent Beck), *Refactoring: Improving the Design of Existing
Code*, 2nd ed. (Addison-Wesley, 2018). Chapter 9: "Organizing Data", pages
237-258. The mechanics in this file are condensed and paraphrased; they are not
the book text verbatim. Page numbers cited in the chapter cross-reference above
correspond to the first printing.

Web validation: chapter 9 move list (Split Variable, Rename Field, Replace
Derived Variable with Query, Change Reference to Value, Change Value to
Reference) confirmed against https://refactoring.com/catalog/ and corroborated
via the O'Reilly online edition at
https://www.oreilly.com/library/view/refactoring-improving-the/9780134757681/.
The inverse pair Change Reference to Value / Change Value to Reference is
explicitly listed in Fowler's catalogue entry descriptions.
