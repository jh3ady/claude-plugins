# Simple design plugin: design

- Date: 2026-07-02
- Status: approved (design), pending spec review
- Author: Jean-Denis VIDOT

## Context and goal

The `jh3ady-claude-plugins` marketplace ships a consistent family of
engineering-principle plugins (`commit-conventions`, `review-conventions`,
`solid-principles`, `simplicity-principles`, `clean-code`, `modular-monolith`,
`dependency-injection`, `hexagonal-architecture`, `domain-driven-design`,
`event-sourcing`, `cqrs`, `screaming-architecture`, `test-driven-development`,
`legacy-code`, `refactoring`, `design-patterns`). They share one pattern: a
generic, composable skill presented as a pragmatic baseline rather than a
dogma, with a lean `SKILL.md`, depth pushed into `references/`, and adjacent
concepts cross-referenced rather than absorbed.

This work adds one plugin: `simple-design`. It covers Kent Beck's four rules
of simple design, formulated during Extreme Programming and popularized by
Martin Fowler (the *BeckDesignRules* bliki), J.B. Rainsberger, and Corey
Haines (*Understanding the Four Rules of Simple Design*, 2014):

1. Passes the tests
2. Reveals intention
3. No duplication (of knowledge)
4. Fewest elements

The central thesis: each individual rule is already owned in depth by a
sibling plugin (passes the tests by `test-driven-development`, reveals
intention by `clean-code`, no duplication by `simplicity-principles`, fewest
elements by `simplicity-principles` via YAGNI and by `refactoring`). A plugin
that re-explained each rule would duplicate the collection at real token cost.
The value of `simple-design` is entirely the **meta layer** the siblings do
not carry: the four rules as a single ordered decision procedure, the priority
ordering used to arbitrate when rules pull against each other, and the idea of
emergent design (design that falls out of refactoring under these four
constraints rather than from up-front planning). The skill is therefore
deliberately light on "what each rule is" and heavy on "how the four combine,
in what order, and to what end".

## Scope

One plugin, `simple-design`, bundling a single skill `simple-design`.

A single skill, not four by rule. The four rules are not four distinct
activities with different triggers; they are one yardstick applied together
during the refactor step. Splitting them would both duplicate the siblings and
misrepresent the practice, whose entire point is that the rules operate as a
set. One skill carries the ordered procedure; supporting detail lives in
`references/`.

### Boundary (focused, with references out)

In scope:

