# Testing Strategy Plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a `testing-strategy` plugin that owns the macro test-portfolio view (shapes, tiers, size versus scope, consumer-driven contract testing, coverage as a signal, flaky tests), sitting above `test-driven-development` without re-teaching its inner loop.

**Architecture:** One plugin, one skill, skill-only (no command or hook), mirroring the sibling plugins. A lean `SKILL.md` carries the macro decision procedure; `references/testing-strategy.md` carries the sourced depth, taxonomy, and one worked TypeScript walkthrough. The plugin is registered in the marketplace and the root README, with reciprocal cross-references added to five sibling plugins.

**Tech Stack:** Markdown with YAML frontmatter (skills), JSON (`plugin.json`, `marketplace.json`), TypeScript in examples. No runtime code, no build. Validation via the `plugin-dev:plugin-validator` and `plugin-dev:skill-reviewer` agents.

## Global Constraints

- Writing language: English. Exact value: all generated files in English.
- No em-dashes anywhere in generated content.
- Words written in full (for example "configuration", "repository", "December"). Standard acronyms allowed: TDD, CI, UI, ROI, DDD, API, JSON.
- Examples in TypeScript only.
- Plugin version: `0.1.0`.
- Author block, copied verbatim: `{"name": "Jean-Denis VIDOT", "url": "https://github.com/jh3ady"}`.
- License: MIT. `homepage`: `https://github.com/jh3ady/claude-plugins/tree/main/plugins/testing-strategy`.
- No Claude self-promotion or `Co-Authored-By` trailers in any commit.
- Commit style: gitmoji + Conventional Commits, `<emoji> <type>(testing-strategy): <summary>`.
- Content must be sourced, not written from memory. No invented verbatim quotations or page numbers beyond the short phrasings verified in the spec's research pass. When adding any new specific claim, verify it with WebSearch/WebFetch first.
- Work happens on branch `feat/testing-strategy-plugin` (already created; the spec is already committed there).

**Canonical sources (validated during brainstorming, reuse these; re-verify any new claim):**
- Test pyramid: Mike Cohn, *Succeeding with Agile* (2009), the "test automation pyramid" (unit / service / UI); originally sketched with Lisa Crispin around 2003-4. https://martinfowler.com/bliki/TestPyramid.html
- Practical test pyramid: Ham Vocke on Fowler's site; "unit" has no canonical definition. https://martinfowler.com/articles/practical-test-pyramid.html
- Testing trophy: Kent C. Dodds (2018, Assert(js)), four tiers static/unit/integration/end-to-end, "the more your tests resemble the way your software is used, the more confidence they can give you", "write tests, not too many, mostly integration". https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications and https://kentcdodds.com/blog/write-tests
- Ice-cream cone anti-pattern: Alister Scott, WatirMelon. https://watirmelon.blog/testing-pyramids/
- Test sizes and size versus scope: Winters, Manshreck, Wright, *Software Engineering at Google*, ch. 11. Small (single process, no network/DB/filesystem, target ~60s), medium (single machine, localhost only, ~300s), large (unrestricted, ~900s). Size (how it runs, resources) is independent of scope (how much code it exercises); optimise for speed and determinism. https://abseil.io/resources/swe-book/html/ch11.html
- Coverage: Fowler, coverage is "a useful tool for finding untested parts of a codebase" but "of little use as a numeric statement of how good your tests are"; a coverage target is Goodhart's law ("when a measure becomes a target, it ceases to be a good measure"). https://martinfowler.com/bliki/TestCoverage.html

---

### Task 1: Scaffold the plugin (manifest, license, directories)

**Files:**
- Create: `plugins/testing-strategy/.claude-plugin/plugin.json`
- Create: `plugins/testing-strategy/LICENSE`

**Interfaces:**
- Consumes: nothing.
- Produces: the plugin directory `plugins/testing-strategy/` and a valid `plugin.json` with `name: "testing-strategy"`, consumed by Tasks 2-7 and by the marketplace entry in Task 5.

