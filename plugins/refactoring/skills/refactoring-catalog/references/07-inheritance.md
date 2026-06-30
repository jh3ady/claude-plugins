# Dealing with inheritance: reference

Deeper mechanics for the "Dealing with inheritance" category in the
`refactoring-catalog` skill. The skill body holds the one-line summaries;
this file holds intent, triggering signal, condensed mechanics, inverse where
one exists, and TypeScript examples for the most structural moves in the group.

Inheritance is the most visible mechanism for sharing behaviour in
object-oriented design, but it can only model one dimension of variation at a
time, it creates a hard compile-time dependency between superclass and
subclass, and the Liskov Substitution Principle constrains how subclasses may
differ from their parent. The moves in this chapter restructure hierarchies to
carry the right amount of shared behaviour, avoid deeper nesting than the
domain justifies, and replace inheritance with delegation when the "is-a"
relationship does not truly hold (Fowler, *Refactoring*, 2nd ed., 2018,
Chapter 12).

## Table of contents

1. [Pull Up Method](#1-pull-up-method)
2. [Pull Up Field](#2-pull-up-field)
3. [Pull Up Constructor Body](#3-pull-up-constructor-body)
4. [Push Down Method](#4-push-down-method)
5. [Push Down Field](#5-push-down-field)
6. [Replace Type Code with Subclasses](#6-replace-type-code-with-subclasses)
7. [Remove Subclass](#7-remove-subclass)
8. [Extract Superclass](#8-extract-superclass)
9. [Collapse Hierarchy](#9-collapse-hierarchy)
10. [Replace Subclass with Delegate](#10-replace-subclass-with-delegate)
11. [Replace Superclass with Delegate](#11-replace-superclass-with-delegate)
12. [Sources](#12-sources)

---

## 1. Pull Up Method

**Intent and motivation.** When the same method body appears independently in
two or more sibling subclasses, the duplication belongs in their common
superclass. Leaving duplicate methods in subclasses means a fix or enhancement
to the method must be applied in every copy, and the copies will inevitably
diverge over time. Pulling the method up to the superclass eliminates the
duplication, ensures all subclasses get the same behaviour automatically, and
places the method where future readers will naturally look for shared
functionality (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 12).

**Triggering signal.** Two or more subclasses declare a method with the same
name, the same parameter list, and essentially the same body; the method does
not reference any subclass-specific field or method that is not already
available in the superclass; or after a sequence of smaller refactorings (such
as Parameterize Function) the methods have been made identical and are ready to
merge.

**Mechanics.**
1. Examine the methods in each subclass to confirm they are truly identical in
   behaviour (not merely in text). If they differ, apply smaller refactorings
   first to make them identical.
2. Check that every field and method referenced by the moved method is already
   present in the superclass, or pull those up first.
3. Copy the method to the superclass. If the method references `this`, confirm
   that `this` refers to the superclass type and that all accessed members are
   available there.
4. Delete the method from each subclass.
5. Run the tests.

**Inverse:** Push Down Method.

### Example

```typescript
// Before: both Employee and Department define the same annualCost method.
// Any change to the formula must be applied in two places.
abstract class Party {
  protected monthlyCost: number;

  constructor(monthlyCost: number) {
    this.monthlyCost = monthlyCost;
  }
}

class Employee extends Party {
  readonly name: string;

  constructor(name: string, monthlyCost: number) {
    super(monthlyCost);
    this.name = name;
  }

  annualCost(): number {
    return this.monthlyCost * 12;
  }
}

class Department extends Party {
  readonly name: string;

  constructor(name: string, monthlyCost: number) {
    super(monthlyCost);
    this.name = name;
  }

  annualCost(): number {
    return this.monthlyCost * 12;
  }
}
```

```typescript
// After: annualCost lives in Party once.
// Employee and Department inherit it; there is one formula to maintain.
abstract class Party {
  protected monthlyCost: number;

  constructor(monthlyCost: number) {
    this.monthlyCost = monthlyCost;
  }

  annualCost(): number {
    return this.monthlyCost * 12;
  }
}

class Employee extends Party {
  readonly name: string;

  constructor(name: string, monthlyCost: number) {
    super(monthlyCost);
    this.name = name;
  }
}

class Department extends Party {
  readonly name: string;

  constructor(name: string, monthlyCost: number) {
    super(monthlyCost);
    this.name = name;
  }
}
```

For any `Employee` or `Department` with a given `monthlyCost`, `annualCost()`
returns the same value before and after. The formula now lives in exactly one
place.

---

## 2. Pull Up Field

**Intent and motivation.** When two or more sibling subclasses declare a field
with the same name and the same conceptual role, the duplication belongs in
their superclass. Fields that live in sibling subclasses are invisible to
polymorphic code operating through the superclass reference, making them
unreachable without a downcast. Moving the field to the superclass removes the
duplication, gives the field a single declaration to read and maintain, and
makes it accessible to all subclass methods and to any method added later to
the superclass (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 12).

**Triggering signal.** Two or more subclasses declare a field with the same
name and the same purpose; both fields are initialised the same way or with
the same value; or code in the superclass (or in methods that operate on the
superclass type) must downcast to access the field.

**Mechanics.**
1. Inspect both field declarations to confirm that they serve the same purpose.
   If the names differ, apply Rename Variable on each to make them match.
2. Declare the field in the superclass, choosing the appropriate access
   modifier.
3. Remove the duplicate declarations in each subclass.
4. If the field was initialised in each subclass constructor, move the
   initialisation to the superclass constructor (applying Pull Up Constructor
   Body if needed).
5. Run the tests.

**Inverse:** Push Down Field.

---

## 3. Pull Up Constructor Body

**Intent and motivation.** When two or more subclass constructors begin with
the same sequence of statements, that duplicated code belongs in the superclass
constructor. Constructor duplication is easy to overlook because constructors
are not overridden in the same way methods are, but the same maintenance risk
applies: a change to the shared initialisation must be made in every copy
(Fowler, *Refactoring*, 2nd ed., 2018, Chapter 12).

**Triggering signal.** Two or more subclass constructors share an identical
opening or closing sequence of statements; the shared statements do not depend
on subclass-specific fields that do not exist in the superclass; or adding a
new subclass would require copying the same initialisation boilerplate.

**Mechanics.**
1. Define a superclass constructor that accepts the parameters needed by the
   shared statements. If a superclass constructor already exists, extend it.
2. Move the shared statements from each subclass constructor into the
   superclass constructor.
3. In each subclass constructor, call `super(...)` with the appropriate
   arguments at the point where the shared code previously appeared (typically
   the first line, as most languages require).
4. If the shared statements must follow some subclass-specific statements
   rather than precede them, extract the shared statements into a method and
   call it from each subclass constructor in the correct position.
5. Run the tests.

---

## 4. Push Down Method

**Intent and motivation.** When a method on the superclass is only relevant to
one subclass, it is in the wrong place. Its presence in the superclass suggests
to readers that it applies to all subclasses, and it may reference subclass-
specific fields that force awkward casts or abstract declarations. Pushing the
method down to the one subclass that uses it keeps each class focused on its
own responsibilities and makes the superclass a cleaner abstraction (Fowler,
*Refactoring*, 2nd ed., 2018, Chapter 12).

**Triggering signal.** A superclass method is referenced only in one subclass
or only in constructors that create one subclass; the method references state
that is specific to one subclass; or the other subclasses would never sensibly
call the method.

**Mechanics.**
1. Copy the method into every subclass that needs it (usually just one).
2. Remove the method from the superclass.
3. If the superclass is abstract and other code refers to the method through
   the superclass type, add an abstract declaration so the type system is
   satisfied. Otherwise, leave the superclass clean.
4. If the method references a field that is specific to this subclass, apply
   Push Down Field to move that field alongside the method.
5. Run the tests.

**Inverse:** Pull Up Method.

---

## 5. Push Down Field

**Intent and motivation.** When a field on the superclass is used only by one
subclass, it pollutes the superclass's interface and forces the other
subclasses to carry state they never use. Pushing the field down to the
subclass that needs it keeps the superclass lean and prevents fields from
accumulating in a base class that no longer represents the right shared
abstraction (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 12).

**Triggering signal.** A superclass field is referenced only in one subclass
or only in the constructor of one subclass; initialising the field in the
superclass constructor requires passing a value that the other subclasses never
provide or always ignore; or the field's name does not belong to the level of
abstraction the superclass represents.

**Mechanics.**
1. Declare the field in the relevant subclass (or in each subclass that uses
   it, if more than one).
2. Remove the field from the superclass.
3. Adjust the superclass constructor if it was responsible for initialising the
   field: remove that responsibility and handle initialisation in the subclass
   constructor instead.
4. Run the tests.

**Inverse:** Pull Up Field.

---

## 6. Replace Type Code with Subclasses

**Intent and motivation.** A type-code field (a string, integer, or enum that
records which variant an object represents) inevitably attracts conditional
dispatch: every function that needs to behave differently per variant must
branch on the field. As new variants are added, every branching function must
be edited. Creating a subclass per variant moves each variant's behaviour into
a dedicated class, enables polymorphic dispatch, and means a new variant is
added by creating one class rather than editing every function (Fowler,
*Refactoring*, 2nd ed., 2018, Chapter 12).

**Triggering signal.** A class carries a type-code field; multiple methods
switch or branch entirely on that field; each branch is substantial enough to
belong in its own class; or the type-code value is set at construction and
never changes over the object's lifetime.

**Mechanics.**
1. Self-encapsulate the type-code field by extracting a getter (apply
   Encapsulate Variable if the field is accessed directly).
2. Create a subclass for each type-code value. Each subclass overrides the
   type-code getter to return its corresponding value as a literal.
3. Replace direct constructor calls with a factory function that selects the
   correct subclass based on the type-code value.
4. Remove the type-code field from the superclass; each subclass now supplies
   the value through the overridden getter.
5. Run the tests.

**Inverse:** Remove Subclass.

### Example

```typescript
// Before: the type string drives conditional behaviour inside the class.
// Every new type requires editing bonusMultiplier and any future method
// that branches on the same field.
class Employee {
  readonly name: string;
  private readonly _type: string;

  constructor(name: string, type: string) {
    this.name = name;
    this._type = type;
  }

  type(): string { return this._type; }

  bonusMultiplier(): number {
    switch (this._type) {
      case "engineer": return 1.0;
      case "manager":  return 1.5;
      case "salesman": return 1.2;
      default:         return 1.0;
    }
  }
}

// Call site: new Employee("Alice", "engineer")
```

```typescript
// After: each subclass owns its type string and bonus multiplier.
// Adding a new type means adding a new class; bonusMultiplier is not touched.
abstract class Employee {
  constructor(readonly name: string) {}

  abstract type(): string;
  abstract bonusMultiplier(): number;
}

class Engineer extends Employee {
  type(): string          { return "engineer"; }
  bonusMultiplier(): number { return 1.0; }
}

class Manager extends Employee {
  type(): string          { return "manager"; }
  bonusMultiplier(): number { return 1.5; }
}

class Salesman extends Employee {
  type(): string          { return "salesman"; }
  bonusMultiplier(): number { return 1.2; }
}

class UnknownEmployee extends Employee {
  type(): string          { return "unknown"; }
  bonusMultiplier(): number { return 1.0; }
}

function createEmployee(name: string, type: string): Employee {
  switch (type) {
    case "engineer": return new Engineer(name);
    case "manager":  return new Manager(name);
    case "salesman": return new Salesman(name);
    default:         return new UnknownEmployee(name);
  }
}

// Call site: createEmployee("Alice", "engineer")
```

For every `(name, type)` combination, `createEmployee` returns an instance
whose `bonusMultiplier()` matches the original value. Note that for an
unrecognised type, `type()` returns `"unknown"` rather than the original string;
the type-code field is an artifact that subsequent refactorings remove, so this
deviation is intentional. The `default` case in the original `bonusMultiplier`
switch returned `1.0`, and `UnknownEmployee.bonusMultiplier()` returns `1.0`,
so no new exceptions are thrown where the before-code returned a value.

---

## 7. Remove Subclass

**Intent and motivation.** A subclass that adds no meaningful behavioural
variation over its superclass is unnecessary complexity. It may have been
introduced for a distinction that has since eroded, or the variation it
represents may be entirely expressible as a field value. Collapsing the
subclass back into the superclass removes the class boundary, simplifies the
hierarchy, and replaces a structural distinction with a data distinction (which
is cheaper to add, remove, or change) (Fowler, *Refactoring*, 2nd ed., 2018,
Chapter 12).

**Triggering signal.** A subclass overrides no methods with meaningfully
different behaviour; its only distinction from the superclass is the value of a
type-code or constant field; or the subtypes it once represented have been
reduced to a single case that no longer justifies a separate class.

**Mechanics.**
1. Add a type-code field (or a getter that returns a distinguishing value) to
   the superclass, giving it the value that the subclass would have returned.
2. Update each point in the code that tests `instanceof` or dispatches on the
   subclass type to use the new getter instead.
3. Replace each factory or constructor call that creates an instance of the
   subclass with one that creates an instance of the superclass, passing the
   appropriate type-code value.
4. Delete the subclass.
5. Run the tests.

**Inverse:** Replace Type Code with Subclasses.

---

## 8. Extract Superclass

**Intent and motivation.** When two classes share fields and methods but are
not connected by inheritance, the shared structure is duplicated. Creating a
superclass and moving the shared elements into it removes the duplication,
gives the shared concept an explicit name in the type hierarchy, and makes it
possible to write polymorphic code that operates on both classes through the
new superclass type (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 12).

**Triggering signal.** Two classes share fields with the same name and purpose;
their methods have similar implementations that differ only in the class-
specific details; or a natural abstraction connects them that is not yet
expressed anywhere in the code.

**Mechanics.**
1. Create an empty superclass and make both existing classes extend it.
2. Apply Pull Up Constructor Body, Pull Up Field, and Pull Up Method as needed
   to move each shared element to the superclass.
3. Review the superclass interface: consider what abstract methods or abstract
   fields it should declare to represent the contract that both subclasses
   fulfil.
4. Run the tests after each pull-up step.

**Related move:** Collapse Hierarchy (the complementary direction: merging a
superclass and subclass when the distinction no longer justifies the split).

---

## 9. Collapse Hierarchy

**Intent and motivation.** When a subclass and its superclass have drifted so
close that the boundary between them no longer carries meaning, maintaining
two classes is pure overhead. The class that was once a specialisation may have
had its variation removed by earlier refactorings, or the domain may have
changed so that the distinction is no longer relevant. Merging the two classes
into one simplifies the hierarchy and reduces the conceptual load for every
reader of the code (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 12).

**Triggering signal.** A subclass adds no fields or methods that differ from
the superclass in a meaningful way; all methods in the subclass merely
delegate to the superclass or add trivially small variations; or the subclass
was once specialised but its variation has been gradually removed by earlier
refactorings.

**Mechanics.**
1. Choose which of the two classes to keep. Usually this is the superclass,
   but keep the one with the more meaningful name or the most call sites if
   they differ.
2. Use Pull Up Field, Pull Up Method, Push Down Field, and Push Down Method to
   move all elements into the chosen class.
3. Update any call site, factory function, or import that references the
   eliminated class to reference the chosen class.
4. Remove the now-empty class.
5. Run the tests.

**Related move:** Extract Superclass (the complementary direction: separating
shared elements from two classes into a new superclass).

---

## 10. Replace Subclass with Delegate

**Intent and motivation.** Inheritance is a powerful mechanism but it has a
critical limitation: it models only one dimension of variation. When an object
must vary along two independent dimensions at once (for example, a booking that
is both premium and for a specific performance type), a single subclass cannot
represent both. A delegate object carries the varying behaviour, is swapped at
runtime rather than fixed at construction, and adds no class-hierarchy depth.
Fowler summarises this as the Gang of Four principle "prefer composition over
inheritance" made concrete (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 12).

**Triggering signal.** A subclass is needed to vary behaviour in one dimension,
but a second independent variation is also needed; objects must switch which
variant they represent at runtime (inheritance cannot support this); or the
subclass is tightly coupled to a framework that limits further extension
through inheritance.

**Mechanics.**
1. Create a delegate class that encapsulates the subclass's variant behaviour.
   Give the delegate a reference back to the host (superclass) instance so it
   can access shared state when needed.
2. Add a field on the superclass (or the formerly-subclassed class) to hold an
   optional delegate.
3. Introduce a factory function (or static method) that creates the host with
   the delegate already populated, replacing calls to the subclass constructor.
4. For each method that the subclass overrides, add a delegation check in the
   superclass method: if the delegate is present, forward the call to it;
   otherwise, execute the original superclass behaviour.
5. Move each subclass method's body into the corresponding method on the
   delegate.
6. Remove the subclass once all of its behaviour has been migrated to the
   delegate.
7. Run the tests after each method migration.

### Example

```typescript
// Before: PremiumBooking overrides hasTalkback and basePrice.
// If a second independent variation were needed (say, a different venue type),
// a matrix of subclasses would be required.
interface Show { price: number; hasTalkback: boolean; }
interface PremiumExtras { premiumFee: number; }

function isPeakDay(date: Date): boolean {
  return date.getDay() === 5 || date.getDay() === 6;
}

class Booking {
  constructor(
    protected readonly show: Show,
    protected readonly date: Date,
  ) {}

  hasTalkback(): boolean {
    return this.show.hasTalkback && !isPeakDay(this.date);
  }

  basePrice(): number {
    return isPeakDay(this.date)
      ? Math.round(this.show.price * 1.15)
      : this.show.price;
  }
}

class PremiumBooking extends Booking {
  constructor(
    show: Show,
    date: Date,
    private readonly extras: PremiumExtras,
  ) {
    super(show, date);
  }

  hasTalkback(): boolean {
    return this.show.hasTalkback; // premium always gets talkback
  }

  basePrice(): number {
    return Math.round(super.basePrice() + this.extras.premiumFee);
  }
}
```

```typescript
// After: PremiumBookingDelegate holds the premium overrides.
// Booking consults it when present; PremiumBooking is removed.
// A second delegate could now be added for venue-type variation independently.
class PremiumBookingDelegate {
  constructor(
    private readonly host: Booking,
    private readonly extras: PremiumExtras,
  ) {}

  hasTalkback(): boolean {
    return this.host.show.hasTalkback;
  }

  extendBasePrice(base: number): number {
    return Math.round(base + this.extras.premiumFee);
  }
}

class Booking {
  readonly show: Show;
  readonly date: Date;
  private _premiumDelegate: PremiumBookingDelegate | undefined;

  constructor(show: Show, date: Date) {
    this.show = show;
    this.date = date;
  }

  static createPremium(
    show: Show,
    date: Date,
    extras: PremiumExtras,
  ): Booking {
    const booking = new Booking(show, date);
    booking._premiumDelegate = new PremiumBookingDelegate(booking, extras);
    return booking;
  }

  hasTalkback(): boolean {
    if (this._premiumDelegate) return this._premiumDelegate.hasTalkback();
    return this.show.hasTalkback && !isPeakDay(this.date);
  }

  basePrice(): number {
    const base = isPeakDay(this.date)
      ? Math.round(this.show.price * 1.15)
      : this.show.price;
    return this._premiumDelegate
      ? this._premiumDelegate.extendBasePrice(base)
      : base;
  }
}

// Former: new PremiumBooking(show, date, extras)
// After:  Booking.createPremium(show, date, extras)
```

For any `(show, date, extras)`:
- `hasTalkback()` on a premium booking returns `show.hasTalkback` (delegate
  path), same as `PremiumBooking.hasTalkback()` returned before.
- `basePrice()` on a premium booking returns
  `round(base + extras.premiumFee)` where `base` is the same value
  `super.basePrice()` returned, so the result is unchanged.
- A non-premium `Booking` (no delegate) behaves identically to the old
  `Booking` class.

The key gain: a second delegate (for example `GroupBookingDelegate`) can now
be added as an independent field without introducing a second dimension of
subclasses.

---

## 11. Replace Superclass with Delegate

**Intent and motivation.** Inheritance implies a true "is-a" relationship: the
subclass must be fully substitutable for the superclass in all its uses (the
Liskov Substitution Principle). When that relationship does not hold (a `Stack`
inheriting from `List` exposes `insert` and `remove` at arbitrary indices,
which violate stack semantics; a `ScrollableWindow` inheriting from
`Rectangle` breaks when the window is resized but the rectangle is immutable),
the inheritance is misleading and actively harmful. Replacing it with a
delegate field makes the relationship explicit as a "has-a" rather than an
"is-a": the former subclass uses the former superclass for implementation but
no longer claims to be one (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 12).

**Triggering signal.** The subclass overrides or hides superclass methods to
prevent callers from using them (a sign of broken substitutability); some
operations inherited from the superclass do not make sense for the subclass; or
the subclass inherits from the superclass purely to reuse its implementation,
not because it represents a true subtype that clients can treat interchangeably
with the superclass.

**Mechanics.**
1. Add a delegate field on the subclass that holds an instance of the
   superclass (or of its interface). Initialise it in the constructor,
   passing any required arguments.
2. For each method of the superclass that the subclass actually uses, add a
   forwarding method on the subclass that delegates to the held instance.
3. Remove the `extends` declaration.
4. Update any code that relied on the subclass being substitutable for the
   superclass: extract an interface from the superclass if shared typing is
   needed, and implement that interface on the subclass explicitly.
5. Run the tests.

---

## 12. Sources

Martin Fowler (with Kent Beck), *Refactoring: Improving the Design of Existing
Code*, 2nd ed. (Addison-Wesley, 2018). Chapter 12: "Dealing with Inheritance",
pages 350-399. The mechanics in this file are condensed and paraphrased; they
are not the book text verbatim. Page numbers cited in the chapter
cross-reference above correspond to the first printing.

Web validation: chapter 12 move list (Pull Up Method, Pull Up Field, Pull Up
Constructor Body, Push Down Method, Push Down Field, Replace Type Code with
Subclasses, Remove Subclass, Extract Superclass, Collapse Hierarchy, Replace
Subclass with Delegate, Replace Superclass with Delegate) confirmed against a
web search cross-check that returned the full chapter 12 listing with page
references, corroborated by the O'Reilly online edition at
https://www.oreilly.com/library/view/refactoring-improving-the/9780134757681/
and the refactoring.com catalogue tags at https://refactoring.com/catalog/.
