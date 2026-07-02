# Testing strategy plugin: design

- Date: 2026-07-02
- Status: approved (design), spec under review
- Author: Jean-Denis VIDOT

## Context and goal

The `jh3ady-claude-plugins` marketplace ships a consistent family of
engineering-principle plugins (`commit-conventions`, `review-conventions`,
`solid-principles`, `simplicity-principles`, `clean-code`, `simple-design`,
`object-calisthenics`, `modular-monolith`, `dependency-injection`,
`hexagonal-architecture`, `domain-driven-design`, `event-sourcing`, `cqrs`,
`screaming-architecture`, `test-driven-development`, `legacy-code`,
`refactoring`, `design-patterns`). They share one pattern: a generic,
composable skill presented as a pragmatic baseline rather than a dogma, with a
lean `SKILL.md`, depth pushed into `references/`, and adjacent concepts
cross-referenced rather than absorbed.

This work adds one plugin: `testing-strategy`. It covers the macro view of an
automated test suite: how many tests of each granularity to keep, at which
level to test what, and what signal a suite must give. It is the outer loop
that sits above `test-driven-development`, which owns the inner
red-green-refactor loop and already gestures at the test pyramid and testing
trophy without owning them.

The central thesis: `test-driven-development` owns the inner loop (a failing
test first, the test-double ladder, in-memory contract tests) and stays at the
level of a single behaviour or module. `testing-strategy` owns the portfolio:
the shapes (pyramid, trophy, ice-cream cone), the tiers (unit, integration,
contract, end-to-end, acceptance), the size-versus-scope distinction, coverage
as a signal rather than a target, flaky tests, and consumer-driven contract
testing as a portfolio decision. Neither re-teaches the other; they
cross-reference.

## Scope

One plugin, `testing-strategy`, bundling a single skill `testing-strategy`.

A single skill, not several. The portfolio view is one coherent activity
(deciding the shape and balance of a test suite), not a set of distinct
triggers. One skill carries the macro decision procedure; supporting detail,
sourcing, and worked examples live in `references/`. Skill-only, no command or
hook, consistent with `simplicity-principles`, `solid-principles`, and
`simple-design`.

### Boundary (focused, with references out)

In scope:

- The macro frame in `SKILL.md`: the portfolio idea (group tests by
  granularity and cost, balance return on investment); the shapes (pyramid,
  practical test pyramid, testing trophy, the ice-cream cone anti-pattern, a
  one-line nod to honeycomb and cupcake); the tiers (unit, integration,
  contract, end-to-end, acceptance) with what each buys and costs; the
  size-versus-scope distinction; the guiding heuristics (push each test to the
  cheapest tier that gives confidence, higher tiers as a second line of
  defence, avoid redundant coverage across tiers, tests should resemble real
  usage); coverage as a signal rather than a target; flaky tests and
  determinism; guardrails; a relationship-to-other-skills section; an "Adapt to
  your context" section; and a pointer to the reference.
- In `references/testing-strategy.md`: the history and sourcing of each shape;
  the full tier taxonomy defined precisely; a size-versus-scope table with
  Google's small/medium/large constraints; the pyramid-versus-trophy debate
  treated fairly; consumer-driven contract testing (Pact-style) placed in the
  portfolio and held distinct from the in-memory contract tests owned by TDD;
  the coverage section (Fowler, Goodhart's law); flaky tests, isolation, and
  determinism; one worked decision walkthrough in TypeScript (for a given
  feature, where its tests land across tiers); and trade-off notes with
  cross-references.

Ownership by territory (the key boundary rule): `testing-strategy` owns the
**macro portfolio**; `test-driven-development` remains the source of truth for
the inner loop and the test-double ladder.

- **Inner loop, red-green-refactor, the test-double ladder, in-memory contract
  tests** to `test-driven-development`. TDD gains a reciprocal reference to
  `testing-strategy` from its "Scope: TDD is the inner loop" section.
- **Integration tests against real adapters** cross-reference
  `hexagonal-architecture` (the ports are the seams; integration tests exercise
  a real adapter against real infrastructure).
- **Characterization tests as an entry point on untested code** cross-reference
  `legacy-code`.
- **Self-testing code as a prerequisite** cross-reference `refactoring`.
- **Acceptance tests expressing the ubiquitous language** cross-reference
  `domain-driven-design`, with a note that a future BDD plugin could own
  acceptance and Gherkin in depth. `testing-strategy` mentions acceptance as a
  tier and references out; it does not own BDD.

Explicitly out of scope:

- The inner red-green-refactor loop and the test-double ladder in depth (owned
  by `test-driven-development`).
- Test tooling: runners, assertion libraries, coverage tool configuration,
  fixture and builder helpers, suite parallelisation.
- The CI/CD pipeline and where the suite runs (reserved for a future
  continuous-delivery plugin).
- BDD, Gherkin, and specification by example in depth (reserved for a future
  BDD plugin; referenced only).

## Key decisions

- **One plugin, one skill** named `testing-strategy`. Skill-only, no command or
  hook.
- **Macro first.** The centre of gravity is the portfolio decision: the shape
  of the suite, the tiers, size versus scope, coverage as a signal, flaky
  tests. The inner loop is deliberately left to TDD and referenced, not
  re-explained.
- **Shapes sourced, not asserted.** The pyramid is attributed to Mike Cohn
  (*Succeeding with Agile*, 2009, where it is the "test automation pyramid",
  originally sketched with Lisa Crispin around 2003-4, and independently
  arrived at by others); the practical test pyramid to Ham Vocke on Martin
  Fowler's site; the testing trophy to Kent C. Dodds (2018, Assert(js), building
  on a tweet by Guillermo Rauch); the ice-cream cone anti-pattern to Alister
  Scott (WatirMelon). Sourcing caveat: no invented verbatim quotations or page
  numbers beyond the short, verifiable phrasings gathered during research.
