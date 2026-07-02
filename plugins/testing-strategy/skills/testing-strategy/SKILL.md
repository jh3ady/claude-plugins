---
name: testing-strategy
description: This skill should be used when deciding the shape and balance of an automated test suite, choosing at which level to test something, weighing unit against integration against end-to-end tests, judging a test pyramid or testing trophy or an inverted ice-cream cone, placing consumer-driven contract tests in the portfolio, reading or setting a coverage target, or dealing with flaky tests, applying testing strategy even when "testing strategy" is not named. Covers the portfolio idea, the shapes (pyramid, practical test pyramid, trophy, ice-cream cone), the tiers (unit, integration, contract, end-to-end, acceptance), the size-versus-scope distinction from Software Engineering at Google, consumer-driven contract testing, coverage as a signal rather than a target, and flaky tests, with TypeScript specifics. This is the macro outer loop: it defers the inner red-green-refactor loop and the test-double ladder to test-driven-development.
---

# Testing Strategy

A test suite is a portfolio: tests of different granularity and cost, held
together because each buys a different kind of confidence. The strategy question
is not "did we test this?" but "how many tests of each kind, at which level do we
test what, and what signal must the suite give as a whole?". A good answer is
fast, deterministic, and cheap to keep green as the code changes.

This is the macro view, the outer loop. It decides the shape of the whole suite
and where each test belongs. The inner red-green-refactor loop that produces the
individual behaviour tests, and the test-double ladder that keeps them fast,
belong to `test-driven-development`; this skill sits above that loop and does not
re-teach it.

## The portfolio idea

Group your tests by granularity (how much they exercise) and cost (how long they
take, how often they break for the wrong reason). Then balance the mix for return
on investment: many cheap, fast, narrow tests that pinpoint a fault, far fewer
slow, broad tests that prove the wiring holds. A suite dominated by cheap tests
runs in seconds, gives a precise failure location, and survives refactoring;
a suite dominated by broad tests is slow, flaky, and vague about what broke. The
whole strategy is a search for that balance, not a rule about any single test.

## The shapes

Several shapes name the same underlying trade-off between confidence and cost.

- **The pyramid** (Mike Cohn, *Succeeding with Agile*, 2009): many unit tests at
  the base, fewer service tests in the middle, fewest user-interface tests at the
  top. The point of the taper is that broad user-interface tests are "brittle,
  expensive to write, and time consuming", so they stay a minority.
