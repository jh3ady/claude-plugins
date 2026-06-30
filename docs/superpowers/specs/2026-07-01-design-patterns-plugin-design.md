# Design patterns plugin: design

- Date: 2026-07-01
- Status: approved (design), pending spec review
- Author: Jean-Denis VIDOT

## Context and goal

The `jh3ady-claude-plugins` marketplace ships a consistent family of
engineering-principle plugins (`commit-conventions`, `review-conventions`,
`solid-principles`, `simplicity-principles`, `clean-code`,
`modular-monolith`, `dependency-injection`, `hexagonal-architecture`,
`domain-driven-design`, `event-sourcing`, `cqrs`, `screaming-architecture`,
`test-driven-development`). They share one pattern: a generic, composable skill
presented as a pragmatic baseline rather than a dogma, with a lean `SKILL.md`,
depth pushed into `references/`, and adjacent concepts cross-referenced rather
than absorbed.

This work adds one plugin: `design-patterns`. It covers the level that sits
between the abstract principles (SOLID, KISS/DRY/YAGNI, clean code) and the
macro architectures (hexagonal, modular monolith, DDD, CQRS): the recurring,
named design solutions of the Gang of Four, plus a small set of modern idioms
that the 1994 catalogue predates.

The central thesis: Claude already knows what a Strategy or an Observer is, so a
catalogue skill would carry almost no value at real token cost. The value of
this plugin is entirely the **judgment layer** Claude does not apply
consistently on its own: when to reach for a pattern, when to refuse it, what
the minimal form is, and how each pattern composes with the rest of this
marketplace. The skill is therefore deliberately light on "what a pattern is"
and heavy on "when, when not, how minimal, how it composes".

## Scope

One plugin, `design-patterns`, bundling a single skill `design-patterns`.

A single skill, not three by Gang of Four category. The category taxonomy
(creational, structural, behavioral) is a classification, not a set of distinct
activities. Unlike `domain-driven-design`, where EventStorming, strategic, and
tactical design are three genuinely different moments of work with different
triggers, a developer never thinks "I have a structural problem"; they think "I
have a variation point" or "I have duplication across families of objects".
Splitting by category would therefore trigger poorly. One skill carries the
judgment frame; the per-category detail is pushed into `references/`.

### Boundary (focused, with references out)

In scope:

- The judgment frame in `SKILL.md`: the decision reflex (a pattern answers an
  *identified* variation point, never an anticipated one; the rule of three
  before abstracting); the extensibility nuance (pragmatic is not
  anti-extensible: when the variation point actually manifests, opening it
  cleanly is OCP done right, not over-engineering; the fault is speculative
  abstraction, not abstraction itself); the minimal-form reflex (in TypeScript a
  Strategy is often a function passed as a parameter, a Command a closure; four
  classes only when they pay their cost); anti-patternitis guardrails (a pattern
  for its name, cargo-culting, gratuitous indirection); a smell-to-candidate
  index that drives selection and triggering; and a composition map.
- The 23 Gang of Four patterns, detailed in `references/` split by category
  (creational, structural, behavioral). Each pattern follows the same template
  and stays light on the canonical definition.
- Four modern idioms the 1994 catalogue predates, in a fourth reference file:
  Null Object, Result/Either, Specification, and functional patterns
  (higher-order functions and closures as a light alternative to Strategy and
  Command, immutability).

Ownership by level of abstraction (the key boundary rule):

- **This plugin owns the generic mechanism.** "Adapter = wrap an incompatible
  interface", "Command = reify a request as an object", "Factory Method /
  Abstract Factory = encapsulate creation". These are genuine Gang of Four
  patterns; their natural home is here, and this plugin is the source of truth
  for the pattern as a pattern.
- **The architecture plugins own the specialised application.** `hexagonal-architecture`
  owns the driving/driven adapter at the boundary (an application of Adapter);
  `cqrs` owns command as a write-model message (a near false friend that shares
  only the word with the Gang of Four Command); `domain-driven-design` owns the
  factory that guards an aggregate's invariants.
- **Cross-references are therefore bidirectional but at different levels.** The
  architecture plugin points to `design-patterns` for the generic mechanism;
  `design-patterns` points to the architecture plugin for the specialised
  application. Each stays the source of truth on its own level; nothing is
  duplicated.

