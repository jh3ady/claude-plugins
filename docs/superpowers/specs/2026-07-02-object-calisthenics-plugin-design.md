# Object calisthenics plugin: design

- Date: 2026-07-02
- Status: approved (design), pending spec review
- Author: Jean-Denis VIDOT

## Context and goal

The `jh3ady-claude-plugins` marketplace ships a consistent family of
engineering-principle plugins (`commit-conventions`, `review-conventions`,
`solid-principles`, `simplicity-principles`, `clean-code`, `simple-design`,
`modular-monolith`, `dependency-injection`, `hexagonal-architecture`,
`domain-driven-design`, `event-sourcing`, `cqrs`, `screaming-architecture`,
`test-driven-development`, `legacy-code`, `refactoring`, `design-patterns`).
They share one pattern: a generic, composable skill presented as a pragmatic
baseline rather than a dogma, with a lean `SKILL.md`, depth pushed into
`references/`, and adjacent concepts cross-referenced rather than absorbed.

This work adds one plugin: `object-calisthenics`. It covers Jeff Bay's nine
rules of object calisthenics, introduced in *The ThoughtWorks Anthology* (2008):

1. Only one level of indentation per method
2. Don't use the ELSE keyword
3. Wrap all primitives and strings
4. First-class collections
5. One dot per line
6. Don't abbreviate
7. Keep all entities small
8. No classes with more than two instance variables
9. No getters, setters, or properties

The central thesis: object calisthenics is not a competing principle set but a
**training discipline**. Bay framed the nine rules as an exercise, deliberately
extreme, to be applied rigorously on a small greenfield project (commonly cited
as the first ~1000 lines) to build object-oriented habits, then relaxed with
judgment in production. The deep principle behind each rule is already owned by
a sibling plugin (value objects by `domain-driven-design`, the Law of Demeter
and naming by `clean-code`, the Single Responsibility Principle by
`solid-principles`, the mechanics that satisfy the rules by `refactoring`). A
plugin that re-explained those principles would duplicate the collection at real
token cost. The value of `object-calisthenics` is the exercise framing plus the
concrete, actionable drill for each rule (how to satisfy it in TypeScript, and
when to relax it), with the underlying principle deferred to its owner.

## Scope

One plugin, `object-calisthenics`, bundling a single skill `object-calisthenics`.

A single skill, not nine by rule. The nine rules are one exercise applied
together, not nine distinct activities with different triggers. Splitting them
would both duplicate the siblings and misrepresent the practice. One skill
carries the discipline and the nine rules as drills; the per-rule mechanics live
in `references/`.

### Boundary (focused, with references out)

In scope:

- The discipline frame in `SKILL.md`: object calisthenics as an exercise
  (apply strictly to build habits, relax with judgment in production, not an
  architectural mandate); the nine rules stated concretely as drills in the
  sibling "smell -> move" style; the "when to relax" reflex; a compact ownership
  map pointing to the siblings; an "Adapt to your context" section; and a
  pointer to the reference.
- In `references/object-calisthenics.md`: the origin and sourcing; each rule
  with the smell it targets, the concrete mechanics to satisfy it in TypeScript
  (a short before/after), when relaxing it is the pragmatic choice, and a
  cross-reference to the sibling that owns the underlying principle; and a short
  note on the exercise as a whole (how the rules compound).

Ownership (the key boundary rule): `object-calisthenics` owns the **exercise and
the concrete drills**; each sibling remains the source of truth for the
principle a rule trains.

- **Rules 1 (one indentation), 2 (no else)** -> `refactoring` (Decompose
  Conditional, Replace Nested Conditional with Guard Clauses, Extract Function)
  and `clean-code` (small functions).
- **Rules 3 (wrap primitives), 4 (first-class collections)** ->
  `domain-driven-design` (value objects) and `refactoring` (the Primitive
  Obsession smell, Encapsulate Collection).
- **Rule 5 (one dot per line)** -> `clean-code` and `refactoring` (the Message
  Chains smell, Hide Delegate) for the Law of Demeter.