- The meta frame in `SKILL.md`: the four rules stated as a priority-ordered
  procedure; how to apply it (the yardstick for the refactor step of the
  red-green-refactor loop; emergent design over big up-front design);
  arbitration when rules conflict (the higher rule wins; Beck's reminder that
  when they genuinely conflict, "empathy wins over some strictly technical
  metric"); the distinction between "fewest elements" and YAGNI; a compact
  ownership map pointing to the siblings; an "Adapt to your context" section;
  and a pointer to the reference.
- In `references/simple-design.md`: the canonical origin and sourcing; each
  rule defined precisely with its one crucial nuance (duplication is of
  knowledge, not text; reveals intention is about the reader; fewest elements
  removes superfluous existing structure, it is not code golf); the ordering
  question treated accurately (see key decisions); one worked TypeScript
  before/after example applying the four rules in sequence during a single
  refactoring; and detailed trade-off notes with cross-references.

Ownership by rule (the key boundary rule): `simple-design` owns the **set and
its ordering**; each sibling remains the source of truth for its own rule.

- **Passes the tests** to `test-driven-development` (the failing-test-first
  discipline, self-testing code).
- **Reveals intention** to `clean-code` (naming, intent-revealing code and
  comments).
- **No duplication** to `simplicity-principles` (DRY, the rule of three,
  duplication versus the wrong abstraction).
- **Fewest elements** to `simplicity-principles` (YAGNI) and to `refactoring`
  (the mechanics that remove superfluous structure).

Cross-references are bidirectional but at different levels: `simple-design`
points to each sibling for the depth of a single rule; the siblings point back
to `simple-design` for the ordered decision procedure that combines them.
Nothing is duplicated.

Explicitly out of scope:

- Re-teaching any single rule in depth (owned by the siblings above).
- The "4 plus 1" or other modern extensions to the rule set; the plugin covers
  the canonical four and may mention extensions only as a one-line reference,
  not as content.

## Key decisions

- **One plugin, one skill** named `simple-design`. Skill-only, no command or
  hook, consistent with `simplicity-principles` and `solid-principles`.
- **Meta first.** The centre of gravity is the ordered procedure, arbitration,
  and emergent design. The "what" of each rule is reduced to a crucial-nuance
  line because the siblings own the depth. This maximises value and minimises
  weight.
- **Ordering treated accurately, sourced not asserted.** The four rules are in
  priority order, so "passes the tests" takes precedence. Fowler considers the
  order of rules 2 and 3 unimportant ("I've always seen their order as
  unimportant, since they feed off each other in refining the code"); Robert C.
  Martin in *Clean Code* lists no-duplication before reveals-intention. The
  skill adopts Fowler's order (tests, intention, duplication, fewest elements)
  as its default, notes Beck's original phrasing and the Fowler-versus-Martin
  ordering, and states plainly that the 2-3 ordering is not worth fighting over
  because the two rules feed each other.
- **"Fewest elements" is not YAGNI.** YAGNI declines to build for a speculative
  future need; "fewest elements" removes superfluous structure that exists now
  (needless indirection, classes or methods that do not earn their keep). The
  skill draws this boundary explicitly and points YAGNI to
  `simplicity-principles`.
- **Emergent design.** The skill frames simple design as the yardstick of the
  refactor step: design emerges from applying the four rules to working,
  tested code, not from big up-front design. Cross-references
  `test-driven-development` and `refactoring`.
- **Examples in TypeScript only.** Consistent with the family.

## Plugin structure

Mirrors the existing plugins, with a single skill:

```
plugins/simple-design/
  .claude-plugin/plugin.json      # name, version 0.1.0, author, MIT license, homepage, keywords
  README.md                       # covers the skill
  LICENSE                         # MIT
  skills/simple-design/
    SKILL.md                      # lean meta core: the ordered procedure
    references/
      simple-design.md            # origin, per-rule nuance, worked example, trade-offs
```

Writing conventions for all generated files: English, no em-dashes, words
written in full (standard acronyms such as TDD, DRY, YAGNI, XP, SOLID are
fine).

## Plugin contents

### `simple-design/SKILL.md` (lean meta core)

- Frontmatter: `name` plus a trigger-oriented `description` (writing,
  modifying, reviewing, or refactoring production code; deciding whether a
  design is "simple enough"; arbitrating between clarity and deduplication;
  applying Beck's four rules of simple design in priority order, even when not
  named).
- **The four rules, in priority order**, one line each in the sibling
  "smell -> move" style, with the statement that the order is a priority for
  arbitration.
- **How to apply it**: the yardstick for the refactor step; emergent design
  over big up-front design.
- **Arbitration**: the higher rule wins; the intention-versus-duplication case
  and Fowler's "they feed off each other"; Beck's "empathy wins over some
  strictly technical metric"; "fewest elements" is not code golf and not YAGNI.
- **Ownership map**: the four sibling pointers listed under Scope.
- **Adapt to your context** section plus a pointer to the reference.

### `references/simple-design.md` (depth, one TypeScript example)

- Sources: Beck, *Extreme Programming Explained* (the XP practice of simple
  design); Fowler, *BeckDesignRules* bliki; Corey Haines, *Understanding the
  Four Rules of Simple Design* (2014); the c2 wiki formulation. Attribution
  without fabricated page numbers or invented verbatim quotations beyond the
  short, verifiable phrasings gathered during research.
- Each rule defined precisely with its one crucial nuance and a cross-reference
  to its owning sibling.
- The ordering question, treated as in key decisions (priority order, Fowler
  versus Martin, the 2-3 order not worth fighting over).
- One worked TypeScript before/after example applying the four rules in
  sequence during a single refactoring.
- Trade-off notes: intention versus duplication; duplication versus the wrong
  abstraction (cross-reference `simplicity-principles`); premature removal of
  useful seams under "fewest elements" (cross-reference `refactoring` and
  `hexagonal-architecture`); simple design as emergent (cross-reference
  `test-driven-development`).

## Research and validation approach

Content must be sourced, not written from memory.

- **Research pass done and ongoing.** The canonical facts were validated with
  WebSearch and WebFetch against Fowler's *BeckDesignRules* bliki and
  references to Beck's original formulation and Corey Haines' book. Any further
  specific claim added during authoring is checked the same way. Sourcing
  caveat: no invented verbatim quotations or page numbers.
- **Authoring tools.** `plugin-dev:plugin-structure` for the plugin scaffold and
  `plugin-dev:skill-development` for the skill structure and frontmatter, on top
  of the house format established by the sibling plugins.
- **Validation and review.** After authoring, the `plugin-dev:skill-reviewer`
  agent reviews the skill for triggering quality and the absence of overlap
  with the siblings (the meta layer must not re-teach a single rule), and the
  `plugin-dev:plugin-validator` agent validates the plugin structure. Content is
  reviewed for accuracy against the sources, internal consistency, and the
  meta-first, pragmatism, and composability framing.

## Marketplace and integration

- Add one entry to `.claude-plugin/marketplace.json` (name, source,
  description, version `0.1.0`).
- Add one row to the root `README.md` plugins table.
- Add reciprocal cross-references to `simple-design` in the four sibling
  plugins (`clean-code`, `simplicity-principles`, `test-driven-development`,
  `refactoring`), matching the existing cross-reference pattern.

## Success criteria

- One installable plugin following the existing structure and conventions,
  with a single focused skill.
- A lean, meta-first `SKILL.md` with depth in `references/`: light on the "what"
  of each rule, heavy on the ordered procedure, arbitration, and emergent
  design.
- The four rules and their priority ordering are actionable in TypeScript from
  the reference alone.
- Ownership by rule is respected: `simple-design` owns the set and its ordering;
  each sibling remains the source of truth for its rule; cross-references run
  both ways with no duplication.
- The ordering is presented accurately and sourced (priority order, Fowler
  versus Martin, the 2-3 order not worth fighting over).
- "Fewest elements" is clearly distinguished from YAGNI.
- Content grounded in the sources and reviewed by the `plugin-dev:skill-reviewer`
  and `plugin-dev:plugin-validator` agents.
- Registered in the marketplace and listed in the root README.
