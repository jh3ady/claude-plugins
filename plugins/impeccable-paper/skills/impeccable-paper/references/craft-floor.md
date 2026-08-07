# Craft floor

Load this after the direction is settled, immediately before editing the canvas, and build without announcing the
checklist. A pinned brief or the committed visual world overrides anything here; your own habit does not.

## Verify

Each of these is a check on the built artboard, not an intention. Run them together in the batched inspection rounds;
the checks share one screenshot and one batched `get_computed_styles` call.

- **Contrast:** body and placeholder text at 4.5:1 or better, large text at 3:1 or better. Read the computed color
  values; do not eyeball a screenshot. On colored surfaces tint secondary text from that hue or the foreground, never
  gray.
- **Depth:** shadows carry an offset and a soft blur. A zero-offset colored halo is decoration.
- **Spacing:** tight groups, generous separation, more space above a heading than below it. Read the computed values.
- **Type:** body measure 45 to 75 characters with 65 to 75 as the prose ideal, display no larger than 6rem, tracking no tighter than -0.04em, balanced
  headings, obvious scale and weight steps. Run the real copy at every frame width and fix what overflows. Confirm every
  face actually renders with `get_font_family_info`; a fallback face silently substituted by the canvas is a failed
  check.
- **States:** a designed surface includes its states as sibling frames when the brief needs them: hover, disabled,
  loading, error, empty. A dashboard designed only in its happy state is half designed.
- **Copy:** the product's own language. Controls name their action; errors name the problem and the recovery. No lorem
  ipsum in a deliverable; author real content or clearly labeled synthetic content.
- **Coverage:** every brief requirement present and findable within seconds.
- **Layers:** every artboard, section, and meaningful group carries an intention-revealing name.

Motion on a canvas is intent, not implementation: when the surface's world depends on a signature motion, annotate it (a
small labeled note near the frame) or demonstrate it in an MP4 export; do not scatter decorative CSS animation through
frames that will be read as stills.

## Refuse

These are the category's defaults, not bans (with one exception marked below): the brief's own words can earn any of
them. Reaching for one when the axis is free means you were not deciding; recognizing that means rewriting the element,
not softening it.

Page scaffolds:

- Same-size cards of icon plus heading plus text as the page structure. Cards are the lazy container; nested cards are
  always wrong.
- The hero-metric template: big number, small label, supporting stats, accent.
- A kicker or eyebrow above a heading. This one is a ban, not a default: no brief earns it back. Delete the label and
  let the heading speak.
- Section numbers (01 / 02 / 03) unless the sequence itself carries information the reader needs.
- A modal for a task that needs neither interruption nor protected focus.

Surface habits:

- Gradient text. Emphasis comes from weight or size.
- Glass and blur as decoration rather than as a specific effect.
- A colored left or right border thicker than 1px on cards, list items, callouts, or alerts.
- Hard offset shadows (4px 4px 0) outside a world that is actually neobrutalist. The zero-blur block shadow is a
  costume, not a depth system.
- Sparklines, progress rings, and soft-shadowed rounded rectangles standing in for content.
- Monospace as a costume for "technical" rather than for code, data, or measurement.
- A system display face (Impact, Arial Black, the platform sans) as the display voice of an own-world page. Check
  availability with
  `get_font_family_info` and pick a face whose character matches the approved lettering; the closest installed font is a
  failure, not a fallback.
- Unicode glyphs or emoji standing in for an icon system. Icons are drawn, as authored SVG in one consistent stroke and
  weight, written to the canvas through `write_html`.
- Light or dark picked by category. Pick it from the use scene: who, where, under what ambient light.

The floor holds the mechanics; it never picks the direction. With every check green, spend the artboard on the committed
world, and when torn between refined and committed, commit.
