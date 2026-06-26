# Domain-driven design plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a `domain-driven-design` plugin bundling two focused, sourced, pragmatic skills (`ddd-strategic-design`, `ddd-tactical-design`) and register it in the marketplace and settings.

**Architecture:** Mirror the existing principle-plugin family (`hexagonal-architecture`, `dependency-injection`): a plugin manifest plus per-skill `SKILL.md` (lean core) and `references/*.md` (depth, TypeScript examples, attributed sources). Two skills under one plugin. Adjacent patterns are cross-referenced, never absorbed.

**Tech Stack:** Markdown skills with YAML frontmatter, JSON manifests. TypeScript only in reference examples.

## Global Constraints

- All files in English. No em-dashes anywhere. Words written in full (configuration, repository, December); standard acronyms allowed: DDD, CQRS, ACL, OHS, PL, API, SOLID, DI, TDD.
- Plugin version: `0.1.0`. Author: `Jean-Denis VIDOT`, url `https://github.com/jh3ady`. License: MIT.
- Voice and structure mirror `plugins/hexagonal-architecture/skills/hexagonal-architecture/SKILL.md`: a short definition, conceptual sections, a `## Guardrails` section, an `## Adapt to your context` section, and a closing `## Reference` pointer. Pragmatic, not dogmatic.
- Sourcing rule: do NOT invent verbatim Evans quotations or page numbers. Use the verified Fowler and Vernon quotations verbatim; attribute Evans paraphrases to "Evans, Domain-Driven Design (2003)" or "the DDD Reference (2015)". Flag Partnership and Big Ball of Mud as 2015 DDD Reference additions.
- No attribution to Claude anywhere (no Co-Authored-By, no generated-with lines).
- Commit messages: gitmoji + Conventional Commits, scope `domain-driven-design`.
- Marketplace owner/repo is `jh3ady/claude-plugins`; the local working directory is `/Users/jh3ady/.config/claude-plugins`. The `enabledPlugins` key uses the suffix `@jh3ady-claude-plugins`.

---

## File Structure

- Create `plugins/domain-driven-design/.claude-plugin/plugin.json` — plugin manifest.
- Create `plugins/domain-driven-design/LICENSE` — MIT (copy of an existing plugin LICENSE).
- Create `plugins/domain-driven-design/README.md` — covers both skills.
- Create `plugins/domain-driven-design/skills/ddd-strategic-design/SKILL.md` — lean strategic core.
- Create `plugins/domain-driven-design/skills/ddd-strategic-design/references/ddd-strategic-design.md` — strategic depth.
- Create `plugins/domain-driven-design/skills/ddd-tactical-design/SKILL.md` — lean tactical core.
- Create `plugins/domain-driven-design/skills/ddd-tactical-design/references/ddd-tactical-design.md` — tactical depth.
- Modify `.claude-plugin/marketplace.json` — add one plugin entry.
- Modify `README.md` (root) — add the `domain-driven-design` row (and the missing `hexagonal-architecture` row, for table consistency).
- Modify `~/.claude/settings.json` (symlinked to `~/.config/claude-config/claude/settings.json`) — add `enabledPlugins` entry.

---

## Task 1: Scaffold the plugin manifest, LICENSE, directories

**Files:**
- Create: `plugins/domain-driven-design/.claude-plugin/plugin.json`
- Create: `plugins/domain-driven-design/LICENSE`

**Interfaces:**
- Produces: the plugin root and manifest other tasks populate; skill directories created on first file write.

- [ ] **Step 1: Copy the LICENSE from an existing plugin**

```bash
mkdir -p plugins/domain-driven-design/.claude-plugin
cp plugins/hexagonal-architecture/LICENSE plugins/domain-driven-design/LICENSE
```

- [ ] **Step 2: Write the manifest**

Create `plugins/domain-driven-design/.claude-plugin/plugin.json`:

```json
{
  "name": "domain-driven-design",
  "version": "0.1.0",
  "description": "Domain-driven design applied pragmatically, in two skills: strategic design (ubiquitous language, bounded contexts, subdomains, context mapping) and tactical design (entities, value objects, aggregates, domain events, repositories, domain services, factories), with TypeScript specifics. Composable with your own conventions.",
  "author": {
    "name": "Jean-Denis VIDOT",
    "url": "https://github.com/jh3ady"
  },
  "license": "MIT",
  "homepage": "https://github.com/jh3ady/claude-plugins/tree/main/plugins/domain-driven-design",
  "keywords": [
    "domain-driven-design",
    "ddd",
    "strategic-design",
    "tactical-design",
    "bounded-context",
    "ubiquitous-language",
    "aggregate",
    "value-object",
    "software-architecture"
  ]
}
```

