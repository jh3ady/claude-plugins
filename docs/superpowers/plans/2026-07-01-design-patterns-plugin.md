# Design patterns plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a `design-patterns` plugin: one judgment-first skill covering the 23 Gang of Four patterns plus four modern idioms, and register it in the marketplace and settings.

**Architecture:** Mirror the existing principle-plugin family (`solid-principles`, `test-driven-development`): a plugin manifest plus a single skill with a lean `SKILL.md` (the judgment frame) and four `references/*.md` files (the per-category depth, light on canonical definitions, with TypeScript examples). The skill is the source of truth for the generic pattern mechanism; the architecture plugins (`hexagonal-architecture`, `cqrs`, `domain-driven-design`) own the specialised applications and are cross-referenced both ways. Repository, dependency injection, and PoEAA enterprise patterns are out of scope.

**Tech Stack:** Markdown skill with YAML frontmatter, JSON manifest. TypeScript only in reference examples.

## Global Constraints

- All files in English. No em-dashes anywhere. Words written in full (configuration, repository, December); standard acronyms allowed: TDD, SOLID, DI, API, OCP, DIP, GoF.
- Plugin version: `0.1.0`. Author: `Jean-Denis VIDOT`, url `https://github.com/jh3ady`. License: MIT.
- Voice and structure mirror `plugins/solid-principles/skills/solid-principles/SKILL.md` and `plugins/test-driven-development/skills/test-driven-development/SKILL.md`: a short definition, conceptual sections, a `## Guardrails` section, an `## Adapt to your context` section, and a closing `## Reference` pointer. Pragmatic, not dogmatic.
- **Judgment first.** Every file stays light on the canonical "what a pattern is" (Claude knows it) and heavy on when to apply, when to refuse, the minimal TypeScript form, and composition with the other plugins. A file that merely defines patterns has failed its purpose.
- **The extensibility nuance must be explicit** wherever it fits: pragmatic is not anti-extensible. When a variation point is real and identified, opening it cleanly with the right pattern is OCP done right, not over-engineering. The fault is speculative abstraction, not abstraction itself.
- Sourcing rule: do NOT invent verbatim quotations or page numbers. Attribute the Gang of Four material to "Gamma, Helm, Johnson, Vlissides, Design Patterns (1994)". Attribute modern idioms to their usual authors (Fowler for Null Object and Specification via Refactoring and PoEAA; Result/Either and the functional idioms to common TypeScript practice).
- No attribution to Claude anywhere (no Co-Authored-By, no generated-with lines).
- Commit messages: gitmoji + Conventional Commits, scope `design-patterns`.
- Marketplace owner/repo is `jh3ady/claude-plugins`; the local working directory is `/Users/jh3ady/.config/claude-plugins`. The `enabledPlugins` key uses the suffix `@jh3ady-claude-plugins`.

---

## File Structure

- Create `plugins/design-patterns/.claude-plugin/plugin.json` — plugin manifest.
- Create `plugins/design-patterns/LICENSE` — MIT (copy of an existing plugin LICENSE).
- Create `plugins/design-patterns/README.md` — covers the skill.
- Create `plugins/design-patterns/skills/design-patterns/SKILL.md` — lean judgment core.
- Create `plugins/design-patterns/skills/design-patterns/references/creational.md` — Gang of Four creational patterns.
- Create `plugins/design-patterns/skills/design-patterns/references/structural.md` — Gang of Four structural patterns.
- Create `plugins/design-patterns/skills/design-patterns/references/behavioral.md` — Gang of Four behavioral patterns.
- Create `plugins/design-patterns/skills/design-patterns/references/modern-idioms.md` — Null Object, Result/Either, Specification, functional patterns.
- Modify `.claude-plugin/marketplace.json` — add one plugin entry (after the current last entry, `refactoring`).
- Modify `README.md` (root) — add the `design-patterns` row (after the `refactoring` row).
- Modify `~/.claude/settings.json` (symlinked to `~/.config/claude-config/claude/settings.json`) — add the `enabledPlugins` entry.

---

## Task 1: Scaffold the plugin manifest, LICENSE, directories

**Files:**
- Create: `plugins/design-patterns/.claude-plugin/plugin.json`
- Create: `plugins/design-patterns/LICENSE`

