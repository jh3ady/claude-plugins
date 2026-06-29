# Legacy code plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a `legacy-code` plugin bundling two focused, sourced, pragmatic skills (`legacy-code-changes`, `legacy-dependency-breaking`) and register it in the marketplace and settings.

**Architecture:** Mirror the existing principle-plugin family (`domain-driven-design`, `test-driven-development`): a plugin manifest plus per-skill `SKILL.md` (lean core) and `references/*.md` (depth, TypeScript examples, attributed sources). Two skills under one plugin. The method skill (`legacy-code-changes`) keeps one reference file; the catalogue skill (`legacy-dependency-breaking`) splits its reference into three files by intent. Adjacent patterns are cross-referenced, never absorbed.

**Tech Stack:** Markdown skills with YAML frontmatter, JSON manifests. TypeScript only in reference examples.

## Global Constraints

- All files in English. No em-dashes anywhere. Words written in full (configuration, repository, December); standard acronyms allowed: TDD, SOLID, DI, API, OO.
- Plugin version: `0.1.0`. Author: `Jean-Denis VIDOT`, url `https://github.com/jh3ady`. License: MIT.
- Voice and structure mirror `plugins/test-driven-development/skills/test-driven-development/SKILL.md` and `plugins/hexagonal-architecture/skills/hexagonal-architecture/SKILL.md`: a short definition, conceptual sections, a `## Guardrails` section, an `## Adapt to your context` section, and a closing `## Reference` pointer. Pragmatic, not dogmatic.
- Sourcing rule: do NOT invent verbatim Feathers quotations or page numbers. Attribute paraphrases to "Feathers, Working Effectively with Legacy Code (2004)". Cross-referenced concepts attributed to their own authors (Fowler for refactoring, Beck for TDD).
- No attribution to Claude anywhere (no Co-Authored-By, no generated-with lines).
- Commit messages: gitmoji + Conventional Commits, scope `legacy-code`.
- Marketplace owner/repo is `jh3ady/claude-plugins`; the local working directory is `/Users/jh3ady/.config/claude-plugins`. The `enabledPlugins` key uses the suffix `@jh3ady-claude-plugins`.

---

## File Structure

- Create `plugins/legacy-code/.claude-plugin/plugin.json` — plugin manifest.
- Create `plugins/legacy-code/LICENSE` — MIT (copy of an existing plugin LICENSE).
- Create `plugins/legacy-code/README.md` — covers both skills.
- Create `plugins/legacy-code/skills/legacy-code-changes/SKILL.md` — lean method core.
- Create `plugins/legacy-code/skills/legacy-code-changes/references/legacy-code-changes.md` — method depth.
- Create `plugins/legacy-code/skills/legacy-dependency-breaking/SKILL.md` — lean catalogue core.
- Create `plugins/legacy-code/skills/legacy-dependency-breaking/references/add-without-touching.md` — Sprout/Wrap techniques.
- Create `plugins/legacy-code/skills/legacy-dependency-breaking/references/get-a-class-into-a-harness.md` — class-construction techniques.
- Create `plugins/legacy-code/skills/legacy-dependency-breaking/references/get-a-method-under-test.md` — method-seam techniques.
- Modify `.claude-plugin/marketplace.json` — add one plugin entry.
- Modify `README.md` (root) — add the `legacy-code` row (and the missing `test-driven-development` row, for table consistency).
- Modify `~/.claude/settings.json` (symlinked to `~/.config/claude-config/claude/settings.json`) — add `enabledPlugins` entry.

---

## Task 1: Scaffold the plugin manifest, LICENSE, directories

**Files:**
- Create: `plugins/legacy-code/.claude-plugin/plugin.json`
- Create: `plugins/legacy-code/LICENSE`

**Interfaces:**
- Produces: the plugin root and manifest other tasks populate; skill directories created on first file write.

- [ ] **Step 1: Copy the LICENSE from an existing plugin**

```bash
mkdir -p plugins/legacy-code/.claude-plugin
cp plugins/test-driven-development/LICENSE plugins/legacy-code/LICENSE
```

- [ ] **Step 2: Write the manifest**

Create `plugins/legacy-code/.claude-plugin/plugin.json`:

