# Dependency injection plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `dependency-injection` plugin to the `jh3ady-claude-plugins` marketplace, mirroring the existing engineering-principle plugins (lean `SKILL.md` plus a sourced `references/` document with TypeScript examples), with Pure DI as the default and DI containers referenced as a justified option.

**Architecture:** One plugin under `plugins/dependency-injection/` with the standard layout (`.claude-plugin/plugin.json`, `skills/dependency-injection/SKILL.md`, `skills/dependency-injection/references/dependency-injection.md`, `README.md`, `LICENSE`). The skill covers dependency injection proper (injection styles, composition root, Pure DI versus container, lifetimes, anti-patterns), with DIP referenced to `solid-principles` and hexagonal / modular monolith referenced as complementary. Integrated into `marketplace.json` and the root `README.md`.

**Tech Stack:** Markdown skill files, JSON manifest, TypeScript code examples in the reference. No build or runtime; validation is JSON parsing, structural parity with sibling plugins, and the `plugin-validator` / `skill-reviewer` agents.

## Global Constraints

- Writing language: English. No em-dashes anywhere. Words in full (no unjustified abbreviations); standard acronyms (DI, IoC, DIP, SOLID, API, TDD) are fine.
- No Claude self-promotion or `Co-Authored-By` trailers in any file or commit.
- Commit messages: gitmoji + Conventional Commits, form `<emoji> <type>(<optional scope>): <summary>`.
- Plugin version: `0.1.0`. License: MIT. Author block: `{ "name": "Jean-Denis VIDOT", "url": "https://github.com/jh3ady" }`.
- `SKILL.md` stays lean (target 60 to 78 lines), depth lives in `references/`.
- Examples in TypeScript only.
- Emphasis: Pure DI (manual constructor injection) is the default; containers are referenced with trade-offs, not tutorialized.
- Every significant claim in the reference must be grounded in the researched primary sources (Fowler, Seemann and van Deursen, Robert C. Martin for DIP, Hevery, container docs). Apply the captured nuances: the term was introduced by consensus (not single-handedly by Fowler); constructor over-injection is a code smell, not an anti-pattern; service locator is contested (Seemann anti-pattern versus Fowler alternative); "Pure DI" replaces "Poor Man's DI"; a module exposes a registration fragment, not its own composition root; the Fowler and Seemann injection-style taxonomies must not be merged; TypeScript runtime type erasure forces token-based injection.

---

### Task 1: Scaffold the plugin (manifest, license, README)

Create the plugin skeleton and the non-skill files.

**Files:**
- Create: `plugins/dependency-injection/.claude-plugin/plugin.json`
- Create: `plugins/dependency-injection/LICENSE`
- Create: `plugins/dependency-injection/README.md`

**Interfaces:**
- Consumes: nothing (first task).
- Produces: plugin directory `plugins/dependency-injection/` with a valid manifest named `dependency-injection`, version `0.1.0`. Later tasks add the skill under `skills/dependency-injection/`.

- [ ] **Step 1: Create `plugin.json`**

```json
{
  "name": "dependency-injection",
  "version": "0.1.0",
  "description": "Dependency injection applied pragmatically: Pure DI (manual constructor injection) first, the composition root, object lifetimes, and the anti-pattern catalogue, with DI containers referenced as a justified option. Composable with your own conventions.",
  "author": {
    "name": "Jean-Denis VIDOT",
    "url": "https://github.com/jh3ady"
  },
  "license": "MIT",
  "homepage": "https://github.com/jh3ady/claude-plugins/tree/main/plugins/dependency-injection",
  "keywords": [
    "dependency-injection",
    "inversion-of-control",
    "composition-root",
    "pure-di",
    "constructor-injection",
    "di-container",
    "software-design"
  ]
}
```

- [ ] **Step 2: Create `LICENSE`**

Run: `cp plugins/clean-code/LICENSE plugins/dependency-injection/LICENSE`
Expected: file exists, identical to the sibling.

- [ ] **Step 3: Create `README.md`**

