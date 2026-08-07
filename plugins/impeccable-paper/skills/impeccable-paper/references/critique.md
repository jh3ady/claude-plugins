# Critique and audit on the canvas

`critique` is a design review with heuristic scoring. `audit` is the
mechanical subset. Both read the canvas through the Paper MCP server; neither
edits it. The chat response is the primary deliverable.

## Contents

- [Setup](#setup)
- [Two isolated assessments](#two-isolated-assessments)
- [Assessment A: design review](#assessment-a-design-review)
- [Assessment B: mechanical audit](#assessment-b-mechanical-audit)
- [The combined report](#the-combined-report)
- [Audit section](#audit-section)
- [Heuristics scoring](#heuristics-scoring)

## Setup

Resolve the target to a concrete artboard or node: the user's named frame, or
the current selection, or ask the user to select in Paper. Gather the
evidence once: `get_tree_summary`, `get_screenshot` at 2x of the whole frame
and of each major section as its own crop (one full-page thumbnail hides
exactly the failures that matter: crude controls, wrong lettering character,
flattened material), and `get_computed_styles` batched over the text, control,
and surface nodes. Read `craft-floor.md` too: its refuse list is the checklist
Assessment B scans against. Also gather the team's own findings:
`list_comment_threads` scoped to the target (default status `open`), reading
any relevant thread in full with `get_comment_thread`.

## Two isolated assessments

When a subagent tool is available, run Assessment A and Assessment B as two
isolated subagents so the mechanical findings cannot anchor the design
judgment; synthesize only after both return. Without subagents, run A fully
and record it before starting B, and say so in the report header. Detector
output anchoring the design eye is the failure this isolation exists to
prevent.

## Assessment A: design review

Think like a design director looking at the screenshots and the structure.

- **Design specificity:** is the composition and visual language grounded in
  this product, or could an unrelated product use it unchanged? Judge this
  before seeing any mechanical findings.
- **Holistic design:** hierarchy, information architecture, emotional fit,
  composition, typography, color, states, copy, edge cases.
- **Cognitive load:** decision points with more than 4 visible options,
  competing calls to action, regions where nothing leads.
- **Emotional journey:** peak-end rule, reassurance at high-stakes moments.
- **Nielsen heuristics:** score all 10 from 0 to 4 (visibility of system
  status, match with the real world, user control, consistency, error
  prevention, recognition over recall, flexibility, aesthetic and minimalist
  design, error recovery, help). Mark heuristics the surface cannot exhibit
  (a static marketing frame has no error recovery) as n/a instead of forcing
  a number.

Return: a specificity verdict, heuristic scores, 2-3 strengths, 3-5 priority
issues ranked by severity, and minor observations.

## Assessment B: mechanical audit

Measured claims only, from computed styles and the tree:

- Contrast ratios for every text and control color pair, against 4.5:1 for
  body and 3:1 for large text and controls.
- Type scale: distinct steps, body measure 45 to 75 characters with 65 to 75
  as the prose ideal, tracking and
  weight coherence, faces confirmed present via `get_font_family_info`.
- Spacing: one scale, tight groups and generous separations, more space above
  headings than below.
- The refuse list from `craft-floor.md`: eyebrows, gradient text, nested
  cards, thick colored side borders, emoji as icons, hero-metric templates.
- Layer hygiene: unnamed artboards, sections, and groups.
- Content: lorem ipsum, truncated or overflowing real copy, unlabeled
  synthetic claims.

Return findings with node names and measured values, plus false positives
noted as such.

## The combined report

Synthesize both assessments into one report: header (target, method, whether
assessments were isolated), specificity verdict, scored heuristics, findings
ranked P0 to P3 with the evidence for each, strengths, and 2-3 recommended
next commands from this skill with one line each. Cross-reference open
comment threads: a finding the team already flagged cites its thread, and a
thread neither assessment reproduced is listed with your verdict on it. The
MCP server cannot create comments, so the report lives in chat; offer,
without doing it unasked, to write a compact summary onto the canvas as a
text frame named `Critique <date>` beside the target, so the backlog lives
where the design lives. Critique resolves no threads; that belongs to the
command that fixes them.

## Audit section

`audit` runs Assessment B alone, no subagent theater, and reports measured
findings ranked by severity with the exact nodes and values. It never scores
heuristics and never judges taste; it is the floor check, fast and repeatable.

## Heuristics scoring

Score each heuristic 0 to 4: 0 systematically violated, 1 frequently
violated, 2 inconsistent, 3 mostly respected with lapses, 4 respected
throughout the surface. Score against the surface's mode: an Operate surface
is judged hard on status visibility, consistency, and error prevention; a
Persuade surface is judged hard on real-world match, minimalist design, and
recognition. Report the per-heuristic scores, not an average; an average hides
exactly the failure the user needs to see.
