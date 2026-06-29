# legacy-code

A Claude Code plugin that encodes Michael Feathers' *Working Effectively with Legacy Code* in two matched skills: one for the method (how to approach any change in untested code safely) and one for the catalogue (which specific technique to reach for when a dependency blocks testing). Together they resolve the central dilemma of working with legacy code: you need tests to change code safely, but the code resists testing until you change it first.

It stays generic on purpose: compose it with your own team conventions for seam patterns, preferred breaking techniques, and test organisation.

## What it does

When you face a change in untested code, need to add a test before you can refactor, or must add new behaviour without disturbing code that resists testing, the two bundled skills apply together. The method skill covers how to work; the catalogue skill covers which specific technique to apply at each decision point.

### legacy-code-changes

When you are working with existing untested code and need to decide where to make a change, how to get code under test, or how to reason about the effects of a change before making it, this skill applies:

- The definition and the dilemma: legacy code is code without tests; to change the code safely you need tests, but to get the code under test you often must change it first to break its dependencies.
- The Legacy Code Change Algorithm: Feathers' five-step backbone for every safe change in untested code (identify change points, find test points, break dependencies, write tests, make changes and refactor), and why collapsing these steps is dangerous.
- Seams and enabling points: a seam is a place where you can alter behaviour without editing in that place; the three seam types are object seams (the primary kind in object-oriented code), link seams, and preprocessing seams, each with its enabling point.
- Characterization tests: how to write a test that documents what the code actually does rather than what it should do, pinning the current behaviour before touching it, and how to handle the case where a characterization test reveals a defect.
- Effect sketching and pinch points: tracing how a change propagates through the codebase before writing tests, and identifying narrow places in the effect chain where many effects funnel through a small testable surface.
- Sensing versus separation: two distinct reasons to break a dependency (you cannot observe what the code computes; you cannot get the code into a harness at all), and how identifying which one you face directs you to the right technique.

### legacy-dependency-breaking

When you know you face a sensing or separation problem and need to choose a specific technique, or when you need to add new behaviour without touching existing untested code, this skill is the catalogue that step three of the change algorithm calls for. The techniques are grouped by intent:

- Add behaviour without touching existing code: Sprout Method, Sprout Class, Wrap Method, and Wrap Class. The lowest-risk moves when the surrounding code resists testing and you must add new behaviour now, writing the new code in isolation and testing it independently without modifying the existing tangled code.
- Get a class into a test harness: Extract Interface, Parameterize Constructor, Introduce Instance Delegator, Introduce Static Setter, Extract and Override Factory Method, Supersede Instance Variable, Pull Up Feature, Push Down Dependency, Replace Global Reference with Getter, and Encapsulate Global References. These break construction-time dependencies so the class can be instantiated in a test.
- Get a method under test: Subclass and Override Method, Extract and Override Call, Extract and Override Getter, Parameterize Method, Break Out Method Object, Adapt Parameter, and Primitivize Parameter. These open object seams inside a method body when the class can be constructed but a hidden dependency inside the method blocks testing or observation.

## Relationship to other plugins

- `test-driven-development`: characterization tests are a case of the same discipline applied in reverse; you observe and encode the actual behaviour rather than specifying the intended behaviour. Once the code is under test, the standard red-green-refactor cycle resumes. The two skills compose: the legacy-code skills cover getting into the harness, and the TDD skill covers what to do once you are there.
- `dependency-injection` and `hexagonal-architecture`: the scaffolding techniques (Parameterize Constructor, Extract Interface) are mechanical first steps toward proper dependency injection and ports-and-adapters. Once tests exist, migrate toward constructor injection and explicit ports. The seams you open in legacy code point in the same direction as hexagonal architecture.
- `clean-code` and `simplicity-principles`: the refactor step (step five of the change algorithm) is where these apply. Getting code under test is not the end goal; the safety net exists so you can improve names, reduce duplication, and simplify structure.
- `solid-principles`: Extract Interface enacts the Dependency Inversion Principle; the Interface Segregation Principle guides how narrow the extracted interface should be. The dependency-breaking techniques are mechanical applications of these principles under the constraint of untested code.

## Install

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install legacy-code@jh3ady-claude-plugins
```

## Adapt to your context

This plugin is a baseline, not a dogma. Your codebase will have its own conventions for where seams live, which dependency-breaking techniques your team has agreed on, how characterization tests are organised alongside the rest of the test suite, and which techniques are most natural in your language or framework. Declare those in your own `CLAUDE.md` or a higher-priority skill. The plugin does not impose them.

## License

Released under the [MIT License](LICENSE).