```markdown
# dependency-injection

A Claude Code plugin that helps wire dependencies pragmatically: supply an
object's collaborators from outside rather than constructing them inside,
with Pure DI (manual constructor injection) as the default and a DI container
treated as an option that must earn its keep.

It stays generic on purpose: compose it with your own container choice and
your team or personal conventions.

## What it does

When you wire dependencies, structure object construction, choose between
manual wiring and a DI container, or review for DI anti-patterns, the bundled
skill applies:

- Constructor injection by default, the composition root, and Pure DI first.
- Object lifetimes and the captive dependency trap.
- The pragmatic rule: no container until convention-based auto-wiring or a
  large object graph genuinely justifies one.
- The anti-pattern catalogue (service locator, control freak, over-injection),
  with the genuine debates surfaced rather than flattened.

## Install

`​`​`bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install dependency-injection@jh3ady-claude-plugins
`​`​`

## Adapt to your context

This plugin is a baseline, not a dogma. Layer your own container choice and
team conventions in your own `CLAUDE.md` or a higher-priority skill. The
plugin does not impose them.

## License

Released under the [MIT License](LICENSE).
```

Note: write the install fenced block with real triple backticks; the markers above are placeholders for this plan document only. Mirror the exact README structure of `plugins/clean-code/README.md` and `plugins/modular-monolith/README.md`.

- [ ] **Step 4: Validate the manifest parses and matches siblings**

Run: `python3 -c "import json; d=json.load(open('plugins/dependency-injection/.claude-plugin/plugin.json')); assert d['name']=='dependency-injection'; assert d['version']=='0.1.0'; print('ok')"`
Expected: `ok`

Run: `diff <(head -1 plugins/clean-code/LICENSE) <(head -1 plugins/dependency-injection/LICENSE)`
Expected: no output (identical first line `MIT License`).

- [ ] **Step 5: Commit**

```bash
git add plugins/dependency-injection/.claude-plugin/plugin.json plugins/dependency-injection/LICENSE plugins/dependency-injection/README.md
git commit -m "✨ feat(dependency-injection): scaffold plugin manifest, license, and readme"
```

---

### Task 2: Write the reference document

Author the deep reference. This is the source of truth from which the lean `SKILL.md` is distilled in Task 3, so it is written first.

**Files:**
- Create: `plugins/dependency-injection/skills/dependency-injection/references/dependency-injection.md`

**Interfaces:**
- Consumes: the plugin directory from Task 1.
- Produces: `references/dependency-injection.md` with eight numbered sections (titles below). Task 3's `SKILL.md` distils sections 2, 3, 4, 5, 6 and the anti-patterns of section 7.

- [ ] **Step 1: Write the reference with these eight sections**

Each section carries at least one TypeScript example and a "when not to apply" or caveat note. Use the verified claims and cite sources inline (author plus URL), matching the citation density of `plugins/modular-monolith/skills/modular-monolith/references/modular-monolith.md`. Lead the TypeScript examples with Pure DI (manual constructor injection, no library). Required content per section:

1. **Definition and origin.** DI = an object receives its dependencies from an external source rather than constructing them itself (Seemann: "dependency injection is passing an argument"). Fowler introduced the term in 2004 by consensus with other IoC advocates (not single-handedly), because "Inversion of Control is too generic a term". Seemann and van Deursen, *Dependency Injection Principles, Practices, and Patterns*. TypeScript example: a class taking its repository via the constructor versus newing it up internally. When not to apply: a class with no real collaborators does not need injection ceremony.

2. **DI vs IoC vs DIP.** The three-way distinction (the most common confusion): IoC is the broad principle (Hollywood principle, "don't call us, we'll call you"); DIP is SOLID's design principle (depend on abstractions, high-level policy owns the abstraction); DI is the narrow technique to supply dependencies. Correct "DI == DIP" and "DI == IoC" as false. Reference `solid-principles` for DIP rather than redefining it. When not to apply: extracting an interface and injecting it is DI but does not by itself achieve DIP unless the high-level policy owns the abstraction.

3. **Injection styles.** Constructor injection as the default and why (it guarantees required dependencies are present at construction; Seemann: "Favour the Constructor Injection pattern over other injection patterns"). Setter/property injection only for genuinely optional dependencies with a good local default; method injection when the dependency varies per call. Note the two taxonomies without merging them: Fowler (Constructor, Setter, Interface); Seemann (Constructor, Property, Method, Ambient Context). TypeScript example: constructor injection, plus a setter-injection case for an optional dependency.

4. **Composition root.** A single location, as close as possible to the entry point, where the object graph is composed (Seemann). One per application regardless of complexity. Register Resolve Release. Confine any container to the composition root (the structural defense against service locator). TypeScript example: a Pure DI composition root wiring the graph by hand at the entry point. When not to apply: libraries and frameworks should not have a composition root.