- [ ] **Step 3: Validate the manifest is parseable JSON**

Run: `python3 -m json.tool plugins/domain-driven-design/.claude-plugin/plugin.json > /dev/null && echo OK`
Expected: `OK`

- [ ] **Step 4: Commit**

```bash
git add plugins/domain-driven-design/.claude-plugin/plugin.json plugins/domain-driven-design/LICENSE
git commit -m "🎉 chore(domain-driven-design): scaffold the plugin manifest and license"
```

---

## Task 2: Author the strategic-design SKILL.md (lean core)

**Files:**
- Create: `plugins/domain-driven-design/skills/ddd-strategic-design/SKILL.md`

**Interfaces:**
- Consumes: the voice and section shape of `plugins/hexagonal-architecture/skills/hexagonal-architecture/SKILL.md` (read it first).
- Produces: a lean skill referencing `references/ddd-strategic-design.md` (authored in Task 3).

**Verified claims to cover (sourced; do not contradict these):**
- Ubiquitous language: a rigorous, living language co-owned by domain experts and developers, used in speech, diagrams, code, and tests; it evolves with understanding. Misconception to correct: it is NOT one glossary for the whole organisation; it is consistent only WITHIN a single bounded context. (Fowler, bliki UbiquitousLanguage; Evans 2003.)
- Bounded context: an explicit boundary (team, codebase, schema) within which one model and its ubiquitous language are consistent; one-to-one with the ubiquitous language. (Fowler, bliki BoundedContext; Evans 2003.)
- Subdomains: Core (complex AND competitive advantage, build in-house with the best team), Supporting (necessary but simple, build simply or outsource), Generic (complex but solved, buy off-the-shelf). Buy-vs-build heuristic (Khononov, Learning DDD 2021). Problem space (subdomain) versus solution space (bounded context) is Vernon's framing (IDDD 2013); 1 subdomain to 1 bounded context is the recommended ideal, not a definition.
- Context mapping: the context map plus relationship patterns. Upstream: Open Host Service, Published Language. Downstream: Conformist, Anticorruption Layer. Symmetric: Partnership, Shared Kernel. Plus Customer/Supplier, Separate Ways, Big Ball of Mud. Source: DDD Reference (2015); note Partnership and Big Ball of Mud are 2015 additions.
- Bounded context is NOT a microservice: a bounded context is the widest sensible model boundary (can be a monolith); microservices are a finer split; a microservice should not span more than one bounded context, but a bounded context may contain several. (Khononov, vladikk.com.)

- [ ] **Step 1: Read the model skill for voice**

Run: `cat plugins/hexagonal-architecture/skills/hexagonal-architecture/SKILL.md`
Expected: observe the frontmatter description style, the short definition, `## Guardrails`, `## Adapt to your context`, `## Reference`.

- [ ] **Step 2: Write the SKILL.md**

Create `plugins/domain-driven-design/skills/ddd-strategic-design/SKILL.md` with:
- Frontmatter `name: ddd-strategic-design` and a trigger-oriented `description` covering: drawing context boundaries, defining a shared/ubiquitous language, classifying subdomains (core/supporting/generic), mapping relationships between systems or teams, deciding where one model ends and another begins, even when the terms "DDD", "domain-driven design", "bounded context", or "ubiquitous language" are not used. The description must also name the strategic half of DDD so a generic "apply DDD" request triggers it. Keep it one paragraph, in the dense style of the hexagonal description.
- Body sections (short prose, mirror hexagonal): a one-paragraph definition of strategic design; `## Ubiquitous language`; `## Bounded context`; `## Subdomains` (with the buy-vs-build heuristic and problem/solution space); `## Context mapping` (list the patterns grouped upstream/downstream/symmetric, one line each); `## Guardrails` (invest in the core only; do not model the big ball of mud, wrap it; CRUD is over-engineering; a bounded context is not a microservice, cross-reference `modular-monolith`); `## Relationship to other skills` (cross-reference `modular-monolith` for module boundaries and `hexagonal-architecture` for the anticorruption layer and the application core; note event storming, CQRS, and event sourcing as out of scope / future plugins); `## Adapt to your context`; `## Reference` pointing to `references/ddd-strategic-design.md`.
- Apply Global Constraints (English, no em-dashes, full words).

