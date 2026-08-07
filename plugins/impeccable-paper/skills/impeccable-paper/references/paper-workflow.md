# Working the Paper canvas through the MCP server

How to drive the Paper MCP tools with precision. Read this once per session before the first canvas edit.

## Contents

- [Connection and context](#connection-and-context)
- [Reading the canvas](#reading-the-canvas)
- [Writing to the canvas](#writing-to-the-canvas)
- [Layer hygiene](#layer-hygiene)
- [Verification loop](#verification-loop)
- [Variants](#variants)
- [Handoff](#handoff)

## Connection and context

Paper Desktop runs the MCP server locally while a file is open. If any tool call fails with a connection error, ask the
user to open Paper Desktop with the target file, then retry once. Do not loop on retries.

Start every task with context, cheapest first:

1. `get_basic_info` for the file name, node count, and artboard dimensions.
2. `get_selection` for what the user is pointing at. Selection is the user's brief; prefer it over guessing among
   artboards.
3. `get_tree_summary` on the relevant artboard for structure without pixels.
4. `get_screenshot` (1x for orientation, 2x when judging craft details) for visual truth.
5. `get_computed_styles` on specific nodes when a judgment needs real values:
   contrast, type sizes, spacing. Batch node IDs into one call.
6. `get_font_family_info` before committing to a face, so the design never depends on a font the canvas cannot render.

Read before you write, always. An edit made without reading the incumbent structure is a guess wearing confidence.

## Reading the canvas

- The tree summary is for structure and naming; the screenshot is for visual judgment; computed styles are for
  measurable claims. Use each for what it proves and do not substitute one for another. A screenshot cannot prove a
  contrast ratio; computed styles cannot prove hierarchy reads well.
- `get_node_info` and `get_children` read one node's properties and direct children; prefer them over repeated
  `get_tree_summary` calls when working a small region of a large artboard.
- `get_jsx` shows the design as React with Tailwind or inline styles. Use it when a precise understanding of an existing
  implementation matters (spacing systems, token-like consistency), not as a default read.
- `get_fill_image` retrieves image fills when the content of an image drives a decision (art direction, cropping,
  legibility of text over it).

## Writing to the canvas

Paper parses real HTML and CSS, which makes `write_html` the native brush for structure and `update_styles` the native
brush for refinement.

- **New surfaces:** `create_artboard` first, with an intention-revealing name and the exact device dimensions, then
  `write_html` to build inside it. Build in coherent sections rather than one giant blob, so a failed parse costs one
  section, not the page.
- **Structural changes:** `write_html` replaces or inserts nodes. Use it when the topology changes (new sections,
  reordered hierarchy).
- **Refinement:** `update_styles` and `set_text_content`, both batched. A polish pass that rewrites whole trees to
  change three colors is destructive and loses the user's manual work. Patch surgically.
- **Reuse:** `duplicate_nodes` deep-clones with an ID mapping; use it for variants, responsive frames, and repeated
  components instead of regenerating near-identical HTML.
- **Reorganization:** `move_nodes` repositions and reparents; `rename_nodes`
  keeps layers legible; `delete_nodes` removes. Confirm with the user before deleting anything you did not create in
  this session.

Author real CSS, not framework shorthand, unless the canvas already uses Tailwind-style classes. Match whatever
convention the incumbent artboards use.

## Layer hygiene

Named layers are the canvas equivalent of clean code. Every artboard, section, and meaningful group gets an
intention-revealing name (`Hero`, `Pricing tiers`,
`Footer / legal`), applied with `rename_nodes` in batches. A canvas full of
`div` and `Frame 47` is unfinished work, whatever the pixels look like.

## Verification loop

The loop is bounded, and the ceiling covers the whole cycle:

1. Build fully. Do not screenshot after every micro-edit.
2. One batched `get_screenshot` round across the affected frames, desktop and mobile together when both exist.
3. Fix everything that round shows, in one batch of edits.
4. At most one confirming round.
5. `finish_working_on_nodes` to clear the working indicators, then report.

Models systematically believe their HTML and CSS recreation succeeded when it did not; the screenshot is the authority,
never your conviction. But the authority is consulted in rounds, not after every brushstroke.

## Variants

`variants` explores committed alternatives side by side, the canvas-native version of in-browser variant iteration:

1. Resolve the target frame and read it (tree, screenshot, computed styles).
2. Agree with the user on the axis of exploration (layout, color strategy, typographic voice, density) and the count, 2
   to 4.
3. `duplicate_nodes` the target once per variant, `move_nodes` the copies into a row beside the original with even gaps,
   `rename_nodes` each copy with the direction it will carry (`Hero / brutalist`, `Hero / editorial`).
4. Build each variant fully committed. Variants that differ by one hue are not variants; each must be a direction
   someone could choose over the others for a reason they can name.
5. One batched screenshot round across all variants, fix, then present them to the user with one line per variant on
   what it argues. The user picks; delete or keep the losers as the user prefers.

## Handoff

- `export` produces PNG, JPG, SVG, or MP4 with scale and dimension overrides. Ask for the intended use before choosing
  format and scale (2x PNG for review, SVG for icons and illustrations).
- For production code, do not hand-translate pixels from memory: use a design-to-code flow (the official Paper plugin
  ships one) that reads the frame's structure, styles, and text through the MCP server and generates code in the
  project's own conventions.