- **The practical test pyramid** (Ham Vocke, on Martin Fowler's site): the value
  is in thinking about categories of test and their trade-offs, not in arguing a
  canonical definition of "unit". Keep the shape, drop the pedantry about labels.
- **The testing trophy** (Kent C. Dodds, 2018): static checks, unit, integration,
  and end-to-end, weighted towards integration for JavaScript applications where
  units are thin. Its guiding line is that "the more your tests resemble the way
  your software is used, the more confidence they can give you".
- **The ice-cream cone** (Alister Scott): the anti-pattern, the pyramid inverted.
  Mostly manual and user-interface tests, few unit tests. It is slow to run,
  brittle under change, and pushes verification to the most expensive tier, so
  feedback arrives late and the suite is distrusted.

The honeycomb and the cupcake are further variations on the same trade-off; they
are deferred to the reference.

## The tiers

- **Unit**: one behaviour through its public surface. Cheapest and fastest,
  pinpoints faults, but proves nothing about wiring across components.
- **Integration**: a component against a real collaborator (a database, a real
  adapter). Buys confidence that the seam holds; costs setup and speed.
- **Contract**: pins the agreement at a boundary so two sides can evolve
  independently. Buys freedom from slow cross-boundary tests; costs a shared
  artifact to maintain.
- **End-to-end**: the whole system through its real entry point. Buys the highest
  realism; costs the most time and the most flakiness, so keep it a minority.
- **Acceptance**: expresses a business rule in the language of the domain. Buys a
  shared, readable definition of done; costs collaboration to keep honest.

## Size versus scope

*Software Engineering at Google* separates two independent axes. **Size** is how
a test runs and what resources it may touch (one process, one machine, or the
network). **Scope** is how much code it actually exercises (one function, a
module, or the whole system). The two are independent: a broad-scoped test that
drives an endpoint end to end can still be **small** if it doubles out its
out-of-process dependencies, and a narrow-scoped test can be large if it insists
on a real database. Choose size and scope deliberately, and optimise the suite
for speed and determinism rather than for how many components a test happens to
touch.

## Guiding heuristics

- Push each test to the cheapest tier that still gives the confidence you need.
  Do not test at a broad tier what a narrow one already proves.
- Treat higher tiers as a second line of defence (Fowler): they catch the wiring
  and integration faults the lower tiers cannot see, not the logic the lower
  tiers already cover.
- Avoid redundant coverage across tiers. The same rule verified at three levels
  triples the maintenance and the flakiness for no extra confidence.
- Let tests resemble real usage (Dodds): the closer a test sits to how the
  software is actually used, the more the confidence it gives you is real.

## Coverage is a signal, not a target

Coverage is a diagnostic, not a grade. Fowler frames it as "a useful tool for
finding untested parts of a codebase" but "of little use as a numeric statement
of how good your tests are": high coverage says lines were executed, not that
their behaviour was asserted. The moment a coverage percentage becomes a target
it stops measuring anything, which is Goodhart's law: "when a measure becomes a
target, it ceases to be a good measure". Read coverage to find the gaps worth
testing; never grade the suite by it or gate a build on a number.

## Flaky tests

A test that passes and fails without any change in the code is worse than no
test, because it erodes trust in the whole suite: once a red is assumed to be
noise, real failures are ignored too. Do not rerun until green as a policy. When
a test turns flaky, quarantine it out of the signal path and fix the root cause
(shared state, real time, order dependence, a live network), or delete it. Never
leave it flickering in the main suite.

## Guardrails

- **Do not invert the pyramid.** The ice-cream cone (mostly manual and
  user-interface tests) is slow, brittle, and gives late feedback.
- **Do not test everything through the user interface.** Drive logic at the
  cheapest tier that proves it; reserve the top tier for a few critical paths.
- **Do not treat coverage as a target.** Use it to find gaps, not to grade the
  suite or gate the build.
- **Do not duplicate a behaviour across tiers.** The same rule checked at three
  levels multiplies cost and flakiness for no added confidence.

## Relationship to other skills

- **`test-driven-development`**: the inner loop this skill sits above.
  Red-green-refactor, testing behaviour through the public API, and the
  test-double ladder (real object, then in-memory implementation, then stub, then
  mock), including the in-memory contract test that keeps a double faithful, all
  live there. This skill decides the portfolio those tests form.
- **`hexagonal-architecture`**: the ports it defines are the seams integration
  tests cross; an integration test exercises a real adapter against real
  infrastructure. This skill decides how many such tests to keep relative to unit
  and end-to-end tests.
- **`legacy-code`**: characterization tests are the entry point when adding tests
  to untested code; this skill frames where they sit in the wider portfolio.
- **`refactoring`**: self-testing code is the prerequisite that makes any strategy
  possible; this skill decides the shape and balance of that test suite.
- **`domain-driven-design`**: acceptance tests express the ubiquitous language at
  the outer tier of the portfolio. A future behaviour-driven-development plugin
  could own acceptance and Gherkin in depth.

## Adapt to your context

This skill is a baseline, not dogma. The right shape depends on the system: a
thin front end leans towards the trophy, a service with rich domain logic towards
the pyramid. Layer your own decisions on top: your test runner and coverage
tooling, exactly where you draw the line between a unit and an integration test,
and any target you are held to. Declare those in your own `CLAUDE.md` or a
higher-priority skill, which overrides this baseline. This skill does not impose
them.

## Reference

For the sourcing and history of the shapes, the full tier taxonomy, the
size-versus-scope table, the pyramid-versus-trophy analysis, consumer-driven
contract testing and its shared-name pitfall, the coverage detail, flaky-test
handling, and a worked TypeScript walkthrough placing one feature across the
tiers, read `references/testing-strategy.md`.
