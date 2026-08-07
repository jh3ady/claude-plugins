# Extract: design tokens on the canvas

`extract` pulls reusable values out of built artboards and consolidates them into Paper's native design token system,
then migrates the canvas onto the tokens. Tokens are CSS custom properties; styles reference them as
`var(--token-name)`.

## Contents

- [Discover the existing system](#discover-the-existing-system)
- [Identify what earns a token](#identify-what-earns-a-token)
- [Plan the vocabulary](#plan-the-vocabulary)
- [Create the tokens](#create-the-tokens)
- [Migrate the canvas](#migrate-the-canvas)
- [Verify](#verify)

## Discover the existing system

Read what already exists before inventing anything: `get_tokens` with the default JSON format lists every token with its
type. An established vocabulary is inherited, not replaced; extraction extends it in its own naming style. When the
session also has a code project with design tokens (Tailwind theme, CSS custom properties, DESIGN.md), read those too
and keep the two vocabularies aligned, because the design-to-code handoff preserves token names.

## Identify what earns a token

Sweep the target with `get_computed_styles` batched across representative nodes, then confirm each candidate's spread
with `find_nodes` on the literal value (a literal color search also finds usages already bound to a token, so the count
is honest).

A value earns a token when it appears three or more times with the same intent. Look for:

- colors doing the same job on different nodes (surface, text pair, action, border, semantic states);
- repeated spacing steps, radii, and container widths;
- repeated type combinations: family, size, weight, line height, letter spacing;
- near-duplicates (three grays within a few percent of each other) that are one decision rendered sloppily; consolidate
  to one value first.

Premature abstraction is worse than duplication: two values that look alike but carry different intents stay separate.
Do not tokenize every value; a token is a decision with a name, not a cache of whatever the canvas contains.

## Plan the vocabulary

Name by role, not by appearance, and follow the file's existing convention when one exists. A two-layer vocabulary
serves most files:

- **Primitives:** the raw scale (`--color-red-500`, `--spacing-4`,
  `--radius-md`).
- **Semantic roles:** what the design means (`--color-surface`,
  `--color-text-secondary`, `--color-action`), aliased onto primitives with
  `var(--color-red-500)` values.

Small files can live on semantic tokens alone; add the primitive layer when the palette genuinely has a scale. Paper
types each token (`color`,
`spacing`, `fontSize`, `fontWeight`, `fontFamily`, `lineHeight`,
`letterSpacing`, `radius`, `container`, `breakpoint`); pick the right type so the token panel stays organized.

## Create the tokens

Batch through `create_tokens`, in the order Paper expects: semantic colors before palette colors, neutrals first, then
primary, secondary, accent; every other type ordered smallest value first. Give each token a one-line
`description` saying when to use it; a token nobody knows how to use is noise. Reuse existing tokens before creating
near-duplicates, and use
`set_tokens` to rename, retarget, or delete tokens when consolidating an existing vocabulary.

## Migrate the canvas

Extraction ends when the canvas actually consumes the tokens:

1. `find_nodes` with the literal value to list every usage (scope with
   `nodeId` when the extraction targets one artboard).
2. Batch `update_styles` replacing the literal with `var(--token-name)`.
3. Repeat per token. A migration that leaves half the usages on literals has created a second source of truth, worse
   than none.

## Verify

- `get_tokens` reads as a coherent, typed, described vocabulary.
- `find_nodes` on each extracted literal returns only token-bound usages.
- One batched screenshot round confirms the canvas is visually unchanged; extraction is refactoring, and a pixel that
  moved is a defect.
- Report the new vocabulary to the user in one table: token, value, role.
