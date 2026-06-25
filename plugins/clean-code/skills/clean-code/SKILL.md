---
name: clean-code
description: Apply clean code craftsmanship (naming, small focused functions, intent-revealing comments, error handling) when writing, modifying, reviewing, or refactoring production code, even when clean code is not explicitly mentioned. Pragmatic, not dogmatic fragmentation.
---

# Clean code

Readable by default. Applied pragmatically: each heuristic has a cost and must earn
its keep against the actual complexity of the code at hand.

## Heuristics

- **Naming**: names use cryptic abbreviations or placeholders (`tmp`, `flg`, `d`)
  -> use intent-revealing names that encode purpose, unit, and role; for methods, let the verb reveal outcome and cost (`find`/`get`, `load`/`read`/`fetch`)
- **Functions**: a function mixes concerns, takes flag arguments that split its behavior, or buries its main path under deeply nested conditionals
  -> extract responsibilities so each function does one thing at one abstraction level; use guard clauses (early returns) to flatten entry validation
- **Comments**: comments restate what the code already says, or dead code accumulates
  -> delete redundant comments; keep comments that explain why, not what
- **Error handling**: null propagates silently, or error codes scatter through callers
  -> prefer exceptions for truly exceptional conditions; return Optional or empty collections for expected absence
- **Boundaries**: third-party calls are scattered across modules, coupling to a vendor API
  -> wrap volatile external dependencies behind a thin adapter; write learning tests

## Guardrails

Do not apply these heuristics as absolute rules:

- Do not fragment functions into trivially small pieces for their own sake. A 30-line
  function that does one clear thing is better than a dozen 3-line helpers whose
  relationship is obscure. The goal is a single level of abstraction, not a line-count target.
- Comments explain intent that code cannot. They are not banned. The smell is redundant
  comments that restate the code, not comments as such. Rationale, caveats, citations,
  and non-obvious constraints are valuable.
- Not every short name is wrong. Conventional loop indices (`i`, `j`), domain-standard
  abbreviations (`url`, `id`, `ctx`), and well-scoped locals can be short without harm.
- Exceptions vs. error codes and null avoidance are language-dependent and contextual.
  Match the idiom of the language and the semantics of the operation.
- Not every third-party integration warrants a wrapper. Reserve adapters for volatile,
  replaceable dependencies; wrapping stable standard libraries adds indirection without payoff.

The simplest readable design wins.

## Adapt to your context

This skill stays generic on purpose. Layer your own conventions on top:

- Add your project's naming conventions, error-handling strategy, and module boundaries
  in your own `CLAUDE.md` or a higher-priority skill. This skill does not impose them.

## Reference

For canonical rules, before/after examples, and detailed over-application notes for each
area, read `references/clean-code.md`.