```json
{
  "name": "legacy-code",
  "version": "0.1.0",
  "description": "Working effectively with legacy code (Michael Feathers) applied pragmatically, in two skills: the method (legacy code is code without tests, the Legacy Code Change Algorithm, seams and enabling points, characterization tests, reasoning about effects) and the dependency-breaking catalogue (Sprout, Wrap, Extract Interface, Subclass and Override, Parameterize Constructor, Extract and Override Factory, and the rest), with TypeScript specifics. Composable with your own conventions.",
  "author": {
    "name": "Jean-Denis VIDOT",
    "url": "https://github.com/jh3ady"
  },
  "license": "MIT",
  "homepage": "https://github.com/jh3ady/claude-plugins/tree/main/plugins/legacy-code",
  "keywords": [
    "legacy-code",
    "michael-feathers",
    "characterization-tests",
    "seams",
    "dependency-breaking",
    "sprout-method",
    "wrap-method",
    "extract-interface",
    "refactoring",
    "software-craftsmanship"
  ]
}
```

- [ ] **Step 3: Validate the manifest is parseable JSON**

Run: `python3 -m json.tool plugins/legacy-code/.claude-plugin/plugin.json > /dev/null && echo OK`
Expected: `OK`

- [ ] **Step 4: Commit**

```bash
git add plugins/legacy-code/.claude-plugin/plugin.json plugins/legacy-code/LICENSE
git commit -m "🎉 chore(legacy-code): scaffold the plugin manifest and license"
```

---

## Task 2: Author the legacy-code-changes SKILL.md (lean core)

**Files:**
- Create: `plugins/legacy-code/skills/legacy-code-changes/SKILL.md`

**Interfaces:**
- Consumes: the voice and section shape of `plugins/test-driven-development/skills/test-driven-development/SKILL.md` (read it first).
- Produces: a lean skill referencing `references/legacy-code-changes.md` (authored in Task 3) and naming the sibling skill `legacy-dependency-breaking`.

**Verified claims to cover (sourced; do not contradict these):**
- Legacy code is code without tests. Feathers' working definition: legacy code is simply code without tests, because tests are what let you change code confidently; code can be well written and still be legacy if it has no tests. (Feathers 2004, Preface and Chapter 1.)
- The change dilemma (the "legacy code dilemma"): to change code safely you need tests in place, but to get many classes under test you must change the code first to break dependencies. You make conservative, mechanical changes to get tests in, then change behaviour with the tests as a safety net. (Feathers 2004, Chapter 1.)
- The Legacy Code Change Algorithm, in order: (1) identify change points, (2) find test points, (3) break dependencies, (4) write tests, (5) make changes and refactor. (Feathers 2004, Chapter 2.)
- A seam is a place where you can alter behaviour in your program without editing in that place; every seam has an enabling point where you decide which behaviour is used. Types: object seams (polymorphism, the main one in OO code), plus link seams and preprocessing seams. (Feathers 2004, Chapter 4.)
- Characterization tests document the behaviour the code actually has, not the behaviour it should have. The discovery loop: write a test you expect to pass, let the assertion failure tell you the real value, then encode that value to pin the behaviour. They protect existing behaviour, bugs included, during change. (Feathers 2004, Chapter 13.)
- Reasoning about effects: effect sketching maps how a change can propagate; pinch points are narrow places where many effects funnel through a small interface, good places to write tests. The two reasons to break a dependency are sensing (you cannot access values the code computes) and separation (you cannot get the code into a harness at all). (Feathers 2004, Chapters 9, 11, 15.)
- When time is short: prefer adding new tested code beside the old (Sprout and Wrap, detailed in the sibling skill) over editing tangled untested code in place. (Feathers 2004, Chapter 6.)

- [ ] **Step 1: Read the model skills for voice**

Run: `cat plugins/test-driven-development/skills/test-driven-development/SKILL.md`
Expected: observe the frontmatter description style, the short definition, conceptual sections, `## Guardrails`-style sections, the closing reference pointer.

- [ ] **Step 2: Write the SKILL.md**

Create `plugins/legacy-code/skills/legacy-code-changes/SKILL.md` with:
- Frontmatter `name: legacy-code-changes` and a trigger-oriented `description` covering: working with existing untested code, fear of changing code that has no tests, deciding where to start a change in unfamiliar code, characterization tests, seams and enabling points, reasoning about how a change propagates (effect sketching, pinch points), and getting code under test before changing it, even when the term "legacy code" is not used. The description must name "legacy code" and Feathers' method so a generic "work with this legacy code" request triggers it, and must steer construction-specific dependency problems to the sibling skill `legacy-dependency-breaking`. Keep it one dense paragraph.
- Body sections (short prose, mirror the TDD skill): a one-paragraph definition (legacy code is code without tests; the change dilemma); `## The Legacy Code Change Algorithm` (the five steps in order); `## Seams and enabling points` (object seams primarily, link and preprocessing named); `## Characterization tests` (pin actual behaviour, the discovery loop, bugs included); `## Reasoning about effects` (effect sketching, pinch points, sensing versus separation); `## When time is short` (Sprout and Wrap as the first low-risk moves, point to `legacy-dependency-breaking`); `## Guardrails` (change surgically rather than rewrite; characterization tests pin behaviour including bugs and are documented not silently fixed; do not gold-plate an already-tested CRUD slice); `## Relationship to other skills` (`legacy-dependency-breaking` for the techniques the algorithm calls for; `test-driven-development` because characterization tests are a case of the same discipline and red-green-refactor resumes once code is under test; `clean-code` and `simplicity-principles` for the refactor step); `## Adapt to your context`; `## Reference` pointing to `references/legacy-code-changes.md`.
- Apply Global Constraints (English, no em-dashes, full words).

