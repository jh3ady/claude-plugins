# testing-strategy

A Claude Code plugin that helps decide the shape and balance of an automated
test suite: how many tests of each kind, at which level to test what, and what
signal the suite must give as a whole. It sits above the inner
red-green-refactor loop, deciding the portfolio those tests form rather than
how any single test is written.

It stays generic on purpose: compose it with your own test runner, coverage
tooling, and team or personal conventions.

## What it does

When you choose at which level to test something, weigh unit against
integration against end-to-end tests, judge a test pyramid or testing trophy
or an inverted ice-cream cone, place consumer-driven contract tests in the
portfolio, read or set a coverage target, or deal with flaky tests, the
bundled skill applies:

- The portfolio idea: tests of different granularity and cost, balanced for
  return on investment rather than judged one at a time.
- The shapes: the pyramid, the practical test pyramid, the testing trophy, and
  the ice-cream cone anti-pattern, as variations on the same trade-off between
  confidence and cost.
- The tiers: unit, integration, contract, end-to-end, and acceptance, and what
  each buys and costs.
- The size-versus-scope distinction from *Software Engineering at Google*: how
  a test runs versus how much code it exercises, chosen deliberately rather
  than conflated.
- Guiding heuristics: push each test to the cheapest tier that still gives the
  confidence you need, and avoid redundant coverage across tiers.
- Coverage as a signal, not a target: a diagnostic for finding gaps, never a
  grade for the suite or a gate on the build.
- Flaky tests: quarantine and fix the root cause instead of rerunning until
  green.
- Consumer-driven contract testing: pinning the agreement at a boundary so two
  sides can evolve independently.

The plugin is architecture-agnostic: it does not require hexagonal, DDD, or
any particular layering, though it composes with them.

## Relationship to other plugins

- `test-driven-development`: the inner loop this plugin sits above.
  Red-green-refactor and the test-double ladder live there; this plugin
  decides the portfolio those tests form.
- `hexagonal-architecture`: the ports it defines are the seams integration
  tests cross; this plugin decides how many such tests to keep relative to
  unit and end-to-end tests.
- `legacy-code`: characterization tests are the entry point when adding tests
  to untested code; this plugin frames where they sit in the wider portfolio.
- `refactoring`: self-testing code is the prerequisite that makes any strategy
  possible; this plugin decides the shape and balance of that test suite.
- `domain-driven-design`: acceptance tests express the ubiquitous language at
  the outer tier of the portfolio.

## Install

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install testing-strategy@jh3ady-claude-plugins
```

## Adapt to your context

This plugin is a baseline, not a dogma. The right shape depends on the
system: a thin front end leans towards the trophy, a service with rich domain
logic towards the pyramid. Layer your own test runner and coverage tooling,
exactly where you draw the line between a unit and an integration test, and
any target you are held to in your own `CLAUDE.md` or a higher-priority
skill. The plugin does not impose them.

## License

Released under the [MIT License](LICENSE).