5. **Pure DI versus a container.** Pure DI = wiring by hand (Seemann renamed "Poor Man's DI" to "Pure DI"); it is strongly typed and gives compile-time feedback. A container auto-wires but loses compile-time safety and earns its keep mainly through convention-based auto-wiring on a large graph. Seemann's rule: "Don't use a DI Container just to use one." Reference the TypeScript containers with trade-offs (NestJS built-in DI and module-scoped providers; tsyringe and InversifyJS, decorator plus `reflect-metadata`; Awilix, no decorators, proxy or classic mode with a minification caveat). State the runtime constraint: TypeScript types are erased at runtime, so a container cannot use an interface as a token; token-based injection (string, `Symbol`, abstract class, `InjectionToken`) is required, and the legacy `experimentalDecorators` plus `emitDecoratorMetadata` mechanism differs from TC39 Stage 3 decorators. TypeScript example: the same graph wired with Pure DI and then sketched with one container, showing the token. When not to apply: a small app does not need a container.

6. **Object lifetimes.** Singleton, transient, scoped (note the .NET "lifetime" versus the book's "lifestyle" terminology). The captive dependency problem: a longer-lived component (singleton) holding a shorter-lived one (scoped or transient) past its due release, which effectively promotes the captive and breaks under concurrency. TypeScript example: a singleton accidentally capturing a per-request dependency, and the fix. When not to apply: a stateless, side-effect-free service can be a singleton without concern.

7. **Anti-patterns.** Service locator presented even-handedly: Seemann classifies it an anti-pattern (it hides dependencies, turning compile-time errors into run-time errors, and a container confined to the composition root is not a service locator) while Fowler treats it as a legitimate DI alternative and Jimmy Bogard rebuts the anti-pattern label; state the default position (prefer injection, confine the container) without pretending it is settled. Control freak (newing up dependencies directly). Constrained construction. Ambient context (a static or global accessor). Injecting the container itself. Constructor over-injection framed explicitly as a code smell, not an anti-pattern (Seemann), signalling an SRP violation, fixed by refactoring responsibilities (Facade or Aggregate Services), not by switching injection styles or wrapping parameters. TypeScript example: a service-locator call site versus the injected equivalent.

8. **Adjacent patterns.** DIP (a design principle DI helps you follow; referenced to `solid-principles`). Hexagonal / ports and adapters: DI is the wiring mechanism that injects adapters at the composition root, "a wiring mechanism, not an architecture". The composition root in a modular monolith: one root per application, each module exposing a registration fragment (not its own composition root). Strategy (injecting a strategy is one form of DI; DI is broader because it injects any collaborator). Distinguish injectables (services, injected) from newables (value objects and entities, created with `new`); per Hevery, newables must not depend on injectables and injectables must not hold newables as state. A single-implementation interface with no boundary is over-abstraction (Reused Abstractions Principle; ties to the `solid-principles` guardrail).

- [ ] **Step 2: Validate structure and conventions**

Run: `grep -c '^## ' plugins/dependency-injection/skills/dependency-injection/references/dependency-injection.md`
Expected: at least `8` second-level headings.

Run: `! grep -n '—' plugins/dependency-injection/skills/dependency-injection/references/dependency-injection.md`
Expected: no output, exit 0 (no em-dashes).

Run: `grep -ic 'code smell' plugins/dependency-injection/skills/dependency-injection/references/dependency-injection.md`
Expected: at least `1` (constructor over-injection is framed as a code smell, not an anti-pattern).

- [ ] **Step 3: Commit**

```bash
git add plugins/dependency-injection/skills/dependency-injection/references/dependency-injection.md
git commit -m "✨ feat(dependency-injection): add the sourced reference document"
```

---

### Task 3: Write the lean SKILL.md

**Files:**
- Create: `plugins/dependency-injection/skills/dependency-injection/SKILL.md`

**Interfaces:**
- Consumes: `references/dependency-injection.md` from Task 2 (its core practices condense sections 3, 4, 5, 6 and the distinction in section 2).
- Produces: the activatable skill. Frontmatter `name: dependency-injection`. Ends pointing to the reference.

- [ ] **Step 1: Write `SKILL.md`**

```markdown
---
name: dependency-injection
description: Apply dependency injection when wiring an object's dependencies, structuring how objects are constructed, choosing between manual wiring and a DI container, or reviewing code for DI anti-patterns, even when the term is not used. Covers constructor injection, the composition root, Pure DI versus containers, object lifetimes, and the anti-pattern catalogue, with TypeScript specifics. Includes pragmatic guardrails against premature containers and over-injection.
---

# Dependency injection

An object receives its dependencies from an external source instead of
constructing them itself. It is a technique, not an architecture, and not the
same as the principle it serves. Apply it pragmatically: Pure DI by default, a
container only when it earns its keep.

## Three things often confused

- **Dependency injection**: the technique of supplying an object's
  dependencies from outside (this skill).
- **Inversion of control (IoC)**: the broad principle that the runtime calls
  your code (the Hollywood principle). DI is one specific style of it.
- **Dependency inversion principle (DIP)**: SOLID's design principle, depend on
  abstractions. DI helps you follow DIP but is not the same thing. See the
  `solid-principles` skill; this skill does not redefine it.

## Core practices

- **Constructor injection by default**: pass required dependencies through the
  constructor, so an object is never half-built. Use setter injection only for
  a genuinely optional dependency, method injection only when it varies per
  call.
- **Composition root**: compose the object graph in one place, as close as
  possible to the entry point. One per application. Confine any container to
  it, and reference it from nowhere else.
- **Pure DI first**: wire the graph by hand. It is strongly typed and fails at
  compile time. Reach for a DI container only when convention-based auto-wiring
  on a large graph outweighs that lost safety.
- **Lifetimes**: singleton, transient, scoped. Watch the captive dependency
  trap: a singleton holding a scoped or transient dependency promotes it and
  breaks under concurrency.

## Guardrails

Prefer the simplest wiring that meets the need:

- Do not reach for a container on a small app. Pure manual wiring is enough
  until the object graph genuinely justifies one.
- Inject services (injectables), not value objects or entities (newables).
- Constructor over-injection is a code smell, not an anti-pattern: too many
  constructor parameters signal an SRP violation. Refactor responsibilities
  (Facade or Aggregate Services); do not switch injection styles to hide it.
- Avoid the service locator and never inject the container itself. (The service
  locator label is debated: Seemann calls it an anti-pattern, Fowler an
  alternative. The safe default is to prefer injection and confine the
  container to the composition root.)
- A single-implementation interface with no boundary is over-abstraction. See
  the `solid-principles` guardrail.

## Complementary patterns (referenced, not redefined)

- **DIP (SOLID)**: the principle DI helps you follow. See `solid-principles`.
- **Hexagonal / ports and adapters**: DI is the wiring that injects adapters at
  the composition root, not the architecture itself.
- **Modular monolith**: one composition root per application; each module
  exposes a registration fragment, not its own root.

## Adapt to your context

This skill stays generic on purpose. Layer your own conventions on top: choose
your container (or none), and define your wiring and lifetime conventions in
your own `CLAUDE.md` or a higher-priority skill, which overrides this baseline.
This skill does not impose them.

## Reference

For the origin, the DI versus IoC versus DIP distinction, injection styles, the
composition root, Pure DI versus containers (with TypeScript token-based
injection and `reflect-metadata`), lifetimes, the anti-pattern catalogue, and
adjacent patterns, all with sources, read `references/dependency-injection.md`.
```

- [ ] **Step 2: Validate frontmatter, length, and conventions**

Run: `head -4 plugins/dependency-injection/skills/dependency-injection/SKILL.md`
Expected: frontmatter opens with `---`, contains `name: dependency-injection` and a `description:` line.

Run: `wc -l plugins/dependency-injection/skills/dependency-injection/SKILL.md`
Expected: roughly 60 to 80 lines (lean).

Run: `! grep -n '—' plugins/dependency-injection/skills/dependency-injection/SKILL.md`
Expected: no output, exit 0 (no em-dashes).

- [ ] **Step 3: Commit**

```bash
git add plugins/dependency-injection/skills/dependency-injection/SKILL.md
git commit -m "✨ feat(dependency-injection): add the lean activatable skill"
```

---

### Task 4: Integrate into the marketplace and root README

**Files:**
- Modify: `.claude-plugin/marketplace.json`
- Modify: `README.md`

**Interfaces:**
- Consumes: the finished plugin from Tasks 1 to 3.
- Produces: a discoverable, installable plugin entry.

- [ ] **Step 1: Add the marketplace entry**

Append this object to the `plugins` array in `.claude-plugin/marketplace.json` (after the `modular-monolith` entry):

```json
{
  "name": "dependency-injection",
  "source": "./plugins/dependency-injection",
  "description": "Dependency injection applied pragmatically: Pure DI (manual constructor injection) first, the composition root, object lifetimes, and the anti-pattern catalogue, with DI containers referenced as a justified option. Composable with your own conventions.",
  "version": "0.1.0"
}
```

- [ ] **Step 2: Add the root README table row**

Add this row to the Plugins table in `README.md`, after the `modular-monolith` row:

```markdown
| [`dependency-injection`](plugins/dependency-injection) | Pure DI (manual constructor injection) first, the composition root, object lifetimes, and the anti-pattern catalogue, with DI containers as a justified option. |
```

- [ ] **Step 3: Validate the marketplace JSON parses and lists the plugin**

Run: `python3 -c "import json; d=json.load(open('.claude-plugin/marketplace.json')); names=[p['name'] for p in d['plugins']]; assert 'dependency-injection' in names, names; print('ok', names)"`
Expected: `ok` followed by the list including `dependency-injection`.

Run: `grep -c 'dependency-injection' README.md`
Expected: at least `1`.

- [ ] **Step 4: Commit**

```bash
git add .claude-plugin/marketplace.json README.md
git commit -m "📝 docs: register the dependency-injection plugin in the marketplace"
```

---

### Task 5: Validate and review the finished plugin

**Files:**
- No new files. May produce small fixes to Tasks 1 to 4 files based on findings.

**Interfaces:**
- Consumes: the complete plugin and integration.
- Produces: a validated, reviewed plugin; any fixes committed.

- [ ] **Step 1: Run the plugin-validator agent**

Dispatch the `plugin-dev:plugin-validator` agent on `plugins/dependency-injection/`. Expected: structure, manifest, and skill files report valid. Apply any structural fixes it raises.

- [ ] **Step 2: Run the skill-reviewer agent**

Dispatch the `plugin-dev:skill-reviewer` agent on `plugins/dependency-injection/skills/dependency-injection/`. Expected: confirms the `description` triggers reliably and the core is lean. Apply description or framing fixes it raises.

- [ ] **Step 3: Fact-check the reference against the nuances**

Re-read `references/dependency-injection.md` and confirm: constructor over-injection is described as a code smell (not an anti-pattern); service locator is presented even-handedly (Seemann versus Fowler); "Pure DI" is used (not "Poor Man's DI" except as the historical name); the Fowler and Seemann injection-style taxonomies are not merged; the TypeScript runtime-erasure / token-based injection point is present; the composition root in a modular monolith is a per-module registration fragment, not a per-module root. Fix any drift.

- [ ] **Step 4: Final structural parity check**

Run: `find plugins/dependency-injection -type f | sort`
Expected: exactly `.claude-plugin/plugin.json`, `LICENSE`, `README.md`, `skills/dependency-injection/SKILL.md`, `skills/dependency-injection/references/dependency-injection.md` (parity with sibling plugins).

- [ ] **Step 5: Commit any fixes**

```bash
git add -A plugins/dependency-injection
git commit -m "✏️ fix(dependency-injection): apply validation and review feedback"
```

If no fixes were needed, skip this commit and note the plugin passed clean.

---

## Self-Review

**Spec coverage:** Plugin structure (Task 1), lean `SKILL.md` with the three-way distinction, core practices, and guardrails (Task 3), sourced reference with the eight sections and TypeScript examples (Task 2), Pure DI first with containers referenced (Task 2 section 5 and Task 3), the contested and imprecise points handled honestly (service locator even-handed, over-injection as a code smell; Task 2 section 7, Task 3, Task 5 step 3), adjacent patterns referenced not absorbed (both files), marketplace and README integration (Task 4), research nuances applied and reviewed (Tasks 2 and 5). All design sections map to a task.

**Placeholder scan:** The lean `SKILL.md` and all manifests/README are given verbatim. The reference is specified section by section with the exact claims and sources rather than pre-written in full, because it is a roughly 300-line sourced prose document; each section lists its required content, example, and citations, which is the actionable equivalent for prose authoring.

**Type consistency:** File paths are consistent across tasks (`skills/dependency-injection/...`). The plugin name `dependency-injection` and version `0.1.0` are identical in `plugin.json`, `marketplace.json`, and the README. The `SKILL.md` core practices (constructor injection, composition root, Pure DI, lifetimes) map to reference sections 3, 4, 5, 6; the three-way distinction maps to section 2.
