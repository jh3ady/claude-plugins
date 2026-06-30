---
name: refactoring-catalog
description:
  This skill should be used when choosing the specific refactoring move to
  apply in a situation, however the need is expressed: "extract this",
  "inline this", "split this function", "replace this conditional",
  "pull this up", "rename this variable", "encapsulate this field",
  "hide this delegate", "move this function", "move this field",
  "push this down to the subclass", or any similar instruction on existing
  code structure, even when Fowler is not named. It covers Fowler's
  complete named catalogue (2nd ed., 2018, with Kent Beck) across seven
  chapters: a first set of refactorings; encapsulation; moving features;
  organizing data; simplifying conditional logic; refactoring APIs; and
  dealing with inheritance. Use alongside the sibling skills
  refactoring-method (the overall method) and code-smells (the diagnostic
  signals that point to specific moves). Composable with your own
  conventions.
---

# Refactoring catalogue

This skill is the named-moves toolbox for Fowler's *Refactoring* (2nd ed.,
2018, with Kent Beck). Each move has a precise name, a condensed mechanic,
and, where one exists, an inverse. The detail lives in the reference files
linked below. For the method of refactoring (two hats, small steps, the test
net), use `refactoring-method`. For diagnosing which move to apply from a code
smell, use `code-smells`.

## A first set of refactorings (chapter 6)

The moves Fowler names most often as everyday defaults (Fowler, *Refactoring*,
2nd ed., 2018, Chapter 6).

- **Extract Function**: pulls a code fragment into a separately named function that expresses the fragment's purpose.
- **Inline Function**: replaces a function call with the function body when the indirection adds no clarity.
- **Extract Variable**: introduces a named variable to hold a complex expression, making it readable and reusable.
- **Inline Variable**: removes a temporary variable when the expression it holds is already clear at its use site.
- **Change Function Declaration**: renames a function or alters its parameter list to better express intent.
- **Encapsulate Variable**: wraps a publicly accessible variable behind getter and setter functions.
- **Rename Variable**: gives a variable a more meaningful name.
- **Introduce Parameter Object**: groups parameters that always travel together into a dedicated data structure.
- **Combine Functions into Class**: groups functions that share a common data record into a class that makes that relationship explicit.
- **Combine Functions into Transform**: enriches a record by passing it through a transform function that appends derived values, consolidating all derivation logic in one place.
- **Split Phase**: separates a computation into two sequential phases with an explicit intermediate data structure between them.

Full mechanics and TypeScript examples in `references/01-first-set.md`.

## Encapsulation (chapter 7)

Moves that tighten access boundaries around data and delegate chains (Fowler,
*Refactoring*, 2nd ed., 2018, Chapter 7).

- **Encapsulate Record**: wraps a plain data record behind a class so access can be controlled and behaviour added.
- **Encapsulate Collection**: exposes a collection through add and remove methods rather than a direct field reference.
- **Replace Primitive with Object**: promotes a primitive value to a class when it requires behaviour or validation.
- **Replace Temp with Query**: replaces a temporary variable with a method call so derived data is always computed fresh.
- **Extract Class**: moves part of a class's responsibilities to a new, focused class.
- **Inline Class**: merges a class that no longer carries enough responsibility into its collaborator.
- **Hide Delegate**: adds delegating methods on a server class so clients do not navigate through its internal objects.
- **Remove Middle Man**: removes delegation methods from a class that does nothing but forward calls to another.
- **Substitute Algorithm**: replaces the body of a function with a cleaner algorithm that produces the same result.

Full mechanics and TypeScript examples in `references/02-encapsulation.md`.

## Moving features (chapter 8)

Moves that relocate code to the module or class where it most naturally belongs
(Fowler, *Refactoring*, 2nd ed., 2018, Chapter 8).

- **Move Function**: relocates a function to the class or module where its logic belongs.
- **Move Field**: relocates a field to the class where it is most used.
- **Move Statements into Function**: absorbs statements that always accompany a function call into that function.
- **Move Statements to Callers**: extracts statements from a function when they need to vary across call sites.
- **Replace Inline Code with Function Call**: replaces duplicate inline code with a call to the existing function that already expresses it.
- **Slide Statements**: moves a statement to sit adjacent to the code it most relates to.
- **Split Loop**: separates a loop that does two things into two loops, each doing one thing.
- **Replace Loop with Pipeline**: replaces an imperative loop with a sequence of pipeline operations (filter, map, reduce).
- **Remove Dead Code**: deletes code that can never be reached.

Full mechanics and TypeScript examples in `references/03-moving-features.md`.

## Organizing data (chapter 9)

Moves that improve how data is named, scoped, and represented (Fowler,
*Refactoring*, 2nd ed., 2018, Chapter 9).

- **Split Variable**: replaces a variable used for more than one purpose with separate variables, one per purpose.
- **Rename Field**: renames a field in a record or class to better express what it holds.
- **Replace Derived Variable with Query**: removes a variable whose value can always be computed from other data.
- **Change Reference to Value**: makes a shared object behave as an immutable value, replaced on change instead of mutated in place.
- **Change Value to Reference**: turns multiple independent copies of a conceptual entity into a single shared reference so all uses see the same state.

Full mechanics and TypeScript examples in `references/04-organizing-data.md`.

## Simplifying conditional logic (chapter 10)

Moves that make conditional branches easier to read and extend (Fowler,
*Refactoring*, 2nd ed., 2018, Chapter 10).

