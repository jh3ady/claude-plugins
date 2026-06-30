# Refactoring Method: Reference

Deeper background for the `refactoring-method` skill. The skill body holds the
working rules; this file holds the canonical definitions, the worked example from
Chapter 1 of *Refactoring* (2nd ed., 2018), the extended two-hats analysis, and
the full when-to-refactor taxonomy, with sources.

## Table of contents

1. [The test net as prerequisite](#1-the-test-net-as-prerequisite)
2. [Chapter 1 worked example: theatrical players](#2-chapter-1-worked-example-theatrical-players)
3. [Step-by-step refactoring sequence](#3-step-by-step-refactoring-sequence)
4. [The two hats: extended notes](#4-the-two-hats-extended-notes)
5. [When to refactor: full taxonomy](#5-when-to-refactor-full-taxonomy)
6. [Sources](#6-sources)

---

## 1. The test net as prerequisite

Fowler is explicit: before refactoring any piece of code, you need a solid suite
of tests covering that code (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 2).
The tests are not a nice-to-have; they are the mechanism by which each small step
is verified safe.

The discipline is:

1. Run the full test suite; all tests pass (green bar before you start).
2. Make one small structural change.
3. Run the test suite again. If it is still green, the step was safe.
4. If any test fails, undo the step immediately and diagnose before proceeding.

This rhythm, applied consistently, means that at every point in the refactoring
sequence the code is in a known working state. There is never a window of
"broken for a while while I reorganise things." The worked example below
demonstrates this at each step.

If the code you want to refactor lacks tests, apply the `legacy-code` skill
first. That skill covers how to get untested code under a characterization test
net via seams and enabling points. Return to the refactoring sequence here once
the bar is green.

---

## 2. Chapter 1 worked example: theatrical players

Fowler opens the book with a theatrical players billing system
(Fowler, *Refactoring*, 2nd ed., 2018, Chapter 1). A theatre company records which plays it
performed and how large each audience was. The billing function produces a
statement showing the charge for each performance and the total volume credits
earned.

### Data structures

```typescript
type PlayType = "tragedy" | "comedy";

interface Play {
    name: string;
    type: PlayType;
}

interface Performance {
    playId: string;
    audience: number;
}

interface Invoice {
    customer: string;
    performances: Performance[];
}
```

### Starting point

The initial implementation is a single function doing everything: iterating
over performances, calculating amounts per play type, accumulating credits, and
formatting the output all in one place.

```typescript
// Starting point: a single function mixing three concerns.
// Based on Fowler, Refactoring, 2nd ed., 2018, Chapter 1.
function statement(invoice: Invoice, plays: Map<string, Play>): string {
    let totalAmount = 0;
    let volumeCredits = 0;
    let result = `Statement for ${invoice.customer}\n`;

    for (const perf of invoice.performances) {
        const play = plays.get(perf.playId)!;
        let thisAmount = 0;

        switch (play.type) {
            case "tragedy":
                thisAmount = 40000;
                if (perf.audience > 30) thisAmount += 1000 * (perf.audience - 30);
                break;
            case "comedy":
                thisAmount = 30000;
                if (perf.audience > 20) thisAmount += 10000 + 500 * (perf.audience - 20);
                thisAmount += 300 * perf.audience;
                break;
            default:
                throw new Error(`unknown type: ${play.type}`);
        }

        volumeCredits += Math.max(perf.audience - 30, 0);
        if (play.type === "comedy") volumeCredits += Math.floor(perf.audience / 5);

        result += `  ${play.name}: ${(thisAmount / 100).toFixed(2)} (${perf.audience} seats)\n`;
        totalAmount += thisAmount;
    }

    result += `Amount owed is ${(totalAmount / 100).toFixed(2)}\n`;
    result += `You earned ${volumeCredits} credits\n`;
    return result;
}
```

Three concerns are entangled: amount calculation per play type, volume credit
calculation, and string formatting. Adding HTML output or a new play type means
editing this function with no natural seam between its responsibilities.

### Test net before the first step

Before touching anything, lock in the current behaviour.

```typescript
// test/statement.test.ts
import {statement} from "../src/statement";

const plays: Map<string, Play> = new Map([
    ["hamlet", {name: "Hamlet", type: "tragedy"}],
    ["asYouLikeIt", {name: "As You Like It", type: "comedy"}],
    ["othello", {name: "Othello", type: "tragedy"}],
]);

const invoice: Invoice = {
    customer: "BigCo",
    performances: [
        {playId: "hamlet", audience: 55},
        {playId: "asYouLikeIt", audience: 35},
        {playId: "othello", audience: 40},
    ],
};

test("statement produces the correct plain text output", () => {
    expect(statement(invoice, plays)).toBe(
        "Statement for BigCo\n" +
        "  Hamlet: 650.00 (55 seats)\n" +
        "  As You Like It: 580.00 (35 seats)\n" +
        "  Othello: 500.00 (40 seats)\n" +
        "Amount owed is 1730.00\n" +
        "You earned 47 credits\n",
    );
});
```

This test passes before any refactoring. It pins the observable output. Every
step in the sequence below must leave this test green.

---

## 3. Step-by-step refactoring sequence

### Step 1: Extract Function: amountFor

The switch statement calculates the amount for one performance. It is a
well-bounded piece of logic with a clear name: `amountFor`. Extracting it to its
own function is the first move (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 1).

```typescript
function amountFor(performance: Performance, play: Play): number {
    let result = 0;
    switch (play.type) {
        case "tragedy":
            result = 40000;
            if (performance.audience > 30) result += 1000 * (performance.audience - 30);
            break;
        case "comedy":
            result = 30000;
            if (performance.audience > 20) result += 10000 + 500 * (performance.audience - 20);
            result += 300 * performance.audience;
            break;
        default:
            throw new Error(`unknown type: ${play.type}`);
    }
    return result;
}

function statement(invoice: Invoice, plays: Map<string, Play>): string {
    let totalAmount = 0;
    let volumeCredits = 0;
    let result = `Statement for ${invoice.customer}\n`;

    for (const perf of invoice.performances) {
        const play = plays.get(perf.playId)!;
        // thisAmount replaced by a direct call to the extracted function
        const thisAmount = amountFor(perf, play);

        volumeCredits += Math.max(perf.audience - 30, 0);
        if (play.type === "comedy") volumeCredits += Math.floor(perf.audience / 5);

        result += `  ${play.name}: ${(thisAmount / 100).toFixed(2)} (${perf.audience} seats)\n`;
        totalAmount += thisAmount;
    }

    result += `Amount owed is ${(totalAmount / 100).toFixed(2)}\n`;
    result += `You earned ${volumeCredits} credits\n`;
    return result;
}
```

Run the test. Still green. The behaviour is unchanged; the structure is clearer.

Note on variable naming in `amountFor`: the local result variable is now named
`result` rather than `thisAmount`. This is a rename (another distinct refactoring)
applied as part of the extraction. Fowler renames immediately after extracting
because the new function's variables deserve names that describe their role in
the extracted context, not in the original one.

### Step 2: Extract Function: playFor and Inline Variable

The `play` local variable inside the loop is a temporary that can be derived on
demand. Extract a function to look up the play, then inline the variable. This
removes a mutable temporary that had to be kept in sync with `perf`.

```typescript
function playFor(performance: Performance, plays: Map<string, Play>): Play {
    return plays.get(performance.playId)!;
}

// In the loop, replace `const play = plays.get(perf.playId)!` with inline calls.
// The Inline Variable refactoring removes the local `play` and uses playFor(perf, plays).
```

After inlining, `amountFor` and the credits calculation both call `playFor`
directly. The function is called twice per iteration, which looks inefficient,
but Fowler's point stands: premature optimisation of structure-for-performance
is a distraction from correctness. Measure before optimising.

Run the test. Still green.

### Step 3: Extract Function: volumeCreditsFor

The credits calculation inside the loop is a second well-bounded concern.

```typescript
function volumeCreditsFor(performance: Performance, plays: Map<string, Play>): number {
    let result = Math.max(performance.audience - 30, 0);
    if (playFor(performance, plays).type === "comedy") {
        result += Math.floor(performance.audience / 5);
    }
    return result;
}
```

Replace the two lines inside the loop with `volumeCreditsFor(perf, plays)`.

Run the test. Still green.

### Step 4: Replace Temp with Query: totalVolumeCredits

The accumulator `volumeCredits` in the loop body can be replaced by a query
function that computes the total after the loop. This removes a mutable variable
from the main function and makes the final-state meaning explicit.

```typescript
function totalVolumeCredits(invoice: Invoice, plays: Map<string, Play>): number {
    return invoice.performances.reduce(
        (total, perf) => total + volumeCreditsFor(perf, plays),
        0,
    );
}

// totalAmount gets the same treatment:
function totalAmount(invoice: Invoice, plays: Map<string, Play>): number {
    return invoice.performances.reduce(
        (total, perf) => total + amountFor(perf, playFor(perf, plays)),
        0,
    );
}
```

The main loop now only builds the line-by-line portion of the result. The two
accumulator temporaries are gone.

Run the test. Still green.

### Step 5: Split Phase: separate calculation from rendering

The final structural move is to separate the concern of enriching the data
(calculating amounts and credits per performance) from the concern of rendering
it as text. Fowler introduces an intermediate data structure
(Fowler, *Refactoring*, 2nd ed., 2018, Chapter 1).

```typescript
interface StatementData {
    customer: string;
    performances: EnrichedPerformance[];
    totalAmount: number;
    totalVolumeCredits: number;
}

interface EnrichedPerformance extends Performance {
    play: Play;
    amount: number;
    volumeCredits: number;
}

function createStatementData(
    invoice: Invoice,
    plays: Map<string, Play>,
): StatementData {
    const enrichedPerformances = invoice.performances.map((perf) => {
        const play = playFor(perf, plays);
        return {
            ...perf,
            play,
            amount: amountFor(perf, play),
            volumeCredits: volumeCreditsFor(perf, plays),
        };
    });

    return {
        customer: invoice.customer,
        performances: enrichedPerformances,
        totalAmount: enrichedPerformances.reduce((t, p) => t + p.amount, 0),
        totalVolumeCredits: enrichedPerformances.reduce((t, p) => t + p.volumeCredits, 0),
    };
}

function renderPlainText(data: StatementData): string {
    let result = `Statement for ${data.customer}\n`;
    for (const perf of data.performances) {
        result += `  ${perf.play.name}: ${(perf.amount / 100).toFixed(2)} (${perf.audience} seats)\n`;
    }
    result += `Amount owed is ${(data.totalAmount / 100).toFixed(2)}\n`;
    result += `You earned ${data.totalVolumeCredits} credits\n`;
    return result;
}

function statement(invoice: Invoice, plays: Map<string, Play>): string {
    return renderPlainText(createStatementData(invoice, plays));
}
```

Run the test. Still green.

Now adding an HTML renderer requires only a new `renderHtml(data: StatementData)`
function: the calculation logic in `createStatementData` is shared without
duplication.

```typescript
function renderHtml(data: StatementData): string {
    let result = `<h1>Statement for ${data.customer}</h1>\n<table>\n`;
    for (const perf of data.performances) {
        result += `  <tr><td>${perf.play.name}</td><td>${(perf.amount / 100).toFixed(2)}</td></tr>\n`;
    }
    result += `</table>\n`;
    result += `<p>Amount owed is <em>${(data.totalAmount / 100).toFixed(2)}</em></p>\n`;
    result += `<p>You earned <em>${data.totalVolumeCredits}</em> credits</p>\n`;
    return result;
}

function htmlStatement(invoice: Invoice, plays: Map<string, Play>): string {
    return renderHtml(createStatementData(invoice, plays));
}
```

Each step in this sequence was a single named refactoring. No step changed the
observable output. The test suite remained green throughout.

---

## 4. The two hats: extended notes

The metaphor is Kent Beck's (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 2). Wear one hat
at a time, never both simultaneously.

### The adding-function hat

Under this hat you are changing what the code does:

- Existing tests stay green throughout; you add new tests for the intended behaviour, which fail until the feature is
  implemented.
- You are enlarging the surface of the system.

### The refactoring hat

Under this hat you are changing how the code expresses what it already does:

- You write no new tests (the existing tests already cover the behaviour).
- Every existing test must pass after every step.
- You are shrinking the surface required to understand the code.

### Why the distinction matters

Mixing the two hats in a single step obscures which type of change caused any
test failure. A failing test after a combined structural-plus-behavioural change
could point to either kind of change. You must undo everything and start over
to isolate the problem. Keeping the hats separate means a failing test always
points to the most recent single action, which is immediately reversible.

### Practical hat-switching

In practice, hats change frequently within a session. A common sequence:

1. Refactoring hat: clean up the area you are about to work in so the new
   feature is easy to add (preparatory refactoring).
2. Adding-function hat: write the new test, then the new code.
3. Refactoring hat: clean up anything the new code introduced.

The key is knowing which hat you are wearing at each moment and being deliberate
about switching. "I am now changing the structure of this function" is a
different mental mode from "I am now making the code do something new."

---

## 5. When to refactor: full taxonomy

Based on Fowler, *Refactoring*, 2nd ed., 2018, Chapter 2, and the accompanying article at
https://martinfowler.com/articles/workflowsOfRefactoring/

### Opportunistic refactoring (the default)

Most refactoring should arise naturally during other work, not be scheduled
separately. If a team is doing refactoring well, the need for large planned
sessions becomes infrequent.

**Preparatory refactoring** happens when adding a feature would be hard in the
current structure. The right first move is to refactor the structure to make the
feature easy to add, then add the feature. Fowler: "The best time to refactor is
just before I add a new feature." The refactoring is justified by the feature
work it enables, not as an end in itself.

**Comprehension refactoring** happens when understanding a piece of code takes
real effort. As you figure out what the code does, move that understanding into
the code itself: rename a confusingly named variable, extract a function with a
name that explains its purpose, clarify a complex condition. The next reader
gets the benefit of your work rather than having to reconstruct it from scratch.

**Litter-pickup refactoring** follows the camp-site rule: leave the code a little
better than you found it. If you encounter something messy while working on
something adjacent, and fixing it takes a minute, fix it now. If it takes longer,
note it and come back. The accumulation of small improvements keeps the codebase
from drifting into a state that requires a large planned session to repair.

### Planned refactoring

Planned refactoring is appropriate when an area is so entangled that opportunistic
moves cannot make a dent. Keep planned sessions bounded: a clear scope, a time
limit, and a specific target state. A team doing opportunistic refactoring
consistently rarely needs large planned sessions.

### Long-term refactoring

Large architectural changes (moving a subsystem across a boundary, splitting a
module that has grown too large, adopting a new abstraction across many call
sites) take weeks or months. The key constraint is that the code must remain
deployable throughout. Techniques such as Branch by Abstraction allow the new
structure to grow in parallel with the old, with a flag controlling which is
live, until the old structure can be removed safely.

### The rule of three (Don Roberts)

The first time you do something, just do it. The second time you do something
similar, do it but notice the duplication. The third time you do something
similar, refactor (Fowler, *Refactoring*, 2nd ed., 2018, Chapter 2). The rule gives permission
to duplicate once, on the expectation that the pattern must appear three times
before it is worth generalising. This keeps premature abstraction in check.

### When not to refactor

- Code you are about to delete. Refactoring it first is pure waste.
- Code you are not touching. Opportunistic refactoring applies when you are in
  the neighbourhood; it does not require seeking out unrelated code to improve.
- Under a hard deadline. Defer and record the debt explicitly. A
  half-refactored function is harder to read than the original.

---

## 6. Sources

- Martin Fowler (with Kent Beck), *Refactoring: Improving the Design of Existing
  Code* (2nd ed., Addison-Wesley, 2018): the primary source for all content in
  this file. Chapter 1 for the theatrical-players worked example and the
  Extract Function, Inline Variable, and Split Phase moves; Chapter 2 for the
  definition of refactoring (noun and verb), the two hats, why to refactor,
  the Design Stamina Hypothesis, the rule of three, and the when-to-refactor
  categories; Chapter 3 (Beck and Fowler) for the bad-smells catalogue
  referenced by the sibling skill `code-smells`.
- Martin Fowler, "Workflows of Refactoring" (essay),
  https://martinfowler.com/articles/workflowsOfRefactoring/, the canonical
  taxonomy of refactoring workflows (preparatory, comprehension, litter-pickup,
  TDD, planned, long-term) that Chapter 2 of the book summarises.
- Martin Fowler, "Design Stamina Hypothesis" (bliki),
  https://martinfowler.com/bliki/DesignStaminaHypothesis.html, the full
  argument for why good design sustains productivity over time, including the
  design payoff line concept.
- Martin Fowler, "An Example of Preparatory Refactoring" (article),
  https://martinfowler.com/articles/preparatory-refactoring-example.html,
  a concrete illustration of refactoring before adding a feature.
- Emily Bache, "Theatrical Players Refactoring Kata" (GitHub),
  https://github.com/emilybache/Theatrical-Players-Refactoring-Kata,
  the chapter 1 example ported to many languages, including TypeScript, useful
  for hands-on practice.