Explicitly out of scope (not Gang of Four patterns, owned elsewhere):

- **Repository**: a PoEAA / DDD pattern, not Gang of Four. With the "Gang of
  Four plus modern idioms" scope it does not enter this plugin at all;
  `domain-driven-design` keeps it entirely.
- **Dependency Injection**: a technique, not a Gang of Four pattern. It stays in
  the `dependency-injection` plugin. This plugin may note only that a Strategy
  is often wired through DI.
- **Enterprise patterns (Fowler's PoEAA)**: Unit of Work, Data Mapper, Identity
  Map, and the rest. Out of scope to avoid overlap with the architecture
  plugins; a separate plugin could cover them later if justified.

## Key decisions

- **One plugin, one skill** named `design-patterns`. Skill-only, no command or
  hook, consistent with `solid-principles`.
- **Judgment first.** The content's centre of gravity is when to apply, when to
  refuse, the minimal form, and composition. The "what" (canonical definition)
  is reduced to the strict minimum because Claude already knows it. This
  maximises value and minimises weight.
- **Single skill, category detail in references.** The Gang of Four taxonomy is a
  classification, not three activities, so it does not justify three skills; the
  detail per category lives in `references/`.
- **Ownership by level of abstraction.** This plugin is the source of truth for
  the generic pattern; the architecture plugins are the source of truth for
  their specialised application; cross-references run both ways at their
  respective levels. Repository and DI are out of scope, not duplicated.
- **Scope locked.** 23 Gang of Four patterns plus four modern idioms (Null
  Object, Result/Either, Specification, functional patterns). Out: Repository,
  DI, PoEAA enterprise patterns.
- **Examples in TypeScript only.** Consistent with the family. The minimal-form
  reflex leans on TypeScript's first-class functions and closures.
- **Pragmatism with extensibility, not against it.** The guardrails warn against
  patternitis and speculative abstraction, but they do not turn into a reflex
  against extensibility: when a variation point is real and identified, the right
  pattern that opens it cleanly is the correct answer, not over-engineering.

## Plugin structure

Mirrors the existing plugins, with a single skill:

```
plugins/design-patterns/
  .claude-plugin/plugin.json      # name, version 0.1.0, author, MIT license, homepage, keywords
  README.md                       # covers the skill
  LICENSE                         # MIT
  skills/design-patterns/
    SKILL.md                      # lean judgment core
    references/
      creational.md               # Gang of Four creational patterns
      structural.md               # Gang of Four structural patterns
      behavioral.md               # Gang of Four behavioral patterns
      modern-idioms.md            # Null Object, Result/Either, Specification, functional patterns
```

Writing conventions for all generated files: English, no em-dashes, words
written in full (standard acronyms such as TDD, SOLID, DI, API, OCP are fine).

## Plugin contents

### `design-patterns/SKILL.md` (lean judgment core)

- Frontmatter: `name` plus a trigger-oriented `description` (introducing,
  reviewing, or refactoring around a variation point; hesitating between
  patterns; asking "should I use a pattern here", even when no pattern is named;
  with explicit guardrails against speculative application).
- **The decision reflex**: a pattern answers an identified variation point, not
  an anticipated one; the rule of three before abstracting.
- **The extensibility nuance**: pragmatic is not anti-extensible. When the
  variation point actually manifests, opening it cleanly is OCP done right, not
  over-engineering. The fault is speculative abstraction, not abstraction
  itself.
- **The minimal-form reflex**: in TypeScript a Strategy is often a function
  passed as a parameter, a Command a closure; draw four classes only when they
  pay their cost.
- **Anti-patternitis guardrails**: a pattern for its name, cargo-culting,
  gratuitous indirection.
- **Smell-to-candidate index**: the real triggering aid (for example "related
  families of objects" to Abstract Factory, "repeated null guards" to Null
  Object, "behaviour varies at runtime" to Strategy).
- **Composition map**: bidirectional references by level (generic mechanism here
  versus specialised application in `hexagonal-architecture`, `cqrs`,
  `domain-driven-design`); Repository and DI explicitly out of scope.
- **References out**: `solid-principles` (OCP and DIP behind most behavioral
  patterns), `simplicity-principles` (the rule of three, duplication versus the
  wrong abstraction), `dependency-injection` (wiring a Strategy), and the
  architecture plugins for specialised applications.
- **Adapt to your context** section plus a pointer to the references.

### `references/*.md` (depth, TypeScript examples)

Each reference uses the same per-pattern template, deliberately light on the
canonical definition:

1. The force or smell that motivates the pattern.
2. When **not** to use it.
3. The minimal TypeScript form.
4. How it composes with the other plugins in this marketplace.

- `creational.md`: Abstract Factory, Builder, Factory Method, Prototype,
  Singleton. Factory Method and Abstract Factory note their specialised use in
  `domain-driven-design`; Singleton carries a strong "when not" given the DI
  composition root.
- `structural.md`: Adapter, Bridge, Composite, Decorator, Facade, Flyweight,
  Proxy. Adapter points to `hexagonal-architecture` for the boundary
  application.
- `behavioral.md`: Chain of Responsibility, Command, Interpreter, Iterator,
  Mediator, Memento, Observer, State, Strategy, Template Method, Visitor.
  Command notes the false friend with the `cqrs` command message; Strategy notes
  the DI wiring and the functional minimal form.
- `modern-idioms.md`: Null Object, Result/Either (with the clean-code error
  handling cross-reference), Specification (with the DDD cross-reference), and
  functional patterns (reinforcing the minimal-form message that a function
  often suffices where the Gang of Four draws classes).

Sources attributed to "Gamma, Helm, Johnson, Vlissides, *Design Patterns*
(1994)" for the Gang of Four material without invented page numbers; modern
idioms attributed to their usual references (Fowler for Specification and Null
Object via *Refactoring* and PoEAA, the functional and Result/Either idioms to
common practice) without fabricated citations.

## Research and validation approach

Content must be sourced, not written from memory.

- **Research pass required.** Before authoring, run a background research pass to
  produce a cited body of knowledge for the skill: the intent and applicability
  of each Gang of Four pattern, the minimal TypeScript form, and the modern
  idioms. Primary source: Gamma et al., *Design Patterns* (1994). Secondary:
  Fowler (*Refactoring*, PoEAA, bliki) for Null Object and Specification, and
  common TypeScript practice for Result/Either and the functional patterns.
  Sourcing caveat: do not publish invented verbatim quotations or page numbers;
  attribute paraphrases to the Gang of Four (1994) or to the relevant author.
- **Validation and review.** After authoring, review the content for accuracy
  against the sources, internal consistency, and adherence to the
  judgment-first, pragmatism, and composability framing. The `skill-reviewer`
  agent assesses triggering quality and the absence of overlap with the
  architecture plugins (the generic mechanism must not cannibalise their
  specialised applications, and vice versa).

## Authoring tools

- `skill-creator` for skill scaffolding and structure best practices.
- `writing-skills` (superpowers), if available, for frontmatter and description
  quality so activation triggers reliably.

## Marketplace and settings integration

- Add one entry to `.claude-plugin/marketplace.json` (name, source,
  description, version `0.1.0`).
- Add one row to the root `README.md` plugins table (if present).
- Enable the plugin in `~/.claude/settings.json`: add
  `"design-patterns@jh3ady-claude-plugins": true` to `enabledPlugins`.

## Success criteria

- One installable plugin following the existing structure and conventions,
  with a single focused skill.
- A lean, judgment-first `SKILL.md` with depth in `references/`: light on the
  canonical "what", heavy on when to apply, when to refuse, the minimal form,
  and composition.
- The 23 Gang of Four patterns plus the four modern idioms are present and
  actionable in TypeScript from the references alone.
- Ownership by level of abstraction is respected: this plugin is the source of
  truth for the generic mechanism, the architecture plugins for their
  specialised application, with bidirectional cross-references and no
  duplication.
- Repository, DI, and PoEAA enterprise patterns are flagged out of scope.
- The extensibility nuance is explicit: speculative abstraction is the fault,
  not abstraction itself.
- Content grounded in the sources and reviewed for accuracy.
- The skill description triggers precisely (on variation points and pattern
  selection) without cannibalising the architecture plugins.
- Registered in the marketplace and enabled in settings.
