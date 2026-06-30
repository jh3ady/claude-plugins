# Refactoring Plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `refactoring` plugin to the marketplace encoding Martin Fowler's *Refactoring* (2nd edition, with Kent Beck) as three skills: the method, the code smells, and the catalogue.

**Architecture:** A plugin directory mirroring the structure of the existing `legacy-code` plugin: a `plugin.json` manifest, an MIT `LICENSE`, a `README.md`, and three skills each with a `SKILL.md` plus `references/`. The catalogue skill keeps its `SKILL.md` light and splits detail across seven reference files, one per book chapter (6 to 12). The plugin is registered in the root marketplace manifest and README table.

**Tech Stack:** Markdown skills (Claude Code plugin format), YAML frontmatter, TypeScript code examples. No build step. Validation is manual via WebSearch/WebFetch against primary sources and the `skill-reviewer` agent.

## Global Constraints

- All files written in English.
- No em-dashes anywhere in generated content.
- No unjustified abbreviations; write words in full (standard acronyms DDD, CQRS, SOLID, TDD, API are fine).
- No Claude self-promotion or `Co-Authored-By` trailers in commits or content.
- Commit messages: gitmoji + Conventional Commits, form `<emoji> <type>(<scope>): <summary>`.
- Code examples in TypeScript only.
- Every `SKILL.md` `description` written in situation-leading third-person voice and ends with "Composable with your own conventions."
- Every `SKILL.md` kept under roughly 250 lines; detail lives in `references/`.
- Book citations use the form `(Fowler, *Refactoring*, 2nd ed., 2018, Chapter N)`; the code smells chapter is attributed to Beck and Fowler.
- Reference structural facts (refactoring names, smell names, chapter membership) must be verified against martinfowler.com and refactoring.com/catalog before a task is considered done. The 2nd edition renamed several refactorings (for example *Extract Method* became *Extract Function*); use the 2nd-edition names.
- Plugin name: `refactoring`. Version: `0.1.0`. License: MIT. Author: Jean-Denis VIDOT, https://github.com/jh3ady.
- Reference model for every structural and stylistic decision: the existing `plugins/legacy-code` plugin.

---

## Task 1: Plugin scaffold (manifest, license, directories)

**Files:**
- Create: `plugins/refactoring/.claude-plugin/plugin.json`
- Create: `plugins/refactoring/LICENSE`
- Create: `plugins/refactoring/skills/refactoring-method/references/` (directory, via the file in Task 2)
- Reference: `plugins/legacy-code/.claude-plugin/plugin.json`, `plugins/legacy-code/LICENSE`

**Interfaces:**
- Produces: the `plugins/refactoring/` directory and a valid `plugin.json` whose `name` is `refactoring`. Later tasks add skills under `plugins/refactoring/skills/`.

- [ ] **Step 1: Copy the LICENSE verbatim from legacy-code**

Read `plugins/legacy-code/LICENSE` and write the identical content to `plugins/refactoring/LICENSE`.

- [ ] **Step 2: Write `plugin.json`**

Mirror the shape of `plugins/legacy-code/.claude-plugin/plugin.json`. Content:

```json
{
  "name": "refactoring",
  "version": "0.1.0",
  "description": "Refactoring (Martin Fowler, 2nd edition, with Kent Beck) applied pragmatically, in three skills: the method (the definition, the two hats, why and when to refactor, mechanics in small steps, and self-testing code as a prerequisite), the code smells (the chapter 3 catalogue of bad smells, each pointing to the refactorings that resolve it), and the refactoring catalogue (the full set of moves grouped by category, with condensed mechanics and TypeScript examples). Composable with your own conventions.",
  "author": {
    "name": "Jean-Denis VIDOT",
    "url": "https://github.com/jh3ady"
  },
  "license": "MIT",
  "homepage": "https://github.com/jh3ady/claude-plugins/tree/main/plugins/refactoring",
  "keywords": [
    "refactoring",
    "martin-fowler",
    "kent-beck",
    "code-smells",
    "extract-function",
    "refactoring-catalog",
    "two-hats",
    "self-testing-code",
    "software-craftsmanship",
    "clean-code"
  ]
}
```