- [ ] **Step 3: Validate frontmatter and triggering**

Use the `skill-reviewer` agent on `plugins/legacy-code/skills/legacy-code-changes/SKILL.md`. Apply its non-cosmetic feedback. Confirm its description does not overlap the sibling catalogue skill (method versus technique selection).
Expected: description triggers reliably; no structural issues.

- [ ] **Step 4: Verify no em-dashes**

Run: `! grep -n "—" plugins/legacy-code/skills/legacy-code-changes/SKILL.md && echo "no em-dash OK"`
Expected: `no em-dash OK`

- [ ] **Step 5: Commit**

```bash
git add plugins/legacy-code/skills/legacy-code-changes/SKILL.md
git commit -m "✨ feat(legacy-code): add the legacy-code-changes skill core"
```

---

## Task 3: Author the legacy-code-changes reference

**Files:**
- Create: `plugins/legacy-code/skills/legacy-code-changes/references/legacy-code-changes.md`

**Interfaces:**
- Consumes: the verified claims from Task 2.
- Produces: the depth document the method SKILL.md points to.

**Section outline (each with prose, a short TypeScript example where it helps, and "when not to apply" notes):**
1. What legacy code is and the change dilemma: code without tests; why edit-and-pray fails; the conservative-changes-first loop. Source: Feathers 2004, Preface and Chapters 1 to 2.
2. The Legacy Code Change Algorithm: the five steps with a worked walkthrough on a small TypeScript example (a class with an untested method you must change). Show identifying the change point, finding the test point, noting the dependency to break, writing a characterization test, then making the change. Source: Feathers 2004, Chapter 2.
3. Seams and enabling points: definition; object seams shown with a TypeScript example (a hard-coded collaborator made overridable so a test can substitute it); link and preprocessing seams named with one line each on when they apply (and a note that object seams are the default in TypeScript). Source: Feathers 2004, Chapter 4.
4. Characterization tests: the discovery loop with a TypeScript example (assert a guessed value, read the real value from the failure, lock it in); the rule that they capture actual behaviour including bugs; how they differ from TDD tests (which describe intended behaviour). Source: Feathers 2004, Chapter 13.
5. Reasoning about effects: effect sketching with a small example of tracing how a field change propagates; pinch points as good test locations; sensing versus separation as the two reasons to break a dependency. Source: Feathers 2004, Chapters 9, 11, 15.
6. Working when time is short: Sprout versus edit-in-place; the risk ladder; pointer to `legacy-dependency-breaking` for the mechanics. Source: Feathers 2004, Chapter 6.
7. When this is overkill: code already under test; a trivial CRUD slice; do not characterize behaviour you are about to delete.
8. Sources: Feathers, Working Effectively with Legacy Code (2004); cross-references to Beck (TDD) and Fowler (Refactoring) for the adjacent steps, with URLs where public.

- [ ] **Step 1: Write the reference document**

Create the file following the section outline above. Mirror the depth and citation style of `plugins/test-driven-development/skills/test-driven-development/references/test-driven-development.md` (read it first for tone). Apply the sourcing rule from Global Constraints.

- [ ] **Step 2: Read it back and check accuracy against the verified claims**

Read the new reference and confirm: legacy code defined as code without tests; the five algorithm steps in the correct order; seams defined with the enabling point; characterization tests capture actual (not intended) behaviour and pin bugs; sensing versus separation present; no invented page numbers.

- [ ] **Step 3: Verify no em-dashes**

Run: `! grep -n "—" plugins/legacy-code/skills/legacy-code-changes/references/legacy-code-changes.md && echo "no em-dash OK"`
Expected: `no em-dash OK`

- [ ] **Step 4: Commit**

```bash
git add plugins/legacy-code/skills/legacy-code-changes/references/legacy-code-changes.md
git commit -m "📝 docs(legacy-code): add the legacy-code-changes reference"
```

---

## Task 4: Author the legacy-dependency-breaking SKILL.md (lean core)

**Files:**
- Create: `plugins/legacy-code/skills/legacy-dependency-breaking/SKILL.md`

