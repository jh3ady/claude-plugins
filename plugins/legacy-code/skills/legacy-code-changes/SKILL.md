---
name: legacy-code-changes
description:
  This skill should be used when working with existing untested code and applying Feathers' method for changing it safely: identifying where to make a change in unfamiliar code, breaking the change dilemma (you need tests to change safely, but the code resists testing), writing characterization tests to pin actual behaviour before touching it, finding seams and enabling points where you can alter behaviour without editing in that place, reasoning about how a change propagates through effect sketching, locating pinch points where many effects narrow to a small testable surface, and distinguishing sensing problems (you cannot observe what the code computes) from separation problems (you cannot get the code into a harness at all). Use it whenever the situation involves untested code that has to change, however it is phrased: "legacy code", "no tests around this", "afraid to change this", "where do I start with this change", "this code is too risky to touch", "I need to understand what this does before I change it", "edit and pray", or "I need to add a test before refactoring", even when Feathers is not named. For the catalogue of dependency-breaking techniques the algorithm's third step calls for, use the sibling skill `legacy-dependency-breaking`.
---

# Legacy Code Changes

Legacy code is code without tests. Feathers' working definition is blunt: a codebase can be well-written,
well-structured, and thoroughly readable, and still be legacy if it has no tests, because tests are what allow you to
change code confidently (Feathers, *Working Effectively with Legacy Code*, 2004). Age and style are beside the point.

This creates a dilemma: to change the code safely you need tests in place, but to get many classes under test you must
change the code first to break its dependencies. The resolution is deliberate sequencing. Make conservative, mechanical
changes to break dependencies and get tests in, then change behaviour with those tests as a safety net. The tests come
before the substantive changes, not after.

## The Legacy Code Change Algorithm

Feathers' five-step algorithm is the backbone of every safe change in untested code (Feathers 2004, Chapter 2):

1. **Identify change points.** Find exactly where in the code the change must go. Narrowing this first keeps the work
   bounded.
2. **Find test points.** Identify places where you can write tests that will detect whether the change does what you
   intend and whether it breaks anything else.
3. **Break dependencies.** Apply the mechanical techniques needed to get the code under test: extract an interface,
   introduce a seam, parameterize a constructor. The sibling skill `legacy-dependency-breaking` is the catalogue for
   this step.
4. **Write tests.** Write characterization tests to pin the current behaviour, then write tests for the intended change.
5. **Make changes and refactor.** Change the code under the safety net of the tests, then refactor with confidence.

Do not collapse these steps. Breaking dependencies before writing tests is not optional: the tests have nowhere to
attach otherwise.

## Seams and enabling points

A seam is a place where you can alter the behaviour of a program without editing in that place (Feathers 2004, Chapter
4). Every seam has an **enabling point**: the location where you decide which behaviour will be in effect, whether a
constructor argument, a configuration flag, a link step, or a preprocessor directive.

Feathers identifies three seam types:

- **Object seams** are the main ones in object-oriented code. Polymorphism makes them possible: pass in a different
  implementation through a constructor or method parameter, and the behaviour changes without touching the class under
  test. Most dependency-breaking work in OO code exploits object seams.
- **Link seams** arise in compiled languages where you can substitute an alternative library or object file at link
  time. The enabling point is the build configuration.
- **Preprocessing seams** use conditional compilation directives to substitute behaviour. The enabling point is the
  preprocessor symbol.

Object seams should be your first instinct. Link and preprocessing seams are available when object seams are not
accessible or would require changes too large to make safely.

## Characterization tests

A characterization test documents the behaviour the code actually has, not the behaviour it should have. Its purpose is
to pin that behaviour so you can change the code without accidentally changing something you did not intend to touch (
Feathers 2004, Chapter 13).

The discovery loop:

1. Write a test you expect to pass based on your reading of the code.
2. Run it. Let the failure (or unexpected pass) tell you what the code actually does.
3. Update the assertion to encode the observed value. The test now characterizes the real behaviour.

An important consequence: characterization tests pin bugs as well as correct behaviour. They document what the code
does, not what it should do. When a characterization test reveals an obvious defect, the right move is to note it (in a
comment or a ticket) and encode the current behaviour anyway, then fix the bug through the standard change algorithm
with its own tests. Silently fixing bugs inside characterization tests destroys the signal that you are pinning, not
correcting.