- [ ] **Step 3: Validate frontmatter and triggering**

Use the `skill-reviewer` agent on `plugins/domain-driven-design/skills/ddd-strategic-design/SKILL.md`. Apply its non-cosmetic feedback.
Expected: description triggers reliably; no structural issues.

- [ ] **Step 4: Verify no em-dashes and that the cross-references resolve**

Run: `! grep -n "—" plugins/domain-driven-design/skills/ddd-strategic-design/SKILL.md && echo "no em-dash OK"`
Expected: `no em-dash OK`

- [ ] **Step 5: Commit**

```bash
git add plugins/domain-driven-design/skills/ddd-strategic-design/SKILL.md
git commit -m "✨ feat(domain-driven-design): add the strategic-design skill core"
```

---

## Task 3: Author the strategic-design reference

**Files:**
- Create: `plugins/domain-driven-design/skills/ddd-strategic-design/references/ddd-strategic-design.md`

**Interfaces:**
- Consumes: the verified claims from Task 2.
- Produces: the depth document the strategic SKILL.md points to.

**Section outline (each with prose, a short TypeScript or pseudo-structural example where it helps, and "when not to apply" notes):**
1. Ubiquitous language: definition, rigour, living and co-owned, per bounded context. Source: Fowler bliki, Evans 2003. Misconception: one language for the whole company.
2. Bounded context: definition, the meter/polyseme example (same term, different meaning across contexts), one-to-one with the language. Source: Fowler bliki.
3. Subdomains: core/supporting/generic with the buy-vs-build decision heuristic; problem space versus solution space (Vernon, IDDD 2013); the 1:1 ideal versus messy reality. Source: Khononov 2021, Vernon 2013, Evans 2003.
4. Context mapping: the context map; a table of the nine patterns (Partnership, Shared Kernel, Customer/Supplier, Conformist, Anticorruption Layer, Open Host Service, Published Language, Separate Ways, Big Ball of Mud) with one accurate line each and the upstream/downstream/symmetric role. Source: DDD Reference (2015); note Partnership and Big Ball of Mud as 2015 additions; "Big Ball of Mud" term predates DDD (Foote and Yoder, 1997).
5. Bounded context versus microservice and module: a bounded context is the upper bound; a microservice should not span more than one; cross-reference `modular-monolith`. Source: Khononov (vladikk.com), Microsoft architecture guidance.
6. When strategic DDD is overkill: simple/CRUD domains; invest deep modelling in the core only; wrap, do not model, the big ball of mud.
7. Sources: list Evans (2003 + DDD Reference 2015), Vernon (IDDD 2013, Distilled 2016), Fowler bliki, Khononov (Learning DDD 2021), with URLs where public.

- [ ] **Step 1: Write the reference document**

Create the file following the section outline above. Mirror the depth and citation style of `plugins/hexagonal-architecture/skills/hexagonal-architecture/references/hexagonal-architecture.md` (read it first for tone). Apply the sourcing rule from Global Constraints.

- [ ] **Step 2: Read it back and check accuracy against the verified claims**

Run: `cat plugins/hexagonal-architecture/skills/hexagonal-architecture/references/hexagonal-architecture.md | head -40`
Then read the new reference and confirm: no invented Evans page numbers; Partnership and Big Ball of Mud flagged as 2015 additions; problem/solution space attributed to Vernon; bounded-context-is-not-a-microservice present.

- [ ] **Step 3: Verify no em-dashes**

Run: `! grep -n "—" plugins/domain-driven-design/skills/ddd-strategic-design/references/ddd-strategic-design.md && echo "no em-dash OK"`
Expected: `no em-dash OK`

- [ ] **Step 4: Commit**

```bash
git add plugins/domain-driven-design/skills/ddd-strategic-design/references/ddd-strategic-design.md
git commit -m "📝 docs(domain-driven-design): add the strategic-design reference"
```

---

## Task 4: Author the tactical-design SKILL.md (lean core)

**Files:**
- Create: `plugins/domain-driven-design/skills/ddd-tactical-design/SKILL.md`

**Interfaces:**
- Consumes: the voice of the hexagonal SKILL.md and the cross-reference names (`hexagonal-architecture`, `dependency-injection`, `clean-code`, `solid-principles`).
- Produces: a lean skill referencing `references/ddd-tactical-design.md` (Task 5).

