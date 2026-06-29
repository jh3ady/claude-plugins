# test-driven-development

A Claude Code plugin that helps apply test-driven development (TDD)
pragmatically, in the classical (Detroit, also called Chicago or classicist)
style: write the failing test first, watch it fail, write the minimal code to
pass, then refactor, while testing behaviour through the public API rather than
verifying interactions with mocks.

The classical style prefers real objects and in-memory implementations over
stubs and mocks, and verifies state ("what is true afterwards?") rather than
choreography ("which calls were made?"). That choice is what keeps tests
durable through aggressive refactoring, because they assert the observable
result and not the implementation. This plugin keeps that framing front and
centre and guards against the brittleness that over-mocking causes.

It stays generic on purpose: compose it with your own architecture rules, test
runner, and team or personal conventions.

## What it does

When you implement a feature, fix a bug, write a unit test, decide what to
test, or decide whether to double a dependency, the bundled skill applies:

- The iron law: no production code without a failing test first, because a test
  you never saw fail proves nothing.
- Red-green-refactor: one failing test for one behaviour, the minimal code to
  pass, then design improvement with the tests held green.
- Testing behaviour, not implementation (Ian Cooper): the unit under test is a
  behaviour or module exposed through its public API, not a class, and the
  trigger for a new test is a new requirement, not a new class or method.
- The test-double ladder: prefer the real object, then an in-memory
  implementation of a contract, with stubs reserved for failure-path injection
  and mocks reserved for true boundaries where the interaction is the behaviour.
- State verification over interaction verification, and why it survives
  refactoring that changed no behaviour.
- Keeping in-memory implementations faithful through contract tests: one suite
  run against both the in-memory and the real implementation.
- Pragmatic guardrails against over-mocking, against testing implementation
  detail, and against one-test-per-class.

The plugin is architecture-agnostic: it does not require hexagonal, DDD, or any
particular layering, though it composes with them.

## Relationship to other plugins

- `hexagonal-architecture`: ports are the contracts you back with in-memory
  implementations, and driving ports are the public surfaces you test behaviour
  through. They pair naturally, but this skill requires no particular
  architecture.
- `domain-driven-design`: entities, value objects, and domain services are the
  real objects you never double; aggregates are tested through their public
  behaviour with repositories backed by in-memory implementations.
- `simplicity-principles`: the green step is YAGNI and KISS in miniature; the
  refactor step is where DRY and the rule of three apply.
- `clean-code` and `solid-principles`: applied in the refactor step; dependency
  inversion is what makes the in-memory ladder possible.

## A note on the name

This plugin shares its name with the `test-driven-development` skill from the
`superpowers` collection. The two are addressed under distinct plugin
namespaces (`test-driven-development:test-driven-development` versus
`superpowers:test-driven-development`), so both can be installed without one
clobbering the other. This one is the classical (Detroit), state-verifying take
and is the authoritative one for this collection; its description is written to
trigger on the specific situations above.

## Install

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install test-driven-development@jh3ady-claude-plugins
```

## Adapt to your context

This plugin is a baseline, not a dogma. Layer your own test runner and
assertion library, your file and naming conventions for tests, your fixture and
builder helpers, and where you draw the line for an integration test in your
own `CLAUDE.md` or a higher-priority skill. The plugin does not impose them.

## License

Released under the [MIT License](LICENSE).
