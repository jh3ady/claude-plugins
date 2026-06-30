---
name: simplicity-principles
description: This skill should be used when writing, modifying, reviewing, or refactoring production code, applying the simplicity principles KISS, DRY, and YAGNI, even when they are not explicitly mentioned. Includes the rule of three and the trade-off between duplication and the wrong abstraction.
---

# Simplicity principles

Do less, but not blindly. Each principle below is a heuristic: apply it
when its cost is justified by the present need, not speculatively.

## Principles

- **KISS**: implementation is clever or elaborate beyond what the problem requires
  -> choose the simplest thing that works; prefer readable over short
- **DRY**: the same knowledge appears in multiple places, diverging silently
  -> establish one authoritative source; reference it from all call sites
- **YAGNI**: code exists for a scenario that is not yet a real requirement
  -> remove or defer; implement when the need is actual, not anticipated

## Trade-offs

**Rule of three before extracting.** Two similar-looking pieces of code may
represent genuinely distinct knowledge. Wait for a third instance before
extracting a shared abstraction; by then the right shape is usually clear.

**Duplication is far cheaper than the wrong abstraction.** (Sandi Metz) Premature
deduplication couples unrelated concepts and produces a parameterized tangle
that grows harder to change than the original duplication. DRY targets
knowledge (a single source of truth for a meaningful decision), not
incidental textual similarity.

**YAGNI defers speculative work, not obvious next steps.** When a requirement
is genuinely imminent and visible at a real boundary, a small, low-complexity
extension can be warranted. The question is whether today's assumptions will
hold, and whether the carry cost of the extra code is lower than the cost of
adding it later. That is a judgement call, not a blanket prohibition.

**KISS is not simplistic.** "Simple" means minimum necessary complexity, not
naive or easy to write. Some problems are inherently complex; KISS is about
not adding to that complexity through accidental cleverness.

## Adapt to your context

This skill stays generic on purpose. Layer your own conventions on top:

- Define what "simple enough" means for your domain and team.
- Add architecture rules and module boundaries in your own `CLAUDE.md` or a
  higher-priority skill. This skill does not impose them.

## Reference

For canonical definitions, before/after examples, and detailed trade-off
notes for each principle, read `references/simplicity.md`.