- [ ] **Step 3: Verify JSON validity**

Run: `python3 -m json.tool plugins/refactoring/.claude-plugin/plugin.json > /dev/null && echo OK`
Expected: `OK`

- [ ] **Step 4: Commit**

```bash
git add plugins/refactoring/.claude-plugin/plugin.json plugins/refactoring/LICENSE
git commit -m "🎉 feat(refactoring): scaffold the refactoring plugin manifest and license"
```

---

## Task 2: Skill `refactoring-method`

**Files:**
- Create: `plugins/refactoring/skills/refactoring-method/SKILL.md`
- Create: `plugins/refactoring/skills/refactoring-method/references/refactoring-method.md`
- Reference: `plugins/legacy-code/skills/legacy-code-changes/SKILL.md` (structure and voice)

**Interfaces:**
- Consumes: the plugin directory from Task 1.
- Produces: skill `refactoring-method`. Skills B and C cross-reference it by name.

**Content requirements (SKILL.md):** Frontmatter `name: refactoring-method` and a situation-leading `description` covering: improving the design of existing code without changing observable behaviour, the two hats, why and when to refactor, the rule of three, preparatory/comprehension/litter-pickup/planned-versus-opportunistic refactoring, small-step mechanics under a test net, and when not to refactor; phrased so it triggers on "clean this up", "improve this design", "refactor this", "this code is messy", even when Fowler is not named; ending "Composable with your own conventions." Body sections:
- Definition (noun versus verb; behaviour-preserving).
- The two hats (adding function versus refactoring, never both at once).
- Why refactor (design, readability, finding bugs, speed; the Design Stamina Hypothesis).
- When to refactor (rule of three; preparatory, comprehension, litter-pickup; planned versus opportunistic).
- The test net as prerequisite, deferring to `test-driven-development`, and to `legacy-code` when tests are absent.
- Mechanics in small steps (tiny changes, compile and test often, reversibility).
- When not to refactor (rewrite-bound code, code that does not need touching, hard deadlines).
- Guardrails; Relationship to other skills (`code-smells`, `refactoring-catalog`, `test-driven-development`, `legacy-code`, `clean-code`/`solid-principles`/`simplicity-principles`); Adapt to your context; Reference pointer.

**Content requirements (references/refactoring-method.md):** The chapter 1 worked example (a play-rental / statement-style example as Fowler uses), condensed and annotated in TypeScript, showing a sequence of small refactorings each preserving behaviour, with the test net called out. Plus extended notes on the two hats and the when-to-refactor categories.

- [ ] **Step 1: Validate structural facts via web**

WebFetch `https://martinfowler.com/articles/refactoring-2nd-ed.html` and WebSearch as needed to confirm: the definition wording, the two-hats framing, the rule of three, and the chapter-1 example used in the 2nd edition. Note the 2nd-edition example structure.

- [ ] **Step 2: Write `references/refactoring-method.md`**

Write the full reference file per the content requirements above. Creating this file also creates the `references/` directory.

- [ ] **Step 3: Write `SKILL.md`**

Write the skill per the content requirements above, under 250 lines, voice matching `legacy-code`.

- [ ] **Step 4: Verify constraints**

Run: `grep -n "—" plugins/refactoring/skills/refactoring-method/SKILL.md plugins/refactoring/skills/refactoring-method/references/refactoring-method.md; echo "em-dash check done"`
Expected: no em-dash matches.
Run: `wc -l plugins/refactoring/skills/refactoring-method/SKILL.md`
Expected: under 250.

- [ ] **Step 5: Commit**