**Interfaces:**
- Produces: the plugin root and manifest other tasks populate; the skill directory is created on first file write. The manifest `description` string is reused verbatim by Task 7 (README) and Task 8 (marketplace entry).

- [ ] **Step 1: Copy the LICENSE from an existing plugin**

```bash
mkdir -p plugins/design-patterns/.claude-plugin
cp plugins/solid-principles/LICENSE plugins/design-patterns/LICENSE
```

- [ ] **Step 2: Write the manifest**

Create `plugins/design-patterns/.claude-plugin/plugin.json`:

```json
{
  "name": "design-patterns",
  "version": "0.1.0",
  "description": "Design patterns applied pragmatically, judgment first: the 23 Gang of Four patterns plus modern idioms (Null Object, Result/Either, Specification, functional patterns), framed by when to reach for a pattern, when to refuse it (the rule of three, no speculative abstraction), the minimal TypeScript form, and ownership by level of abstraction so the generic mechanism lives here while its specialised application lives in hexagonal, CQRS, and DDD. Composable with your own conventions.",
  "author": {
    "name": "Jean-Denis VIDOT",
    "url": "https://github.com/jh3ady"
  },
  "license": "MIT",
  "homepage": "https://github.com/jh3ady/claude-plugins/tree/main/plugins/design-patterns",
  "keywords": [
    "design-patterns",
    "gang-of-four",
    "gof",
    "creational-patterns",
    "structural-patterns",
    "behavioral-patterns",
    "null-object",
    "result-either",
    "specification",
    "software-craftsmanship"
  ]
}
```

- [ ] **Step 3: Validate the manifest is parseable JSON**

Run: `python3 -m json.tool plugins/design-patterns/.claude-plugin/plugin.json > /dev/null && echo OK`
Expected: `OK`

- [ ] **Step 4: Commit**

```bash
git add plugins/design-patterns/.claude-plugin/plugin.json plugins/design-patterns/LICENSE
git commit -m "🎉 chore(design-patterns): scaffold the plugin manifest and license"
```

---

## Task 2: Author the design-patterns SKILL.md (lean judgment core)

**Files:**
- Create: `plugins/design-patterns/skills/design-patterns/SKILL.md`

**Interfaces:**
- Consumes: the voice and section shape of `plugins/solid-principles/skills/solid-principles/SKILL.md` (read it first).
- Produces: a lean skill referencing the four files authored in Tasks 3 to 6 (`references/creational.md`, `references/structural.md`, `references/behavioral.md`, `references/modern-idioms.md`). The smell-to-pattern index and the composition map defined here are the spine consumed by the reference tasks.

**Verified claims to cover (sourced; do not contradict these):**
- A design pattern is a named, reusable solution to a recurring design problem in a context; the Gang of Four catalogue groups them into creational, structural, and behavioral. (Gamma et al. 1994.)
- Patterns answer an identified variation point, not an anticipated one. Introduce the abstraction when the third case appears (the rule of three), not on the first speculative guess. (Composability with `simplicity-principles`.)
- The extensibility nuance: when a variation point is real and identified, opening it cleanly with the right pattern is the Open/Closed Principle done right, not over-engineering. The fault is speculative abstraction, not abstraction itself. (Composability with `solid-principles`.)
- The minimal-form reflex: in TypeScript first-class functions and closures often replace a multi-class pattern. A Strategy is frequently a function parameter; a Command, a closure; a Decorator, a wrapping function. Draw the classes only when they pay their cost.
- Ownership by level of abstraction: this skill is the source of truth for the generic mechanism (Adapter as wrapping an incompatible interface, Command as reifying a request, Factory as encapsulating creation); the architecture plugins own the specialised application (hexagonal owns boundary adapters, CQRS owns the command message, DDD owns the aggregate factory). Cross-references run both ways.

- [ ] **Step 1: Read the model skill for voice**

Run: `cat plugins/solid-principles/skills/solid-principles/SKILL.md`
Expected: observe the frontmatter description style, the short definition, conceptual sections, the `## Guardrails` section, the `## Adapt to your context` section, the closing reference pointer.

- [ ] **Step 2: Write the SKILL.md**

