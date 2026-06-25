---
name: solid-principles
description: Apply the five SOLID principles (SRP, OCP, LSP, ISP, DIP) when writing, modifying, reviewing, or refactoring production code, even when SOLID is not explicitly mentioned. Includes pragmatic guardrails against over-engineering and speculative abstraction.
---

# SOLID principles

A reusable baseline of five design heuristics. Apply them pragmatically, not
as a dogma: each principle has a cost (indirection, extra types, cognitive
load) that must be weighed against its present payoff.

## Principles

- **SRP**: class couples unrelated concerns (multiple independent reasons to change)
  -> separate into focused units, one cohesion boundary each
- **OCP**: adding a variant requires editing a working conditional
  -> extract the varying behavior behind an interface; extend, do not modify
- **LSP**: a subtype breaks the parent contract (wrong return type, stricter precondition)
  -> honor the contract or replace inheritance with composition
- **ISP**: a class is forced to implement interface methods it cannot satisfy
  -> split the fat interface into narrow, client-specific interfaces
- **DIP**: high-level logic hard-codes a low-level dependency (untestable, inflexible)
  -> introduce a seam (interface or abstract type) and inject the concrete implementation

## Guardrails

Do not apply a principle speculatively:

- The question for DIP and ISP is not how many implementations exist today. It
  is whether a real boundary or seam justifies the abstraction now: an
  architectural port over an external system (database, message broker,
  third-party API), a genuine testing seam, or a contract you want to stabilize.
  An interface with a single implementation at such a boundary is DIP done
  correctly. What is speculative is adding indirection over an internal
  collaborator that has no boundary role and no testing or inversion reason,
  purely to look SOLID.
- Do not split a class just because it has many methods; split when two genuinely
  independent reasons to change are observable (SRP class explosion).
- Do not add an abstraction layer before a second variation exists (OCP premature
  abstraction; follow the rule of three).
- A principle that adds indirection without a present payoff is over-application.

Prefer the simplest design that meets the current need. Complexity is a cost,
not a virtue.

## Adapt to your context

This skill stays generic on purpose. Layer your own conventions on top:

- Define your project's architecture rules and module boundaries.
- Add team-specific guidelines (naming, layering, allowed patterns) in your own
  `CLAUDE.md` or a higher-priority skill. This skill does not impose them.

## Reference

For canonical definitions, before/after examples in TypeScript, and detailed
"when not to apply" notes for each principle, read `references/solid.md`.