**Verified claims to cover (sourced):**
- Entity: defined by identity, not attributes; identity runs through time and representations; equality is identity-based. (Evans 2003; Fowler EvansClassification.)
- Value object: defined by its attributes; equality by value; immutable; side-effect-free. (Evans 2003; Fowler ValueObject.)
- Aggregate and aggregate root: a cluster treated as one unit; outside references only the root; the consistency and transaction boundary; transactions should not cross aggregate boundaries. (Evans 2003; Fowler DDD_Aggregate.) Vernon's four rules (Effective Aggregate Design, 2011): (1) model true invariants in consistency boundaries, (2) design small aggregates, (3) reference other aggregates by identity, (4) use eventual consistency outside the boundary.
- Domain event: a representation of something that happened in the domain that domain experts care about. (Evans, DDD Reference 2015; Vernon IDDD 2013; Fowler eaaDev/DomainEvent.) CQRS and event sourcing are SEPARATE, often-paired patterns, out of scope here.
- Repository: a collection-like abstraction over aggregate persistence; provide repositories only for aggregate roots; not a DAO (different abstraction level); distinct from a factory (find existing versus create new). (Evans 2003.)
- Domain service: domain logic that belongs to no single entity or value object; stateless; distinct from an application service (orchestration, no business rules). (Evans 2003; Fowler EvansClassification.)
- Factory: encapsulates valid creation of a complex object or whole aggregate; not needed where a constructor suffices (YAGNI). (Evans 2003.)
- Module: a named, cohesive, low-coupling partition of the model, named in the ubiquitous language. (Evans 2003.)
- Anemic domain model: an anti-pattern (data bags with logic pushed into services); incurs the cost of a domain model without the benefits. (Fowler AnemicDomainModel.) Other misconceptions: not every entity is an aggregate root or needs a repository; repository is not a DAO.

- [ ] **Step 1: Write the SKILL.md**