**Interfaces:**
- Consumes: the voice of the TDD skill and the cross-reference names (`legacy-code-changes`, `test-driven-development`, `dependency-injection`, `hexagonal-architecture`, `solid-principles`, `clean-code`).
- Produces: a lean skill referencing the three intent references authored in Tasks 5 to 7. The exact three intent-group headings and the technique-to-group assignment defined here are consumed by Tasks 5, 6, and 7.

**Intent groups and technique assignment (the catalogue; later tasks detail these):**
- Group A, "Add behaviour without touching existing code" (reference `add-without-touching.md`): Sprout Method, Sprout Class, Wrap Method, Wrap Class.
- Group B, "Get a class into a test harness" (reference `get-a-class-into-a-harness.md`): Extract Interface, Parameterize Constructor, Introduce Instance Delegator, Introduce Static Setter, Extract and Override Factory Method, Supersede Instance Variable, Pull Up Feature, Push Down Dependency, Replace Global Reference with Getter, Encapsulate Global References.
- Group C, "Get a method under test" (reference `get-a-method-under-test.md`): Subclass and Override Method, Extract and Override Call, Extract and Override Getter, Extract and Override Factory Method (as a method seam), Parameterize Method, Break Out Method Object, Adapt Parameter, Primitivize Parameter, Replace Function with Function Pointer (named, C-only), Definition Completion (named, C/C++-only), Link Substitution (named, link-seam only), Template Redefinition (named, C++/generics-only), Text Redefinition (named, interpreted-language-only).
- Each technique is detailed in exactly one file. Techniques that are language-specific or not relevant to TypeScript (the "named" ones above) get a short note, not full mechanics.

**Verified claims to cover (sourced):**
- The two reasons to break dependencies are sensing and separation: sensing to detect effects you cannot otherwise see, separation to get code into a harness at all. (Feathers 2004, Chapter 4.)
- Sprout and Wrap add new behaviour in new, tested code without editing the tangled old code in place; they are the lowest-risk first moves when you cannot yet get the surrounding code under test. (Feathers 2004, Chapter 6.)
- Getting a class into a harness fails most often because of irritating or dangerous dependencies in construction (heavy constructors, global or static access, singletons); the fix is to break the dependency via an interface, a parameter, or an override so the class can be instantiated under test. (Feathers 2004, Chapters 9, 10.)
- Getting a method under test fails when the behaviour you need to exercise is buried behind a hidden dependency inside the method; open an object seam with subclass-and-override or extract-and-override so the test can substitute it. (Feathers 2004, Chapters 9, 10.)
- These techniques are scaffolding toward tests, not the destination design; once tests exist, refactor toward clean dependency management (constructor injection, ports and adapters). (Feathers 2004, throughout; cross-reference DI and hexagonal.)

- [ ] **Step 1: Write the SKILL.md**

Create `plugins/legacy-code/skills/legacy-dependency-breaking/SKILL.md` with:
- Frontmatter `name: legacy-dependency-breaking` and a trigger-oriented `description` covering: a class or method that cannot be instantiated or exercised in a test because of its dependencies (heavy constructors, singletons, static calls, global state, hidden side effects), needing to add code without disturbing existing untested code, and choosing a specific dependency-breaking technique (Sprout, Wrap, Extract Interface, Subclass and Override, Parameterize Constructor, Extract and Override Factory), even when the term is not used. The description must steer the overall how-to-approach-a-change question to the sibling skill `legacy-code-changes` so the two do not overlap. One dense paragraph.
- Body sections (short prose): a one-paragraph definition (you break a dependency to sense or to separate; the technique catalogue makes untestable code testable); `## The two reasons: sensing and separation`; `## Add behaviour without touching existing code` (Group A: Sprout Method, Sprout Class, Wrap Method, Wrap Class, one or two lines each, when to reach for each); `## Get a class into a test harness` (Group B: the most-used ones named with one line each, Extract Interface and Parameterize Constructor highlighted); `## Get a method under test` (Group C: Subclass and Override Method and Extract and Override Call highlighted, the rest named); `## Guardrails` (these are temporary scaffolding toward tests, not the target design; prefer the least invasive seam; once green, refactor toward DI and ports and adapters; do not break dependencies in code you will not test); `## Relationship to other skills` (`legacy-code-changes` for the method that calls these in; `test-driven-development` for the seam concept and testable design; `dependency-injection` and `hexagonal-architecture` for the clean target; `solid-principles` for the interface and inversion principles behind Extract Interface; `clean-code` for the refactor step); `## Adapt to your context`; `## Reference` pointing to all three intent files (`references/add-without-touching.md`, `references/get-a-class-into-a-harness.md`, `references/get-a-method-under-test.md`) with a one-line description of each.
- Apply Global Constraints.

