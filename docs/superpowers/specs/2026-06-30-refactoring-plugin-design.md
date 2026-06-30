# Design: `refactoring` plugin

Date: 2026-06-30
Status: approved (pending written-spec review)

## Goal

Add a `refactoring` plugin to the marketplace that encodes Martin Fowler's
*Refactoring: Improving the Design of Existing Code* (2nd edition, 2018, with
Kent Beck) applied pragmatically. It follows the established conventions of the
marketplace and uses the `legacy-code` plugin as its structural reference.

## Positioning

Refactoring is a standalone discipline: improving the internal structure of
existing code without changing its observable behaviour, as part of everyday
development. It is not an appendix to legacy code.

Fowler assumes self-testing code. The test safety net is therefore a
prerequisite of refactoring, not its subject. This produces cross-cutting
relationships at parity, with no dominant plugin:

- `test-driven-development`: the "Refactor" of red-green-refactor. The book's
  *Building Tests* chapter defers to that discipline rather than duplicating it.
- `clean-code`, `solid-principles`, `simplicity-principles`: the code smells
  point toward these principles; refactoring is the mechanical "how" that
  realises them.
- `legacy-code`: one relationship among several. When code has no tests yet,
  apply Feathers first to install the safety net, then refactor. This is the
  "refactor step" that `legacy-code` delegates, but it does not define this
  plugin.

## Conventions (inherited from the marketplace)

- Code examples in **TypeScript** (consistent with the whole marketplace; the
  2nd edition itself uses JavaScript, which is close enough that adaptation is
  faithful).
- `SKILL.md` `description` written in situation-leading third-person voice,
  ending the marketplace tagline "Composable with your own conventions."
- Book citations throughout (Fowler, *Refactoring*, 2nd ed., 2018, with chapter
  references).
- Each `SKILL.md` kept under roughly 250 lines; detail lives in `references/`.
- Sections: guardrails, relationship to other skills, "Adapt to your context".
- MIT license, copied from `legacy-code`.

## Skills (3)

### A. `refactoring-method`

The discipline (chapters 1, 2, 4). The why, when, and how, not the moves.

- Fowler's definition: alter internal structure without changing observable
  behaviour; the noun versus the verb.
- The two hats: adding a feature OR refactoring, never both at once; always
  knowing which hat is on.
- Why refactor: design, readability, finding bugs, development speed (the
  Design Stamina Hypothesis).
- When: the rule of three; preparatory, comprehension, litter-pickup; planned
  versus opportunistic.
- The test net as prerequisite (self-testing code), deferring to
  `test-driven-development` and, when tests are absent, to `legacy-code`.
- Mechanics in small steps: tiny changes, compile and test often,
  reversibility.
- When not to refactor: code to be rewritten or discarded, code that does not
  need touching, hard deadlines.
- Guardrails, relationships, "Adapt to your context".
- `references/refactoring-method.md`: the chapter 1 worked example, condensed
  and annotated in TypeScript.

### B. `code-smells`

The bad smells catalogue (chapter 3, Beck and Fowler). The trigger: what it
smells like, and which refactoring it points to.

- The roughly 24 smells, grouped into families for readability (Bloaters,
  Object-Orientation Abusers, Change Preventers, Dispensables, Couplers), while
  keeping Fowler's exact names: Mysterious Name, Duplicated Code, Long Function,
  Long Parameter List, Global Data, Mutable Data, Divergent Change, Shotgun
  Surgery, Feature Envy, Data Clumps, Primitive Obsession, Repeated Switches,
  Loops, Lazy Element, Speculative Generality, Temporary Field, Message Chains,
  Middle Man, Insider Trading, Large Class, Alternative Classes with Different
  Interfaces, Data Class, Refused Bequest, Comments.
- For each smell: recognisable signal, why it hurts, and the catalogue
  refactorings that address it (cross-reference to skill C).
- Articulation with `clean-code` / `solid-principles` / `simplicity-principles`
  (overlap acknowledged, not duplicated: the angle here is "detect in order to
  trigger a move").
- `references/code-smells.md`: smell-to-refactorings table with short
  TypeScript examples.

### C. `refactoring-catalog`

The full set of moves (around sixty, chapters 6 to 12; exact count confirmed
against the catalogue when writing). Complete coverage, condensed mechanics,
grouped by the book's categories.

- A First Set of Refactorings; Encapsulation; Moving Features; Organizing Data;
  Simplifying Conditional Logic; Refactoring APIs; Dealing with Inheritance.
- Each entry: name, intent and motivation, triggering signal, mechanics
  condensed to a few steps, and its inverse where one exists (Extract/Inline,
  and so on).
- We cite and synthesise; we do not reproduce the book's verbatim mechanics.
- `references/`: one file per category (7 files), with TypeScript examples for
  the most structural moves.

## File structure

```
plugins/refactoring/
├── .claude-plugin/plugin.json
├── LICENSE
├── README.md
└── skills/
    ├── refactoring-method/
    │   ├── SKILL.md
    │   └── references/refactoring-method.md
    ├── code-smells/
    │   ├── SKILL.md
    │   └── references/code-smells.md
    └── refactoring-catalog/
        ├── SKILL.md
        └── references/
            ├── 01-first-set.md
            ├── 02-encapsulation.md
            ├── 03-moving-features.md
            ├── 04-organizing-data.md
            ├── 05-conditionals.md
            ├── 06-apis.md
            └── 07-inheritance.md
```

The 7 catalogue reference files follow the 7 book chapters exactly.

## Manifest, README, marketplace

- `plugin.json` modelled on `legacy-code`: `name`, `version` 0.1.0,
  situation-leading `description` ending "Composable with your own
  conventions.", `author`, `license` MIT, `homepage`, and `keywords`
  (`refactoring`, `martin-fowler`, `kent-beck`, `code-smells`,
  `extract-function`, `refactoring-catalog`, `two-hats`, `self-testing-code`,
  `software-craftsmanship`, and so on).
- Plugin `README.md` on the `legacy-code` model (intro; What it does, one
  subsection per skill; Relationship to other plugins; Install; Adapt to your
  context; License).
- New `refactoring` entry in `.claude-plugin/marketplace.json` and a new row in
  the root `README.md` table.

## Web validation plan

For every skill written, verify against primary sources (martinfowler.com,
refactoring.com/catalog) using WebSearch and WebFetch:

1. Exact names of refactorings and smells (the 2nd edition renamed several, for
   example *Extract Method* became *Extract Function*).
2. Correct chapter membership.
3. Fidelity of each summarised definition, motivation, and mechanics.

At the end, run the skills through the `skill-reviewer` agent.

## Out of scope

- Verbatim reproduction of the book's step-by-step mechanics (copyright and
  volume).
- Languages other than TypeScript in examples.
- A separate skill per refactoring category (kept as reference files within
  `refactoring-catalog`).