- [ ] **Step 1: Define the acceptance checks**

The manifest must parse as JSON, contain exactly the keys used by siblings (`name`, `version`, `description`, `author`, `license`, `homepage`, `keywords`), and set `name` to `testing-strategy` and `version` to `0.1.0`.

- [ ] **Step 2: Write `plugin.json`**

```json
{
  "name": "testing-strategy",
  "version": "0.1.0",
  "description": "Testing strategy applied pragmatically, the macro view above the inner TDD loop: the portfolio idea, the shapes (the pyramid, the practical test pyramid, the testing trophy, the ice-cream cone anti-pattern), the tiers (unit, integration, contract, end-to-end, acceptance), the size-versus-scope distinction from Software Engineering at Google, consumer-driven contract testing, coverage as a signal rather than a target, and flaky tests, with TypeScript specifics. Composable with your own conventions.",
  "author": {
    "name": "Jean-Denis VIDOT",
    "url": "https://github.com/jh3ady"
  },
  "license": "MIT",
  "homepage": "https://github.com/jh3ady/claude-plugins/tree/main/plugins/testing-strategy",
  "keywords": [
    "testing-strategy",
    "test-pyramid",
    "testing-trophy",
    "test-automation",
    "integration-testing",
    "end-to-end-testing",
    "contract-testing",
    "test-coverage",
    "flaky-tests",
    "software-craftsmanship"
  ]
}
```

- [ ] **Step 3: Create the LICENSE**

Copy the sibling license verbatim so the text and year match:

```bash
cp plugins/test-driven-development/LICENSE plugins/testing-strategy/LICENSE
```

- [ ] **Step 4: Verify the manifest parses and the keys are right**

Run:
```bash
python3 -c "import json; d=json.load(open('plugins/testing-strategy/.claude-plugin/plugin.json')); assert d['name']=='testing-strategy'; assert d['version']=='0.1.0'; assert set(d)=={'name','version','description','author','license','homepage','keywords'}; assert '—' not in json.dumps(d); print('ok')"
```
Expected: `ok`

- [ ] **Step 5: Commit**

```bash
git add plugins/testing-strategy/.claude-plugin/plugin.json plugins/testing-strategy/LICENSE
git commit -m "🎉 feat(testing-strategy): scaffold plugin manifest and license"
```

---

### Task 2: Write the SKILL.md (lean macro core)

**Files:**
- Create: `plugins/testing-strategy/skills/testing-strategy/SKILL.md`

**Interfaces:**
- Consumes: the plugin directory from Task 1.
- Produces: the skill entry point. Its final "Reference" section points to `references/testing-strategy.md`, authored in Task 3.

- [ ] **Step 1: Define the acceptance checks**

The file must start with YAML frontmatter carrying `name: testing-strategy` and a trigger-oriented `description`. The body must contain, in order, sections for: the portfolio idea, the shapes, the tiers, size versus scope, guiding heuristics, coverage as a signal, flaky tests, guardrails, relationship to other skills, adapt to your context, and a reference pointer. No em-dashes. Every named source (Cohn, Fowler, Vocke, Dodds, Scott, Google) must match the Global Constraints citations.

- [ ] **Step 2: Write the frontmatter**

```markdown
---
name: testing-strategy
description: Apply testing strategy when deciding the shape and balance of an automated test suite, choosing at which level to test something, weighing unit against integration against end-to-end tests, judging a test pyramid or testing trophy or an inverted ice-cream cone, placing consumer-driven contract tests in the portfolio, reading or setting a coverage target, or dealing with flaky tests, even when "testing strategy" is not named. Covers the portfolio idea, the shapes (pyramid, practical test pyramid, trophy, ice-cream cone), the tiers (unit, integration, contract, end-to-end, acceptance), the size-versus-scope distinction from Software Engineering at Google, consumer-driven contract testing, coverage as a signal rather than a target, and flaky tests, with TypeScript specifics. This is the macro outer loop: it defers the inner red-green-refactor loop and the test-double ladder to test-driven-development.
---
```