```bash
git add plugins/refactoring/skills/refactoring-method
git commit -m "✨ feat(refactoring): add the refactoring-method skill"
```

---

## Task 3: Skill `code-smells`

**Files:**
- Create: `plugins/refactoring/skills/code-smells/SKILL.md`
- Create: `plugins/refactoring/skills/code-smells/references/code-smells.md`

**Interfaces:**
- Consumes: the plugin directory from Task 1; cross-references `refactoring-method` and `refactoring-catalog` by name.
- Produces: skill `code-smells`.

**Content requirements (SKILL.md):** Frontmatter `name: code-smells` and a situation-leading `description` covering: recognising the bad smells of chapter 3 (Beck and Fowler) and mapping each to the refactorings that resolve it; triggering on "this smells", "duplicated code", "this function is too long", "too many parameters", "feature envy", and the like, even when Fowler is not named; ending "Composable with your own conventions." Body: the roughly 24 smells, grouped into families (Bloaters, Object-Orientation Abusers, Change Preventers, Dispensables, Couplers) while keeping Fowler's exact names; for each smell a one-line recognisable signal and the catalogue refactorings that address it (cross-reference `refactoring-catalog`). Sections: how to use smells (as triggers, not rules); overlap with `clean-code`/`solid-principles`/`simplicity-principles` (acknowledged, not duplicated); Guardrails; Relationship to other skills; Adapt to your context; Reference pointer.

**Content requirements (references/code-smells.md):** A smell-to-refactorings table for all smells, each row with the smell, its signal, why it hurts, and the recommended refactorings (2nd-edition names). Short TypeScript examples for the most common smells (Long Function, Duplicated Code, Long Parameter List, Feature Envy, Primitive Obsession).

- [ ] **Step 1: Validate the smell list via web**

WebFetch `https://refactoring.guru/refactoring/smells` and/or WebSearch to confirm the full list of chapter-3 smells and their exact 2nd-edition names. Cross-check the smell-to-refactoring mappings against refactoring.com/catalog where possible.

- [ ] **Step 2: Write `references/code-smells.md`**

Write the full reference file per the content requirements.

- [ ] **Step 3: Write `SKILL.md`**

Write the skill per the content requirements, under 250 lines.

- [ ] **Step 4: Verify constraints**

Run: `grep -n "—" plugins/refactoring/skills/code-smells/SKILL.md plugins/refactoring/skills/code-smells/references/code-smells.md; echo done`
Expected: no matches.
Run: `wc -l plugins/refactoring/skills/code-smells/SKILL.md`
Expected: under 250.

- [ ] **Step 5: Commit**

```bash
git add plugins/refactoring/skills/code-smells
git commit -m "✨ feat(refactoring): add the code-smells skill"
```

---

## Task 4: Skill `refactoring-catalog` (SKILL.md + first-set + encapsulation references)

**Files:**
- Create: `plugins/refactoring/skills/refactoring-catalog/SKILL.md`
- Create: `plugins/refactoring/skills/refactoring-catalog/references/01-first-set.md`
- Create: `plugins/refactoring/skills/refactoring-catalog/references/02-encapsulation.md`
- Reference: `plugins/legacy-code/skills/legacy-dependency-breaking/SKILL.md` (catalogue-skill structure)

**Interfaces:**
- Consumes: the plugin directory from Task 1; cross-referenced by `code-smells` and `refactoring-method`.
- Produces: skill `refactoring-catalog` with its `SKILL.md` and the first two of seven reference files. Tasks 5 and 6 add the remaining five.

