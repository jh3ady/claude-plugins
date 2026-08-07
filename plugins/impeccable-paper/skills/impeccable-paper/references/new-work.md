# New visual work on the canvas

Use this flow for `craft`, for `shape`, and whenever the request creates a new
surface or replaces a visual identity in Paper.

## Contents

- [Shape: discover before drawing](#shape-discover-before-drawing)
- [Decide what is already true](#decide-what-is-already-true)
- [Choose the right amount of invention](#choose-the-right-amount-of-invention)
- [Commit the world](#commit-the-world)
- [Record the decision](#record-the-decision)
- [Build with full commitment](#build-with-full-commitment)
- [Inspect and finish](#inspect-and-finish)

## Shape: discover before drawing

`shape` discovers what should be made and how it should work, then returns a
confirmed design brief without touching the canvas.

Ask two or three related questions per round through the structured question
tool when available, then wait. One round is the default; add a second only
when the answers expose a material gap. Assert the likely reading and invite
correction instead of turning obvious facts into menus.

Round 1, purpose, people, and outcome: what is this surface for, who reaches
it and in what state of mind, what must they understand or do, and what is
uniquely true here that a template could not claim.

Round 2, only for material unresolved decisions: real content and assets and
their realistic ranges; the states that matter (first-run, empty, loading,
error, success); intended fidelity and breadth; what must remain untouched;
binding platform or delivery constraints.

Never ask for CSS values or canned aesthetic lanes. Write the smallest useful
brief (job and audience, outcome and proof, selected direction, scope and
boundaries, states and ranges, interaction intent, constraints), present it for
confirmation, and stop. Shape never edits the canvas.

## Decide what is already true

Read the canvas: existing artboards, their tree summaries, screenshots, and
computed styles. When the session also has a code project, read PRODUCT.md and
DESIGN.md if they exist.

- **Redesign:** preserve product truth, content, and explicit brand
  commitments; replace the old visual world rather than polishing it. Build on
  a new artboard beside the original; the old artboard is evidence of what the
  subject is, not authority over what it becomes.
- **Established world:** inherit it. A coherent identity already on the canvas
  is documented and extended, not replaced.
- **Incomplete brand:** preserve confirmed assets and recognizable traits,
  then expand the system for the new surface.
- **No visual authority (empty file):** create a new world with the user.

A section or component inside an established artboard inherits that artboard.
Do not turn a local addition into a new identity exercise.

## Choose the right amount of invention

**Extend an existing artboard:** inherit its world and composition. Resolve
only the new purpose, content, hierarchy, and states.

**Create a whole surface inside an established world:** keep the visual system
fixed. Derive several materially different structures from the content, task,
and user behavior, and pick with the user when the choice is genuinely open.

**Create or replace the visual world:**

1. Name the product's unique mechanism in one sentence, the audience's real
   scene, its cultural home, and what this first surface must prove. Name the
   page this category always ships and its predictable opposite; both are the
   rut, and neither may appear among the candidates.
2. From the audience's cultural world, list seven concrete visual systems,
   artifacts, places, or rituals it knows by heart, each with one line on why
   it resonates and can carry the mechanism. The audience's world includes its
   graphic and screen traditions: notation, publications, identity programs,
   data graphics, interfaces. When more than three of the seven share one
   material family, the derivation stopped at the obvious artifact; dig until
   the list spans at least three families.
3. Turn the strongest three or four into complete directions: each joins a
   reusable visual world to a concrete first-surface experience, with an
   honest one-line risk.
4. Present the directions through the structured question tool: each with its
   thesis, palette, materials, first viewport, and risk. Always include the
   standing exit as the last option: the category standard, played straight.
   It is the user's door, never yours; never recommend it. When the user takes
   it, convention becomes the commitment: ask which two or three products this
   should sit alongside, make their craft level the bar, and execute the canon
   at full fidelity, without irony.
5. A re-roll eliminates every direction already shown. After two consecutive
   re-rolls, ask what quality is missing. A user-pinned direction beats
   everything.

Every direction presented must already be viable: claims true, a real palette
and component family, workable at full-surface scale. Demonstration content is
design material: author it at full fidelity and label it synthetic. What stays
uninventable are commercial and factual claims: prices, customers, benchmarks,
capabilities the product does not have.

## Commit the world

Pick a color strategy before picking colors: Restrained (neutrals plus one
accent; the default for Operate and Read), Committed (one saturated color
carries 30 to 60 percent of the surface), Full palette (3 to 4 named roles),
or Drenched (the surface is the color). Persuade and Experience surfaces have
permission for the bolder strategies; take them when the brief allows. Color
commits at page scale: fields that own whole regions, not accents scattered
over a neutral ground. Dark or light is never a default: write one sentence of
physical scene (who uses this, where, under what light) and let it force the
answer.

Choose faces like objects from the subject's world, in the mode's register,
and confirm each with `get_font_family_info` before committing. Operate and
Read surfaces are well served by workhorse UI faces; Persuade and Experience
surfaces want faces with a point of view. These training-data defaults mean
you stopped looking: Fraunces, Playfair Display, Cormorant, Lora, Crimson,
Newsreader, Syne, Space Grotesk, Space Mono, IBM Plex, Inter as display, DM
Sans, DM Serif, Outfit, Plus Jakarta Sans, Instrument Sans. Naming one anyway
requires a reason no other face could satisfy, and a subject association is
never that reason.

Calibration: AI-generated interfaces cluster around a few looks regardless of
subject: warm cream ground with high-contrast serif display and a terracotta
accent; near-black with one neon accent and glowing edges; broadsheet
hairlines with italic serif and small tracked mono labels. All are legitimate
when the brief calls for them. Where the brief leaves the aesthetic free,
landing in one means the self-check failed: if someone could guess the
aesthetic from the category alone, rework until they could not. A warm,
bookish, family, or child-facing subject does not soften this: cream plus
serif for a book subject is the default wearing the subject's clothes.

## Record the decision

Before building, write the direction as a contract the canvas itself carries:
a small text frame named `Direction contract`, placed beside the artboard,
five short blocks, 150 words at most.

- **THESIS:** the one idea this surface owns and the category default it
  refuses.
- **OWN-WORLD:** the palette and component language, specific enough to be
  recognizable with all content removed.
- **STORY:** what the visitor understands, believes, and does.
- **FIRST VIEWPORT:** the exact composition, what is where at what scale, and
  where the primary action sits.
- **FINISH:** "unreviewed is unfinished; this build ends with the batched
  inspection and the critique verdict."

If a block reads like a mood, the direction is not decided yet. The finishing
inspection audits the artboard against this contract.

## Build with full commitment

Create the artboard at the surface's real device dimensions, name it, and
build with `write_html` in coherent sections. Build the assigned direction,
not a safer interpretation of it. Commit every atom: navigation, buttons,
inputs, and links are rebuilt in the world's vocabulary; a stock component
inside a committed world is a lapse.

- **The first viewport is a thesis, not a header.** Demonstrate the mechanism
  immediately, at the scale the form has in life. The memory test: if someone
  left after one viewport, what would they describe an hour later? If the
  honest answer is a mood, the concept has not committed yet.
- **Prove the hero before building past it.** Screenshot the first viewport
  before any later section; every following section inherits its shortfall.
- **Prove, don't claim.** Show the subject doing its job: the interface at
  work, specifics a competitor could not copy-paste. Sections that restate a
  claim in different words add length, not substance.
- **Author the assets; never substitute chrome.** Great surfaces live on
  carefully made content: names, entries, copy, covers, textures. Gradients,
  glass, and generic icon tiles where an authored asset belongs are the gap
  wearing chrome. Icons are authored SVG in the world's own grammar.
- **Pace the scroll like a studio.** Vary density, scale, and quiet inside one
  grammar; a dense passage earns a quiet one, and the page ends anchored by a
  real close. One spacing rhythm throughout.

## Inspect and finish

Read `craft-floor.md` if not already loaded. Inspect the affected frames in
one batched screenshot round, critique the render against the user's request
and the direction contract, fix material gaps in one batch, and confirm with
one final round; two rounds is the ceiling. On a Persuade surface, verify the
mode did its job: a first-time visitor should know what this is, why it
matters, and what to do within seconds.

Then offer `critique` as a fresh-eyes pass; a build thread reviewing its own
work inherits its own optimism.