Create `plugins/design-patterns/skills/design-patterns/SKILL.md` with:
- Frontmatter `name: design-patterns` and a trigger-oriented `description` covering: introducing, reviewing, or refactoring around a point of variation; hesitating between two patterns; asking whether a pattern is warranted here; recognising a smell that a pattern addresses (behaviour that varies at runtime, repeated null guards, families of related objects, a tangle of conditionals), even when no pattern is named. The description must name "design patterns" and "Gang of Four" so a generic "should I use a pattern" request triggers it, must include explicit guardrails against speculative application, and must steer specialised applications (boundary adapters, the CQRS command message, the aggregate factory) to the owning architecture plugins. One dense paragraph.
- Body sections (short prose, mirror the SOLID skill): a one-paragraph definition (a named solution to a recurring problem; the three GoF families); `## The decision reflex` (a pattern answers an identified variation point, not an anticipated one; the rule of three before abstracting); `## Pragmatic, not anti-extensible` (the extensibility nuance: opening a real variation point cleanly is OCP done right; speculative abstraction is the fault, not abstraction); `## Reach for the minimal form` (in TypeScript a function or closure often replaces a multi-class pattern; classes only when they pay their cost); `## Smell to candidate pattern` (a compact table: behaviour varies at runtime to Strategy or State; families of related products to Abstract Factory; repeated null guards to Null Object; add behaviour around an object to Decorator; reify a request, queue or undo it to Command; a subsystem too wide to use to Facade; an object structure walked by many operations to Visitor; success-or-failure threaded through returns to Result/Either; a composable business rule to Specification); `## Ownership and composition` (this skill owns the generic mechanism; `hexagonal-architecture` owns boundary adapters, `cqrs` owns the command message, `domain-driven-design` owns the aggregate factory and pairs with Specification, `event-sourcing` pairs with Memento and Observer, `refactoring` holds the mechanics that arrive at a pattern such as Replace Conditional with Polymorphism; Repository and dependency injection are out of scope, owned by `domain-driven-design` and `dependency-injection`); `## Guardrails` (no pattern for its name; no cargo-cult; no gratuitous indirection; prefer the least machinery that solves the real problem; a pattern you cannot name a current need for is speculative); `## Adapt to your context`; `## Reference` pointing to the four reference files with a one-line description of each.
- Apply Global Constraints (English, no em-dashes, full words, judgment first, the extensibility nuance present).

- [ ] **Step 3: Validate frontmatter and triggering**

Use the `skill-reviewer` agent on `plugins/design-patterns/skills/design-patterns/SKILL.md`. Apply its non-cosmetic feedback. Confirm the description triggers on variation-point and pattern-selection situations and does not cannibalise the architecture plugins (it must route specialised applications out, not absorb them).
Expected: description triggers reliably; no structural issues.

- [ ] **Step 4: Verify no em-dashes**

Run: `! grep -n "—" plugins/design-patterns/skills/design-patterns/SKILL.md && echo "no em-dash OK"`
Expected: `no em-dash OK`

- [ ] **Step 5: Commit**

```bash
git add plugins/design-patterns/skills/design-patterns/SKILL.md
git commit -m "✨ feat(design-patterns): add the design-patterns skill core"
```

---

## Task 3: Author the creational patterns reference

**Files:**
- Create: `plugins/design-patterns/skills/design-patterns/references/creational.md`

**Interfaces:**
- Consumes: the per-pattern template, the smell-to-pattern index, and the composition map from Task 2.
- Produces: the first of the four reference files the SKILL.md points to.

**Per-pattern template (every pattern, deliberately light on the canonical definition):**
1. The force or smell that motivates it (one or two sentences).
2. When NOT to use it (the pragmatic guardrail).
3. The minimal TypeScript form (a short, type-consistent example).
4. How it composes with the other plugins (cross-reference where relevant).

**Patterns to cover (the five GoF creational patterns):**
1. **Abstract Factory**: families of related products created together; when not (only one family exists, so it is speculative; YAGNI); minimal TS (an object of factory functions); composition (the aggregate factory specialisation lives in `domain-driven-design`). Source: Gamma et al. 1994.
2. **Builder**: step-by-step construction of a complex object with many optional parts; when not (few parameters, so an options object or named parameters suffice in TypeScript); minimal TS (an options-object constructor, with a fluent builder shown only as the heavier alternative). Source: Gamma et al. 1994.
3. **Factory Method**: defer the choice of concrete type to a method; when not (a plain function or a parameter does the job); minimal TS (a factory function); composition (`domain-driven-design` owns the invariant-guarding aggregate factory). Source: Gamma et al. 1994.
4. **Prototype**: create by cloning an existing instance; when not (rare in TypeScript; object spread or `structuredClone` usually suffices, and mutable shared state is a trap); minimal TS (a `clone()` returning a structural copy). Source: Gamma et al. 1994.
5. **Singleton**: a single shared instance with a global access point. This is the strong-guardrail pattern: when not (almost always; a module-level constant or a single instance wired once in the dependency-injection composition root gives the same sharing without the global coupling and the test pain); minimal TS (a module-level `export const`); composition (lifetime management belongs to `dependency-injection`). Source: Gamma et al. 1994.