- [ ] **Step 2: Validate with skill-reviewer**

Use the `skill-reviewer` agent on the new SKILL.md. Apply non-cosmetic feedback. Confirm the description triggers on "cannot instantiate / cannot test this class" situations and does not cannibalise the `legacy-code-changes` method description.

- [ ] **Step 3: Verify no em-dashes**

Run: `! grep -n "—" plugins/legacy-code/skills/legacy-dependency-breaking/SKILL.md && echo "no em-dash OK"`
Expected: `no em-dash OK`

- [ ] **Step 4: Commit**

```bash
git add plugins/legacy-code/skills/legacy-dependency-breaking/SKILL.md
git commit -m "✨ feat(legacy-code): add the legacy-dependency-breaking skill core"
```

---

## Task 5: Author the "add without touching" reference (Group A)

**Files:**
- Create: `plugins/legacy-code/skills/legacy-dependency-breaking/references/add-without-touching.md`

**Interfaces:**
- Consumes: the Group A technique assignment and the intent-group headings from Task 4.
- Produces: the first of the three catalogue files the SKILL.md points to.

**Techniques to detail (each: intent, mechanism as numbered steps, a TypeScript before/after example, cost or risk, when to prefer it):**
1. **Sprout Method**: when you must add code to an existing method but cannot get it under test, write the new logic as a new, fully tested method and call it from the old one. Mechanism, TypeScript example (a new `calculatePackingSlip` style method sprouted and tested), cost (the host method stays untested). Source: Feathers 2004, Chapter 6.
2. **Sprout Class**: when even the host class cannot be instantiated under test, put the new logic in a new tested class and call it from the old code. TypeScript example, cost, when to choose over Sprout Method. Source: Feathers 2004, Chapter 6.
3. **Wrap Method**: when you want new behaviour to run before or after existing behaviour without changing it, rename the old method and create a new one that calls the renamed original plus the new tested step. TypeScript example, the two forms (rename-and-wrap, and the new-name form), cost. Source: Feathers 2004, Chapter 6.
4. **Wrap Class**: the decorator-level version; wrap the whole class so new behaviour runs around the old, with the new wrapper under test. TypeScript example (a decorator implementing the same interface), cost, when to choose over Wrap Method. Source: Feathers 2004, Chapter 6.

End with a short "choosing within this group" note (method versus class, sprout versus wrap) and a Sources line (Feathers 2004, Chapter 6).

- [ ] **Step 1: Write the reference document**

Create the file following the technique list above. Each technique fully actionable from the file alone. Mirror the TDD reference's depth and citation style. Apply the sourcing rule.

- [ ] **Step 2: Accuracy check**

Read the file and confirm: four techniques each with mechanism, a TypeScript example, and a cost; Sprout adds new tested code beside old; Wrap runs new behaviour around unchanged old behaviour; TypeScript examples are type-consistent; no invented page numbers.

- [ ] **Step 3: Verify no em-dashes**

Run: `! grep -n "—" plugins/legacy-code/skills/legacy-dependency-breaking/references/add-without-touching.md && echo "no em-dash OK"`
Expected: `no em-dash OK`

- [ ] **Step 4: Commit**

```bash
git add plugins/legacy-code/skills/legacy-dependency-breaking/references/add-without-touching.md
git commit -m "📝 docs(legacy-code): add the add-without-touching technique reference"
```

---

## Task 6: Author the "get a class into a harness" reference (Group B)

**Files:**
- Create: `plugins/legacy-code/skills/legacy-dependency-breaking/references/get-a-class-into-a-harness.md`

**Interfaces:**
- Consumes: the Group B technique assignment from Task 4.
- Produces: the second catalogue file.

