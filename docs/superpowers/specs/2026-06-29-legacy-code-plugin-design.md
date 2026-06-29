# Legacy code plugin: design

- Date: 2026-06-29
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

This work adds one plugin: `legacy-code`. It encodes Michael Feathers'
*Working Effectively with Legacy Code* (2004). The book is large, so it ships
two focused skills under a single plugin rather than one overloaded skill.

The central thesis that runs through both skills: **legacy code is code without
tests**. You cannot change code with confidence without tests, but to get code
under test you often must first break its dependencies. That dilemma is the
problem the two skills solve, in order: the method that frames the work, and
the catalogue of techniques that makes untestable code testable.

## Scope

One plugin, `legacy-code`, bundling two skills:

- `legacy-code-changes`: the mental model and process (what legacy code is, the
  Legacy Code Change Algorithm, seams and enabling points, characterization
  tests, reasoning about effects, sensing and separation).
- `legacy-dependency-breaking`: the catalogue of dependency-breaking techniques
  that get a class or a method into a test harness (Sprout, Wrap, Extract
  Interface, Subclass and Override Method, Parameterize Constructor, Extract and
  Override Factory Method, and the rest), grouped by intent.

This follows the family's multi-skill precedent set by `domain-driven-design`:
the topic is too large for a single lean skill, and the method/catalogue split
is the canonical division of Feathers' book (the early chapters teach the
algorithm and the seam model; the long back half is a recipe catalogue). Both
skill descriptions mention "legacy code" so a generic request pulls the relevant
skill (the method for how to approach a change; the catalogue for how to break a
specific dependency). No third umbrella skill: YAGNI.

### Boundary (focused, with references out)

In scope:

- `legacy-code-changes`: the definition of legacy code and the change dilemma;
  the Legacy Code Change Algorithm (identify change points, find test points,
  break dependencies, write tests, make the change, refactor); seams and
  enabling points (object seams primarily, link and preprocessing seams
  mentioned); characterization tests (capturing actual behaviour, not intended
  behaviour, and the loop for discovering it); reasoning about effects (effect
  sketching, pinch points); sensing and separation; the "I do not have much
  time" strategies; "I cannot get this class into a test harness" framing.
- `legacy-dependency-breaking`: the dependency-breaking techniques, grouped by
  intent rather than as a flat list of all twenty-four. The catalogue is
  complete and actionable: every technique is detailed enough to apply without
  the book (intent, mechanism, TypeScript example, cost or risk). Techniques
  that are language-specific or not relevant to TypeScript (link-seam,
  preprocessing, and C-style tricks such as Link Substitution, Definition
  Completion, or Replace Function with Function Pointer) are named with a short
  note rather than given full TypeScript mechanics.

Referenced as complementary, never absorbed:

- **Test-driven development**: characterization tests are a special case of the
  same discipline; once code is under test, red-green-refactor resumes. The
  seam concept also underpins testable design. Referenced to
  `test-driven-development`.
- **Clean code and simplicity**: the refactor step after the code is secured;
  small focused functions and clear names. Referenced to `clean-code`,
  `simplicity-principles`.
- **Hexagonal architecture and dependency injection**: the target design once
  the seams are open. Dependency-breaking techniques are temporary scaffolding
  toward tests; ports, adapters, and constructor injection are where a cleaned
  design lands. Referenced to `hexagonal-architecture`,
  `dependency-injection`.
- **SOLID**: extract-interface and depend-on-abstractions techniques lean on
  the dependency-inversion and interface-segregation principles. Referenced to
  `solid-principles`.

Explicitly out of scope:

- A general refactoring catalogue (Fowler's *Refactoring*): refactorings that
  are not about breaking dependencies or opening seams (Move Method, Replace
  Conditional with Polymorphism, and the like) are referenced, not reproduced.
  This exclusion never removes the mechanics of Feathers' dependency-breaking
  techniques themselves: each of those stays fully detailed in the catalogue so
  it can be applied without the book.
- Language-specific or tool-specific test-harness setup (runners, assertion
  libraries, coverage, CI). Consistent with the `test-driven-development`
  plugin's stated non-goals.

## Key decisions

- **One plugin, two skills.** `legacy-code-changes` (method) and
  `legacy-dependency-breaking` (catalogue).
- **Name: `legacy-code`** for the plugin; descriptive, non-prefixed skill names
  (`legacy-code-changes`, `legacy-dependency-breaking`) so the method/catalogue
  split is explicit and triggers precisely.
- **Activation, clearly separated.** `legacy-code-changes` activates when
  working with existing untested code, when afraid to modify uncovered code,
  when deciding where to start a change, on characterization tests, seams, and
  reasoning about effects, even when the term is not used.
  `legacy-dependency-breaking` activates when a class or method cannot be
  instantiated or exercised in a test because of its dependencies (heavy
  constructors, singletons, static calls, hidden side effects), when adding code
  without disturbing the existing code, or when choosing a specific technique
  (Sprout, Wrap, Extract Interface, Subclass and Override).
- **Catalogue grouped by intent, not enumerated flat.** Three intent groups:
  add behaviour without touching existing code (Sprout Method, Sprout Class,
  Wrap Method, Wrap Class); get a class into a harness (Extract Interface,
  Parameterize Constructor, Introduce Instance Delegator, Extract and Override
  Factory Method); get a method under test (Subclass and Override Method,
  Extract and Override Call, Extract and Override Getter, Parameterize Method,
  Break Out Method Object, Adapt Parameter). The SKILL.md teaches the grouping
  and the most-used techniques; the references hold the complete, actionable
  catalogue so any technique can be applied without the book.
- **Catalogue reference split by intent (three files).** The
  `legacy-dependency-breaking` skill carries three reference files, one per
  intent group, mirroring the SKILL.md grouping so only the relevant group
  loads. This is a deliberate departure from the family's one-reference-per-skill
  norm, justified by the catalogue's size; the `legacy-code-changes` skill keeps
  a single reference. Every technique lands in exactly one intent file.
- **Lean `SKILL.md` per skill.** Each core stays short: definitions, the core
  practices, pragmatic guardrails, and references-out. Depth, the full
  technique catalogue, examples, and sources live in `references/`.
- **Pragmatism baked in.** Change surgically around the change point rather than
  rewriting; characterization tests pin existing behaviour, bugs included, and
  are documented rather than "fixed" in passing; dependency-breaking techniques
  are temporary scaffolding toward tests, not the target design; on a simple,
  already-tested CRUD slice, do not bring out the artillery.
- **Examples in TypeScript only.** Consistent with the family. The book's
  Java/C++ object-oriented framing is translated to TypeScript; the procedural
  / non-object-oriented chapter is out of scope for examples (a brief mention
  only, if it serves a guardrail).

## Plugin structure

Mirrors the existing plugins, with two skills:

```
plugins/legacy-code/
  .claude-plugin/plugin.json      # name, version 0.1.0, author, MIT license, homepage, keywords
  README.md                       # covers both skills
  LICENSE                         # MIT
  skills/
    legacy-code-changes/
      SKILL.md                    # lean core
      references/legacy-code-changes.md          # detailed method, TypeScript examples, sources
    legacy-dependency-breaking/
      SKILL.md                    # lean core
      references/
        add-without-touching.md         # Sprout Method/Class, Wrap Method/Class
        get-a-class-into-a-harness.md   # Extract Interface, Parameterize Constructor, Introduce Instance Delegator, Extract and Override Factory Method, ...
        get-a-method-under-test.md      # Subclass and Override Method, Extract and Override Call/Getter, Parameterize Method, Break Out Method Object, Adapt Parameter, ...
```

Writing conventions for all generated files: English, no em-dashes, words
written in full (standard acronyms such as TDD, SOLID, DI, API are fine).

## Plugin contents

### `legacy-code-changes/SKILL.md` (lean core)

- Frontmatter: `name` plus a trigger-oriented `description` (working with
  existing untested code, fear of changing uncovered code, where to start a
  change, characterization tests, seams, reasoning about effects, even when the
  term is not used).
- **What legacy code is**: code without tests, and the change dilemma (to change
  code safely you need tests; to add tests you often must change the code
  first).
- **The Legacy Code Change Algorithm**: identify change points, find test
  points, break dependencies, write tests, make the change, refactor.
- **Seams and enabling points**: a seam is a place to alter behaviour without
  editing in place; object seams primarily, with link and preprocessing seams
  named. The enabling point is where the choice is made.
- **Characterization tests**: tests that document what the code actually does,
  not what it should do; the loop to discover behaviour (write a test that
  asserts something likely false, let the failure reveal the real behaviour,
  lock it in).
- **Reasoning about effects**: effect sketching, pinch points; sensing and
  separation as the two reasons to break a dependency.
- **When time is short**: Sprout and Wrap as the low-risk first moves (detailed
  in the catalogue skill); avoid editing tangled code in place.
- **Pragmatic guardrails**: change surgically, do not rewrite; characterization
  tests pin behaviour including bugs; do not gold-plate an already-tested CRUD
  slice.
- **References out**: `test-driven-development` (characterization tests as a
  case of the same discipline; red-green-refactor afterwards),
  `legacy-dependency-breaking` (the techniques the algorithm calls for),
  `clean-code` / `simplicity-principles` (the refactor step).
- **Adapt to your context** section plus a pointer to the reference.

### `legacy-dependency-breaking/SKILL.md` (lean core)

- Frontmatter: `name` plus a trigger-oriented `description` (a class or method
  that cannot be instantiated or exercised in a test because of its
  dependencies, adding code without disturbing existing code, choosing a
  specific technique, even when the term is not used).
- **The two problems**: you cannot instantiate a class in a harness, or you
  cannot sense what a method does. Each technique targets one of these.
- **Add without touching existing code**: Sprout Method, Sprout Class, Wrap
  Method, Wrap Class. The safest first moves; new behaviour goes in tested new
  code beside the untested old code.
- **Get a class into a harness**: Extract Interface, Parameterize Constructor,
  Introduce Instance Delegator, Extract and Override Factory Method. Break the
  hard-to-construct dependency so the class can be created under test.
- **Get a method under test**: Subclass and Override Method, Extract and
  Override Call, Extract and Override Getter, Parameterize Method, Break Out
  Method Object, Adapt Parameter. Open a seam inside the method under test.
- **Pragmatic guardrails**: these are scaffolding toward tests, not the target
  design; prefer the least invasive technique that opens the seam; once tested,
  refactor toward a clean design (DI, ports and adapters).
- **References out**: `test-driven-development` (the seam concept, testable
  design), `dependency-injection` / `hexagonal-architecture` (the clean target
  once seams are open), `solid-principles` (interface and inversion principles
  behind Extract Interface), `clean-code` (the refactor step).
- **Adapt to your context** section plus a pointer to the reference.

### `references/*.md` (depth, TypeScript examples, sources)

Each reference carries TypeScript examples and "when not to apply" notes.

- `legacy-code-changes/references/legacy-code-changes.md`: one file, the method
  in depth (the algorithm, the seam taxonomy, characterization testing, effect
  sketching and pinch points).
- `legacy-dependency-breaking/references/`: three files, one per intent group
  (`add-without-touching.md`, `get-a-class-into-a-harness.md`,
  `get-a-method-under-test.md`). Together they form the complete, actionable
  catalogue: every technique appears in exactly one file. Techniques relevant to
  TypeScript are detailed with intent, mechanism, a TypeScript example, and
  cost or risk, so they can be applied without the book. Language-specific or
  non-TypeScript techniques are named with a short note (what they are, why they
  do not apply here) rather than full mechanics, so the catalogue stays faithful
  to Feathers without padding the files with irrelevant tricks.

Sources attributed to "Feathers, *Working Effectively with Legacy Code* (2004)"
without invented page numbers; cross-referenced concepts attributed to their
own authors (Fowler for refactoring, Beck for TDD).

## Research and validation approach

Content must be sourced, not written from memory.

- **Research pass required.** Before authoring, run a background research pass
  to produce a primary-source-cited body of knowledge for both skills (the
  Legacy Code Change Algorithm, the seam taxonomy and enabling points,
  characterization testing, effect sketching and pinch points, and the
  dependency-breaking technique catalogue with each technique's intent and
  mechanism). Primary source: Feathers, *Working Effectively with Legacy Code*
  (2004). Secondary: Fowler's *Refactoring* and bliki for the refactoring
  cross-references, Beck for the TDD cross-reference. Sourcing caveat: do not
  publish invented verbatim quotations or page numbers; attribute paraphrases to
  "Feathers (2004)".
- **Validation and review.** After authoring, review the content for accuracy
  against the sources, internal consistency, and adherence to the pragmatism and
  composability framing. The `skill-reviewer` agent assesses triggering quality
  and overlap for both skills (the method and catalogue descriptions must not
  cannibalise each other).

## Authoring tools

- `skill-creator` for skill scaffolding and structure best practices.
- `writing-skills` (superpowers), if available, for frontmatter and description
  quality so activation triggers reliably.

## Marketplace and settings integration

- Add one entry to `.claude-plugin/marketplace.json` (name, source,
  description, version `0.1.0`).
- Add one row to the root `README.md` plugins table (if present).
- Enable the plugin in `~/.claude/settings.json`: add
  `"legacy-code@jh3ady-claude-plugins": true` to `enabledPlugins`.

## Success criteria

- One installable plugin following the existing structure and conventions,
  bundling two focused skills.
- Lean skills with depth in `references/`.
- The dependency-breaking catalogue is complete and actionable: every
  TypeScript-relevant technique can be applied from the references alone, without
  the book; non-applicable techniques are named with a short note.
- Content grounded in Feathers' book and reviewed for accuracy, with the
  pragmatic guardrails applied.
- Pragmatism and composability framing present; adjacent plugins (TDD, clean
  code, simplicity, hexagonal, dependency injection, SOLID) referenced rather
  than absorbed; a general refactoring catalogue flagged out of scope.
- The two skill descriptions trigger precisely and do not overlap.
- Registered in the marketplace and enabled in settings.
