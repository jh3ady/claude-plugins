# Modular monolith plugin Implementation Plan

> **Addendum (2026-06-26):** Event sourcing, referenced in the steps below as a
> future candidate plugin, has since been realised as the standalone
> `event-sourcing` plugin. CQRS remains a future candidate. The text below is
> preserved as the point-in-time record of the original plan.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `modular-monolith` plugin to the `jh3ady-claude-plugins` marketplace, mirroring the existing engineering-principle plugins (lean `SKILL.md` plus a sourced `references/` document with TypeScript examples).

**Architecture:** One plugin under `plugins/modular-monolith/` with the standard layout (`.claude-plugin/plugin.json`, `skills/modular-monolith/SKILL.md`, `skills/modular-monolith/references/modular-monolith.md`, `README.md`, `LICENSE`). The skill is the focused-with-references-out topic agreed in the design: modular monolith proper (boundaries, communication, data isolation, enforcement, extraction), with DDD/hexagonal/CQRS referenced as complementary. Integrated into `marketplace.json` and the root `README.md`.

**Tech Stack:** Markdown skill files, JSON manifest, TypeScript code examples in the reference. No build or runtime; validation is JSON parsing, structural parity with sibling plugins, and the `plugin-validator` / `skill-reviewer` agents.

## Global Constraints

- Writing language: English. No em-dashes anywhere. Words in full (no unjustified abbreviations); standard acronyms (DDD, CQRS, API, SOLID, TDD) are fine.
- No Claude self-promotion or `Co-Authored-By` trailers in any file or commit.
- Commit messages: gitmoji + Conventional Commits, form `<emoji> <type>(<optional scope>): <summary>`.
- Plugin version: `0.1.0`. License: MIT. Author block: `{ "name": "Jean-Denis VIDOT", "url": "https://github.com/jh3ady" }`.
- `SKILL.md` stays lean (target 50 to 65 lines), depth lives in `references/`.
- Every significant claim in the reference must be grounded in the researched primary sources (Grzybek, Newman, Fowler, Simon Brown, Shopify, Spring Modulith). Apply the captured corrections: `dotnet/eShop` is microservices not a modular monolith; "big ball of mud" is Foote and Yoder (1997); TypeScript project references are build orchestration not encapsulation; Nx does not deprecate barrel files.
- Examples in TypeScript only.

---

### Task 1: Scaffold the plugin (manifest, license, README)

Create the plugin skeleton and the non-skill files. Use the `skill-creator` skill for the skill scaffold conventions when creating the `skills/modular-monolith/` directory in Task 2; this task sets up everything around it.

**Files:**
- Create: `plugins/modular-monolith/.claude-plugin/plugin.json`
- Create: `plugins/modular-monolith/LICENSE`
- Create: `plugins/modular-monolith/README.md`

**Interfaces:**
- Consumes: nothing (first task).
- Produces: plugin directory `plugins/modular-monolith/` with a valid manifest named `modular-monolith`, version `0.1.0`. Later tasks add the skill under `skills/modular-monolith/`.

- [ ] **Step 1: Create `plugin.json`**

```json
{
  "name": "modular-monolith",
  "version": "0.1.0",
  "description": "The modular monolith applied pragmatically: one deployable unit, strictly bounded modules with public APIs, isolated data, and TypeScript-ecosystem boundary enforcement. Composable with your own conventions.",
  "author": {
    "name": "Jean-Denis VIDOT",
    "url": "https://github.com/jh3ady"
  },
  "license": "MIT",
  "homepage": "https://github.com/jh3ady/claude-plugins/tree/main/plugins/modular-monolith",
  "keywords": [
    "modular-monolith",
    "software-architecture",
    "module-boundaries",
    "monolith",
    "microservices",
    "bounded-context",
    "ddd"
  ]
}
```

- [ ] **Step 2: Create `LICENSE`**

Copy the MIT license text verbatim from a sibling plugin so the wording and copyright line match.