End with a short "choosing within this group" note and a Sources line (Gamma et al. 1994).

- [ ] **Step 1: Write the reference document**

Create the file following the per-pattern template and the pattern list above. Keep each pattern light on definition, heavy on judgment. Mirror the depth and citation style of `plugins/solid-principles/skills/solid-principles/references/solid.md` (read it first for tone). Apply the sourcing rule.

- [ ] **Step 2: Accuracy check**

Read the file and confirm: five creational patterns each with the four template points; Singleton carries the strong "when not" steering to a module constant or the DI composition root; Abstract Factory and Factory Method cross-reference the DDD aggregate factory; TypeScript examples are type-consistent; no invented page numbers.

- [ ] **Step 3: Verify no em-dashes**

Run: `! grep -n "—" plugins/design-patterns/skills/design-patterns/references/creational.md && echo "no em-dash OK"`
Expected: `no em-dash OK`

- [ ] **Step 4: Commit**

```bash
git add plugins/design-patterns/skills/design-patterns/references/creational.md
git commit -m "📝 docs(design-patterns): add the creational patterns reference"
```

---

## Task 4: Author the structural patterns reference

**Files:**
- Create: `plugins/design-patterns/skills/design-patterns/references/structural.md`

**Interfaces:**
- Consumes: the per-pattern template and the composition map from Task 2.
- Produces: the second reference file.

**Patterns to cover (the seven GoF structural patterns), each with the four template points:**
1. **Adapter**: wrap an object so an incompatible interface fits the one a client expects; when not (you control both sides, so just change one); minimal TS (a wrapping object or function); composition (`hexagonal-architecture` owns the driving and driven adapter at the boundary; this entry is the generic mechanism, point there for the boundary application). Source: Gamma et al. 1994.
2. **Bridge**: separate an abstraction from its implementation so the two vary independently; when not (only one implementation exists; premature, so YAGNI); minimal TS (an abstraction holding an implementor interface). Source: Gamma et al. 1994.
3. **Composite**: treat individual objects and compositions of objects uniformly through a shared interface (part-whole trees); when not (no real recursive structure); minimal TS (a node interface with leaf and composite). Source: Gamma et al. 1994.
4. **Decorator**: attach responsibilities to an object dynamically by wrapping it in something that shares its interface; when not (a single fixed behaviour, so just write it); minimal TS (a higher-order function wrapping a function, with the class form shown as the heavier alternative); composition (the functional form ties to `references/modern-idioms.md`). Source: Gamma et al. 1994.
5. **Facade**: a single simplified entry point over a wide subsystem; when not (the subsystem is already small); minimal TS (a module exposing a narrow API); composition (a module public API in `modular-monolith` and a feature entry point in `screaming-architecture` are this idea at the architecture level). Source: Gamma et al. 1994.
6. **Flyweight**: share fine-grained objects to save memory; the strong-guardrail structural pattern: when not (almost always; this is premature optimisation unless a measured memory problem exists; `simplicity-principles`); minimal TS (a small cache of shared instances). Source: Gamma et al. 1994.
7. **Proxy**: a surrogate that controls access to another object (lazy loading, access control, logging, remote); when not (no cross-cutting concern to interpose); minimal TS (a wrapping object or a JavaScript `Proxy`). Source: Gamma et al. 1994.

End with a short "choosing within this group" note (Adapter versus Decorator versus Proxy all wrap, but for different reasons) and a Sources line.

- [ ] **Step 1: Write the reference document**

Create the file following the per-pattern template and the pattern list. Keep each pattern light on definition, heavy on judgment. Mirror the SOLID reference's depth and citation style. Apply the sourcing rule.

- [ ] **Step 2: Accuracy check**