**Content requirements (SKILL.md):** Frontmatter `name: refactoring-catalog` and a situation-leading `description` covering: choosing the specific refactoring move for a situation, grouped by the book categories (a first set; encapsulation; moving features; organizing data; simplifying conditional logic; refactoring APIs; dealing with inheritance); triggering on "extract this", "inline this", "split this function", "replace this conditional", "pull this up", and the like, even when Fowler is not named; ending "Composable with your own conventions." Body: a short orientation paragraph, then one short subsection per category listing its moves by exact 2nd-edition name with a one-line intent each, and a pointer to the matching reference file. Sections: how to read a catalogue entry; the inverse-pairs idea (Extract/Inline and so on); Guardrails (mechanics in small steps, behaviour preservation, test after each step); Relationship to other skills; Adapt to your context.

**Content requirements (reference files):** Each entry: name, intent and motivation, triggering signal, mechanics condensed to a few steps, and its inverse where one exists. Condensed, not the book verbatim. TypeScript examples for the most structural moves in each file.
- `01-first-set.md`: Extract Function, Inline Function, Extract Variable, Inline Variable, Change Function Declaration, Encapsulate Variable, Rename Variable, Introduce Parameter Object, Combine Functions into Class, Combine Functions into Transform, Split Phase.
- `02-encapsulation.md`: Encapsulate Record, Encapsulate Collection, Replace Primitive with Object, Replace Temp with Query, Extract Class, Inline Class, Hide Delegate, Remove Middle Man, Substitute Algorithm.

- [ ] **Step 1: Validate the chapter 6 and 7 move lists via web**

WebFetch `https://refactoring.com/catalog/` and confirm the exact 2nd-edition names and membership for the "first set" and "encapsulation" chapters. Confirm inverse pairs.

- [ ] **Step 2: Write `SKILL.md`**

Write the catalogue skill per the content requirements, under 250 lines. List all seven categories even though only two reference files exist yet (Tasks 5 and 6 add the rest); the pointers are correct because the file names are fixed in this plan.

- [ ] **Step 3: Write `references/01-first-set.md`**

- [ ] **Step 4: Write `references/02-encapsulation.md`**

- [ ] **Step 5: Verify constraints**

Run: `grep -rn "—" plugins/refactoring/skills/refactoring-catalog/; echo done`
Expected: no matches.
Run: `wc -l plugins/refactoring/skills/refactoring-catalog/SKILL.md`
Expected: under 250.

- [ ] **Step 6: Commit**

```bash
git add plugins/refactoring/skills/refactoring-catalog
git commit -m "✨ feat(refactoring): add the refactoring-catalog skill with first-set and encapsulation references"
```

---

## Task 5: Catalogue references (moving features, organizing data, conditionals)

**Files:**
- Create: `plugins/refactoring/skills/refactoring-catalog/references/03-moving-features.md`
- Create: `plugins/refactoring/skills/refactoring-catalog/references/04-organizing-data.md`
- Create: `plugins/refactoring/skills/refactoring-catalog/references/05-conditionals.md`

**Interfaces:**
- Consumes: the `refactoring-catalog` skill from Task 4 (these file names are already referenced from its `SKILL.md`).
- Produces: three more reference files. Same entry format as Task 4.

**Content requirements:**
- `03-moving-features.md`: Move Function, Move Field, Move Statements into Function, Move Statements to Callers, Replace Inline Code with Function Call, Slide Statements, Split Loop, Replace Loop with Pipeline, Remove Dead Code.
- `04-organizing-data.md`: Split Variable, Rename Field, Replace Derived Variable with Query, Change Reference to Value, Change Value to Reference.
- `05-conditionals.md`: Decompose Conditional, Consolidate Conditional Expression, Replace Nested Conditional with Guard Clauses, Replace Conditional with Polymorphism, Introduce Special Case, Introduce Assertion.

- [ ] **Step 1: Validate the chapter 8, 9, 10 move lists via web**

WebFetch `https://refactoring.com/catalog/` and confirm exact names and membership for moving features, organizing data, and simplifying conditional logic.

- [ ] **Step 2: Write `references/03-moving-features.md`**

- [ ] **Step 3: Write `references/04-organizing-data.md`**

- [ ] **Step 4: Write `references/05-conditionals.md`**