## Reasoning about effects

Before changing a line of code, reason about how that change can propagate. **Effect sketching** is the practice of
tracing the chain: this field changes, which affects that return value, which the caller reads, and so on (Feathers
2004, Chapter 11). Sketching the effect chain before writing tests tells you which behaviours are actually at
risk.

**Pinch points** are narrow places in the effect chain where many effects funnel through a small interface (Feathers
2004, Chapter 11). A pinch point is a good place to write tests: one test there covers a wide arc of the behaviour
behind it.

Two reasons to break a dependency (Feathers 2004, Chapter 3):

- **Sensing:** you cannot access the values the code computes. The code does the work but you have no way to observe the
  result in a test.
- **Separation:** you cannot get the code into a test harness at all. The class instantiates something heavy, calls out
  to a database, or requires global state you cannot replicate.

Identifying which problem you face determines which breaking technique to reach for. Most techniques target one or the
other, though some address both.

## When time is short

When you must make a change and have little time to get existing code under test, prefer adding new tested code beside
the old over editing tangled untested code in place (Feathers 2004, Chapter 6).

The two lowest-risk moves are **Sprout** and **Wrap**: sprout a new method or class for the new behaviour, tested in
isolation; wrap the existing method to intercept calls, attaching your tested logic before or after. Both allow you to
write tests for your new code without needing to get the existing code under test first.

For the full technique catalogue, see the sibling skill `legacy-dependency-breaking`.

## Guardrails

- **Change surgically, not wholesale.** The impulse to rewrite is strong when the code is ugly. Resist it until the code
  is under test. A rewrite without tests is a leap of faith; a rewrite with characterization tests in place is a
  refactor.
- **Characterization tests pin behaviour, including bugs.** Do not silently fix defects while writing them. Document the
  anomaly separately and fix it through the algorithm with its own dedicated tests.
- **Do not apply the algorithm to already-tested code.** If a slice is already under test and is straightforward CRUD,
  the full five-step ceremony adds friction without benefit. Reserve it for the untested code that actually needs it.
- **Do not characterize code you are about to delete, or behaviour you are not touching.** Write tests for what you are
  changing and what is adjacent to it; let the rest be. Pinning behaviour you will remove, or that the change cannot
  reach, is wasted ceremony.
- **Keep dependency-breaking changes mechanical and minimal.** Their sole purpose is to create a seam. They should not
  change observable behaviour; verify that with the tests you write in step four.
- **Do not skip the refactor step.** Getting the code under test is not the end goal. The safety net exists so you can
  improve the design. Stopping after green leaves the code in a state that was barely testable by construction.

## Relationship to other skills

- **`legacy-dependency-breaking`**: the catalogue of techniques for step three of the algorithm (break dependencies).
  When you know you face a sensing or separation problem, that skill gives you the specific moves. This skill is the
  method; that one is the toolbox.
- **`test-driven-development`**: characterization tests are a case of the same discipline applied in reverse (observe
  first, then encode), and once code is under test the standard red-green-refactor cycle resumes. The two skills
  compose: this one covers getting into the harness, the TDD skill covers what to do once you are there.
- **`testing-strategy`**: characterization tests are the entry point when adding tests to untested code;
  `testing-strategy` frames where they sit in the wider portfolio.
- **`clean-code`** and **`simplicity-principles`**: the refactor step in the algorithm is where these apply. Getting
  code under test does not mean leaving it as found; the safety net is the licence to improve names, reduce duplication,
  and simplify structure.

## Adapt to your context

This skill stays generic on purpose. Your codebase will have its own conventions for where seams live, which
dependency-breaking techniques your team has agreed on, and how characterization tests are organized alongside the rest
of the test suite. Declare those in your own `CLAUDE.md` or a higher-priority skill, which overrides this baseline. This
skill does not impose them.

## Reference

For a worked example of the full five-step algorithm on a realistic class, annotated characterization-test sequences,
effect-sketching diagrams, a decision guide for sensing versus separation, and extended notes on each seam type, read
`references/legacy-code-changes.md`.