- **Decompose Conditional**: extracts the condition and each branch into clearly named functions.
- **Consolidate Conditional Expression**: merges a sequence of checks that produce the same result into one expression.
- **Replace Nested Conditional with Guard Clauses**: replaces a nested conditional tree with early-return guard clauses.
- **Replace Conditional with Polymorphism**: routes type-specific behaviour into subclasses or polymorphic objects, removing a conditional.
- **Introduce Special Case**: introduces a special-case object to absorb common handling for a specific value (the Null Object pattern and its variants).
- **Introduce Assertion**: adds a code assertion to make a hidden assumption explicit and verifiable.

Full mechanics and TypeScript examples in `references/05-simplifying-conditional-logic.md`.

## Refactoring APIs (chapter 11)

Moves that make functions easier and safer to call (Fowler, *Refactoring*,
2nd ed., 2018, Chapter 11).

- **Separate Query from Modifier**: splits a function that both returns a value and causes a side effect into two separate functions.
- **Parameterize Function**: unifies functions that differ only in a literal value by adding a parameter for that value.
- **Remove Flag Argument**: replaces a boolean flag argument with two explicitly named functions.
- **Preserve Whole Object**: passes the source object rather than individual fields derived from it.
- **Replace Parameter with Query**: removes a parameter whose value the function can compute itself from data already available.
- **Replace Query with Parameter**: adds a parameter for a value the function currently looks up, removing a hidden dependency.
- **Remove Setting Method**: deletes a setter to make a field immutable after construction.
- **Replace Constructor with Factory Function**: replaces a constructor with a factory function for greater control over object creation.
- **Replace Function with Command**: wraps a function in a command object to allow undo, parameterisation, or step-wise execution.
- **Replace Command with Function**: collapses a command object back into a plain function when the extra capability is not needed.

Full mechanics and TypeScript examples in `references/06-refactoring-apis.md`.

## Dealing with inheritance (chapter 12)

Moves that restructure class hierarchies (Fowler, *Refactoring*, 2nd ed., 2018,
Chapter 12).

- **Pull Up Method**: moves a method shared across subclasses to the superclass.
- **Pull Up Field**: moves a field shared across subclasses to the superclass.
- **Pull Up Constructor Body**: moves shared constructor logic to the superclass constructor.
- **Push Down Method**: moves a method used only by one subclass down to that subclass.
- **Push Down Field**: moves a field used only by one subclass down to that subclass.
- **Replace Type Code with Subclasses**: creates a subclass per type-code value to enable polymorphic dispatch.
- **Remove Subclass**: collapses a subclass that adds too little variation back into the superclass.
- **Extract Superclass**: creates a new superclass to share structure and behaviour across two related classes.
- **Collapse Hierarchy**: merges a superclass and subclass when their distinction no longer justifies the indirection.
- **Replace Subclass with Delegate**: replaces an inheritance relationship with a delegate field when the subclass varies behaviour rather than type.
- **Replace Superclass with Delegate**: replaces inheritance with a delegate field when the superclass is not a true type relationship for the subclass.

Full mechanics and TypeScript examples in `references/07-inheritance.md`.

## How to read a catalogue entry

Each entry in the reference files carries:

1. **Name**: the exact 2nd-edition name, with any common aliases noted.
2. **Intent and motivation**: what the move achieves and why you reach for it.
3. **Triggering signal**: the code pattern or situation that calls for this move.
4. **Mechanics**: the steps, condensed from Fowler's description. These are a guide, not a script; adapt the order to the actual code.
5. **Inverse**: the move that reverses this one, where one exists.
6. **Example**: a TypeScript before-and-after for the most structural moves.

## Inverse pairs

Several moves are inverses of each other. Knowing the inverse guards against
over-application and lets you reverse course when context changes:

- Extract Function / Inline Function
- Extract Variable / Inline Variable
- Extract Class / Inline Class
- Hide Delegate / Remove Middle Man
- Move Statements into Function / Move Statements to Callers
- Change Reference to Value / Change Value to Reference
- Replace Parameter with Query / Replace Query with Parameter
- Replace Function with Command / Replace Command with Function
- Pull Up Method / Push Down Method
- Pull Up Field / Push Down Field
- Replace Type Code with Subclasses / Remove Subclass

Inverses are independent moves applied in different circumstances, not
reversals of the same edit made in a single step.

## Guardrails

- **Test net first.** Confirm that the behaviour being restructured is under test before applying any move. If it is not, use the `legacy-code` skill to establish a characterization test net first.
- **One move at a time.** Apply a single named move, run the tests, commit. Do not batch multiple moves into one step; if a test fails, the single change pinpoints the cause.
- **Behaviour preservation is mandatory.** A move that changes observable behaviour is not a refactoring; it is something else. Keep the two hats separate (see `refactoring-method`).
- **Test after each mechanical step.** The mechanics in the reference files are ordered so each step compiles and all tests pass before the next step begins. Follow that order.

## Relationship to other skills

- **`refactoring-method`**: the method of refactoring: the two hats, small steps, the test net, when not to refactor. This skill is the toolbox; that one is the method. Use them together.
- **`code-smells`**: the 24 code smells of Chapter 3, each pointing to the moves in this catalogue. Use that skill to identify the smell; use this one for the move mechanics.
- **`test-driven-development`**: the red-green-refactor loop places refactoring at the third step. The moves in this catalogue are what that step applies.
- **`clean-code`**, **`solid-principles`**, **`simplicity-principles`**: the target properties that refactoring works toward. The moves here are the mechanism.
- **`legacy-code`**: when the code has no tests, that skill establishes the test net via seams and characterization tests. Return here once the bar is green.

## Adapt to your context

This skill stays generic on purpose. Your team may have agreed conventions for
naming extracted functions, a project policy on when Extract Class is preferred
over Introduce Parameter Object, or linting rules that constrain certain moves.
Declare those in your own `CLAUDE.md` or a higher-priority skill, which
overrides this baseline. This skill does not impose specific thresholds or
conventions.
