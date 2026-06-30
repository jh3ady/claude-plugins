# Refactoring APIs: reference

Deeper mechanics for the "Refactoring APIs" category in the
`refactoring-catalog` skill. The skill body holds the one-line summaries;
this file holds intent, triggering signal, condensed mechanics, inverse where
one exists, and TypeScript examples for the most structural moves in the group.

A function's public signature is a contract with its callers. Hidden side
effects, flag arguments that force callers to pass `true` or `false` with no
context, and parameters whose value is already derivable from other arguments
all make that contract harder to understand and use correctly. The moves in
this chapter reshape function signatures and the objects they create so that
callers can reason about each function from its interface alone, without
reading the implementation (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 11).

## Table of contents

1. [Separate Query from Modifier](#1-separate-query-from-modifier)
2. [Parameterize Function](#2-parameterize-function)
3. [Remove Flag Argument](#3-remove-flag-argument)
4. [Preserve Whole Object](#4-preserve-whole-object)
5. [Replace Parameter with Query](#5-replace-parameter-with-query)
6. [Replace Query with Parameter](#6-replace-query-with-parameter)
7. [Remove Setting Method](#7-remove-setting-method)
8. [Replace Constructor with Factory Function](#8-replace-constructor-with-factory-function)
9. [Replace Function with Command](#9-replace-function-with-command)
10. [Replace Command with Function](#10-replace-command-with-function)
11. [Sources](#11-sources)

---

## 1. Separate Query from Modifier

**Intent and motivation.** A function that both returns a value and causes a
side effect (writing to a file, sending a notification, updating shared state)
violates the Command-Query Separation principle: queries should be free of side
effects, and commands should return nothing. When the two concerns are merged,
callers who want the return value may unknowingly trigger the side effect
multiple times, and callers who want the side effect may accidentally depend on
the return value. Splitting them into a pure query and a void modifier lets
each be called safely and independently (Fowler, *Refactoring*, 2nd ed., 2018,
Chapter 11).

**Triggering signal.** A function returns a value and also mutates state, sends
a message, or writes to an external resource; calling the function twice to
check a condition would incorrectly trigger the side effect twice; or the
function is hard to use in a test because the assertion would re-trigger the
side effect.

**Mechanics.**
1. Create a new query function that returns the same value as the original
   but contains none of the side-effect code.
2. For each call site that uses the return value, replace it with a call to
   the new query function. Add a call to the original function immediately
   before or after where the side effect is also needed, or leave the original
   call unchanged for now.
3. Remove the return value from the original function, making it a void
   modifier.
4. Verify that all call sites now either call the query (when only the value
   is needed) or call the modifier (when only the side effect is needed) or
   call both in sequence (when both are needed).
5. Run the tests.

**Inverse:** none formally named; the reverse (recombining a query and a
modifier) is rarely desirable and has no standard name.

### Example

```typescript
// Before: totalOutstanding returns a value AND sends a bill email.
// Calling it twice to check whether the amount exceeds a threshold
// sends two emails: a silent, untestable coupling.
interface Invoice { amount: number; }

class Customer {
  readonly email: string;
  private readonly invoices: Invoice[];

  constructor(email: string, invoices: Invoice[]) {
    this.email = email;
    this.invoices = invoices;
  }

  getTotalOutstandingAndSendBill(): number {
    const total = this.invoices.reduce((sum, inv) => sum + inv.amount, 0);
    if (total > 0) {
      sendEmail(this.email, `You owe ${total}`);
    }
    return total;
  }
}

declare function sendEmail(to: string, body: string): void;
```

```typescript
// After: totalOutstanding is a pure query with no side effects;
// sendBill is a void modifier that calls the query internally.
// Callers can invoke either or both, independently.
class Customer {
  readonly email: string;
  private readonly invoices: Invoice[];

  constructor(email: string, invoices: Invoice[]) {
    this.email = email;
    this.invoices = invoices;
  }

  totalOutstanding(): number {
    return this.invoices.reduce((sum, inv) => sum + inv.amount, 0);
  }

  sendBill(): void {
    const total = this.totalOutstanding();
    if (total > 0) {
      sendEmail(this.email, `You owe ${total}`);
    }
  }
}
```

For any `Customer` with a given set of invoices, `totalOutstanding()` returns
the same number that `getTotalOutstandingAndSendBill()` returned, and
`sendBill()` produces the same email. A caller that only needs the total no
longer triggers the email; a caller that needs both calls each function once.

---

## 2. Parameterize Function

**Intent and motivation.** When two or more functions differ only by a literal
value in their bodies, each function is a specialisation of the same general
computation. Replacing the literal with a parameter and merging the functions
into one removes the duplication, makes the shared logic easy to maintain in
one place, and makes the relationship between the specialisations explicit in
the signature (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 11).

**Triggering signal.** Two or more functions have almost identical bodies that
differ only by a literal value; adding a new variation of the same pattern
would require adding yet another near-duplicate function; or the literal value
is a numeric or string constant whose meaning is already captured in the
function name.

**Mechanics.**
1. Pick one of the similar functions and apply Change Function Declaration to
   add a parameter for the value that varies, giving it a descriptive name.
2. Update that function's body to use the parameter instead of the literal.
3. Update every call site for that function to pass the literal value
   explicitly.
4. Run the tests.
5. For each remaining similar function, replace its body with a call to the
   parameterized function, passing the appropriate literal.
6. Run the tests after each.
7. Once all callers use the unified function, remove the now-redundant
   duplicates.
8. Run the tests.

**Related move:** Remove Flag Argument addresses the related but opposite
situation: a function already accepts a value that selects between two
completely different behaviours. Where Parameterize Function unifies functions
that vary by a continuous value, Remove Flag Argument separates a function
that branches on a discrete flag.

---

## 3. Remove Flag Argument

**Intent and motivation.** A boolean (or enum used as a flag) parameter that
controls which of two distinct behaviours a function performs mixes those two
behaviours inside a single function. Call sites must pass `true` or `false`
with no name to explain what is being selected, making the intent invisible.
The function body must branch on the flag, tying two unrelated responsibilities
together. Replacing the flag with two explicitly named functions restores
clarity at every call site and lets each function's body focus on one
responsibility (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 11).

**Triggering signal.** A function has a boolean parameter; its body contains a
top-level `if` or ternary that branches on that parameter and the two branches
are largely independent; or call sites read `book(order, true)` and it is
impossible to tell from the call alone what `true` means.

**Mechanics.**
1. For each value of the flag, create a dedicated function with an explicit
   name that describes what the flag value means. Its body can be a wrapper
   that calls the original function with the flag hard-coded, or it can
   contain only the relevant branch of the original.
2. For each call site, replace the call with a call to the appropriate named
   function.
3. Run the tests after each call-site update.
4. Once all call sites use the named functions, remove the original flagged
   function (or make it private if it is still useful as an internal detail).
5. Run the tests.

**Related move:** Parameterize Function (the complementary direction: merging
functions that vary by a continuous value).

### Example

```typescript
// Before: the boolean rushDelivery controls two distinct scheduling paths.
// "book(order, true)" is unreadable without reading the function signature.
interface Order { id: string; destination: string; }

function book(order: Order, isRush: boolean): void {
  if (isRush) {
    scheduleRush(order);
    notifyCustomer(order, "rush");
  } else {
    scheduleRegular(order);
    notifyCustomer(order, "regular");
  }
}

declare function scheduleRush(order: Order): void;
declare function scheduleRegular(order: Order): void;
declare function notifyCustomer(order: Order, mode: string): void;
```

```typescript
// After: bookRush and bookRegular name the intent at every call site.
// The original book function is removed; neither named function has a flag.
function bookRush(order: Order): void {
  scheduleRush(order);
  notifyCustomer(order, "rush");
}

function bookRegular(order: Order): void {
  scheduleRegular(order);
  notifyCustomer(order, "regular");
}
```

For any `Order`, `bookRush(order)` produces the same outcome as
`book(order, true)`, and `bookRegular(order)` produces the same outcome as
`book(order, false)`. Call sites now communicate intent without any
documentation needed.

---

## 4. Preserve Whole Object

**Intent and motivation.** When a function receives several individual values
all derived from the same source object, the caller must know which fields to
extract, and the function is coupled to the structure of that object through
every call site. If the function later needs an additional field from the same
source, the signature must change and every caller must be updated. Passing the
whole object lets the function retrieve what it needs directly, decouples the
caller from the object's internals, and typically reduces the parameter count
(Fowler, *Refactoring*, 2nd ed., 2018, Chapter 11).

**Triggering signal.** A function receives two or more parameters that are all
derived from the same object at every call site; the same derivation pattern
is repeated across multiple callers; or the parameter list has grown because
more fields from the same source were added over time.

**Mechanics.**
1. Create a new parameter for the whole source object.
2. For each existing parameter that is derivable from the whole object,
   replace its use inside the function body with a read directly from the new
   parameter.
3. Remove each now-redundant parameter from the function signature.
4. Update each call site to pass the whole object rather than the individual
   fields.
5. Run the tests.

*Note:* if the function is on a different module from the source object and
passing the whole object would introduce an unwanted dependency, consider
whether Introduce Parameter Object (creating a purpose-built data structure)
is a better fit.

---

## 5. Replace Parameter with Query

**Intent and motivation.** When a function can derive the value of a parameter
entirely from other data it already receives, the parameter is redundant: the
caller computes a value that the function could equally compute itself. Removing
the parameter simplifies every call site, centralises the derivation logic, and
makes the parameter list a more faithful description of the function's genuine
inputs (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 11).

**Triggering signal.** At every call site, the value passed for a parameter is
computed from other arguments or from data available to the function; the
derivation expression is repeated identically at every call site; or the
parameter was added defensively but the function always has enough information
to compute its value without it.

**Mechanics.**
1. Identify the expression that computes the parameter's value at a typical
   call site.
2. Extract that expression into a new function (or a method) if it is not
   already encapsulated.
3. In the main function's body, replace all reads of the parameter with a call
   to that new function or expression.
4. Apply Change Function Declaration to remove the parameter from the
   signature.
5. Update all call sites to remove the argument.
6. Run the tests.

**Inverse:** Replace Query with Parameter.

---

## 6. Replace Query with Parameter

**Intent and motivation.** When a function reaches into its environment to look
up a value (reading a module-level variable, calling a method on an object it
navigated to, or accessing a singleton), that dependency is invisible in the
signature. The function's result can change because of something outside its
parameter list, making it harder to test, harder to reason about, and harder
to move. Making the looked-up value an explicit parameter removes the hidden
dependency, makes the function purer, and moves the responsibility for
providing the value to the caller (Fowler, *Refactoring*, 2nd ed., 2018,
Chapter 11).

**Triggering signal.** A function calls a method or reads a field on an object
it was not given as a parameter; the function's result varies depending on
mutable shared state; or making the function testable in isolation requires
patching or injecting the external reference.

**Mechanics.**
1. Extract the looked-up expression inside the function into a local variable
   using Extract Variable.
2. Extract the remainder of the function body (the part that uses the variable)
   into a new function, with the variable as a parameter.
3. Inline the outer function back to its call sites, replacing each call with
   the value expression followed by a call to the new function.
4. Once all callers pass the value explicitly, rename the new function to the
   original name if appropriate.
5. Run the tests.

**Inverse:** Replace Parameter with Query.

---

## 7. Remove Setting Method

**Intent and motivation.** A setter on a field communicates that the field may
be changed after construction. When a field is only ever set once (at
construction time) and should remain constant for the object's lifetime,
having a setter leaves the door open to accidental or unauthorised mutation.
Removing the setter, and making the field `readonly` where the type system
allows it, makes the immutability of the field explicit and enforces it
statically (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 11).

**Triggering signal.** A field has a setter that is only called from the
constructor or from the factory function that creates the object; the field is
never reassigned after creation in any other code path; or a code review
reveals a setter that was generated automatically but is never actually needed.

**Mechanics.**
1. Confirm that the setter is called only at construction (either in the
   constructor itself or in the factory that immediately follows construction).
2. If the setter is called from outside the constructor, move the assignment
   into the constructor and pass the value as a constructor parameter.
3. Delete the setter.
4. Mark the field `readonly` (or the equivalent in the language) to enforce
   the invariant in the type system.
5. Run the tests.

---

## 8. Replace Constructor with Factory Function

**Intent and motivation.** A constructor is constrained in several ways: it
can only return an instance of the class it belongs to, its name is fixed to
the class name (offering no extra description), and it cannot be overridden to
return a subclass instance. A factory function has none of these constraints:
it can choose which class to instantiate based on its arguments, carry a
descriptive name that explains what kind of object it creates, and return a
default or a null-object instead of throwing when no valid instance can be
produced. Factory functions are also easier to pass as higher-order values and
easier to replace in tests (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 11).

**Triggering signal.** Callers pass a raw type-code string or enum to the
constructor to select a variant; the constructor name gives no hint about what
kind of object the caller intends to create; the same class needs to be
instantiated in different ways depending on context; or the constructor
performs logic that would be cleaner in a named function.

**Mechanics.**
1. Create a factory function (a standalone function or a static method) whose
   body calls the constructor.
2. For each call site that calls the constructor directly, replace it with a
   call to the factory function.
3. Run the tests after each replacement.
4. Once all external call sites use the factory, restrict direct constructor
   access (make it `private` or `protected`) so that all creation goes through
   the factory.
5. Run the tests.

### Example

```typescript
// Before: the type string is passed directly to the constructor.
// "new Employee('Alice', 'engineer')" is readable, but the type string
// is an unguarded literal with no validation or documentation.
class Employee {
  readonly name: string;
  readonly type: string;

  constructor(name: string, type: string) {
    this.name = name;
    this.type = type;
  }

  monthlyCost(): number {
    switch (this.type) {
      case "engineer": return 8_000;
      case "manager":  return 10_000;
      case "salesman": return 7_000;
      default:         return 6_000;
    }
  }
}

// Call sites:
// new Employee("Alice", "engineer")
// new Employee("Bob", "manager")
```

```typescript
// After: factory functions name the intent; the constructor is private.
// The type string can no longer be passed incorrectly from a call site.
class Employee {
  readonly name: string;
  private readonly _type: string;

  private constructor(name: string, type: string) {
    this.name = name;
    this._type = type;
  }

  static createEngineer(name: string): Employee {
    return new Employee(name, "engineer");
  }

  static createManager(name: string): Employee {
    return new Employee(name, "manager");
  }

  static createSalesman(name: string): Employee {
    return new Employee(name, "salesman");
  }

  monthlyCost(): number {
    switch (this._type) {
      case "engineer": return 8_000;
      case "manager":  return 10_000;
      case "salesman": return 7_000;
      default:         return 6_000;
    }
  }
}

// Call sites:
// Employee.createEngineer("Alice")
// Employee.createManager("Bob")
```

For every `(name, type)` combination previously valid, the factory function
produces an `Employee` with the same `name`, the same internal `_type`, and
the same `monthlyCost()` result. The private constructor prevents new call
sites from bypassing the factory and passing an arbitrary type string.

---

## 9. Replace Function with Command

**Intent and motivation.** A plain function is the simplest unit of behaviour,
but it cannot carry state between calls, cannot be undone, and cannot expose
its intermediate steps. Wrapping a function in a command object (a class with
a field per parameter and an `execute` method) grants all of these
capabilities: intermediate results become named fields (making complex
computations debuggable), an `undo` method can reverse the effect, the command
can be stored in a queue and replayed, and its behaviour can be varied through
subclassing. Use this move only when one of those capabilities is genuinely
needed; the simpler form is always the plain function (Fowler, *Refactoring*,
2nd ed., 2018, Chapter 11).

**Triggering signal.** A function has so many parameters or so much
intermediate state that it would benefit from being broken into steps with
named fields; the operation must be reversible (undoable); instances of the
function must be stored, queued, or replayed; or the function needs to vary
behaviour in ways best expressed by subclassing the command.

**Mechanics.**
1. Create a class. Name it after the function it wraps.
2. Move the function's body into an `execute` method on the class.
3. For each parameter of the original function, add a corresponding instance
   field to the class and assign it in the constructor.
4. Replace each read of a local parameter in `execute` with the corresponding
   field access.
5. Update each call site to construct the command and call `execute`.
6. Run the tests.

**Inverse:** Replace Command with Function.

---

## 10. Replace Command with Function

**Intent and motivation.** A command object adds indirection and complexity
that is only justified if the extra capabilities it provides (undo, step-wise
execution, subclassing) are actually needed. When the command class has a
single `execute` method, is never subclassed, stores its parameters only to
pass them immediately to `execute`, and is always constructed and executed in
the same expression, it adds no value over a plain function. Collapsing it
back to a function removes the unnecessary class and all of its ceremony
(Fowler, *Refactoring*, 2nd ed., 2018, Chapter 11).

**Triggering signal.** A command class has a single method; its constructor
parameters are passed unchanged to that method each time; it is never
subclassed; it provides no undo or step-wise execution; and every call site
constructs and immediately executes the command in a single expression.

**Mechanics.**
1. Apply Extract Function to the body of the command's `execute` method,
   giving the extracted function the name of the command or something more
   descriptive.
2. For each field of the class, add it as a parameter to the extracted function
   and remove the corresponding field reads.
3. Inline the `execute` method (replace it with a call to the new function).
4. Adjust each call site to call the new function directly, passing the values
   that were previously passed to the constructor.
5. Delete the command class.
6. Run the tests.

**Inverse:** Replace Function with Command.

---

## 11. Sources

Martin Fowler (with Kent Beck), *Refactoring: Improving the Design of Existing
Code*, 2nd ed. (Addison-Wesley, 2018). Chapter 11: "Refactoring APIs". The
mechanics in this file are condensed and paraphrased; they are not the book
text verbatim.

Web validation: chapter 11 move list (Separate Query from Modifier,
Parameterize Function, Remove Flag Argument, Preserve Whole Object, Replace
Parameter with Query, Replace Query with Parameter, Remove Setting Method,
Replace Constructor with Factory Function, Replace Function with Command,
Replace Command with Function) confirmed against the O'Reilly online edition
table of contents at
https://www.oreilly.com/library/view/refactoring-improving-the/9780134757681/ch11.xhtml
and corroborated by the refactoring.com catalogue tags at
https://refactoring.com/catalog/ and a web search cross-check of the chapter 11
section listing.