Read the file and confirm: seven structural patterns each with the four template points; Adapter points to `hexagonal-architecture` for the boundary application while owning the generic mechanism; Facade cross-references `modular-monolith` and `screaming-architecture`; Flyweight carries the premature-optimisation guardrail; Decorator shows the functional minimal form; TypeScript examples are type-consistent; no invented page numbers.

- [ ] **Step 3: Verify no em-dashes**

Run: `! grep -n "—" plugins/design-patterns/skills/design-patterns/references/structural.md && echo "no em-dash OK"`
Expected: `no em-dash OK`

- [ ] **Step 4: Commit**

```bash
git add plugins/design-patterns/skills/design-patterns/references/structural.md
git commit -m "📝 docs(design-patterns): add the structural patterns reference"
```

---

## Task 5: Author the behavioral patterns reference

**Files:**
- Create: `plugins/design-patterns/skills/design-patterns/references/behavioral.md`

**Interfaces:**
- Consumes: the per-pattern template and the composition map from Task 2.
- Produces: the third reference file.

**Patterns to cover (the eleven GoF behavioral patterns), each with the four template points:**
1. **Chain of Responsibility**: pass a request along a chain until a handler takes it; when not (a single handler or a simple conditional suffices); minimal TS (an array of handler functions iterated until one returns). Source: Gamma et al. 1994.
2. **Command**: reify a request as an object so it can be passed, queued, logged, or undone; when not (no need to store or reverse the action, so call the function directly); minimal TS (a closure, with the object form shown for undo or queueing); composition (false friend warning: the `cqrs` command is a write-model message, a different concept that shares only the word; point there). Source: Gamma et al. 1994.
3. **Interpreter**: represent a grammar and evaluate sentences in it; the strong-guardrail behavioral pattern: when not (almost always; reach for a real parser or a data-driven rule before building an interpreter); minimal TS (a tiny expression tree with an `interpret` method), kept short. Source: Gamma et al. 1994.
4. **Iterator**: traverse a collection without exposing its representation; when not (TypeScript already has it; use `Symbol.iterator`, generators, and `for...of` rather than hand-rolling); minimal TS (a generator function). Source: Gamma et al. 1994.
5. **Mediator**: centralise how a set of objects interact so they do not refer to each other directly; when not (the indirection hides the flow and over-centralises; few collaborators); minimal TS (a coordinator object). Source: Gamma et al. 1994.
6. **Memento**: capture and restore an object's state without exposing its internals; when not (no real undo or checkpoint need); minimal TS (a snapshot function and a restore function); composition (`event-sourcing` snapshots are this idea applied to the event store; point there). Source: Gamma et al. 1994.
7. **Observer**: notify dependents when a subject changes; when not (a single synchronous caller; over-eventing makes flow hard to trace); minimal TS (a set of callbacks, or `EventTarget`); composition (domain events in `domain-driven-design` and the projection-driving events in `event-sourcing` are this idea at the domain level). Source: Gamma et al. 1994.
8. **State**: let an object change its behaviour when its internal state changes, by delegating to a state object; when not (two states and one flag, so a conditional is clearer); minimal TS (a map from state to behaviour); composition (closely related to Strategy: same shape, different intent). Source: Gamma et al. 1994.
9. **Strategy**: make a family of algorithms interchangeable behind a common interface; when not (one algorithm, so it is speculative); minimal TS (a function passed as a parameter, with the interface form for stateful strategies); composition (usually wired through `dependency-injection`; it is the OCP and DIP move from `solid-principles`). This entry carries the extensibility nuance explicitly: a real, identified variation point makes Strategy the correct answer, not over-engineering. Source: Gamma et al. 1994.
10. **Template Method**: define the skeleton of an algorithm and let subclasses fill in steps; when not (inheritance is heavier than needed; prefer passing the varying steps as functions, which is composition over inheritance); minimal TS (a function taking the varying steps as callbacks, with the subclass form noted); composition (Strategy is the composition-based alternative). Source: Gamma et al. 1994.
11. **Visitor**: represent an operation to perform over the elements of an object structure, so new operations are added without changing the elements; the heavy behavioral pattern: when not (TypeScript discriminated unions plus an exhaustive `switch` usually beat the double-dispatch ceremony; reach for Visitor only when the element set is stable and operations multiply); minimal TS (a discriminated union with an exhaustive switch shown as the lighter alternative, then the visitor form). Source: Gamma et al. 1994.