Run: `cp plugins/clean-code/LICENSE plugins/modular-monolith/LICENSE`
Expected: file exists, identical to the sibling.

- [ ] **Step 3: Create `README.md`**

```markdown
# modular-monolith

A Claude Code plugin that helps structure an application as a modular
monolith, pragmatically: one deployable unit, modules with strictly
enforced boundaries, and isolated data, without sliding into a big ball of
mud or paying the microservices premium too early.

It stays generic on purpose: compose it with your own architecture rules
and your team or personal conventions.

## What it does

When you structure, review, or refactor application architecture, module
boundaries, or deployment topology, the bundled skill applies:

- The three invariants: public-API boundaries, deliberate inter-module
  communication, and per-module data isolation.
- Boundary enforcement in the TypeScript/Node ecosystem.
- The pragmatic rule: coarse modules first, let a module earn its
  independence, and match per-module sophistication to the actual need.
- Complementary patterns (DDD, hexagonal, CQRS) referenced, not imposed.

## Install

\`\`\`bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install modular-monolith@jh3ady-claude-plugins
\`\`\`

## Adapt to your context

This plugin is a baseline, not a dogma. Layer your own module rules and
team conventions in your own `CLAUDE.md` or a higher-priority skill. The
plugin does not impose them.

## License

Released under the [MIT License](LICENSE).
```

Note: write the install fenced block with real triple backticks; the escaping above is only for this plan document.

- [ ] **Step 4: Validate the manifest parses and matches siblings**

Run: `python3 -c "import json; d=json.load(open('plugins/modular-monolith/.claude-plugin/plugin.json')); assert d['name']=='modular-monolith'; assert d['version']=='0.1.0'; print('ok')"`
Expected: `ok`

Run: `diff <(head -1 plugins/clean-code/LICENSE) <(head -1 plugins/modular-monolith/LICENSE)`
Expected: no output (identical first line `MIT License`).

- [ ] **Step 5: Commit**

```bash
git add plugins/modular-monolith/.claude-plugin/plugin.json plugins/modular-monolith/LICENSE plugins/modular-monolith/README.md
git commit -m "✨ feat(modular-monolith): scaffold plugin manifest, license, and readme"
```

---

### Task 2: Write the reference document

Author the deep reference. This is the source of truth from which the lean `SKILL.md` is distilled in Task 3, so it is written first. Use the `skill-creator` skill first to scaffold the `skills/modular-monolith/` directory the way the other plugins are laid out.

**Files:**
- Create: `plugins/modular-monolith/skills/modular-monolith/references/modular-monolith.md`

**Interfaces:**
- Consumes: the plugin directory from Task 1.
- Produces: `references/modular-monolith.md` with eight numbered sections (titles below). Task 3's `SKILL.md` ends with `read references/modular-monolith.md` and its three invariants must match sections 2, 4, and 5 here.

- [ ] **Step 1: Write the reference with these eight sections**

Each section carries at least one TypeScript example and a "when not to apply" or caveat note. Use the verified claims and cite sources inline (author name plus URL is enough; match the citation density of `references/solid.md`). Required content per section:

1. **Definition and taxonomy.** Modular monolith = exactly one deployment unit, designed in a modular way (Grzybek). Newman's three-way taxonomy: single-process monolith, modular monolith ("separate modules, combined for deployment"), distributed monolith ("everything has to be deployed at the same time", the worst of both). The symmetry: big ball of mud (Foote and Yoder, 1997) is to the monolith what the distributed monolith is to microservices. Simon Brown: "if you can't build a well-structured monolith, what makes you think microservices is the answer?"

2. **Boundary design.** By business capability / vertical slice, not technical layer (Grzybek rejects layer-first). A module exposes a public API (provided interface) and hides its internals; it declares a required interface on other modules' APIs (Spring Modulith vocabulary). TypeScript example: a `payments/` module exposing `index.ts` with a `PaymentsApi` and keeping handlers/entities internal. When not to apply: do not split a coherent capability into anemic technical layers.