Create `plugins/domain-driven-design/skills/ddd-tactical-design/SKILL.md` with:
- Frontmatter `name: ddd-tactical-design` and a trigger-oriented `description` covering: modelling domain building blocks, deciding whether a concept is an entity or a value object, designing an aggregate and its consistency boundary, choosing a repository or domain service, reviewing for an anemic domain model, even when the terms "DDD" or "aggregate" are not used; name the tactical half of DDD so a generic "apply DDD" request triggers it. One dense paragraph.
- Body sections (short prose): a one-paragraph definition of tactical design (the building blocks that express a rich domain model inside one bounded context); `## Entity`; `## Value object`; `## Aggregate and aggregate root` (with Vernon's four rules as a tight list); `## Domain event` (DDD building block; note CQRS and event sourcing are separate and out of scope); `## Repository`; `## Domain service`; `## Factory`; `## Modules` (one or two sentences); `## Guardrails` (the anemic domain model is an anti-pattern; prefer small aggregates; not every entity is an aggregate root or needs a repository; CRUD is over-engineering); `## Relationship to other skills` (a repository is a secondary port, cross-reference `hexagonal-architecture`; wiring via `dependency-injection`; naming and small functions via `clean-code` and `solid-principles`); `## Adapt to your context`; `## Reference` pointing to `references/ddd-tactical-design.md`.
- Apply Global Constraints.

- [ ] **Step 2: Validate with skill-reviewer**

Use the `skill-reviewer` agent on the new SKILL.md. Apply non-cosmetic feedback.

- [ ] **Step 3: Verify no em-dashes**

Run: `! grep -n "—" plugins/domain-driven-design/skills/ddd-tactical-design/SKILL.md && echo "no em-dash OK"`
Expected: `no em-dash OK`

- [ ] **Step 4: Commit**

```bash
git add plugins/domain-driven-design/skills/ddd-tactical-design/SKILL.md
git commit -m "✨ feat(domain-driven-design): add the tactical-design skill core"
```

---

## Task 5: Author the tactical-design reference

**Files:**
- Create: `plugins/domain-driven-design/skills/ddd-tactical-design/references/ddd-tactical-design.md`

**Interfaces:**
- Consumes: the verified claims from Task 4.
- Produces: the depth document the tactical SKILL.md points to.

**Section outline (each with prose, a TypeScript example, and "when not to apply" notes):**
1. Entity: identity, equality, lifecycle. TypeScript example: an entity with an id and identity equality. Misconception: do not give entities value-equality.
2. Value object: value equality, immutability, side-effect-free. TypeScript example: a `Money` or `EmailAddress` value object, immutable, with `equals`. When not to apply: a thin CRUD field with no invariant.
3. Aggregate and aggregate root: consistency and transaction boundary; Vernon's four rules with a worked example (an `Order` root guarding line-item invariants, referencing `CustomerId` by identity, emitting an event for cross-aggregate work). Source: Vernon Effective Aggregate Design (2011), Evans 2003, Fowler DDD_Aggregate.
4. Domain event: definition; a TypeScript event type; how it differs from CQRS and event sourcing (separate patterns, future plugins). Source: Evans DDD Reference, Vernon, Fowler.
5. Repository: collection-like interface, one per aggregate root, expressed in ubiquitous-language terms; not a DAO; distinct from a factory. TypeScript example: an `OrderRepository` interface (note the tie-in: this is a secondary port in `hexagonal-architecture`). Source: Evans 2003.
6. Domain service versus application service: where each lives and what each may contain. TypeScript example: a domain service spanning two aggregates versus an application service orchestrating a use case. Source: Evans 2003, Fowler EvansClassification.
7. Factory: when justified (complex construction, whole-aggregate assembly, atomic invariants); YAGNI otherwise. TypeScript example.
8. Modules: cohesion and coupling, named in the ubiquitous language. Source: Evans 2003.
9. Pragmatic cautions and misconceptions: anemic domain model (Fowler, anti-pattern); large aggregates (Vernon); not 1:1 entity-aggregate-repository; repository is not a DAO; full tactical machinery is overkill for mostly-CRUD slices with no true invariants.
10. Sources: Evans (2003 + DDD Reference 2015), Vernon (IDDD 2013, Effective Aggregate Design 2011), Fowler bliki (ValueObject, EvansClassification, DDD_Aggregate, AnemicDomainModel, eaaDev/DomainEvent), Khononov (Learning DDD 2021), with URLs.

- [ ] **Step 1: Write the reference document**

Create the file following the outline. Mirror the hexagonal reference's depth and citation style. Apply the sourcing rule.

- [ ] **Step 2: Accuracy check**

Read the file and confirm: Vernon's four rules stated correctly; domain event separated from CQRS/event sourcing; repository-is-not-a-DAO and anemic-model-is-an-anti-pattern present; no invented Evans page numbers; TypeScript examples compile mentally (types consistent).

- [ ] **Step 3: Verify no em-dashes**

Run: `! grep -n "—" plugins/domain-driven-design/skills/ddd-tactical-design/references/ddd-tactical-design.md && echo "no em-dash OK"`
Expected: `no em-dash OK`

- [ ] **Step 4: Commit**

```bash
git add plugins/domain-driven-design/skills/ddd-tactical-design/references/ddd-tactical-design.md
git commit -m "📝 docs(domain-driven-design): add the tactical-design reference"
```

---

## Task 6: Author the plugin README

**Files:**
- Create: `plugins/domain-driven-design/README.md`

**Interfaces:**
- Consumes: the two skills' scope.
- Produces: the plugin landing document.

- [ ] **Step 1: Read the model README**

Run: `cat plugins/hexagonal-architecture/README.md`
Expected: observe the structure (title, intro, "What it does", "Install", "Adapt to your context", "License").

- [ ] **Step 2: Write the README**

Create `plugins/domain-driven-design/README.md` mirroring that structure, but documenting BOTH bundled skills (strategic and tactical), each with a short bullet list of what it covers. Install block:

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install domain-driven-design@jh3ady-claude-plugins
```

Apply Global Constraints.

- [ ] **Step 3: Verify no em-dashes**

Run: `! grep -n "—" plugins/domain-driven-design/README.md && echo "no em-dash OK"`
Expected: `no em-dash OK`

- [ ] **Step 4: Commit**

```bash
git add plugins/domain-driven-design/README.md
git commit -m "📝 docs(domain-driven-design): add the plugin readme"
```

---

## Task 7: Register in the marketplace and the root README

**Files:**
- Modify: `.claude-plugin/marketplace.json`
- Modify: `README.md` (root)

**Interfaces:**
- Consumes: the plugin name and description from Task 1.

- [ ] **Step 1: Add the marketplace entry**

Append to the `plugins` array in `.claude-plugin/marketplace.json`, after the `hexagonal-architecture` entry:

```json
    {
      "name": "domain-driven-design",
      "source": "./plugins/domain-driven-design",
      "description": "Domain-driven design applied pragmatically, in two skills: strategic design (ubiquitous language, bounded contexts, subdomains, context mapping) and tactical design (entities, value objects, aggregates, domain events, repositories, domain services, factories), with TypeScript specifics. Composable with your own conventions.",
      "version": "0.1.0"
    }
```

- [ ] **Step 2: Validate the marketplace JSON**

Run: `python3 -m json.tool .claude-plugin/marketplace.json > /dev/null && echo OK`
Expected: `OK`

- [ ] **Step 3: Add the root README rows**

In the root `README.md` plugins table, add the missing `hexagonal-architecture` row (table consistency) and the new `domain-driven-design` row, after the `dependency-injection` row:

```markdown
| [`hexagonal-architecture`](plugins/hexagonal-architecture) | Ports and adapters applied pragmatically: the dependency rule, primary and secondary ports and adapters, the application core, composition-root wiring, and the relationship to Onion and Clean Architecture. |
| [`domain-driven-design`](plugins/domain-driven-design) | DDD applied pragmatically in two skills: strategic design (ubiquitous language, bounded contexts, subdomains, context mapping) and tactical design (entities, value objects, aggregates, domain events, repositories, services, factories). |
```

- [ ] **Step 4: Commit**

```bash
git add .claude-plugin/marketplace.json README.md
git commit -m "📝 docs(domain-driven-design): register the plugin in the marketplace"
```

---

## Task 8: Validate the whole plugin and enable it in settings

**Files:**
- Modify: `~/.claude/settings.json` (symlinked to `~/.config/claude-config/claude/settings.json`)

**Interfaces:**
- Consumes: the finished plugin.

- [ ] **Step 1: Run the plugin validator**

Use the `plugin-validator` agent on `plugins/domain-driven-design`. Apply any structural fixes it reports (manifest, skill frontmatter, directory layout).
Expected: plugin validates; two skills discovered.

- [ ] **Step 2: Confirm both skills are discoverable**

Run: `find plugins/domain-driven-design -name SKILL.md`
Expected: two paths (ddd-strategic-design, ddd-tactical-design).

- [ ] **Step 3: Enable the plugin in settings**

Add to the `enabledPlugins` object in `~/.claude/settings.json` (the symlink target is `~/.config/claude-config/claude/settings.json`; edit the real file), after the `hexagonal-architecture@jh3ady-claude-plugins` entry:

```json
    "domain-driven-design@jh3ady-claude-plugins": true
```

- [ ] **Step 4: Validate the settings JSON**

Run: `python3 -m json.tool ~/.claude/settings.json > /dev/null && echo OK`
Expected: `OK`

- [ ] **Step 5: Final review and spec sign-off**

Re-read the spec `docs/superpowers/specs/2026-06-26-domain-driven-design-plugin-design.md` and confirm every success criterion is met: one plugin, two lean skills, depth in references, sourced and reviewed content, pragmatism and composability framing, adjacent patterns referenced, event storming/CQRS/event sourcing flagged as future, registered in marketplace and enabled in settings.

- [ ] **Step 6: Note for the user**

The `enabledPlugins` change lives in the `claude-config` repository (the symlink target), not in `claude-plugins`. Tell the user to review and commit that change in `claude-config` separately, since it is a different repository.

---

## Self-Review

- **Spec coverage:** Every spec section maps to a task. Plugin structure → Tasks 1, 2, 4, 6. Strategic skill → Tasks 2, 3. Tactical skill → Tasks 4, 5. Sourcing and validation → Tasks 3, 5, 8. Marketplace and settings → Tasks 7, 8. Pragmatism, composability, and out-of-scope flags → embedded in Tasks 2 and 4 section instructions.
- **Placeholder scan:** No "TBD"/"TODO". Prose deliverables (skills and references) carry explicit, sourced claim lists and section outlines rather than invented final copy, which is the correct granularity for authoring tasks; structural files (manifest, marketplace entry, README rows, settings entry) carry exact content.
- **Type consistency:** Skill names (`ddd-strategic-design`, `ddd-tactical-design`), the `@jh3ady-claude-plugins` suffix, the `0.1.0` version, and the plugin description string are identical across Tasks 1, 7, and 8.