End with a short "choosing within this group" note (Strategy versus State versus Template Method) and a Sources line.

- [ ] **Step 1: Write the reference document**

Create the file following the per-pattern template and the pattern list. Keep each pattern light on definition, heavy on judgment. Mirror the SOLID reference's depth and citation style. Apply the sourcing rule.

- [ ] **Step 2: Accuracy check**

Read the file and confirm: eleven behavioral patterns each with the four template points; Command carries the CQRS false-friend warning; Strategy carries the extensibility nuance and the DI and SOLID composition; Memento and Observer cross-reference `event-sourcing` and `domain-driven-design`; Iterator steers to native TypeScript; Interpreter and Visitor carry their strong "when not"; TypeScript examples are type-consistent; no invented page numbers.

- [ ] **Step 3: Verify no em-dashes**

Run: `! grep -n "—" plugins/design-patterns/skills/design-patterns/references/behavioral.md && echo "no em-dash OK"`
Expected: `no em-dash OK`

- [ ] **Step 4: Commit**

```bash
git add plugins/design-patterns/skills/design-patterns/references/behavioral.md
git commit -m "📝 docs(design-patterns): add the behavioral patterns reference"
```

---

## Task 6: Author the modern idioms reference

**Files:**
- Create: `plugins/design-patterns/skills/design-patterns/references/modern-idioms.md`

**Interfaces:**
- Consumes: the per-pattern template and the composition map from Task 2.
- Produces: the fourth reference file.

**Idioms to cover (the four modern idioms the 1994 catalogue predates), each with the four template points:**
1. **Null Object**: a neutral object that implements the expected interface and does nothing, replacing scattered null or undefined checks; when not (when absence is meaningful and a caller must react to it, the Null Object hides a real branch or a bug); minimal TS (a `NullLogger` style no-op implementation); composition (a calmer alternative to repeated guards, see `clean-code`). Source: Fowler, Refactoring.
2. **Result / Either**: model success or failure as a return value rather than throwing, so the failure path is explicit in the type; when not (truly exceptional, unrecoverable failures, where an exception is clearer; do not thread a Result through every layer dogmatically); minimal TS (a `type Result<T, E> = { ok: true; value: T } | { ok: false; error: E }` with a small example); composition (this is the error-handling stance from `clean-code`; pairs with explicit domain errors). Source: common TypeScript practice.
3. **Specification**: reify a boolean business rule as a composable object with `and`, `or`, and `not`, so rules combine and read in domain terms; when not (a one-off predicate, where a plain function is lighter; do not build the algebra speculatively); minimal TS (a `Specification<T>` interface with `isSatisfiedBy` and combinators); composition (a domain-layer pattern, see `domain-driven-design`). Source: Fowler, and Evans/Fowler on Specification.
4. **Functional patterns**: higher-order functions and closures as a light alternative to Strategy and Command, plus immutability; this entry reinforces the minimal-form message: a function often suffices where the Gang of Four draws classes; when not (when state, lifecycle, or multiple coordinated methods genuinely need an object); minimal TS (a strategy passed as a function and a command as a closure, contrasted with their class forms); composition (the recurring "reach for the minimal form" thread from the SKILL.md). Source: common practice.

End with a one-paragraph note tying these back to the SKILL.md decision reflex (modern idioms are often the minimal form that a classic pattern over-engineers) and a Sources line.

- [ ] **Step 1: Write the reference document**

Create the file following the per-pattern template and the idiom list. Keep each idiom light on definition, heavy on judgment. Mirror the SOLID reference's depth and citation style. Apply the sourcing rule.

- [ ] **Step 2: Accuracy check**

Read the file and confirm: four idioms each with the four template points; Result/Either cross-references `clean-code` error handling and warns against dogmatic threading; Specification cross-references `domain-driven-design` and warns against building the algebra speculatively; functional patterns reinforce the minimal-form message; Null Object carries the "absence is meaningful" guardrail; TypeScript examples are type-consistent; no invented citations.

- [ ] **Step 3: Verify no em-dashes**

Run: `! grep -n "—" plugins/design-patterns/skills/design-patterns/references/modern-idioms.md && echo "no em-dash OK"`
Expected: `no em-dash OK`

- [ ] **Step 4: Commit**

