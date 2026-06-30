# Moving features: reference

Deeper mechanics for the "Moving features" category in the
`refactoring-catalog` skill. The skill body holds the one-line summaries;
this file holds intent, triggering signal, condensed mechanics, inverse where
one exists, and TypeScript examples for the most structural moves in the group.

Moving features addresses the question of location: where does a piece of
behaviour, data, or logic most naturally live? A function in the wrong class,
a statement duplicated at every call site, or a loop doing two jobs all pay an
ongoing readability tax. The moves in this chapter reposition those elements so
that the code that belongs together lives together (Fowler, *Refactoring*, 2nd
ed., 2018, Chapter 8).

## Table of contents

1. [Move Function](#1-move-function)
2. [Move Field](#2-move-field)
3. [Move Statements into Function](#3-move-statements-into-function)
4. [Move Statements to Callers](#4-move-statements-to-callers)
5. [Replace Inline Code with Function Call](#5-replace-inline-code-with-function-call)
6. [Slide Statements](#6-slide-statements)
7. [Split Loop](#7-split-loop)
8. [Replace Loop with Pipeline](#8-replace-loop-with-pipeline)
9. [Remove Dead Code](#9-remove-dead-code)
10. [Sources](#10-sources)

---

## 1. Move Function

**Aliases:** Move Method (1st edition name).

**Intent and motivation.** A function that is more coupled to another context
than to its own home creates unnecessary dependencies. Moving it to the context
it uses most lowers the coupling between modules, makes the receiving module
more self-contained, and makes the function easier to find for a reader who
already understands that context. The decision of where a function belongs
depends on which data it reads, which functions it calls, and which concept it
most clearly expresses (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 8).

**Triggering signal.** A function refers more often to data or functions in
another module than in its own; another class would find the function useful as
a member method; or a function creates an unwanted dependency on a module it
should not need to know about.

**Mechanics.**
1. Examine all functions and data that the function uses. Consider whether any
   of those elements should move with it, or whether moving them separately
   first would make this move cleaner.
2. Check whether the function is polymorphic (overridden in a subclass). If it
   is, the move requires additional care to preserve dispatch semantics.
3. Copy the function to the target context. Adjust the body to work there: for
   example, change an implicit `this` to an explicit parameter if moving from
   a method to a free function, or vice versa.
4. Run the tests.
5. Update the source function to delegate to the target if immediate removal of
   all callers is not practical. Remove the delegation wrapper once all callers
   have been updated.
6. Run the tests.

### Example

```typescript
// Before: distanceFor is a method on GPSTrack, but it only reads from
// two TrackPoint values and has no reason to live on the track itself.
interface TrackPoint {
  latitude: number;
  longitude: number;
}

class GPSTrack {
  constructor(readonly points: TrackPoint[]) {}

  private distanceFor(start: TrackPoint, end: TrackPoint): number {
    const latDiff = end.latitude - start.latitude;
    const lonDiff = end.longitude - start.longitude;
    return Math.sqrt(latDiff * latDiff + lonDiff * lonDiff);
  }

  totalDistance(): number {
    let total = 0;
    for (let i = 1; i < this.points.length; i++) {
      total += this.distanceFor(this.points[i - 1], this.points[i]);
    }
    return total;
  }
}
```

```typescript
// After: distance belongs to TrackPoint as a method measuring the
// Euclidean distance to another point. GPSTrack delegates to it.
class TrackPoint {
  constructor(
    readonly latitude: number,
    readonly longitude: number,
  ) {}

  distanceTo(other: TrackPoint): number {
    const latDiff = other.latitude - this.latitude;
    const lonDiff = other.longitude - this.longitude;
    return Math.sqrt(latDiff * latDiff + lonDiff * lonDiff);
  }
}

class GPSTrack {
  constructor(readonly points: TrackPoint[]) {}

  totalDistance(): number {
    let total = 0;
    for (let i = 1; i < this.points.length; i++) {
      total += this.points[i - 1].distanceTo(this.points[i]);
    }
    return total;
  }
}
```

`distanceTo` belongs to `TrackPoint` because it operates purely on two
`TrackPoint` values. `GPSTrack` no longer holds or exposes the intermediate
calculation. `totalDistance()` returns the same number before and after the
move for any `points` array; the only change is where the computation lives.
Note: promoting `TrackPoint` from an `interface` to a `class` is a prerequisite
step that hosts the moved method; it is not part of Move Function itself.

---

## 2. Move Field

**Intent and motivation.** A field that is more often read and updated by code
in another class than by the class that owns it is misplaced. It creates
coupling in the wrong direction: the other class depends on the owning class
for data that should belong to it. Moving the field to the class that uses it
most reduces that coupling, shortens parameter lists, and makes both classes
more self-contained (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 8).

**Triggering signal.** Every read or update of a field passes through a class
other than the one that owns the field; a cluster of parameters being passed
through multiple levels all belong to the receiving class; or Extract Class
identifies a group of fields that form a natural unit better placed elsewhere.

**Mechanics.**
1. Encapsulate the field in its current class if it is not already accessed
   through getter and setter methods.
2. Create the field in the target class, adding getter and setter methods.
3. Run the tests.
4. Choose a reference path from the source class to the target class. Update
   the getter and setter in the source class to delegate to the target field.
5. Run the tests.
6. Update all external callers to use the target class's getter and setter
   directly. Remove the source field and its delegation once all callers are
   updated.
7. Run the tests.

---

## 3. Move Statements into Function

**Intent and motivation.** When the same statements always appear alongside a
call to a particular function at every call site, those statements belong inside
the function. Absorbing them eliminates the repetition, makes each call site
simpler, and ensures that future callers automatically get the necessary
context. This is the inverse of Move Statements to Callers (Fowler,
*Refactoring*, 2nd ed., 2018, Chapter 8).

**Triggering signal.** The same block of statements appears immediately before
or after a function call at every call site with no variation across sites; the
statements are tightly coupled to the function's purpose; or removing the
statements from each call site would make those sites significantly easier to
read.

**Mechanics.**
1. If the call sites are not identical (some include the statements, some do
   not), use Slide Statements first to position the statements consistently
   adjacent to the call at each site.
2. Choose one call site. Apply Extract Function to bundle the call and the
   surrounding statements into a new named function.
3. At a second call site, verify that applying the same extraction produces the
   same result. Replace that call site with a call to the new function.
4. Repeat step 3 for each remaining call site.
5. Once all call sites use the new function, inline the original function into
   the new one so the absorbed statements become part of the original function's
   body under the original name.
6. Run the tests.

**Inverse:** Move Statements to Callers.

---

## 4. Move Statements to Callers

**Intent and motivation.** When a function body contains statements that need
to behave differently across call contexts, those statements no longer belong
inside the function. Moving them out preserves the single-purpose nature of the
function and lets each caller handle the varying behaviour independently. This
is the inverse of Move Statements into Function (Fowler, *Refactoring*, 2nd
ed., 2018, Chapter 8).

**Triggering signal.** A function has begun to serve multiple caller contexts
and a portion of its body must be conditional on which context is calling;
callers need to add or suppress behaviour around the call in ways that differ
across sites; or a function's responsibility has grown and a subset of its
statements now belong to the callers rather than to the function.

**Mechanics.**
1. If the function does more than moving the statements out, apply Extract
   Function first to isolate the statements that need to move.
2. Apply Inline Function to the existing function so all call sites have the
   full body inlined.
3. At each call site, apply Slide Statements to move the affected statements to
   the position where that caller needs them.
4. Apply Extract Function to what remains at each call site to restore a version
   of the original function minus the moved statements.
5. Run the tests.

**Inverse:** Move Statements into Function.

---

## 5. Replace Inline Code with Function Call

**Intent and motivation.** When a block of inline code does exactly what an
existing function does, maintaining two copies of the same logic is a
liability. Any change must be applied in both places, and the similarity may
not be obvious to future readers. Replacing the inline code with a call to the
function eliminates the duplication and makes the intent clear through the
function's name (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 8).

**Triggering signal.** A block of inline code does exactly what an existing
function or library method already provides; the code was written before the
function existed; or a function was recently extracted from one call site but
its counterpart elsewhere was not updated at the same time.

**Mechanics.**
1. Identify the existing function whose behaviour matches the inline code.
2. Replace the inline code with a call to that function.
3. Run the tests.

---

## 6. Slide Statements

**Intent and motivation.** Code is easier to understand when related statements
are grouped together and separated from unrelated code. A variable declaration
far from its first use, or a statement interleaved with unrelated logic, forces
the reader to hold more context than necessary. Sliding statements to be
adjacent to the code they relate to reduces that cognitive load and often
reveals opportunities for Extract Function (Fowler, *Refactoring*, 2nd ed.,
2018, Chapter 8).

**Triggering signal.** A variable is declared significantly before its first
use; a group of statements that conceptually belong together are interleaved
with unrelated statements; or preparation code for a function call is scattered
around the call site rather than immediately preceding it.

**Mechanics.**
1. Identify the statement to move and the target position adjacent to the code
   it relates to.
2. Verify that no statement between the current position and the target reads
   or writes state that the moving statement also reads or writes. If one does,
   the slide is not safe without first addressing that dependency.
3. Move the statement to the target position.
4. Run the tests.

---

## 7. Split Loop

**Intent and motivation.** A loop that does two separate things in one pass is
harder to understand than two loops each doing one thing. The reader must track
both jobs simultaneously to verify they do not interfere. Splitting the loop
makes each loop's purpose clear at a glance and often enables Extract Function
on each loop independently. The performance cost of a second pass is rarely
significant; if it is, a profiler will confirm it (Fowler, *Refactoring*, 2nd
ed., 2018, Chapter 8).

**Triggering signal.** A single loop accumulates two different results, updates
two unrelated values, or mixes filtering and aggregation in a way that serves
two responsibilities at once.

**Mechanics.**
1. Copy the loop body.
2. Identify which statements belong to each of the two responsibilities.
   Remove the statements for responsibility B from the first copy, and the
   statements for responsibility A from the second copy.
3. Run the tests.
4. Apply Extract Function to each loop if naming the responsibility would
   further clarify the code.

### Example

```typescript
// Before: one loop computes total salary and finds the youngest employee.
// A reader must track two accumulations and two variables simultaneously.
interface Employee {
  name: string;
  salary: number;
  age: number;
}

function summarise(
  employees: Employee[],
): { totalSalary: number; youngest: string } {
  let totalSalary = 0;
  let youngest = employees[0];
  for (const emp of employees) {
    totalSalary += emp.salary;
    if (emp.age < youngest.age) youngest = emp;
  }
  return { totalSalary, youngest: youngest.name };
}
```

```typescript
// After: two focused loops, each with a single responsibility.
// Each can be extracted into a named function without carrying the other's state.
function summarise(
  employees: Employee[],
): { totalSalary: number; youngest: string } {
  let totalSalary = 0;
  for (const emp of employees) {
    totalSalary += emp.salary;
  }

  let youngest = employees[0];
  for (const emp of employees) {
    if (emp.age < youngest.age) youngest = emp;
  }

  return { totalSalary, youngest: youngest.name };
}
```

For any non-empty `employees` array, both versions produce the same
`{ totalSalary, youngest }`. The second loop iterates the same elements in the
same order with the same comparison, so `youngest` is identical.

---

## 8. Replace Loop with Pipeline

**Intent and motivation.** An imperative `for` loop that filters and transforms
data describes the mechanics of each step rather than the intent. Reading it
requires tracing the loop variable and any accumulator to reconstruct what the
loop produces. A pipeline of `filter`, `map`, and `reduce` calls expresses each
transformation as a named operation, making the data flow readable as a linear
sequence of declarative steps (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 8).

**Triggering signal.** A `for` loop consists of one or more `if` guards
selecting records, followed by projections or accumulations transforming or
summarising those records; the loop body has no side effects beyond building
the output; or the logic would read naturally as a series of pipeline
operations.

**Mechanics.**
1. Create a variable for the collection being iterated and assign it the loop's
   source.
2. For each behaviour in the loop, replace it with the appropriate pipeline
   method: an `if` guard becomes `filter`; a value projection becomes `map`; an
   accumulation becomes `reduce`.
3. Remove the original loop once the pipeline produces the same result.
4. Run the tests.

### Example

```typescript
// Before: imperative loop with a filter condition and a projection.
// The reader must trace `result` and the condition to understand the intent.
interface Author {
  name: string;
  twitter: string;
  office: string;
}

function twitterHandlesForIndia(authors: Author[]): string[] {
  const result: string[] = [];
  for (const author of authors) {
    if (author.office === "India") {
      result.push(author.twitter);
    }
  }
  return result;
}
```

```typescript
// After: pipeline expresses the same logic as two named operations.
function twitterHandlesForIndia(authors: Author[]): string[] {
  return authors
    .filter(author => author.office === "India")
    .map(author => author.twitter);
}
```

For any `authors` array, both versions return the same sequence of Twitter
handles in the same order. The pipeline reads as a declaration: keep authors
from India, then project to their Twitter handle.

---

## 9. Remove Dead Code

**Intent and motivation.** Code that can never be reached or is never called
carries a silent cost: readers spend time trying to understand it, tests may be
written for it, and refactorings must work around it. Modern version control
preserves every deleted line in history, so there is no risk of losing the code
permanently. Removing dead code makes the codebase smaller, clearer, and
cheaper to maintain (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 8).

**Triggering signal.** A function, method, variable, or conditional branch that
is never called or never reached; a branch whose condition can never be true
given the range of possible inputs; or code guarded by a flag that is always
`false`.

**Mechanics.**
1. If the dead code is not flagged by a compiler or linter, verify that it is
   truly unreachable: search all call sites and trace the conditions that guard
   it.
2. Delete the code.
3. Run the tests.

---

## 10. Sources

Martin Fowler (with Kent Beck), *Refactoring: Improving the Design of Existing
Code*, 2nd ed. (Addison-Wesley, 2018). Chapter 8: "Moving Features", pages
198-236. The mechanics in this file are condensed and paraphrased; they are not
the book text verbatim. Page numbers cited in the chapter cross-reference above
correspond to the first printing.

Web validation: chapter 8 move list confirmed against
https://refactoring.com/catalog/ and corroborated by the O'Reilly online edition
table of contents at https://www.oreilly.com/library/view/refactoring-improving-the/9780134757681/.
The inverse pair Move Statements into Function / Move Statements to Callers is
stated explicitly in Fowler's chapter 8 descriptions on refactoring.com.