- **Size versus scope taken from Google.** *Software Engineering at Google*
  distinguishes a test's size (how it runs, what it may do, resources consumed:
  small, medium, large) from its scope (how much code it exercises: narrow,
  medium, broad). The key insight is that Google optimises for speed and
  determinism regardless of scope, and that a broad-scoped test can still be
  small when it uses doubles for out-of-process dependencies. The reference
  gives the small/medium/large constraints.
- **Pyramid versus trophy treated fairly.** Both agree the end-to-end tier
  stays a small minority. The trophy rebalances towards integration for
  JavaScript front-end applications ("write tests, not too many, mostly
  integration"); the classical pyramid keeps unit tests as the broad base. The
  skill presents this as context-dependent, not a winner, and notes that
  classical sociable tests already sit between the two.
- **Contract testing: both meanings, clearly separated.** The in-memory
  contract test (one suite run against a real and an in-memory implementation
  to keep the double faithful) stays owned by TDD. Consumer-driven contract
  testing between deployed services (Pact-style: the consumer generates a
  contract, replayed against the real provider in the provider's build) is a
  portfolio decision and is owned here, framed as a way to replace slow,
  brittle cross-service end-to-end tests with fast, deterministic ones. The
  reference states plainly that the two share a name and solve different
  problems.
- **Coverage as a signal.** Following Fowler, coverage is a useful tool for
  finding untested code but of little use as a numeric statement of test
  quality; a coverage target is a textbook instance of Goodhart's law ("when a
  measure becomes a target, it ceases to be a good measure"). The skill states
  this and refuses coverage-as-target.
- **Examples in TypeScript only.** Consistent with the family.

## Plugin structure

Mirrors the existing plugins, with a single skill:

```
plugins/testing-strategy/
  .claude-plugin/plugin.json      # name, version 0.1.0, author, MIT license, homepage, keywords
  README.md                       # covers the skill
  LICENSE                         # MIT
  skills/testing-strategy/
    SKILL.md                      # lean macro core: the portfolio decision
    references/
      testing-strategy.md         # shapes, tiers, size vs scope, contract testing, coverage, flaky, worked example
```

Writing conventions for all generated files: English, no em-dashes, words
written in full (standard acronyms such as TDD, CI, UI, ROI are fine).

## Plugin contents

### `testing-strategy/SKILL.md` (lean macro core)

- Frontmatter: `name` plus a trigger-oriented `description` (deciding the shape
  or balance of a test suite; choosing at which level to test something;
  weighing unit against integration against end-to-end; judging a test pyramid,
  testing trophy, or an inverted ice-cream cone; placing consumer-driven
  contract tests; reading or setting a coverage target; dealing with flaky
  tests; even when "testing strategy" is not named).
- **The portfolio idea**: group tests by granularity and cost, balance return
  on investment.
- **The shapes**: pyramid, practical test pyramid, testing trophy, the
  ice-cream cone anti-pattern, with a one-line nod to honeycomb and cupcake,
  each sourced.
- **The tiers**: unit, integration, contract, end-to-end, acceptance, one line
  each on what it buys and what it costs.
- **Size versus scope**: the Google distinction, optimise for speed and
  determinism.
- **Guiding heuristics**: cheapest tier that gives confidence; higher tiers as a
  second line of defence; no redundant coverage across tiers; tests should
  resemble real usage.
- **Coverage as a signal, not a target**: Fowler plus Goodhart.
- **Flaky tests and determinism**: a flaky test is worse than no test.
- **Guardrails**: the ice-cream cone, testing through the UI, coverage as a
  target, redundant tiers.
- **Relationship to other skills**: the cross-references listed under Scope.
- **Adapt to your context** section plus a pointer to the reference.

### `references/testing-strategy.md` (depth, TypeScript)

- Sources: Cohn, *Succeeding with Agile* (2009); Fowler, *TestPyramid* and
  *TestCoverage* bliki; Vocke, *The Practical Test Pyramid*; Dodds, the testing
  trophy and "write tests, not too many, mostly integration"; Scott, the
  ice-cream cone; Winters, Manshreck, Wright, *Software Engineering at Google*
  (test sizes, size versus scope). Attribution without fabricated page numbers
  or invented verbatim quotations beyond the short, verifiable phrasings
  gathered during research.
- The history and sourcing of each shape.
- The full tier taxonomy defined precisely (unit, integration, contract,
  end-to-end, acceptance), including where sociable and solitary tests sit.
- A size-versus-scope table with Google's small (single process, no network or
  filesystem), medium (single machine, localhost only), large (unrestricted)
  constraints, and the note that size and scope are independent axes.
- The pyramid-versus-trophy debate treated as context-dependent, with the point
  of agreement (end-to-end stays small).
- Consumer-driven contract testing (Pact-style) placed in the portfolio, held
  distinct from TDD's in-memory contract tests, with the shared-name warning.
- The coverage section (Fowler, Goodhart's law), coverage as a diagnostic not a
  target.
- Flaky tests, test isolation, and determinism.
- One worked TypeScript decision walkthrough: for a given feature, where each of
  its tests lands across the tiers, and why.
- Trade-off notes with cross-references (TDD for the inner loop and doubles,
  hexagonal for integration at adapters, legacy-code for characterization
  tests, refactoring for self-testing code, DDD for acceptance and the
  ubiquitous language).

## Research and validation approach

Content must be sourced, not written from memory.

- **Research pass done and ongoing.** The canonical facts were validated with
  WebSearch and WebFetch against Fowler's *TestPyramid* and *TestCoverage*
  bliki, the Cohn pyramid origin, Vocke's practical test pyramid, Dodds' testing
  trophy, Scott's ice-cream cone, and *Software Engineering at Google* on test
  sizes and size versus scope. Any further specific claim added during authoring
  is checked the same way. Sourcing caveat: no invented verbatim quotations or
  page numbers.
- **Authoring tools.** `plugin-dev:plugin-structure` for the plugin scaffold and
  `plugin-dev:skill-development` for the skill structure and frontmatter, on top
  of the house format established by the sibling plugins.
- **Validation and review.** After authoring, the `plugin-dev:skill-reviewer`
  agent reviews the skill for triggering quality and the absence of overlap with
  `test-driven-development` (the macro layer must not re-teach the inner loop or
  the double ladder), and the `plugin-dev:plugin-validator` agent validates the
  plugin structure. Content is reviewed for accuracy against the sources,
  internal consistency, and the macro-first, pragmatism, and composability
  framing.

## Marketplace and integration

- Add one entry to `.claude-plugin/marketplace.json` (name, source,
  description, version `0.1.0`).
- Add one row to the root `README.md` plugins table.
- Add reciprocal cross-references to `testing-strategy` in the sibling plugins:
  `test-driven-development` (from its inner-loop scope section),
  `hexagonal-architecture`, `legacy-code`, `refactoring`, and
  `domain-driven-design`, matching the existing cross-reference pattern.

## Success criteria

- One installable plugin following the existing structure and conventions, with
  a single focused skill.
- A lean, macro-first `SKILL.md` with depth in `references/`: light on the inner
  loop (owned by TDD), heavy on the portfolio decision, the shapes, size versus
  scope, coverage, and flaky tests.
- The tiers, the shapes, and the size-versus-scope distinction are actionable in
  TypeScript from the reference alone.
- Ownership by territory is respected: `testing-strategy` owns the macro
  portfolio; `test-driven-development` remains the source of truth for the inner
  loop and the double ladder; cross-references run both ways with no
  duplication.
- Contract testing is presented in both meanings, clearly separated: the
  in-memory variant referenced to TDD, the consumer-driven variant owned here.
- Coverage is presented as a signal, not a target (Fowler, Goodhart).
- Content grounded in the sources and reviewed by the `plugin-dev:skill-reviewer`
  and `plugin-dev:plugin-validator` agents.
- Registered in the marketplace and listed in the root README.