3. **Enforcement in TypeScript/Node.** TypeScript has no cross-file `internal`; encapsulation is tooling-enforced. Ladder weakest to strongest: barrel `index.ts` as the only public entry point; lint rules (`@nx/enforce-module-boundaries` with tags and `depConstraints`; `dependency-cruiser` forbidden rules for non-monorepos); separate pnpm workspace packages with `workspace:*` (resolution-level hard boundary, strongest). Correction to state explicitly: TypeScript project references / `composite` orchestrate build order, they do NOT block reach-in imports. TypeScript example: a `dependency-cruiser` forbidden rule banning deep imports across modules, plus an Nx `depConstraints` snippet.

4. **Inter-module communication.** Default to a direct synchronous call to another module's public API. Reach for in-process events only when you deliberately want decoupling or eventual consistency (cite Milan Jovanovic: defaulting to async events created hidden coupling; "make that bet on purpose, not by default"). Never reach into another module's internals; an anti-corruption layer is reasonable on a synchronous boundary. Note the contested axis (Grzybek's reference project mandates async events; both camps agree the choice must be deliberate). TypeScript example: a direct `paymentsApi.charge(...)` call versus publishing an `OrderPlaced` in-process event, with the decision rule in prose.

5. **Data isolation.** Schema per module, no shared tables, no cross-module foreign keys or joins, no transaction spanning two modules (Grzybek). Note the contested axis: one physical database with a schema per module versus multiple databases (Newman); both require logical isolation, choose physical separation deliberately. TypeScript example: two modules owning distinct schemas, cross-module data obtained via the other module's API rather than a SQL join.

6. **Trade-offs and when to use.** What the monolith keeps (Fowler, Microservice Trade-Offs, quote): single-transaction ACID updates, strong consistency, no network/serialization cost, easier boundary refactoring. Costs: single deploy/scaling unit, single runtime, standing risk of boundary erosion. Default position: Newman "microservices should not be the default choice"; Fowler MicroservicePremium "don't even consider microservices unless you have a system that's too complex to manage as a monolith." Justifying drivers for microservices: large-team coordination, independent scaling, independent deploy cadence, polyglot needs.

7. **Extraction to microservice.** Well-bounded modules with isolated data are the seams. Strangler Fig (Newman): intercept calls to old functionality, redirect to a new service, extract one or two first. Lift-and-shift along existing code boundaries inherits the coupling; extract along business domains.

8. **Anti-patterns.** Shared database tables across modules (implicit contracts that ripple); leaking internals; the distributed monolith; a "common"/shared-kernel dumping ground (keep it minimal, no business rules); circular dependencies between modules (signal to extract a third module or merge two); modules organized by technical layer instead of domain.

- [ ] **Step 2: Validate structure and conventions**

Run: `grep -nc '^## ' plugins/modular-monolith/skills/modular-monolith/references/modular-monolith.md`
Expected: at least `8` second-level headings (the eight sections, plus any intro/sources heading).

Run: `! grep -n '—' plugins/modular-monolith/skills/modular-monolith/references/modular-monolith.md`
Expected: no output, exit 0 (no em-dashes).

Run: `grep -nl 'eShop' plugins/modular-monolith/skills/modular-monolith/references/modular-monolith.md; echo "checked eShop not miscited"`
Expected: if `eShop` appears at all, confirm by reading it is described as microservices, not a modular monolith.

- [ ] **Step 3: Commit**

```bash
git add plugins/modular-monolith/skills/modular-monolith/references/modular-monolith.md
git commit -m "✨ feat(modular-monolith): add the sourced reference document"
```

---

### Task 3: Write the lean SKILL.md

**Files:**
- Create: `plugins/modular-monolith/skills/modular-monolith/SKILL.md`

**Interfaces:**
- Consumes: `references/modular-monolith.md` from Task 2 (its three invariants are the condensed form of sections 2, 4, 5).
- Produces: the activatable skill. Frontmatter `name: modular-monolith`. Ends pointing to the reference.

- [ ] **Step 1: Write `SKILL.md`**

```markdown
---
name: modular-monolith
description: Apply the modular monolith pattern when structuring, reviewing, or refactoring application architecture, module boundaries, or deployment topology, and when weighing a monolith against microservices, even when the term is not used. Covers public-API module boundaries, inter-module communication, per-module data isolation, TypeScript-ecosystem enforcement, and extraction to microservices. Includes pragmatic guardrails against premature splitting and over-engineering.
---

# Modular monolith

One application deployed as a single artifact, internally split into modules
with strictly enforced boundaries. It is the disciplined monolith: above the
big ball of mud (no boundaries), below microservices (no network premium).
Apply it as a pragmatic default, not a dogma.

## The three invariants

- **Boundary**: each module exposes a public API; everything else is internal
  and unreachable from other modules. Define modules by business capability
  (vertical slice), not by technical layer.
- **Communication**: call another module's public API directly by default.
  Reach for an in-process event only when you deliberately want decoupling or
  eventual consistency. Never reach into another module's internals.
- **Data**: a schema per module. No shared tables, no cross-module foreign
  keys or joins, no transaction spanning two modules. Cross-module data is
  obtained through the other module's API.

## Enforcement (TypeScript/Node)

TypeScript has no cross-file `internal`, so boundaries are tooling-enforced,
weakest to strongest: a barrel `index.ts` as the only public entry point;
lint rules (`@nx/enforce-module-boundaries`, `dependency-cruiser`); separate
pnpm workspace packages (`workspace:*`), the strongest boundary. Note:
TypeScript project references orchestrate the build, they do not block
reach-in imports.

## Guardrails

Prefer the simplest structure that meets the need:

- Start with fewer, coarser modules; let a module earn its independence.
  Splitting later is cheap, merging back is costly. A module boundary is a
  guess, treat it as one.
- Match per-module sophistication to need: a CRUD module is not a DDD module.
- Do not make everything event-driven in-process; that is hidden coupling in
  disguise. A direct call is the default.
- A modular monolith is the sensible default. Move to microservices only for
  a real driver: independent scaling, deploy cadence, team autonomy, or
  polyglot needs, not for fashion.

## Complementary patterns (not prerequisites)

The modular monolith is the container. These are choices about each module's
content, referenced here, not imposed:

- **DDD bounded contexts**: where to draw boundaries. A module can be a
  bounded context, but DDD is not required.
- **Hexagonal / ports and adapters**: how to structure a module's inside,
  decided module by module.
- **CQRS and event sourcing**: optional and orthogonal.

## Adapt to your context

This skill stays generic on purpose. Layer your own conventions on top:
define your module catalog, naming, and allowed dependencies in your own
`CLAUDE.md` or a higher-priority skill. This skill does not impose them.

## Reference

For the full taxonomy, boundary and enforcement examples in TypeScript, the
communication and data-isolation rules, trade-offs, extraction path, and
anti-patterns, all with sources, read `references/modular-monolith.md`.
```

- [ ] **Step 2: Validate frontmatter, length, and conventions**

Run: `head -4 plugins/modular-monolith/skills/modular-monolith/SKILL.md`
Expected: frontmatter opens with `---`, contains `name: modular-monolith` and a `description:` line.

Run: `wc -l plugins/modular-monolith/skills/modular-monolith/SKILL.md`
Expected: roughly 55 to 70 lines (lean, in the range of sibling skills).

Run: `! grep -n '—' plugins/modular-monolith/skills/modular-monolith/SKILL.md`
Expected: no output, exit 0 (no em-dashes).

- [ ] **Step 3: Commit**

```bash
git add plugins/modular-monolith/skills/modular-monolith/SKILL.md
git commit -m "✨ feat(modular-monolith): add the lean activatable skill"
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

Append this object to the `plugins` array in `.claude-plugin/marketplace.json` (after the `clean-code` entry):

```json
{
  "name": "modular-monolith",
  "source": "./plugins/modular-monolith",
  "description": "The modular monolith applied pragmatically: one deployable unit, strictly bounded modules with public APIs, isolated data, and TypeScript-ecosystem boundary enforcement. Composable with your own conventions.",
  "version": "0.1.0"
}
```

- [ ] **Step 2: Add the root README table row**

Add this row to the Plugins table in `README.md`, after the `clean-code` row:

```markdown
| [`modular-monolith`](plugins/modular-monolith) | One deployable unit, strictly bounded modules with public APIs, isolated data, and TypeScript-ecosystem boundary enforcement. |
```

- [ ] **Step 3: Validate the marketplace JSON parses and lists the plugin**

Run: `python3 -c "import json; d=json.load(open('.claude-plugin/marketplace.json')); names=[p['name'] for p in d['plugins']]; assert 'modular-monolith' in names, names; print('ok', names)"`
Expected: `ok` followed by the list including `modular-monolith`.

Run: `grep -c 'modular-monolith' README.md`
Expected: at least `1`.

- [ ] **Step 4: Commit**

```bash
git add .claude-plugin/marketplace.json README.md
git commit -m "📝 docs: register the modular-monolith plugin in the marketplace"
```

---

### Task 5: Validate and review the finished plugin

**Files:**
- No new files. May produce small fixes to Tasks 1 to 4 files based on findings.

**Interfaces:**
- Consumes: the complete plugin and integration.
- Produces: a validated, reviewed plugin; any fixes committed.

- [ ] **Step 1: Run the plugin-validator agent**

Dispatch the `plugin-dev:plugin-validator` agent on `plugins/modular-monolith/`. Expected: structure, manifest, and skill files report valid. Apply any structural fixes it raises.

- [ ] **Step 2: Run the skill-reviewer agent**

Dispatch the `plugin-dev:skill-reviewer` agent on `plugins/modular-monolith/skills/modular-monolith/`. Expected: confirms the `description` triggers reliably and the core is lean. Apply description or framing fixes it raises.

- [ ] **Step 3: Fact-check the reference against the corrections**

Re-read `references/modular-monolith.md` and confirm: `eShop` (if present) is described as microservices; "big ball of mud" is attributed to Foote and Yoder; TypeScript project references are described as build orchestration not encapsulation; Nx barrel files are not described as deprecated. Fix any drift.

- [ ] **Step 4: Final structural parity check**

Run: `find plugins/modular-monolith -type f | sort`
Expected: exactly `.claude-plugin/plugin.json`, `LICENSE`, `README.md`, `skills/modular-monolith/SKILL.md`, `skills/modular-monolith/references/modular-monolith.md` (parity with sibling plugins).

- [ ] **Step 5: Commit any fixes**

```bash
git add -A plugins/modular-monolith
git commit -m "✏️ fix(modular-monolith): apply validation and review feedback"
```

If no fixes were needed, skip this commit and note the plugin passed clean.

---

## Self-Review

**Spec coverage:** Plugin structure (Task 1), lean `SKILL.md` with the three invariants and guardrails (Task 3), sourced reference with the eight sections and TypeScript examples (Task 2), TypeScript/Node enforcement (Tasks 2 and 3), contested axes as deliberate choices (reference sections 4 and 5, skill invariants), complementary patterns referenced not absorbed (both files), marketplace and README integration (Task 4), research corrections applied and reviewed (Tasks 2 and 5). All design sections map to a task.

**Placeholder scan:** The lean `SKILL.md` and all manifests/README are given verbatim. The reference is specified section by section with the exact claims and sources to use rather than pre-written in full, because it is a roughly 300-line sourced prose document; each section lists its required content, example, and citations, which is the actionable equivalent for prose authoring.

**Type consistency:** File paths are consistent across tasks (`skills/modular-monolith/...`). The plugin name `modular-monolith` and version `0.1.0` are identical in `plugin.json`, `marketplace.json`, and the README. The three invariants in `SKILL.md` (boundary, communication, data) map one-to-one to reference sections 2, 4, 5.