**Techniques to detail (each: intent, mechanism as numbered steps, a TypeScript before/after example, cost or risk):**
1. **Extract Interface**: define an interface for a hard-to-use dependency so a test can pass a fake implementation; the highest-value, lowest-risk separation technique in TypeScript. Worked TypeScript example (a `Database` collaborator extracted to an interface, a test fake substituted). Tie-in: this is the dependency-inversion move behind `hexagonal-architecture` ports. Source: Feathers 2004, Chapter 25.
2. **Parameterize Constructor**: add a constructor parameter for a dependency the class currently creates internally, defaulting to the real one, so tests pass a substitute. TypeScript example, cost (the default keeps production callers unchanged). Source: Feathers 2004, Chapter 25.
3. **Introduce Instance Delegator**: when static calls block testing, add an instance method that delegates to the static, so a subclass or fake can override the instance method. TypeScript example, cost. Source: Feathers 2004, Chapter 25.
4. **Introduce Static Setter**: when a singleton blocks testing, add a setter that lets a test replace the singleton instance with a fake. TypeScript example, cost (test-only mutability), when it is a last resort. Source: Feathers 2004, Chapter 25.
5. **Extract and Override Factory Method**: move a constructor call inside a method into an overridable factory method so a test subclass returns a fake. TypeScript example, cost. Source: Feathers 2004, Chapter 25.
6. **Supersede Instance Variable**: provide a setter-like supersede method to replace an object created in the constructor when constructor parameterization is not possible. TypeScript example, cost, why it is riskier than Parameterize Constructor. Source: Feathers 2004, Chapter 25.
7. **Pull Up Feature** and **Push Down Dependency**: restructure an inheritance hierarchy to separate the testable feature from the untestable dependency. One TypeScript example covering both directions, cost. Source: Feathers 2004, Chapter 25.
8. **Replace Global Reference with Getter** and **Encapsulate Global References**: route access to global or module-level state through a seam (a getter or a wrapper object) that a test can override. One TypeScript example, cost. Source: Feathers 2004, Chapter 25.

End with a Sources line and a one-paragraph note: in TypeScript prefer Extract Interface and Parameterize Constructor first; the static-setter and supersede techniques are last resorts; the clean destination is constructor injection (cross-reference `dependency-injection`).

- [ ] **Step 1: Write the reference document**

Create the file following the technique list. Each technique fully actionable from the file alone. Mirror the TDD reference's depth and citation style. Apply the sourcing rule.

- [ ] **Step 2: Accuracy check**

Read the file and confirm: every technique has a mechanism, a TypeScript example, and a cost; Extract Interface and Parameterize Constructor are flagged as the preferred first moves; static-setter and supersede flagged as last resorts; the DI cross-reference is present; TypeScript examples are type-consistent; no invented page numbers.

- [ ] **Step 3: Verify no em-dashes**

Run: `! grep -n "—" plugins/legacy-code/skills/legacy-dependency-breaking/references/get-a-class-into-a-harness.md && echo "no em-dash OK"`
Expected: `no em-dash OK`

- [ ] **Step 4: Commit**

```bash
git add plugins/legacy-code/skills/legacy-dependency-breaking/references/get-a-class-into-a-harness.md
git commit -m "📝 docs(legacy-code): add the get-a-class-into-a-harness technique reference"
```

---

## Task 7: Author the "get a method under test" reference (Group C)

**Files:**
- Create: `plugins/legacy-code/skills/legacy-dependency-breaking/references/get-a-method-under-test.md`

**Interfaces:**
- Consumes: the Group C technique assignment from Task 4.
- Produces: the third catalogue file.

**Techniques to detail (TypeScript-relevant ones with full mechanism, example, and cost; the rest named with a short note on why they do not apply in TypeScript):**
1. **Subclass and Override Method**: the central method-seam technique; subclass the class under test in the test and override the method that holds the unwanted dependency. TypeScript example, cost (requires the method to be overridable). Source: Feathers 2004, Chapter 25.
2. **Extract and Override Call**: extract a problematic call into its own method, then override that method in a test subclass. TypeScript example, cost. Source: Feathers 2004, Chapter 25.
3. **Extract and Override Getter**: replace direct field access with a getter you can override to return a fake. TypeScript example, cost. Source: Feathers 2004, Chapter 25.
4. **Extract and Override Factory Method** (as a method seam): cross-reference the Group B entry; note its use here is to break a construction dependency inside the method under test. One-line pointer, no duplicated mechanics.
5. **Parameterize Method**: add a parameter so a test can pass a substitute for something the method creates internally. TypeScript example, cost. Source: Feathers 2004, Chapter 25.
6. **Break Out Method Object**: move a long, tangled method into its own class whose constructor takes the collaborators, making it instantiable and testable in isolation. TypeScript example, cost. Source: Feathers 2004, Chapter 25.
7. **Adapt Parameter** and **Primitivize Parameter**: when a parameter type is itself hard to construct in a test, introduce a narrow interface (Adapt Parameter) or a primitive-based helper (Primitivize Parameter) to ease testing. One TypeScript example covering Adapt Parameter, a short note on Primitivize Parameter, cost. Source: Feathers 2004, Chapter 25.
8. **Named-only (not TypeScript-relevant), one short note each on what they are and why they do not apply here:** Replace Function with Function Pointer (C), Definition Completion (C and C++), Link Substitution (link seam), Template Redefinition (C++ and generic templates), Text Redefinition (interpreted languages such as Ruby). These complete the catalogue faithfully without padding the file with irrelevant mechanics.