```bash
git add plugins/design-patterns/skills/design-patterns/references/modern-idioms.md
git commit -m "📝 docs(design-patterns): add the modern idioms reference"
```

---

## Task 7: Author the plugin README

**Files:**
- Create: `plugins/design-patterns/README.md`

**Interfaces:**
- Consumes: the skill scope, the judgment-first framing, and the ownership-by-level rule.
- Produces: the plugin landing document.

- [ ] **Step 1: Read the model READMEs**

Run: `cat plugins/solid-principles/README.md plugins/test-driven-development/README.md`
Expected: observe the structure (title, intro, "What it does", "Relationship to other plugins", "Install", "Adapt to your context", "License").

- [ ] **Step 2: Write the README**

Create `plugins/design-patterns/README.md` mirroring that structure:
- Intro framing the plugin as judgment first: Claude already knows what a pattern is, so the value is when to apply, when to refuse, the minimal form, and composition.
- `## What it does`: the judgment frame in the skill, then the four reference groups (creational, structural, behavioral, modern idioms), naming the 23 Gang of Four patterns plus Null Object, Result/Either, Specification, and functional patterns. State the ownership-by-level rule (generic mechanism here; specialised application in the architecture plugins) and the extensibility nuance.
- `## Relationship to other plugins`: `solid-principles` (OCP and DIP behind most behavioral patterns), `simplicity-principles` (the rule of three, duplication versus the wrong abstraction), `dependency-injection` (wiring a Strategy; lifetime instead of Singleton), `hexagonal-architecture` (boundary adapters), `cqrs` (the command message, a false friend), `domain-driven-design` (the aggregate factory, Specification), `event-sourcing` (Memento and Observer at the store level), `refactoring` (the mechanics that arrive at a pattern). State explicitly that Repository and dependency injection are out of scope, owned elsewhere.
- Install block:

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install design-patterns@jh3ady-claude-plugins
```

- `## Adapt to your context` and `## License`. Apply Global Constraints.

- [ ] **Step 3: Verify no em-dashes**

Run: `! grep -n "—" plugins/design-patterns/README.md && echo "no em-dash OK"`
Expected: `no em-dash OK`

- [ ] **Step 4: Commit**

```bash
git add plugins/design-patterns/README.md
git commit -m "📝 docs(design-patterns): add the plugin readme"
```

---

## Task 8: Register in the marketplace and the root README

**Files:**
- Modify: `.claude-plugin/marketplace.json`
- Modify: `README.md` (root)

**Interfaces:**
- Consumes: the plugin name and the description string from Task 1.

- [ ] **Step 1: Add the marketplace entry**

Append to the `plugins` array in `.claude-plugin/marketplace.json`, after the `refactoring` entry (the current last entry). Add a comma after the previous entry's closing brace so the array stays valid JSON:

```json
    {
      "name": "design-patterns",
      "source": "./plugins/design-patterns",
      "description": "Design patterns applied pragmatically, judgment first: the 23 Gang of Four patterns plus modern idioms (Null Object, Result/Either, Specification, functional patterns), framed by when to reach for a pattern, when to refuse it (the rule of three, no speculative abstraction), the minimal TypeScript form, and ownership by level of abstraction so the generic mechanism lives here while its specialised application lives in hexagonal, CQRS, and DDD. Composable with your own conventions.",
      "version": "0.1.0"
    }
```

- [ ] **Step 2: Validate the marketplace JSON**

Run: `python3 -m json.tool .claude-plugin/marketplace.json > /dev/null && echo OK`
Expected: `OK`

- [ ] **Step 3: Add the root README row**

In the root `README.md` plugins table, add the `design-patterns` row after the `refactoring` row (the current last row, before `## Contributing`):

```markdown
| [`design-patterns`](plugins/design-patterns) | Design patterns judgment first: the 23 Gang of Four patterns plus modern idioms (Null Object, Result/Either, Specification, functional patterns), framed by when to apply, when to refuse (the rule of three, no speculative abstraction), the minimal TypeScript form, and ownership by level so the generic mechanism lives here while its specialised application lives in hexagonal, CQRS, and DDD. |
```

- [ ] **Step 4: Verify no em-dashes in the added row**

Run: `! grep -n "—" README.md && echo "no em-dash OK"`
Expected: `no em-dash OK`

