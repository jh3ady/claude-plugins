# claude-plugins

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A curated marketplace of open-source [Claude Code](https://www.anthropic.com/claude-code)
plugins.

## Installation

Add the marketplace, then install a plugin:

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install <plugin>@jh3ady-claude-plugins
```

You can also declare the marketplace in your `settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "jh3ady-claude-plugins": {
      "source": { "source": "github", "repo": "jh3ady/claude-plugins" }
    }
  }
}
```

## Plugins

| Plugin | Description |
| ------ | ----------- |
| [`commit-conventions`](plugins/commit-conventions) | gitmoji + Conventional Commits for commit messages: subject-based scopes, the 50/72 rule, lower-case-verb casing. |
| [`review-conventions`](plugins/review-conventions) | Conventional Comments for pull and merge request reviews: labelled, decorated, actionable comments. |
| [`solid-principles`](plugins/solid-principles) | The five SOLID principles applied pragmatically: recognizable smells, focused refactorings, guardrails against over-engineering. |
| [`simplicity-principles`](plugins/simplicity-principles) | KISS, DRY, and YAGNI applied pragmatically: do-less heuristics, the rule of three, duplication versus the wrong abstraction. |
| [`clean-code`](plugins/clean-code) | Clean code craftsmanship applied pragmatically: naming, small focused functions, intent-revealing comments, error handling. |
| [`simple-design`](plugins/simple-design) | Kent Beck's four rules of simple design, meta first: passes the tests, reveals intention, no duplication, fewest elements, as one priority-ordered procedure for the refactor step, with arbitration when the rules conflict and simple design as emergent, each rule owned by its sibling plugin. |
| [`object-calisthenics`](plugins/object-calisthenics) | Jeff Bay's nine rules of object calisthenics as a training discipline: one indentation level, no else, wrap primitives, first-class collections, one dot per line, no abbreviations, small entities, two instance variables, no getters or setters, applied strictly as an exercise and relaxed with judgement, each rule's principle owned by its sibling plugin. |
| [`modular-monolith`](plugins/modular-monolith) | One deployable unit, strictly bounded modules with public APIs, isolated data, and TypeScript-ecosystem boundary enforcement. |
| [`dependency-injection`](plugins/dependency-injection) | Pure DI (manual constructor injection) first, the composition root, object lifetimes, and the anti-pattern catalogue, with DI containers as a justified option. |
| [`hexagonal-architecture`](plugins/hexagonal-architecture) | Ports and adapters applied pragmatically: the dependency rule, primary and secondary ports and adapters, the application core, composition-root wiring, and the relationship to Onion and Clean Architecture. |
| [`domain-driven-design`](plugins/domain-driven-design) | DDD applied pragmatically in three skills: EventStorming (collaborative domain discovery), strategic design (ubiquitous language, bounded contexts, subdomains, context mapping), and tactical design (entities, value objects, aggregates, domain events, repositories, services, factories). |
| [`event-sourcing`](plugins/event-sourcing) | An append-only event store as the system of record, event-sourced aggregates rehydrated by replaying events, snapshots, projections and read models, schema versioning and upcasting, and the relationship to CQRS. |
| [`cqrs`](plugins/cqrs) | The command/query split promoted to the model level, command and query handlers, the write model versus read models and projections, the levels of separation from a shared store to separate stores, and the consistency trade-off. |
| [`screaming-architecture`](plugins/screaming-architecture) | A top-level structure that announces the business domain and its use cases rather than the framework: package-by-feature over package-by-layer, vertical slices, and composition with hexagonal, clean, and domain-driven design. |
| [`test-driven-development`](plugins/test-driven-development) | TDD in the classical (Detroit) style: a failing test first, red-green-refactor, testing behaviour not implementation, the test-double ladder preferring real objects and in-memory implementations over mocks, and contract tests. |
| [`legacy-code`](plugins/legacy-code) | Working effectively with legacy code (Feathers) in two skills: the method (code without tests, the Legacy Code Change Algorithm, seams, characterization tests, reasoning about effects) and the dependency-breaking catalogue (Sprout, Wrap, Extract Interface, Subclass and Override, and the rest). |
| [`refactoring`](plugins/refactoring) | Refactoring (Fowler, 2nd ed., with Beck) in three skills: the method (definition, the two hats, when and why to refactor, small-step mechanics, self-testing code as prerequisite), the code smells (the chapter 3 catalogue, each pointing to its refactorings), and the catalogue (the full set of moves grouped by category, with condensed mechanics and TypeScript examples). |
| [`design-patterns`](plugins/design-patterns) | Design patterns judgment first: the 23 Gang of Four patterns plus modern idioms (Null Object, Result/Either, Specification, functional patterns), framed by when to apply, when to refuse (the rule of three, no speculative abstraction), the minimal TypeScript form, and ownership by level so the generic mechanism lives here while its specialised application lives in hexagonal, CQRS, and DDD. |

## Contributing

Issues and suggestions are welcome. Open an issue to report a problem or
propose a plugin.

## License

Released under the [MIT License](LICENSE). Individual plugins may carry
their own license; see each plugin's directory.