End with a Sources line and a one-paragraph note: Subclass and Override Method is the workhorse; reach for Break Out Method Object when a method is too tangled to seam in place; the clean destination is to inject the collaborator (cross-reference `dependency-injection`).

- [ ] **Step 1: Write the reference document**

Create the file following the technique list. TypeScript-relevant techniques fully actionable; named-only techniques get a one-to-two sentence note. Mirror the TDD reference's depth and citation style. Apply the sourcing rule.

- [ ] **Step 2: Accuracy check**

Read the file and confirm: the TypeScript-relevant techniques each have a mechanism, a TypeScript example, and a cost; Subclass and Override Method is the highlighted workhorse; the five named-only techniques are present with a short reason they do not apply; Extract and Override Factory Method is cross-referenced, not duplicated; TypeScript examples are type-consistent; no invented page numbers.

- [ ] **Step 3: Verify no em-dashes**

Run: `! grep -n "—" plugins/legacy-code/skills/legacy-dependency-breaking/references/get-a-method-under-test.md && echo "no em-dash OK"`
Expected: `no em-dash OK`

- [ ] **Step 4: Commit**

```bash
git add plugins/legacy-code/skills/legacy-dependency-breaking/references/get-a-method-under-test.md
git commit -m "📝 docs(legacy-code): add the get-a-method-under-test technique reference"
```

---

## Task 8: Author the plugin README

**Files:**
- Create: `plugins/legacy-code/README.md`

**Interfaces:**
- Consumes: the two skills' scope and the catalogue grouping.
- Produces: the plugin landing document.

- [ ] **Step 1: Read the model READMEs**

Run: `cat plugins/test-driven-development/README.md plugins/domain-driven-design/README.md`
Expected: observe the structure (title, intro, "What it does", "Relationship to other plugins", "Install", "Adapt to your context", "License") and how the DDD README documents multiple bundled skills.

- [ ] **Step 2: Write the README**

Create `plugins/legacy-code/README.md` mirroring that structure, documenting BOTH bundled skills:
- Intro framing legacy code as code without tests and the change dilemma.
- `## What it does`, with a subsection per skill: `legacy-code-changes` (the method: definition, the algorithm, seams, characterization tests, reasoning about effects) and `legacy-dependency-breaking` (the catalogue grouped by intent: add without touching, get a class into a harness, get a method under test).
- `## Relationship to other plugins`: `test-driven-development` (characterization tests as a case of the same discipline; red-green-refactor afterwards), `dependency-injection` and `hexagonal-architecture` (the clean target once seams are open), `clean-code` and `simplicity-principles` (the refactor step), `solid-principles` (the principles behind Extract Interface).
- Install block:

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install legacy-code@jh3ady-claude-plugins
```

- `## Adapt to your context` and `## License`. Apply Global Constraints.

- [ ] **Step 3: Verify no em-dashes**

Run: `! grep -n "—" plugins/legacy-code/README.md && echo "no em-dash OK"`
Expected: `no em-dash OK`

- [ ] **Step 4: Commit**

```bash
git add plugins/legacy-code/README.md
git commit -m "📝 docs(legacy-code): add the plugin readme"
```

---

## Task 9: Register in the marketplace and the root README

**Files:**
- Modify: `.claude-plugin/marketplace.json`
- Modify: `README.md` (root)

**Interfaces:**
- Consumes: the plugin name and description from Task 1.

- [ ] **Step 1: Add the marketplace entry**

Append to the `plugins` array in `.claude-plugin/marketplace.json`, after the `test-driven-development` entry (the current last entry):

```json
    {
      "name": "legacy-code",
      "source": "./plugins/legacy-code",
      "description": "Working effectively with legacy code (Michael Feathers) applied pragmatically, in two skills: the method (legacy code is code without tests, the Legacy Code Change Algorithm, seams and enabling points, characterization tests, reasoning about effects) and the dependency-breaking catalogue (Sprout, Wrap, Extract Interface, Subclass and Override, Parameterize Constructor, Extract and Override Factory, and the rest), with TypeScript specifics. Composable with your own conventions.",
      "version": "0.1.0"
    }
```

Note: add a comma after the previous entry's closing brace so the array stays valid JSON.

- [ ] **Step 2: Validate the marketplace JSON**

Run: `python3 -m json.tool .claude-plugin/marketplace.json > /dev/null && echo OK`
Expected: `OK`

- [ ] **Step 3: Add the root README rows**

In the root `README.md` plugins table, add the missing `test-driven-development` row (table consistency) and the new `legacy-code` row, after the `screaming-architecture` row:

```markdown
| [`test-driven-development`](plugins/test-driven-development) | TDD in the classical (Detroit) style: a failing test first, red-green-refactor, testing behaviour not implementation, the test-double ladder preferring real objects and in-memory implementations over mocks, and contract tests. |
| [`legacy-code`](plugins/legacy-code) | Working effectively with legacy code (Feathers) in two skills: the method (code without tests, the Legacy Code Change Algorithm, seams, characterization tests, reasoning about effects) and the dependency-breaking catalogue (Sprout, Wrap, Extract Interface, Subclass and Override, and the rest). |
```

- [ ] **Step 4: Verify no em-dashes in the added rows**

Run: `! grep -n "—" README.md && echo "no em-dash OK"`
Expected: `no em-dash OK`

- [ ] **Step 5: Commit**

```bash
git add .claude-plugin/marketplace.json README.md
git commit -m "📝 docs(legacy-code): register the plugin in the marketplace"
```

---

## Task 10: Validate the whole plugin and enable it in settings

**Files:**
- Modify: `~/.claude/settings.json` (symlinked to `~/.config/claude-config/claude/settings.json`)

**Interfaces:**
- Consumes: the finished plugin.

- [ ] **Step 1: Run the plugin validator**

Use the `plugin-validator` agent on `plugins/legacy-code`. Apply any structural fixes it reports (manifest, skill frontmatter, directory layout).
Expected: plugin validates; two skills discovered.

- [ ] **Step 2: Confirm both skills and all four references are present**

Run: `find plugins/legacy-code -name SKILL.md && echo "---" && find plugins/legacy-code -name '*.md' -path '*/references/*'`
Expected: two SKILL.md paths (legacy-code-changes, legacy-dependency-breaking); four reference files (legacy-code-changes.md, add-without-touching.md, get-a-class-into-a-harness.md, get-a-method-under-test.md).

- [ ] **Step 3: Enable the plugin in settings**

Add to the `enabledPlugins` object in `~/.claude/settings.json` (the symlink target is `~/.config/claude-config/claude/settings.json`; edit the real file), after the `test-driven-development@jh3ady-claude-plugins` entry (add a comma to that line first, since it is currently the last entry):

```json
    "legacy-code@jh3ady-claude-plugins": true
```

- [ ] **Step 4: Validate the settings JSON**

Run: `python3 -m json.tool ~/.claude/settings.json > /dev/null && echo OK`
Expected: `OK`

- [ ] **Step 5: Final review and spec sign-off**

Re-read the spec `docs/superpowers/specs/2026-06-29-legacy-code-plugin-design.md` and confirm every success criterion is met: one plugin, two lean skills, depth in references, the dependency-breaking catalogue complete and actionable (every TypeScript-relevant technique applicable from the references alone; non-applicable techniques named), content grounded in Feathers and reviewed, pragmatism and composability framing, adjacent plugins referenced rather than absorbed, the two descriptions triggering precisely without overlap, registered in marketplace and enabled in settings.

- [ ] **Step 6: Note for the user**

The `enabledPlugins` change lives in the `claude-config` repository (the symlink target), not in `claude-plugins`. Tell the user to review and commit that change in `claude-config` separately, since it is a different repository.

---

## Self-Review

- **Spec coverage:** Plugin structure → Tasks 1, 2, 4, 8. Method skill (`legacy-code-changes`) → Tasks 2, 3. Catalogue skill (`legacy-dependency-breaking`) and its three intent references → Tasks 4, 5, 6, 7. Catalogue completeness and actionability → Tasks 5, 6, 7 (every technique assigned in Task 4 detailed or named once). Sourcing and validation → Tasks 3, 5, 6, 7, 10. Marketplace and settings → Tasks 9, 10. Pragmatism, composability, and the out-of-scope framing → embedded in Tasks 2 and 4 section instructions and the README in Task 8.
- **Placeholder scan:** No "TBD"/"TODO". Prose deliverables (skills and references) carry explicit, sourced claim lists, intent-group assignments, and per-technique outlines rather than invented final copy, which is the correct granularity for authoring tasks; structural files (manifest, marketplace entry, README rows, settings entry) carry exact content.
- **Type consistency:** Skill names (`legacy-code-changes`, `legacy-dependency-breaking`), the three reference filenames (`add-without-touching.md`, `get-a-class-into-a-harness.md`, `get-a-method-under-test.md`), the `@jh3ady-claude-plugins` suffix, the `0.1.0` version, and the plugin description string are identical across Tasks 1, 4, 5, 6, 7, 9, and 10. Each catalogue technique is assigned to exactly one reference file in Task 4 and detailed or named in exactly one of Tasks 5, 6, 7 (Extract and Override Factory Method is detailed in Group B and cross-referenced, not duplicated, in Group C).