- [ ] **Step 5: Verify constraints**

Run: `grep -rn "—" plugins/refactoring/skills/refactoring-catalog/references/0[345]*.md; echo done`
Expected: no matches.

- [ ] **Step 6: Commit**

```bash
git add plugins/refactoring/skills/refactoring-catalog/references
git commit -m "✨ feat(refactoring): add moving-features, organizing-data, and conditionals catalogue references"
```

---

## Task 6: Catalogue references (APIs, inheritance)

**Files:**
- Create: `plugins/refactoring/skills/refactoring-catalog/references/06-apis.md`
- Create: `plugins/refactoring/skills/refactoring-catalog/references/07-inheritance.md`

**Interfaces:**
- Consumes: the `refactoring-catalog` skill from Task 4.
- Produces: the final two reference files; the catalogue is now complete.

**Content requirements:**
- `06-apis.md`: Separate Query from Modifier, Parameterize Function, Remove Flag Argument, Preserve Whole Object, Replace Parameter with Query, Replace Query with Parameter, Remove Setting Method, Replace Constructor with Factory Function, Replace Function with Command, Replace Command with Function.
- `07-inheritance.md`: Pull Up Method, Pull Up Field, Pull Up Constructor Body, Push Down Method, Push Down Field, Replace Type Code with Subclasses, Remove Subclass, Extract Superclass, Collapse Hierarchy, Replace Subclass with Delegate, Replace Superclass with Delegate.

- [ ] **Step 1: Validate the chapter 11 and 12 move lists via web**

WebFetch `https://refactoring.com/catalog/` and confirm exact names and membership for refactoring APIs and dealing with inheritance.

- [ ] **Step 2: Write `references/06-apis.md`**

- [ ] **Step 3: Write `references/07-inheritance.md`**

- [ ] **Step 4: Verify constraints**

Run: `grep -rn "—" plugins/refactoring/skills/refactoring-catalog/references/0[67]*.md; echo done`
Expected: no matches.

- [ ] **Step 5: Commit**

```bash
git add plugins/refactoring/skills/refactoring-catalog/references
git commit -m "✨ feat(refactoring): add APIs and inheritance catalogue references"
```

---

## Task 7: Plugin README

**Files:**
- Create: `plugins/refactoring/README.md`
- Reference: `plugins/legacy-code/README.md` (section structure and voice)

**Interfaces:**
- Consumes: the three skills from Tasks 2 to 6.
- Produces: the plugin README.

**Content requirements:** Follow the `legacy-code` README structure exactly: title; one-paragraph intro stating the book and the three-skill split, plus the "stays generic on purpose" line; `## What it does` with a `### refactoring-method`, `### code-smells`, and `### refactoring-catalog` subsection each summarising the skill in a few bullets; `## Relationship to other plugins` (`test-driven-development`, `legacy-code`, `clean-code`, `solid-principles`, `simplicity-principles`); `## Install` with the marketplace add and `/plugin install refactoring@jh3ady-claude-plugins` commands; `## Adapt to your context`; `## License`.

- [ ] **Step 1: Write `README.md`**

Write per the content requirements.

- [ ] **Step 2: Verify constraints**

Run: `grep -n "—" plugins/refactoring/README.md; echo done`
Expected: no matches.

- [ ] **Step 3: Commit**

```bash
git add plugins/refactoring/README.md
git commit -m "📝 docs(refactoring): add the plugin README"
```

---

## Task 8: Register in marketplace and root README

**Files:**
- Modify: `.claude-plugin/marketplace.json` (append a `refactoring` entry to the `plugins` array, after the `legacy-code` entry)
- Modify: `README.md` (append a `refactoring` row to the Plugins table)

**Interfaces:**
- Consumes: the completed plugin.
- Produces: the registered, discoverable plugin.

- [ ] **Step 1: Append the marketplace entry**