- [ ] **Step 5: Commit**

```bash
git add .claude-plugin/marketplace.json README.md
git commit -m "📝 docs(design-patterns): register the plugin in the marketplace"
```

---

## Task 9: Validate the whole plugin and enable it in settings

**Files:**
- Modify: `~/.claude/settings.json` (symlinked to `~/.config/claude-config/claude/settings.json`)

**Interfaces:**
- Consumes: the finished plugin.

- [ ] **Step 1: Run the plugin validator**

Use the `plugin-validator` agent on `plugins/design-patterns`. Apply any structural fixes it reports (manifest, skill frontmatter, directory layout).
Expected: plugin validates; one skill discovered.

- [ ] **Step 2: Confirm the skill and all four references are present**

Run: `find plugins/design-patterns -name SKILL.md && echo "---" && find plugins/design-patterns -name '*.md' -path '*/references/*' | sort`
Expected: one SKILL.md path (design-patterns); four reference files (behavioral.md, creational.md, modern-idioms.md, structural.md).

- [ ] **Step 3: Enable the plugin in settings**

Add to the `enabledPlugins` object in `~/.claude/settings.json` (the symlink target is `~/.config/claude-config/claude/settings.json`; edit the real file), after the `refactoring@jh3ady-claude-plugins` entry (add a comma to that line first if it is the last entry):

```json
    "design-patterns@jh3ady-claude-plugins": true
```

- [ ] **Step 4: Validate the settings JSON**

Run: `python3 -m json.tool ~/.claude/settings.json > /dev/null && echo OK`
Expected: `OK`

- [ ] **Step 5: Final review and spec sign-off**

Re-read the spec `docs/superpowers/specs/2026-07-01-design-patterns-plugin-design.md` and confirm every success criterion is met: one plugin with one judgment-first skill; lean SKILL.md with depth in four references; the 23 Gang of Four patterns plus the four modern idioms present and actionable in TypeScript from the references alone; ownership by level of abstraction respected (generic mechanism here, specialised application referenced out, no duplication); Repository, DI, and PoEAA flagged out of scope; the extensibility nuance explicit; content reviewed for accuracy; the description triggers precisely without cannibalising the architecture plugins; registered in the marketplace and enabled in settings.

- [ ] **Step 6: Note for the user**

The `enabledPlugins` change lives in the `claude-config` repository (the symlink target), not in `claude-plugins`. Tell the user to review and commit that change in `claude-config` separately, since it is a different repository.

---

## Self-Review

- **Spec coverage:** Plugin identity and structure → Tasks 1, 2, 7. Judgment-first SKILL.md (decision reflex, extensibility nuance, minimal form, smell index, composition map, guardrails) → Task 2. The 23 Gang of Four patterns → Tasks 3 (5 creational), 4 (7 structural), 5 (11 behavioral); total 23. The four modern idioms → Task 6. Ownership by level of abstraction and bidirectional cross-references → embedded in Tasks 2 to 6 (Adapter to hexagonal, Command to CQRS, factories to DDD, Memento and Observer to event-sourcing, Specification to DDD, Singleton and Strategy to dependency-injection). Repository, DI, and PoEAA out of scope → stated in Task 2, the references, and Task 7. Sourcing and validation → Global Constraints plus accuracy checks in Tasks 3 to 6 and the sign-off in Task 9. Marketplace and settings → Tasks 8, 9.
- **Placeholder scan:** No "TBD"/"TODO". Prose deliverables (the skill and the four references) carry an explicit per-pattern template, a complete pattern list per file, sourced intent claims, and per-pattern "when not" and composition notes rather than invented final copy, which is the correct granularity for authoring tasks; structural files (manifest, marketplace entry, README row, settings entry) carry exact content.
- **Type consistency:** The skill name (`design-patterns`), the four reference filenames (`creational.md`, `structural.md`, `behavioral.md`, `modern-idioms.md`), the `@jh3ady-claude-plugins` suffix, the `0.1.0` version, and the plugin description string are identical across Tasks 1, 2, 3, 4, 5, 6, 8, and 9. Each Gang of Four pattern is assigned to exactly one reference file (creational five, structural seven, behavioral eleven), and each modern idiom appears once in Task 6. The `Result<T, E>` shape and the `Specification<T>` interface named in Task 6 are the only invented type signatures and are self-contained to that file.
```
