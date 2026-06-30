# A first set of refactorings: reference

Deeper mechanics for the "A first set of refactorings" category in the
`refactoring-catalog` skill. The skill body holds the one-line summaries;
this file holds intent, triggering signal, condensed mechanics, inverse where
one exists, and TypeScript examples for the most structural moves in the group.

These eleven moves are the ones Fowler reaches for most often. Most other
refactorings in the catalogue are applications or combinations of these
(Fowler, *Refactoring*, 2nd ed., 2018, Chapter 6).

## Table of contents

1. [Extract Function](#1-extract-function)
2. [Inline Function](#2-inline-function)
3. [Extract Variable](#3-extract-variable)
4. [Inline Variable](#4-inline-variable)
5. [Change Function Declaration](#5-change-function-declaration)
6. [Encapsulate Variable](#6-encapsulate-variable)
7. [Rename Variable](#7-rename-variable)
8. [Introduce Parameter Object](#8-introduce-parameter-object)
9. [Combine Functions into Class](#9-combine-functions-into-class)
10. [Combine Functions into Transform](#10-combine-functions-into-transform)
11. [Split Phase](#11-split-phase)
12. [Sources](#12-sources)

---

## 1. Extract Function

**Aliases:** Extract Method (1st edition name).

**Intent and motivation.** When a code fragment requires a comment to explain
what it does, that fragment deserves a name. Extract Function turns the
fragment into a named function whose name makes the comment unnecessary. Short,
well-named functions lower the cost of reading code because the reader can
trust the function's name rather than tracing its body. They also improve
reuse: once extracted, the same fragment can be called from multiple places
(Fowler, *Refactoring*, 2nd ed., 2018, Chapter 6).

**Triggering signal.** A block of code is wrapped in a comment that describes
what it does; a section is visually distinct within a longer function; the same
logic is copied in a second place; or the function body is long enough that
holding its full intent in memory requires effort.

**Mechanics.**
1. Create a new function and name it by what it does, not by how it does it.
2. Copy the identified code fragment into the new function.
3. Examine the fragment for local variables from the enclosing scope that it
   reads. Pass each as a parameter.
4. Examine the fragment for local variables that it assigns. If only one such
   variable exists, return it. If more than one, consider further decomposition
   before extracting.
5. Replace the original fragment with a call to the new function.
6. Run the tests.

**Inverse:** Inline Function.

### Example

```typescript
// Before: charge computation is buried inside printStatement;
// a reader must trace three lines to understand what "Amount owed" means.
interface Order {
  customer: string;
  quantity: number;
  itemPrice: number;
}

function printStatement(order: Order): string {
  let result = `Statement for ${order.customer}\n`;
  const baseCharge = order.quantity * order.itemPrice;
  const discount = order.quantity > 500 ? baseCharge * 0.05 : 0;
  const charge = baseCharge - discount;
  result += `Amount owed: ${charge}\n`;
  return result;
}
```

```typescript
// After: the charge computation lives in calculateCharge,
// and printStatement reads as a narrative.
function calculateCharge(order: Order): number {
  const baseCharge = order.quantity * order.itemPrice;
  const discount = order.quantity > 500 ? baseCharge * 0.05 : 0;
  return baseCharge - discount;
}

function printStatement(order: Order): string {
  let result = `Statement for ${order.customer}\n`;
  result += `Amount owed: ${calculateCharge(order)}\n`;
  return result;
}
```

The observable behaviour is identical. `calculateCharge` is now independently
testable and can be called from other print functions if needed.

---

## 2. Inline Function

**Aliases:** Inline Method (1st edition name).

**Intent and motivation.** When a function's body is as clear as its name, or
when the function has been decomposed into so many small pieces that navigation
between them costs more than it saves, inline the function. Inlining is also
the first step before regrouping a cluster of poorly decomposed functions
(Fowler, *Refactoring*, 2nd ed., 2018, Chapter 6).

**Triggering signal.** A function whose body says exactly the same thing as
its name; a function that is called from exactly one place and adds no
meaningful abstraction; or a situation where you want to re-extract differently
and need a flat starting point.

**Mechanics.**
1. Confirm the function is not polymorphic (not overridden in a subclass). If
   it is, stop; inlining changes dispatch semantics.
2. Locate every call site for the function.
3. At each call site, replace the call with the function body, adjusting local
   variable names to avoid shadowing.
4. Run the tests after each replacement.
5. Once all call sites are replaced, delete the function declaration.

**Inverse:** Extract Function.

---

## 3. Extract Variable

**Aliases:** Introduce Explaining Variable (1st edition name).

**Intent and motivation.** A complex expression crammed into a single
statement forces the reader to decode it line by line. Naming the result in a
variable makes the expression self-documenting and makes it easier to step
through in a debugger. When a sub-expression appears in more than one place,
extracting it also removes the duplication (Fowler, *Refactoring*, 2nd ed.,
2018, Chapter 6).

**Triggering signal.** An expression that requires a mental footnote to decode;
a conditional test whose terms are non-obvious; or a sub-expression that
appears in more than one part of the function.

**Mechanics.**
1. Confirm that the expression has no side effects (it can be evaluated any
   number of times without changing observable state).
2. Declare a new variable and assign the expression to it. Make it a `const`.
3. Replace every occurrence of the expression in the function with the new
   variable.
4. Run the tests.

**Inverse:** Inline Variable.

---

## 4. Inline Variable

**Intent and motivation.** When the name of a temporary variable is no
clearer than the expression it holds, the variable adds visual noise rather
than meaning. Inlining it removes the extra indirection and makes the code
more direct. It is also a prerequisite for several other moves: Extract
Function and Replace Temp with Query often require inlining variables that
would otherwise escape their new scope (Fowler, *Refactoring*, 2nd ed., 2018,
Chapter 6).

**Triggering signal.** A `const` whose right-hand side is a short, readable
expression that appears only once; or a temporary that must be removed before
a larger restructuring can proceed.

**Mechanics.**
1. Check that the variable is assigned exactly once and that the right-hand
   side expression is free of side effects.
2. Replace the first use of the variable with the right-hand side expression.
3. Run the tests.
4. Replace all remaining uses; then delete the declaration.
5. Run the tests again.

**Inverse:** Extract Variable.

---

## 5. Change Function Declaration

**Aliases:** Rename Function, Rename Method, Add Parameter, Remove Parameter,
Change Signature (various 1st edition names).

**Intent and motivation.** A function's name is its public contract. A name
that does not explain what the function does, parameters that accept raw
primitives where a typed abstraction would be clearer, or a parameter list
that has grown inconsistent with how the function is actually used all degrade
readability and increase the chance of misuse. Change Function Declaration
corrects any of these problems (Fowler, *Refactoring*, 2nd ed., 2018,
Chapter 6).

**Triggering signal.** Difficulty naming a function because its current name
is misleading or too generic; a parameter passed as a raw string or number
where a named type would communicate intent; callers passing the same cluster
of arguments repeatedly; or a parameter that is no longer used.

**Mechanics (simple case: rename or single-parameter change).**
1. Change the declaration.
2. Update all call sites.
3. Run the tests.

**Mechanics (migration: for a change that must be rolled out gradually).**
1. If needed, refactor the function body to make the desired new signature
   easier to achieve.
2. Introduce a new function with the desired signature. Its body delegates to
   the old function.
3. Run the tests to confirm the delegation works.
4. Update each caller one by one to use the new function. Run the tests after
   each.
5. Once all callers use the new function, remove the old function (or the
   delegation wrapper if the new function now contains the real body).
6. Run the tests.

### Example

```typescript
// Before: abbreviated name and an untyped string parameter.
function getRatingDiscount(price: number, type: string): number {
  if (type === "premium") return price * 0.05;
  if (type === "vip") return price * 0.1;
  return 0;
}

// Intermediate: a new function with the desired signature
// delegates to the old one during the migration.
type CustomerTier = "basic" | "premium" | "vip";

function discountForCustomerTier(price: number, tier: CustomerTier): number {
  return getRatingDiscount(price, tier);
}

// After: all callers updated; the delegation wrapper is removed
// and the body lives in the final function.
function discountForCustomerTier(price: number, tier: CustomerTier): number {
  if (tier === "premium") return price * 0.05;
  if (tier === "vip") return price * 0.1;
  return 0;
}
```

The migration approach lets existing callers continue to compile and pass
tests while each is updated at its own pace.

---

## 6. Encapsulate Variable

**Intent and motivation.** Data that is directly accessible from any part of
the codebase is hard to reason about: any code anywhere can read or modify it,
so changes to it have unpredictable reach. Wrapping it behind accessor
functions creates a single controlled point through which all reads and writes
pass. Once encapsulated, validation, logging, lazy initialisation, or change
notification can be added without touching every consumer. Encapsulate Variable
is a prerequisite for several other moves, including Encapsulate Record and
Move Field (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 6).

**Triggering signal.** A module-level variable or class field is read or
written from many places; the code that uses the data is spread across files;
or you need to intercept reads or writes to add behaviour.

**Mechanics.**
1. Create a getter function that returns the variable.
2. Create a setter function that assigns to the variable (only if mutation
   should remain possible).
3. Replace every read of the variable with a call to the getter.
4. Replace every write with a call to the setter.
5. Narrow the visibility of the underlying variable to the module, making the
   getter and setter the only access points.
6. Run the tests.

---

## 7. Rename Variable

**Intent and motivation.** A name is a compressed explanation of what
something holds or does. A poor name forces the reader to look at the context
every time to reconstruct that explanation. Rename Variable corrects a name
anywhere it is misleading, too short, or inconsistent with the domain language.
The cost of renaming is low with a modern editor; the benefit compounds every
time the code is read (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 6).

**Triggering signal.** A variable whose name does not communicate what it
holds; a name that is an abbreviation where the full word would be clearer; or
a name that reflects an old understanding of the code that has since changed.

**Mechanics.**
1. If the variable is widely used outside its declaring module, consider
   applying Encapsulate Variable first so the rename can be performed in one
   place (the getter/setter) rather than at every call site.
2. Rename the declaration.
3. Update all references. Use your editor's rename-symbol tool where available.
4. Run the tests.

---

## 8. Introduce Parameter Object

**Intent and motivation.** When the same cluster of parameters always travels
together across multiple function signatures, those parameters form a natural
data clump. Replacing them with a dedicated data structure reduces the surface
area of each signature, eliminates the risk of passing arguments in the wrong
order, and gives the cluster a name in the domain model. Once the structure
exists, behaviour that naturally belongs to the cluster can migrate into it,
making it a first-class domain object (Fowler, *Refactoring*, 2nd ed., 2018,
Chapter 6).

**Triggering signal.** Two or more parameters always appear together in the
same order at every call site; functions that operate on the same cluster of
data share similar parameter lists; or a new class or interface would clarify
what the cluster represents.

**Mechanics.**
1. Create a data structure (an interface for a simple value container, or a
   class if behaviour will be added later) with a field for each parameter in
   the cluster.
2. Apply Change Function Declaration to add a parameter of the new type to the
   function. Use a default value so existing callers still compile.
3. Update each call site to construct and pass the new structure.
4. For each original parameter that is now part of the structure, remove it
   from the function signature using Change Function Declaration.
5. Run the tests.
6. Migrate any behaviour that naturally belongs to the structure into it.

### Example

```typescript
// Before: min and max always travel together as separate parameters.
interface Reading { temp: number; time: Date; }
interface Station { name: string; readings: Reading[]; }

function readingsOutsideRange(station: Station, min: number, max: number): Reading[] {
  return station.readings.filter(r => r.temp < min || r.temp > max);
}

// Call site: readingsOutsideRange(station, -5, 25)
```

```typescript
// After: NumberRange groups min and max and carries the containment logic.
interface NumberRange {
  readonly min: number;
  readonly max: number;
  contains(value: number): boolean;
}

class TemperatureRange implements NumberRange {
  constructor(readonly min: number, readonly max: number) {}
  contains(value: number): boolean {
    return value >= this.min && value <= this.max;
  }
}

function readingsOutsideRange(station: Station, range: NumberRange): Reading[] {
  return station.readings.filter(r => !range.contains(r.temp));
}

// Call site: readingsOutsideRange(station, new TemperatureRange(-5, 25))
```

The `contains` method is the first piece of domain behaviour that belongs to
the range concept. It can be followed by `overlaps`, `isEmpty`, and so on
as the domain evolves, without touching `readingsOutsideRange`.

---

## 9. Combine Functions into Class

**Intent and motivation.** When a cluster of functions all operate on the same
data record, passing that record as a first argument each time, the relationship
between the functions and the data is implicit. Grouping them into a class
makes the relationship explicit in the type system, reduces parameter passing
(the data becomes `this`), and gives the cluster a cohesive name. It also
signals that the cluster represents a meaningful concept in the domain (Fowler,
*Refactoring*, 2nd ed., 2018, Chapter 6).

**Triggering signal.** Several functions always receive the same record or
group of values as their primary parameter; the functions belong to the same
conceptual responsibility; or a record is passed around many levels and would
be more cohesive as an object with methods.

**Mechanics.**
1. Encapsulate the common data record (apply Encapsulate Record if it is a
   plain object).
2. Create a class whose constructor receives the data record as its initial
   state.
3. Move each function in the cluster into the class as a method, removing the
   now-redundant parameter for the data that is held in `this`.
4. Update each call site to use the class.
5. Run the tests.

---

## 10. Combine Functions into Transform

**Intent and motivation.** When derived data is computed from a base record
in multiple places, the derivations scatter and can drift out of sync. Combine
Functions into Transform consolidates all derivations into a single function
that takes the base record and returns an enriched copy with all derived fields
added. Any consumer of the enriched record finds the precomputed values already
present and does not need to re-derive them. This move is an alternative to
Combine Functions into Class when you prefer immutable data records over
stateful objects (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 6).

**Triggering signal.** The same derived value is computed from the same base
data in more than one place; consumers of a record repeat calculation logic
that belongs to the record's concept; or you prefer a pure functional style
with enriched immutable records over classes with instance methods.

**Mechanics.**
1. Create a transform function that copies the base record into a new output
   record (use a spread or a shallow copy to preserve the original).
2. Pick one derivation function and move its logic into the transform,
   appending the result as a new field on the enriched record.
3. Run the tests.
4. Repeat for each remaining derivation function.
5. Update consumers to read from the enriched record rather than calling the
   derivation functions.
6. Run the tests.

---

## 11. Split Phase

**Intent and motivation.** A function that does two different things in
sequence is harder to understand than two functions that each do one thing. The
reader must hold the context for both phases at once and verify that they do
not interfere. Split Phase makes the boundary explicit by introducing an
intermediate data structure between the two phases, naming it, and giving each
phase its own function. The first phase transforms the input into the
intermediate structure; the second phase transforms the intermediate structure
into the output (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 6).

**Triggering signal.** A function has two visually distinct sections that
could be summarised as "prepare then process" or "parse then compute"; a
function depends on different sets of data for each of its two sections; or
testing the second section is hard because it is coupled to the first.

**Mechanics.**
1. Extract all code that constitutes the second phase into its own function.
2. Identify the data the two phases share. That data is the candidate
   intermediate structure.
3. Introduce an interface for the intermediate data structure as a new
   parameter to the extracted second-phase function.
4. Run the tests to verify the extraction did not change behaviour.
5. Examine each parameter of the second-phase function. If it is computed in
   the first phase (and is not consumed by the first phase itself), move it
   into the intermediate data structure and remove it from the function
   signature.
6. When the second-phase function receives only the intermediate data structure
   (and any parameters the first phase cannot supply), extract the first phase
   into its own function as well.
7. Run the tests.

### Example

```typescript
// Before: price computation and shipping calculation are tangled together.
// A reader must track both at once and verify there is no interleaving.
interface Product {
  basePrice: number;
  discountThreshold: number;
  discountRate: number;
}
interface ShippingMethod {
  discountThreshold: number;
  discountedFee: number;
  feePerCase: number;
}

function priceOrder(
  product: Product,
  quantity: number,
  shipping: ShippingMethod,
): number {
  const basePrice = product.basePrice * quantity;
  const discount =
    Math.max(quantity - product.discountThreshold, 0) *
    product.basePrice *
    product.discountRate;
  const shippingPerCase =
    basePrice > shipping.discountThreshold
      ? shipping.discountedFee
      : shipping.feePerCase;
  return basePrice - discount + quantity * shippingPerCase;
}
```

```typescript
// After: PriceData is the intermediate structure.
// Phase 1 (calculateBasePrice) knows about Product and quantity.
// Phase 2 (applyShipping) knows about PriceData and ShippingMethod.
// Neither phase knows what the other does.

interface PriceData {
  readonly basePrice: number;
  readonly discount: number;
  readonly quantity: number;
}

function priceOrder(
  product: Product,
  quantity: number,
  shipping: ShippingMethod,
): number {
  const priceData = calculateBasePrice(product, quantity);
  return applyShipping(priceData, shipping);
}

function calculateBasePrice(product: Product, quantity: number): PriceData {
  const basePrice = product.basePrice * quantity;
  const discount =
    Math.max(quantity - product.discountThreshold, 0) *
    product.basePrice *
    product.discountRate;
  return { basePrice, discount, quantity };
}

function applyShipping(priceData: PriceData, shipping: ShippingMethod): number {
  const shippingPerCase =
    priceData.basePrice > shipping.discountThreshold
      ? shipping.discountedFee
      : shipping.feePerCase;
  return priceData.basePrice - priceData.discount + priceData.quantity * shippingPerCase;
}
```

`PriceData` can now carry additional pricing fields without touching
`applyShipping`, and shipping logic can be tested against a fixed `PriceData`
without constructing a `Product`.

---

## 12. Sources

Martin Fowler (with Kent Beck), *Refactoring: Improving the Design of Existing
Code*, 2nd ed. (Addison-Wesley, 2018). Chapter 6: "A First Set of
Refactorings", pages 106-170. The mechanics in this file are condensed and
paraphrased; they are not the book text verbatim. Page numbers cited in the
chapter cross-reference above correspond to the first printing.
