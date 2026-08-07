# Refinement playbooks

One section per refinement command. Every command here preserves the incumbent
visual world, content, and everything outside scope; identity replacement
belongs to `new-work.md`. Every command starts by reading the target (tree,
screenshot, computed styles), edits surgically with `update_styles` and
`set_text_content`, and verifies in the bounded rounds `paper-workflow.md`
defines. Every command ends by offering `polish` as the next step, never by
running it unasked, unless it was `polish`.

## Contents

- [Polish](#polish)
- [Bolder](#bolder)
- [Quieter](#quieter)
- [Distill](#distill)
- [Layout](#layout)
- [Typeset](#typeset)
- [Colorize](#colorize)
- [Delight](#delight)
- [Clarify](#clarify)
- [Adapt](#adapt)

## Polish

Polish is refinement, never concealed redesign. If the concept itself is
wrong, say so and recommend `craft` or `bolder` instead of smuggling in a
replacement.

1. Establish the system: read the canvas's own conventions from `get_tokens`
   when the file has a token vocabulary, and from computed styles across
   sibling frames. Classify each drift: missing token or system value,
   one-off implementation, conceptual mismatch, or local defect. Fix the
   cause at the narrowest correct level, and promote a genuinely reusable
   value to a token (see `extract.md`) rather than repeating the literal.
2. Gather the backlog: open comment threads on the target
   (`list_comment_threads`, then `get_comment_thread` on the relevant ones)
   and any prior critique summary on the canvas. The team's feedback comes
   first; resolve each fully addressed thread with
   `set_comment_thread_status` and report which were closed.
3. Triage in order: the team's open threads and misleading or broken-looking
   regions first, then missing states the brief needs, then hierarchy and
   layout drift, then visual inconsistencies, then layer naming.
4. Polish the whole frame to one bar; do not perfect one corner while leaving
   the rest below it. Keep same-role typography identical across frames, fix
   optical as well as mathematical alignment, verify contrast in every state
   frame, keep icon families in one stroke and weight.
5. Verify with the bounded rounds and leave the layers named.

## Bolder

Amplification, almost always scoped to a region that already exists. The
surrounding frame, its system, and its conventions are the given. The reflex
answer, reaching for more effects, is the opposite of bold; reject it first.

- Scope is sovereign: touch only the named target; add no colors, fonts,
  radii, or primitives the frame does not already own. If the system cannot
  express the direction, ask before expanding it.
- A region reads flat because it quietly opts out of the system's strongest
  moves. Bring it up to the expressive level its neighbors already reach, in
  the system's own vocabulary.
- Commit, then clarify: make one decisive move completely, then quiet
  everything around it so the move is legible. If every element got louder,
  the region got flatter.
- The skeleton test: strip the copy and study the bare structure in the
  screenshot. If the region only works once the words return, the boldness is
  in the text size, not the design.

## Quieter

Quiet design is harder than bold design; subtlety needs precision. Quieter
means refined, never generic: think luxury, not laziness.

- Persuade and Experience: restrain the palette, add whitespace and
  typographic air; reduce drama without eliminating the point of view.
- Operate and Read: reduce visual noise; fewer background accents, flatter
  containers, less color, less decoration. The tool disappears into the task.
- Moves, applied with `update_styles`: desaturate toward 70 to 85 percent,
  let neutrals dominate with color as accent, tint grays warm or cool instead
  of pure gray, never gray text on a colored surface, drop weights one step
  (900 to 600, 700 to 500), thin or remove borders, remove decorations that
  do not serve hierarchy, even out spacing into one rhythm.
- Never flatten hierarchy completely, never strip all color, never remove the
  anchors. The point of view must survive the cuts.

## Distill

Strip to essence. Every element must justify its existence; simplicity is
removing obstacles between users and their goals, not removing features.

- Find the ONE primary goal of the frame; there should be exactly one.
- Information: remove redundant copy and secondary actions, hide complexity
  behind clear entry points, keep one primary action with few secondaries.
- Visual: 1-2 colors plus neutrals, one family with 3-4 sizes, remove
  containers that only decorate, never nest cards, one spacing scale.
- Copy: cut every sentence in half, then do it again; active voice; say it
  once.
- Never simplify into ambiguity: mystery is not minimalism, and information
  users need to decide stays.

## Layout

Layout turns product priority into reading order, grouping, rhythm, and
usable space. Diagnose the structural problem on the screenshot before moving
boxes.

- Assess: the squint test on the screenshot (do primary, secondary, and major
  groups still read in order with detail blurred?); grouping by proximity
  versus containers compensating for weak proximity; rhythm (deliberate tight
  and generous intervals versus one repeated gap); density fit to use
  frequency; behavior across the device frames that exist.
- Set the spatial thesis before editing: the primary path, what belongs
  together, which element leads, the intended density.
- Apply: group by meaning with proximity before containers; use a documented
  spacing scale (a 4-unit base gives the useful middle steps); let hierarchy
  follow product priority, not habit; keep repetition where it supports
  recognition and break it only when content or priority changes.
- Verify with the squint test again on the fresh screenshot.

## Typeset

Typography carries information, hierarchy, and voice. Improve it inside the
established world; face replacement that would create a new identity routes
through `new-work.md`.

- Assess from computed styles: the roles in use, whether adjacent sizes are
  too close to carry different jobs, whether repeated roles stay identical
  across frames, body measure within 45 to 75 characters (65 to 75 is the
ideal for prose; denser roles may run shorter), and whether every
  face renders (`get_font_family_info`).
- Set the system: the fewest roles and families that make hierarchy
  unmistakable; combine size, weight, space, and tone instead of asking size
  alone to do all the work.
- Apply: body at a comfortable reading size for the frame's device; line
  height tuned inversely with measure; light text on dark surfaces gets
  slightly more line height, a touch more tracking, and one step more weight
  when the face needs it; tabular figures for data.
- Operate and Read frames: one well-tuned family, fixed scale with a 1.125 to
  1.2 ratio, is often right. Persuade and Experience frames: display type may
  carry the voice.

## Colorize

Introduce color as hierarchy, meaning, and atmosphere. Preserve confirmed
brand colors; do not replace a visual world under the guise of colorizing it.

- Audit first: which colors are confirmed commitments, where grayscale
  obscures hierarchy or state, which contrast pairs fail.
- Choose a strategy and name it before editing: the emotional temperature,
  the dominant relationship, and the dosage. Build roles, not a bag of
  swatches: surfaces, text pair, action, borders, semantic states.
- Apply at system scale: the strongest color owns a deliberate region or role
  instead of scattering tiny accents; the primary action stays easy to find;
  on colored surfaces derive secondary text from the surface hue; in dark
  frames compose elevation explicitly, never invert mechanically.
- Verify computed contrast on every pair: 4.5:1 body, 3:1 large text and
  controls, and never let color be the only carrier of a meaning.

## Delight

Product character at moments that earn it, not a layer of generic whimsy.

- Find the opportunity: effort worth acknowledging, an empty or first-use
  frame that can orient, an error moment that needs empathy, a detail that
  could express the brand.
- One delight thesis: state in one sentence what the user should feel and why
  that feeling belongs to this product; choose the smallest device that
  delivers it, derived from the product's world, never a stock catalog.
- Protect the experience: delight must not obscure the primary task, override
  conventions, or add unrequested claims. Copy uses the product's language;
  generic whimsy is worse than neutral clarity.
- The verification: the moment is specific enough that a neighboring product
  could not use it unchanged.

## Clarify

Rewrite unclear interface text on the canvas so users understand what
happened, what matters, and what to do next. Preserve factual meaning and
brand voice; ask before changing claims.

- Audit the whole flow across frames, not isolated strings: ambiguous verbs,
  jargon, vague labels, missing consequences, inconsistent terminology,
  redundant headings and intros.
- For each state, decide the one fact the user needs now, the next action,
  and the tone for the moment. Say each idea once.
- Actions name what will happen, with a specific verb and object; destructive
  confirmations name the object and consequence on the button, never `Yes` or
  `OK`. Labels persist; placeholders are examples. Errors answer what failed,
  why when known, and how to recover. Empty states distinguish first use from
  no-results and give the next action.
- Apply with batched `set_text_content`; verify by rereading the flow in the
  screenshots at realistic widths.

## Adapt

Derive the surface at other device widths as sibling frames.

1. Ask or infer the target devices; use their exact viewport dimensions.
2. `duplicate_nodes` the source frame per device, `move_nodes` into a labeled
   row, `rename_nodes` (`Home / desktop 1440`, `Home / mobile 390`).
3. Adaptation is structural, not proportional shrinking: reorder, collapse,
   reflow, or reveal based on what remains important at that width. Touch
   targets stay usable; type stays at a readable size rather than scaling
   down with the frame.
4. Verify all frames in one screenshot round: reading order intact, nothing
   overflowing, hierarchy preserved at every width.