- [ ] **Step 3: Write the body**

Author the following sections as prose in the house style (compare `plugins/test-driven-development/skills/test-driven-development/SKILL.md` for tone and length). Each bullet below is a required claim, grounded in the Global Constraints sources. Keep it lean; push detail to the reference.

1. `# Testing Strategy` intro (2-4 sentences): a test suite is a portfolio of tests of different granularity and cost; the strategy question is how many of each, at which level to test what, and what signal the suite must give. State up front that this is the macro view and that the inner red-green-refactor loop belongs to `test-driven-development`.
2. `## The portfolio idea`: group tests by granularity and cost; balance return on investment; a good suite is fast, deterministic, and mostly made of cheap tests.
3. `## The shapes`:
   - The **pyramid** (Mike Cohn, *Succeeding with Agile*, 2009): many unit tests at the base, fewer service tests, fewest UI tests; UI tests are "brittle, expensive to write, and time consuming".
   - The **practical test pyramid** (Ham Vocke, on Fowler's site): the value is in thinking about categories of test and their trade-offs, not in a canonical definition of "unit".
   - The **testing trophy** (Kent C. Dodds, 2018): static, unit, integration, end-to-end, weighted towards integration for JavaScript applications; "the more your tests resemble the way your software is used, the more confidence they can give you".
   - The **ice-cream cone** anti-pattern (Alister Scott): the inverted pyramid (mostly manual and UI tests, few unit tests); why it is slow and brittle.
   - One line naming honeycomb and cupcake as further variations, deferred to the reference.
4. `## The tiers`: one line each on what it buys and costs, for unit, integration, contract, end-to-end, acceptance.
5. `## Size versus scope`: the Google distinction (size = how it runs and what it may do; scope = how much code it exercises); the two axes are independent; a broad-scoped test can still be small with doubles; optimise for speed and determinism.
6. `## Guiding heuristics`: push each test to the cheapest tier that gives confidence; higher tiers are a second line of defence (Fowler); avoid redundant coverage across tiers; tests should resemble real usage (Dodds).
7. `## Coverage is a signal, not a target`: Fowler (coverage finds untested code, is a poor quality score); a coverage target is Goodhart's law.
8. `## Flaky tests`: a non-deterministic test is worse than no test because it erodes trust in the whole suite; quarantine or fix, never ignore.
9. `## Guardrails`: the ice-cream cone; testing everything through the UI; coverage as a target; redundant tiers testing the same behaviour.
10. `## Relationship to other skills`: bullets naming
    - `test-driven-development` (the inner loop, red-green-refactor, and the test-double ladder including in-memory contract tests; this skill is the outer loop above it),
    - `hexagonal-architecture` (ports are the seams; integration tests exercise a real adapter against real infrastructure),
    - `legacy-code` (characterization tests as the entry point when adding tests to untested code),
    - `refactoring` (self-testing code as the prerequisite that makes any strategy possible),
    - `domain-driven-design` (acceptance tests express the ubiquitous language; a future BDD plugin could own acceptance and Gherkin in depth).
11. `## Adapt to your context`: baseline not dogma; layer your runner, coverage tooling, where you draw the integration-test line, in your own `CLAUDE.md` or a higher-priority skill.
12. `## Reference`: one sentence pointing to `references/testing-strategy.md` for the sourcing, the full tier taxonomy, the size-versus-scope table, the pyramid-versus-trophy analysis, consumer-driven contract testing, the coverage detail, flaky-test handling, and the worked walkthrough.

- [ ] **Step 4: Verify structure, sourcing, and no em-dashes**

Run:
```bash
cd plugins/testing-strategy/skills/testing-strategy
grep -q "^name: testing-strategy$" SKILL.md && echo "name ok"
for s in "## The portfolio idea" "## The shapes" "## The tiers" "## Size versus scope" "## Guiding heuristics" "## Coverage is a signal" "## Flaky tests" "## Guardrails" "## Relationship to other skills" "## Adapt to your context" "## Reference"; do grep -qF "$s" SKILL.md || echo "MISSING: $s"; done
for name in Cohn Fowler Vocke Dodds Scott Google; do grep -qF "$name" SKILL.md || echo "MISSING SOURCE: $name"; done
! grep -q "—" SKILL.md && echo "no em-dash ok"
cd -
```
Expected: `name ok`, `no em-dash ok`, and no `MISSING` lines.

- [ ] **Step 5: Commit**

```bash
git add plugins/testing-strategy/skills/testing-strategy/SKILL.md
git commit -m "✨ feat(testing-strategy): add the macro test-portfolio skill"
```

---

### Task 3: Write references/testing-strategy.md (depth)

**Files:**
- Create: `plugins/testing-strategy/skills/testing-strategy/references/testing-strategy.md`

**Interfaces:**
- Consumes: the SKILL.md from Task 2 (this is the target of its "Reference" pointer).
- Produces: the depth document; no downstream code depends on its internals.

- [ ] **Step 1: Define the acceptance checks**

The reference must contain sections for: sources, the shapes' history, the tier taxonomy, a size-versus-scope table, the pyramid-versus-trophy analysis, consumer-driven contract testing (with the shared-name warning), coverage, flaky tests, and one worked TypeScript walkthrough. No em-dashes. TypeScript is the only example language.

- [ ] **Step 2: Write the document**

Author these sections (compare `plugins/test-driven-development/skills/test-driven-development/references/test-driven-development.md`, 492 lines, for depth and tone):

1. `# Testing Strategy` intro plus `## Sources`: list the Global Constraints sources with attribution, no fabricated page numbers.
2. `## The shapes, and where they came from`: the pyramid (Cohn 2009, unit/service/UI; sketched with Lisa Crispin around 2003-4; Fowler's two essential points: many more low-level tests than broad-stack tests, and high-level tests as a second line of defence); the practical test pyramid (Vocke; "unit" is ill-defined; think in categories); the trophy (Dodds 2018, static/unit/integration/end-to-end, integration-weighted for JavaScript, the resemblance principle); the ice-cream cone (Scott, the inverted pyramid, why it melts); one paragraph naming honeycomb (Spotify, integration-centric) and cupcake (Thoughtworks) as context-specific variants.
3. `## The tiers`: precise definitions of unit, integration, contract, end-to-end, acceptance; where sociable versus solitary tests sit (cross-reference `test-driven-development` for that distinction).
4. `## Size versus scope`: a Markdown table with Google's three sizes and their constraints:

```markdown
| Size   | Runs on          | May use            | Network            | Typical target |
| ------ | ---------------- | ------------------ | ------------------ | -------------- |
| Small  | single process   | no filesystem/DB   | none               | ~60s           |
| Medium | single machine   | threads, blocking  | localhost only     | ~300s          |
| Large  | anywhere         | unrestricted       | any                | ~900s          |
```
   Then a paragraph: size (how it runs, resources) is independent of scope (how much code it exercises); a broad-scoped endpoint test can be small if it doubles out-of-process dependencies; Google optimises for speed and determinism, which is why it prefers size to the traditional unit/integration labels.
5. `## Pyramid versus trophy`: treat as context-dependent, not a winner; both keep end-to-end a small minority; the trophy rebalances towards integration for front-end JavaScript where units are thin; classical sociable tests already sit between the two. Cross-reference `test-driven-development`.
6. `## Contract testing: two different things with one name`: 
   - The **in-memory contract test** (one suite run against a real and an in-memory implementation, to keep the double faithful) is owned by `test-driven-development`; reference it, do not re-teach it.
   - The **consumer-driven contract test** (Pact-style) between deployed services: the consumer declares its expectations and generates a contract; the contract is replayed against the real provider in the provider's build; a breaking provider change fails the provider's build. Framed as a portfolio decision that replaces slow, brittle cross-service end-to-end tests with fast, deterministic ones.
   - State plainly that the two share a name and solve different problems (double fidelity within a process versus integration drift between services).
   - Include a short TypeScript sketch of a consumer expectation and what it asserts (a shape and status the consumer relies on), kept minimal and tool-agnostic.
7. `## Coverage`: Fowler (a diagnostic for finding untested code, a poor quality score); Goodhart's law when it becomes a target; use it to find gaps, not to grade.
8. `## Flaky tests`: causes (shared state, time, order dependence, real network); a flaky test erodes trust in the whole suite; quarantine and fix, never rerun-until-green as policy; cross-reference the isolation desiderata in `test-driven-development`.
9. `## A worked walkthrough`: take one feature (for example "confirm an order") and place its tests across the tiers in TypeScript: a unit/sociable test for the domain rule, an integration test for the repository adapter, a consumer-driven contract test for the payment provider it calls, and one end-to-end test for the critical path; explain why each lands where it does and why nothing is duplicated across tiers.
10. `## Trade-offs and cross-references`: the inner loop and doubles to `test-driven-development`; integration at adapters to `hexagonal-architecture`; characterization tests to `legacy-code`; self-testing code to `refactoring`; acceptance and the ubiquitous language to `domain-driven-design`.

- [ ] **Step 3: Verify structure, examples, and no em-dashes**

Run:
```bash
cd plugins/testing-strategy/skills/testing-strategy/references
for s in "## Sources" "## The tiers" "## Size versus scope" "## Pyramid versus trophy" "## Contract testing" "## Coverage" "## Flaky tests" "## A worked walkthrough" "## Trade-offs"; do grep -qF "$s" testing-strategy.md || echo "MISSING: $s"; done
grep -q '```typescript' testing-strategy.md && echo "ts example ok"
! grep -q "—" testing-strategy.md && echo "no em-dash ok"
cd -
```
Expected: `ts example ok`, `no em-dash ok`, no `MISSING` lines.

- [ ] **Step 4: Commit**

```bash
git add plugins/testing-strategy/skills/testing-strategy/references/testing-strategy.md
git commit -m "📝 docs(testing-strategy): add the reference depth document"
```

---

### Task 4: Write the plugin README

**Files:**
- Create: `plugins/testing-strategy/README.md`

**Interfaces:**
- Consumes: the plugin name and skill from Tasks 1-3.
- Produces: the plugin-level README; no downstream dependency.

- [ ] **Step 1: Define the acceptance checks**

Mirror the sibling README shape (see `plugins/test-driven-development/README.md`): a title, an intro, a "What it does" bullet list, a "Relationship to other plugins" list, an "Install" block, an "Adapt to your context" note, and a "License" line. No em-dashes.

- [ ] **Step 2: Write the README**

Follow the sibling structure. Required content:
- Title `# testing-strategy` and a two-paragraph intro: it helps decide the shape and balance of a test suite (macro view), sitting above `test-driven-development`; it stays generic, composable with your runner and conventions.
- `## What it does`: bullets for the portfolio idea, the shapes, the tiers, size versus scope, guiding heuristics, coverage as a signal, flaky tests, and consumer-driven contract testing.
- `## Relationship to other plugins`: `test-driven-development` (inner loop and doubles versus this outer loop), `hexagonal-architecture` (integration at adapters), `legacy-code` (characterization tests), `refactoring` (self-testing code), `domain-driven-design` (acceptance and the ubiquitous language).
- `## Install`:
  ```bash
  /plugin marketplace add jh3ady/claude-plugins
  /plugin install testing-strategy@jh3ady-claude-plugins
  ```
- `## Adapt to your context` and `## License` (MIT), matching the sibling wording.

- [ ] **Step 3: Verify**

Run:
```bash
cd plugins/testing-strategy
for s in "## What it does" "## Relationship to other plugins" "## Install" "## Adapt to your context" "## License"; do grep -qF "$s" README.md || echo "MISSING: $s"; done
grep -qF "install testing-strategy@jh3ady-claude-plugins" README.md && echo "install ok"
! grep -q "—" README.md && echo "no em-dash ok"
cd -
```
Expected: `install ok`, `no em-dash ok`, no `MISSING` lines.

- [ ] **Step 4: Commit**

```bash
git add plugins/testing-strategy/README.md
git commit -m "📝 docs(testing-strategy): add the plugin README"
```

---

### Task 5: Register in the marketplace and the root README

**Files:**
- Modify: `.claude-plugin/marketplace.json` (append one entry after the `design-patterns` entry, which is currently last)
- Modify: `README.md` (append one row to the plugins table)

**Interfaces:**
- Consumes: the `plugin.json` name and description from Task 1.
- Produces: the marketplace registration; discoverability of the plugin.

- [ ] **Step 1: Define the acceptance checks**

`marketplace.json` must remain valid JSON and gain exactly one entry with `name: "testing-strategy"`, `source: "./plugins/testing-strategy"`, a description matching the plugin, and `version: "0.1.0"`. The root README gains one table row.

- [ ] **Step 2: Add the marketplace entry**

Insert after the last entry (`design-patterns`) in the `plugins` array of `.claude-plugin/marketplace.json`. Add a comma to the current final entry's closing brace, then:

```json
    {
      "name": "testing-strategy",
      "source": "./plugins/testing-strategy",
      "description": "Testing strategy applied pragmatically, the macro view above the inner TDD loop: the portfolio idea, the shapes (the pyramid, the practical test pyramid, the testing trophy, the ice-cream cone anti-pattern), the tiers (unit, integration, contract, end-to-end, acceptance), the size-versus-scope distinction from Software Engineering at Google, consumer-driven contract testing, coverage as a signal rather than a target, and flaky tests, with TypeScript specifics. Composable with your own conventions.",
      "version": "0.1.0"
    }
```

- [ ] **Step 3: Add the root README table row**

Append this row at the end of the plugins table in the root `README.md` (after the `design-patterns` row):

```markdown
| [`testing-strategy`](plugins/testing-strategy) | The macro test-portfolio view above the inner TDD loop: the shapes (pyramid, practical test pyramid, testing trophy, the ice-cream cone anti-pattern), the tiers (unit, integration, contract, end-to-end, acceptance), the size-versus-scope distinction from Software Engineering at Google, consumer-driven contract testing, coverage as a signal rather than a target, and flaky tests. |
```

- [ ] **Step 4: Verify JSON validity and both edits**

Run:
```bash
python3 -c "import json; d=json.load(open('.claude-plugin/marketplace.json')); names=[p['name'] for p in d['plugins']]; assert names.count('testing-strategy')==1, names; e=[p for p in d['plugins'] if p['name']=='testing-strategy'][0]; assert e['source']=='./plugins/testing-strategy'; assert e['version']=='0.1.0'; assert '—' not in json.dumps(d); print('marketplace ok')"
grep -qF "[\`testing-strategy\`](plugins/testing-strategy)" README.md && echo "readme row ok"
! grep -q "—" README.md && echo "no em-dash ok"
```
Expected: `marketplace ok`, `readme row ok`, `no em-dash ok`.

- [ ] **Step 5: Commit**

```bash
git add .claude-plugin/marketplace.json README.md
git commit -m "📝 docs(testing-strategy): register in marketplace and root README"
```

---

### Task 6: Add reciprocal cross-references in sibling plugins

**Files:**
- Modify: `plugins/test-driven-development/skills/test-driven-development/SKILL.md` (the "Scope: TDD is the inner loop" section, lines ~246-257)
- Modify: `plugins/hexagonal-architecture/skills/*/SKILL.md` (the relationship section of the relevant skill)
- Modify: `plugins/legacy-code/skills/legacy-code-changes/SKILL.md` (relationship section)
- Modify: `plugins/refactoring/skills/refactoring-method/SKILL.md` (relationship section)
- Modify: `plugins/domain-driven-design/skills/*/SKILL.md` (the tactical or the relevant skill's relationship section)

**Interfaces:**
- Consumes: the `testing-strategy` skill name from Task 2.
- Produces: bidirectional cross-references matching the existing pattern (a bulleted `**\`testing-strategy\`**: ...` line in each relationship section).

- [ ] **Step 1: Add the TDD reciprocal reference**

In `plugins/test-driven-development/skills/test-driven-development/SKILL.md`, at the end of the "Scope: TDD is the inner loop" section (after the paragraph ending "already sit comfortably between the two."), add one sentence pointing outward:

```markdown

For the outer loop, see `testing-strategy`: the test portfolio, the shapes
(pyramid, trophy, the ice-cream cone anti-pattern), the tiers, the
size-versus-scope distinction, consumer-driven contract testing, and coverage
as a signal rather than a target.
```

- [ ] **Step 2: Add the four other reciprocal references**

In each of the following relationship sections, add one bullet in the established style. Locate each relationship section first (grep for the existing `test-driven-development` bullet shown below), then insert an adjacent `testing-strategy` bullet.

- `plugins/hexagonal-architecture` (in the skill whose relationship section lists sibling skills):
  ```markdown
  - **`testing-strategy`**: integration tests exercise a real adapter against real infrastructure; the ports defined here are the seams those tests cross. `testing-strategy` decides how many such tests to keep relative to unit and end-to-end tests.
  ```
- `plugins/legacy-code/skills/legacy-code-changes/SKILL.md` (near the existing `test-driven-development` bullet at line ~126):
  ```markdown
  - **`testing-strategy`**: characterization tests are the entry point when adding tests to untested code; `testing-strategy` frames where they sit in the wider portfolio.
  ```
- `plugins/refactoring/skills/refactoring-method/SKILL.md` (near the existing `test-driven-development` bullet at line ~195):
  ```markdown
  - **`testing-strategy`**: self-testing code is the prerequisite for safe refactoring; `testing-strategy` decides the shape and balance of that test suite.
  ```
- `plugins/domain-driven-design` (in the skill whose relationship section fits best, tactical design being the natural home):
  ```markdown
  - **`testing-strategy`**: acceptance tests express the ubiquitous language at the outer tier of the portfolio; `testing-strategy` owns where they sit and how many to keep.
  ```

- [ ] **Step 3: Verify every reciprocal reference exists**

Run:
```bash
for f in \
  plugins/test-driven-development/skills/test-driven-development/SKILL.md \
  plugins/legacy-code/skills/legacy-code-changes/SKILL.md \
  plugins/refactoring/skills/refactoring-method/SKILL.md ; do
  grep -qF "testing-strategy" "$f" && echo "ok: $f" || echo "MISSING: $f"
done
grep -rlF "testing-strategy" plugins/hexagonal-architecture/skills/ | head -1 | grep -q . && echo "ok: hexagonal" || echo "MISSING: hexagonal"
grep -rlF "testing-strategy" plugins/domain-driven-design/skills/ | head -1 | grep -q . && echo "ok: ddd" || echo "MISSING: ddd"
```
Expected: five `ok:` lines, no `MISSING`.

- [ ] **Step 4: Verify no em-dashes were introduced**

Run:
```bash
git diff --cached --unified=0 2>/dev/null; for f in plugins/test-driven-development/skills/test-driven-development/SKILL.md plugins/legacy-code/skills/legacy-code-changes/SKILL.md plugins/refactoring/skills/refactoring-method/SKILL.md; do grep -n "—" "$f" && echo "EM-DASH in $f"; done; echo "checked"
```
Expected: `checked`, no `EM-DASH` lines.

- [ ] **Step 5: Commit**

```bash
git add plugins/test-driven-development plugins/hexagonal-architecture plugins/legacy-code plugins/refactoring plugins/domain-driven-design
git commit -m "📝 docs(testing-strategy): add reciprocal cross-references in sibling plugins"
```

---

### Task 7: Validate and review

**Files:**
- No new files; may apply fixes to files from Tasks 1-6 based on findings.

**Interfaces:**
- Consumes: the whole plugin from Tasks 1-6.
- Produces: a validated, reviewed plugin.

- [ ] **Step 1: Run the plugin validator agent**

Dispatch the `plugin-dev:plugin-validator` agent on `plugins/testing-strategy`. Fix any structural finding (manifest keys, directory layout, frontmatter) inline, then re-run until clean.

- [ ] **Step 2: Run the skill reviewer agent**

Dispatch the `plugin-dev:skill-reviewer` agent on `skills/testing-strategy`. It must confirm: the description triggers on the right situations, and there is no overlap with `test-driven-development` (the macro layer must not re-teach the inner loop or the test-double ladder). Fix findings inline.

- [ ] **Step 3: Content accuracy pass against sources**

Re-read SKILL.md and the reference against the Global Constraints sources. Confirm each attributed claim matches its source, no verbatim quotation or page number was invented, and the contract-testing two-meanings separation is explicit. Fix inline.

- [ ] **Step 4: Full no-em-dash and JSON sanity sweep**

Run:
```bash
grep -rn "—" plugins/testing-strategy && echo "EM-DASH FOUND" || echo "no em-dash ok"
python3 -c "import json; json.load(open('plugins/testing-strategy/.claude-plugin/plugin.json')); json.load(open('.claude-plugin/marketplace.json')); print('json ok')"
```
Expected: `no em-dash ok`, `json ok`.

- [ ] **Step 5: Commit any review fixes**

```bash
git add -A
git commit -m "🎨 style(testing-strategy): apply validation and review fixes" || echo "nothing to commit"
```

- [ ] **Step 6: Update the spec status and finish the branch**

Set the spec status line to `approved (design and spec), implemented` in `docs/superpowers/specs/2026-07-02-testing-strategy-plugin-design.md`, commit, then use `superpowers:finishing-a-development-branch` to decide how to integrate `feat/testing-strategy-plugin`.

```bash
git add docs/superpowers/specs/2026-07-02-testing-strategy-plugin-design.md
git commit -m "📝 docs(testing-strategy): mark the spec implemented"
```

---

## Self-Review

**Spec coverage:**
- One plugin, one skill, skill-only → Task 1 (scaffold), Task 2 (skill). Covered.
- Lean SKILL.md macro core with all listed sections → Task 2. Covered.
- references/ depth (shapes, tiers, size vs scope, pyramid vs trophy, contract testing, coverage, flaky, worked example, trade-offs) → Task 3. Covered.
- Contract testing in both meanings, clearly separated → Task 3 Step 2 section 6. Covered.
- Coverage as a signal, not a target (Fowler, Goodhart) → Task 2 section 7, Task 3 section 7. Covered.
- Size versus scope from Google → Task 2 section 5, Task 3 section 4 (table). Covered.
- Shapes sourced, not asserted → Global Constraints sources, applied in Tasks 2-3, verified in Task 2 Step 4. Covered.
- Plugin README → Task 4. Covered.
- Marketplace entry + root README row → Task 5. Covered.
- Reciprocal cross-references in TDD, hexagonal, legacy-code, refactoring, DDD → Task 6. Covered.
- Validation by plugin-validator and skill-reviewer → Task 7. Covered.
- Out of scope (tooling, CI, BDD depth) → not built; BDD referenced only in Task 2 section 10 and Task 6 DDD bullet. Covered.
- Conventions (English, no em-dashes, TypeScript, 0.1.0, MIT) → Global Constraints, verified per task. Covered.

**Placeholder scan:** No "TBD"/"TODO". Prose sections are specified as required-claim outlines with exact sources and verification commands, which is the honest unit for sourced documentation (final wording is authored and re-verified against sources during execution, per the Global Constraints). All JSON, commands, and table rows are given verbatim.

**Type consistency:** Names are stable across tasks: plugin name `testing-strategy`, skill path `skills/testing-strategy/SKILL.md`, reference `references/testing-strategy.md`, marketplace `source: "./plugins/testing-strategy"`, install `testing-strategy@jh3ady-claude-plugins`. The five cross-reference targets in Task 6 match the five relationship bullets in Task 2 section 10.