Add after the `legacy-code` object in the `plugins` array of `.claude-plugin/marketplace.json`:

```json
    {
      "name": "refactoring",
      "source": "./plugins/refactoring",
      "description": "Refactoring (Martin Fowler, 2nd edition, with Kent Beck) applied pragmatically, in three skills: the method (the definition, the two hats, why and when to refactor, mechanics in small steps, and self-testing code as a prerequisite), the code smells (the chapter 3 catalogue of bad smells, each pointing to the refactorings that resolve it), and the refactoring catalogue (the full set of moves grouped by category, with condensed mechanics and TypeScript examples). Composable with your own conventions.",
      "version": "0.1.0"
    }
```

(Ensure the preceding entry's closing brace gets a trailing comma.)

- [ ] **Step 2: Append the root README table row**

Add as the last row of the Plugins table in the root `README.md`:

```markdown
| [`refactoring`](plugins/refactoring) | Refactoring (Fowler, 2nd ed., with Beck) in three skills: the method (definition, the two hats, when and why to refactor, small-step mechanics, self-testing code as prerequisite), the code smells (the chapter 3 catalogue, each pointing to its refactorings), and the catalogue (the full set of moves grouped by category, with condensed mechanics and TypeScript examples). |
```

- [ ] **Step 3: Verify JSON validity**

Run: `python3 -m json.tool .claude-plugin/marketplace.json > /dev/null && echo OK`
Expected: `OK`

- [ ] **Step 4: Commit**

```bash
git add .claude-plugin/marketplace.json README.md
git commit -m "📝 docs(refactoring): register the plugin in the marketplace"
```

---

## Task 9: Skill review and validation pass

**Files:**
- Modify (as needed): any `SKILL.md` based on reviewer feedback.

**Interfaces:**
- Consumes: all three completed skills.
- Produces: review-clean skills.

- [ ] **Step 1: Run skill-reviewer on each skill**

Dispatch the `skill-reviewer` agent on `refactoring-method`, `code-smells`, and `refactoring-catalog` (can be parallel). Collect feedback.

- [ ] **Step 2: Apply feedback**

Apply non-trivial reviewer feedback (description triggering, structure, clarity). Skip suggestions that conflict with the marketplace conventions or the spec.

- [ ] **Step 3: Final constraint sweep**

Run: `grep -rn "—" plugins/refactoring/ ; echo "em-dash sweep done"`
Expected: no matches.
Run: `python3 -m json.tool plugins/refactoring/.claude-plugin/plugin.json > /dev/null && python3 -m json.tool .claude-plugin/marketplace.json > /dev/null && echo "JSON OK"`
Expected: `JSON OK`

- [ ] **Step 4: Commit any review fixes**

```bash
git add plugins/refactoring
git commit -m "💄 docs(refactoring): apply skill-reviewer feedback"
```

---

## Self-Review (plan author)

**Spec coverage:** Positioning (Task 2 description and README), TypeScript convention (global constraint, all reference tasks), 3 skills (Tasks 2, 3, 4 to 6), file structure (Tasks 1 to 6 create exactly the spec's tree), manifest/README/marketplace (Tasks 1, 7, 8), web validation plan (validation step in every content task plus Task 9), out-of-scope respected (no per-refactoring skill; TypeScript only; condensed mechanics). All covered.

**Placeholder scan:** Content tasks intentionally specify *what* each skill must contain rather than the full prose, because the deliverables are reference documents authored against live web sources, not code with deterministic output. Each task names the exact moves/smells to cover, the exact files, the exact section structure, and a verification command, which is the actionable contract a content subagent needs. No "TBD"/"TODO" left.

**Type consistency:** File names are fixed and reused consistently (`01-first-set.md` through `07-inheritance.md`); skill names (`refactoring-method`, `code-smells`, `refactoring-catalog`) are identical across cross-references; the `plugin.json` and `marketplace.json` descriptions are byte-identical.
