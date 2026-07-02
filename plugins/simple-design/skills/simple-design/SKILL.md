---
name: simple-design
description: This skill should be used when judging whether a design is "simple enough", when arbitrating between clarity and deduplication, or when writing, modifying, reviewing, or refactoring production code, applying Kent Beck's four rules of simple design in priority order (passes the tests, reveals intention, no duplication, fewest elements), even when they are not explicitly mentioned. It carries the ordered decision procedure and the arbitration between the rules; each rule's depth is owned by a sibling plugin.
---

# Simple design

Kent Beck's four rules of simple design are one yardstick, not four. Their
value is the ordered procedure: a design is simple when it passes the tests,
reveals intention, has no duplication, and uses the fewest elements, in that
order of priority. Apply them together during the refactor step; do not treat
any single rule in isolation.

Each rule is defined and detailed by a sibling plugin (see the ownership map).
This skill owns only what none of them carries: the set, its ordering, and how
to arbitrate when the rules pull against each other.

## The four rules, in priority order

The order is a priority for arbitration, not a checklist sequence. When two
rules conflict, the higher one wins.

1. **Passes the tests**: the design does not work, or its behaviour is not
   verified -> make it correct and covered first; nothing else matters until it
   works.
2. **Reveals intention**: the code works but a reader cannot tell what it means
   or why -> name and shape it so the intent is obvious to the next reader.
3. **No duplication**: the same piece of knowledge lives in more than one place
   and can diverge -> establish one authoritative source (duplication of
   knowledge, not of text).
4. **Fewest elements**: classes, methods, or indirection remain that no longer
   earn their keep -> remove what the first three rules do not require.

## How to apply it

**It is the yardstick of the refactor step.** In the red-green-refactor loop,
"green" satisfies rule 1. Refactoring is the act of driving the working code up
rules 2, 3, and 4. Simple design is what "refactor" aims at.

**Design emerges; it is not planned up front.** A simple design is the result
of repeatedly applying these four rules to working, tested code, not of a big
design decided before the code exists. Let structure appear under the rules
rather than imposing it in advance.

## Arbitration when the rules conflict

**The higher rule wins.** Never sacrifice correctness (rule 1) for elegance.
Prefer a clear name (rule 2) over a fold that removes textual duplication but
hides intent.

**Intention versus duplication (rules 2 and 3).** These feed each other far
more often than they conflict: removing duplication usually clarifies intent,
and naming intent usually exposes the real duplication. Their relative order is
not worth fighting over. When they do pull apart (deduplicating would obscure
what the code means, or two fragments look alike but mean different things),
favour intention and leave the apparent duplication; similar-looking code is
not duplicated knowledge. See `simplicity-principles` for duplication versus
the wrong abstraction.

**Empathy is the tie-breaker.** When a genuine conflict remains, Beck's guidance
is that empathy for the reader wins over any strictly technical metric. Optimise
for the next person who reads the code.

**Fewest elements is not code golf, and not YAGNI.** Rule 4 removes superfluous
structure that exists now (needless indirection, a class or method that does not
earn its keep); it does not mean the shortest possible code, and it does not
mean removing a useful seam. Declining to build for a speculative future need is
YAGNI, owned by `simplicity-principles`.

## Ownership map

This skill owns the set and its ordering. Each rule's depth lives elsewhere:

- **Passes the tests** -> `test-driven-development` (failing test first,
  self-testing code) and `refactoring` (refactor only under a green suite).
- **Reveals intention** -> `clean-code` (naming, intent-revealing code and
  comments).
- **No duplication** -> `simplicity-principles` (DRY, the rule of three,
  duplication versus the wrong abstraction).
- **Fewest elements** -> `simplicity-principles` (YAGNI) and `refactoring`
  (the mechanics that remove superfluous structure).

## Adapt to your context

This skill stays generic on purpose. Layer your own conventions on top:

- Define what "simple enough" means for your domain and team, and where the
  ceiling on deduplication sits.
- Add architecture rules and module boundaries in your own `CLAUDE.md` or a
  higher-priority skill. This skill does not impose them.

## Reference

For the canonical origin and sourcing, each rule's crucial nuance, the ordering
question (Fowler versus Martin), a worked TypeScript example applying the four
rules in sequence, and detailed trade-off notes, read
`references/simple-design.md`.