- **Rule 6 (don't abbreviate)** -> `clean-code` (naming).
- **Rule 7 (keep entities small)** -> `clean-code` (small functions and classes)
  and `solid-principles` (the Single Responsibility Principle).
- **Rule 8 (two instance variables)** -> `solid-principles` (SRP, high cohesion).
- **Rule 9 (no getters/setters)** -> `clean-code` and `domain-driven-design`
  (Tell Don't Ask, a rich domain model that encapsulates its state).

Cross-references are bidirectional but at different levels: `object-calisthenics`
points to each sibling for the depth of the principle; the siblings point back
for the drill that trains it. Nothing is duplicated.

Relationship to `simple-design`: both are craft disciplines rather than isolated
principles, and they are complementary. Simple design is the priority-ordered
yardstick for the refactor step; object calisthenics is a habit-building
exercise made of concrete constraints. The skill notes the pairing without
absorbing it.

Explicitly out of scope:

- Re-teaching the underlying principles in depth (owned by the siblings above).
- Language-specific enforcement tooling (linters, custom rules). The skill stays
  generic; enforcement configuration belongs in the user's own setup.

## Key decisions

- **One plugin, one skill** named `object-calisthenics`. Skill-only, no command
  or hook, consistent with `simple-design`, `simplicity-principles`, and
  `solid-principles`.
- **Discipline first.** The centre of gravity is the exercise framing and the
  concrete drill for each rule, plus when to relax. The deep "why" of each rule
  is deferred to the sibling that owns it. This maximises value and minimises
  weight and duplication.
- **The rules are concrete drills, kept actionable.** Unlike `simple-design`
  (pure meta), the value here includes the specific "how to satisfy this rule"
  mechanics, because that is what the exercise trains. The depth that is deferred
  is the underlying principle, not the drill.
- **Exercise framing is explicit and sourced.** The rules are deliberately
  extreme and meant to be applied rigorously as training, then relaxed with
  judgment; they are guidelines, not an architectural mandate. Sourced to Bay's
  essay and its common reading, without fabricated verbatim quotations.
- **Examples in TypeScript only.** Consistent with the family.

## Plugin structure

Mirrors the existing plugins, with a single skill:

```
plugins/object-calisthenics/
  .claude-plugin/plugin.json      # name, version 0.1.0, author, MIT license, homepage, keywords
  README.md                       # covers the skill
  LICENSE                         # MIT
  skills/object-calisthenics/
    SKILL.md                      # discipline frame plus the nine rules as drills
    references/
      object-calisthenics.md      # origin, per-rule mechanics and when-to-relax, cross-references
```

Writing conventions for all generated files: English, no em-dashes, words
written in full (standard acronyms such as SRP, SOLID, DDD, TypeScript are fine).

## Plugin contents

### `object-calisthenics/SKILL.md` (discipline frame plus drills)

- Frontmatter: `name` plus a trigger-oriented `description` (writing or
  reviewing object-oriented code, practising or drilling clean OO habits,
  deciding how strictly to apply the nine rules, recognising primitive obsession,
  deep nesting, feature envy, or anemic objects, applying Jeff Bay's object
  calisthenics, even when not named).
- **What object calisthenics is**: an exercise, applied rigorously to build
  habits and relaxed with judgment in production; not an architectural mandate.
- **The nine rules**, one line each in the "smell -> move" style, stated as
  concrete drills.
- **When to relax**: the pragmatic reading (the rules sharpen instincts;
  production keeps the ones that pay their way).
- **Ownership map**: the sibling pointers listed under Scope; the `simple-design`
  pairing.
- **Adapt to your context** section plus a pointer to the reference.

### `references/object-calisthenics.md` (depth, TypeScript drills)

- Sources: Jeff Bay, "Object Calisthenics", in *The ThoughtWorks Anthology*
  (Pragmatic Bookshelf, 2008); widely used secondary summaries. Attribution
  without fabricated page numbers or invented verbatim quotations.
- Each rule: the smell it targets, a short TypeScript before/after drill, the
  "when to relax" note, and the cross-reference to the owning sibling.
- A closing note on how the rules compound (small entities plus two instance
  variables plus no getters push toward value objects and Tell Don't Ask) and on
  pairing with `simple-design`.

## Research and validation approach

Content must be sourced, not written from memory.

- **Research pass done and ongoing.** The nine rules, their order, and their
  rationales were validated with WebSearch and WebFetch against reliable
  secondary sources (William Durand's write-up and others), and the exercise
  framing and the relax-in-production guidance were checked the same way. Any
  further specific claim added during authoring is checked likewise. Sourcing
  caveat: the primary essay PDF was not machine-readable, so no verbatim
  quotation from it is published; the framing is paraphrased and attributed.
- **Authoring tools.** `plugin-dev:plugin-structure` for the plugin scaffold and
  `plugin-dev:skill-development` for the skill structure and frontmatter, on top
  of the house format established by the sibling plugins.
- **Validation and review.** After authoring, the `plugin-dev:skill-reviewer`
  agent reviews the skill for triggering quality and the absence of overlap with
  the siblings (the drills must not re-teach the underlying principles), and the
  `plugin-dev:plugin-validator` agent validates the plugin structure. Content is
  reviewed for accuracy against the sources, internal consistency, and the
  discipline-first, pragmatism, and composability framing.

## Marketplace and integration

- Add one entry to `.claude-plugin/marketplace.json` (name, source,
  description, version `0.1.0`), placed in the principles cluster after
  `simple-design`. The `plugin.json` and `marketplace.json` descriptions are kept
  byte-for-byte identical (a repository invariant).
- Add one row to the root `README.md` plugins table.
- Add reciprocal cross-references to `object-calisthenics` in the sibling plugins
  it draws on (`clean-code`, `solid-principles`, `refactoring`, and
  `domain-driven-design` tactical design), matching the existing cross-reference
  pattern.

## Success criteria

- One installable plugin following the existing structure and conventions, with
  a single focused skill.
- A lean, discipline-first `SKILL.md` with depth in `references/`: the exercise
  framing plus the nine rules as concrete drills, with the underlying principle
  of each rule deferred to its owning sibling.
- Each rule is actionable in TypeScript from the reference alone, with an
  explicit "when to relax" note.
- Ownership is respected: `object-calisthenics` owns the exercise and the drills;
  each sibling remains the source of truth for the principle a rule trains;
  cross-references run both ways with no duplication.
- The exercise framing (apply strictly as training, relax with judgment in
  production, not an architectural mandate) is explicit and sourced.
- Content grounded in the sources and reviewed by the `plugin-dev:skill-reviewer`
  and `plugin-dev:plugin-validator` agents.
- Registered in the marketplace and listed in the root README, with the two
  manifest descriptions identical.
