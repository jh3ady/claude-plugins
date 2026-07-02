# simple-design

A Claude Code plugin that applies Kent Beck's four rules of simple design to
the code you write and review, pragmatically. Its value is not re-teaching each
rule (the sibling plugins do that) but carrying the meta layer none of them
does: the four rules as one priority-ordered decision procedure, how to
arbitrate when they pull against each other, and simple design as something that
emerges from refactoring rather than from up-front planning.

It stays generic on purpose: compose it with your own project conventions and
your team or personal rules.

## What it does

When you write, modify, review, or refactor production code, judge whether a
design is "simple enough", or hesitate between clarity and deduplication, the
bundled skill applies Kent Beck's four rules in priority order:

1. **Passes the tests**: correctness, verified, is the non-negotiable floor.
2. **Reveals intention**: the code makes its meaning obvious to the next reader.
3. **No duplication**: every piece of knowledge has one authoritative source
   (duplication of knowledge, not of text).
4. **Fewest elements**: no class, method, or indirection that the first three
   rules do not require.

The skill adds what the individual rules do not:

- **The ordered procedure.** The four rules are one yardstick, applied together
  during the refactor step of the red-green-refactor loop, in a fixed priority
  order.
- **Arbitration.** When rules conflict, the higher one wins; the order of
  "reveals intention" and "no duplication" is not worth fighting over because
  they feed each other; and when a genuine conflict remains, empathy for the
  reader is the tie-breaker.
- **Emergent design.** A simple design is the result of applying the four rules
  to working, tested code, not of a design decided before the code exists.
- **The boundary with YAGNI.** "Fewest elements" removes superfluous structure
  that exists now; it is neither code golf nor a licence to strip useful seams,
  and it is not the same as declining to build for a speculative future need.

## Relationship to other plugins

This skill owns the set of rules and their ordering. Each rule's depth lives in
a sibling plugin:

- `test-driven-development`: owns "passes the tests", the failing test first
  and self-testing code that make the other three rules safe to pursue.
- `clean-code`: owns "reveals intention", naming and intent-revealing code and
  comments.
- `simplicity-principles`: owns "no duplication" (DRY, the rule of three,
  duplication versus the wrong abstraction) and "fewest elements" on its YAGNI
  side (not building for a speculative future need).
- `refactoring`: owns the mechanics of the refactor step that simple design is
  the target of, including the safe removal of superfluous structure.

Cross-references run both ways: this plugin points to each sibling for the depth
of a single rule; the siblings point back here for the ordered procedure that
combines them. Nothing is duplicated.

## Install

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install simple-design@jh3ady-claude-plugins
```

## Adapt to your context

This plugin is a baseline procedure, not a dogma. Layer your own conventions on
top: define what "simple enough" means for your domain and team, decide where
the ceiling on deduplication sits, and configure architecture rules and module
boundaries in your own `CLAUDE.md` or a higher-priority skill. The plugin does
not impose them.

## License

Released under the [MIT License](LICENSE).
