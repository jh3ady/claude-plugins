# Secure coding plugin: design

- Date: 2026-07-02
- Status: implemented (design and spec authored under delegation, pending user review)
- Author: Jean-Denis VIDOT

## Context and goal

The `jh3ady-claude-plugins` marketplace ships a consistent family of
engineering-principle plugins (`commit-conventions`, `review-conventions`,
`solid-principles`, `simplicity-principles`, `clean-code`, `simple-design`,
`object-calisthenics`, `modular-monolith`, `dependency-injection`,
`hexagonal-architecture`, `domain-driven-design`, `event-sourcing`, `cqrs`,
`screaming-architecture`, `test-driven-development`, `legacy-code`,
`refactoring`, `design-patterns`, `testing-strategy`). They share one pattern:
a generic, composable skill presented as a pragmatic baseline rather than a
dogma, with a lean `SKILL.md`, depth pushed into `references/`, and adjacent
concepts cross-referenced rather than absorbed.

This work adds one plugin: `secure-coding`. It carries the craftsmanship
discipline of writing secure application code: the secure-by-design mindset,
the proactive controls a developer applies while coding, and the catalogue of
the most critical risks to recognise and prevent. It is knowledge, not tooling:
it stays complementary to the `sentrux` scanner (a structural-health MCP) and
the `/security-review` command (a diff auditor), which are instruments rather
than composable discipline.

The central thesis: security is a design and coding property built in from the
start, not a test run at the end. `secure-coding` owns the developer-facing
discipline of building it in. It grounds itself in current, verifiable OWASP
standards (Top 10:2025, Proactive Controls 2024, ASVS 5.0.0) and the historical
secure-by-design principles (Saltzer and Schroeder, 1975), and it defers
adjacent territories (design-time threat modelling, deep cryptography, security
testing, infrastructure hardening, compliance) to their owners or to future
sibling plugins rather than absorbing them.

## Scope

One plugin, `secure-coding`, bundling a single skill `secure-coding`.

A single skill, not several. Writing secure code is one coherent developer
activity (apply the proactive controls, recognise and prevent the top risks)
driven by one cluster of triggers. One skill carries the decision procedure;
supporting detail, sourcing, standards mapping, and worked TypeScript examples
live in `references/`. Skill-only, no command or hook, consistent with
`clean-code`, `solid-principles`, and `testing-strategy`. YAGNI: threat
modelling and supply-chain security are noted as candidate future siblings, not
built now.

### Boundary (focused, with references out)

In scope:

- The core frame in `SKILL.md`: the secure-by-design mindset (the historical
  principles distilled: least privilege, fail-safe defaults / fail closed,
  defence in depth, complete mediation, economy of mechanism, secure defaults,
  never trust input, minimise the attack surface, do not roll your own crypto);
  the proactive controls (OWASP Proactive Controls 2024, C1 to C10) as the
  "what to do while coding" checklist; the OWASP Top 10:2025 as the risk
  catalogue to recognise and prevent; the concrete practice clusters (access
  control and authorization; authentication and digital identity; input
  handling, injection, and output encoding; cryptography and secrets; secure
  configuration and defaults; dependencies and the software supply chain; error
  handling and exceptional conditions; security logging and monitoring; server
  side request forgery); guardrails; a relationship-to-other-skills section; an
  "Adapt to your context" section; and a pointer to the reference.
- In `references/secure-coding.md`: the secure-by-design principles in full with
  their Saltzer and Schroeder origin; the OWASP Top 10:2025 catalogue, each
  entry with cause, prevention, and a TypeScript note; the Proactive Controls
  2024 mapped to the practices; the ASVS 5.0.0 verification levels (L1/L2/L3)
  and how to use the standard as a checklist; concrete TypeScript practices
  (parameterized queries, contextual output encoding, schema validation with a
  library such as Zod, password hashing with argon2 or bcrypt, JWT and session
  pitfalls, secrets via environment or a secret manager, security headers,
  CSRF, CORS, rate limiting, SSRF allowlisting, dependency pinning and auditing,
  SBOM, structured security logging that never records secrets); one worked
  TypeScript walkthrough; and trade-off notes with cross-references.

Ownership by territory (the key boundary rule): `secure-coding` owns the
**developer-facing discipline of writing secure code**. Adjacent territories are
referenced, not absorbed.

- **Design-time threat modelling** (STRIDE, attack trees, data flow diagrams) is
  referenced from *Insecure Design* (A06) and the secure-by-design mindset, with
  a note that a future `threat-modeling` sibling could own it in depth. This
  skill states that risk should be modelled proportionately; it does not run the
  workshop. This mirrors how `testing-strategy` references a future BDD plugin.
- **Boundaries as trust boundaries** cross-reference `hexagonal-architecture`:
  the ports and adapters are exactly where input validation, authentication, and
  authorization belong. `secure-coding` places the controls; `hexagonal` owns
  the boundary structure.
- **Error handling** cross-references `clean-code`: `clean-code` owns disciplined
  error handling in general; `secure-coding` owns its security dimension, the
  mishandling of exceptional conditions (A10) and not leaking sensitive detail
  in errors.
- **Security and abuse-case testing** cross-reference `testing-strategy` and
  `test-driven-development`: where security tests sit in the portfolio and how to
  drive an abuse case test-first.
- **Secrets and configuration wiring** cross-reference `dependency-injection`:
  secrets are supplied at the composition root, never hardcoded.
- **The `sentrux` MCP and the `/security-review` command** are named as
  complementary tooling: instruments that detect, whereas this skill is the
  discipline that prevents.

Explicitly out of scope:

- Threat modelling in depth (STRIDE tables, attack trees, DFD workshops):
  reserved for a future `threat-modeling` sibling; referenced only.
- Deep cryptography (algorithm internals, protocol design): the skill teaches
  "use vetted libraries and standard constructions, do not roll your own"; it
  does not teach how to build a cipher.
- Software supply-chain security in depth (SBOM tooling, provenance, SLSA
  levels): touched as a practice and a Top 10 category; a future
  `supply-chain-security` sibling could own the depth.
- Security tooling and its configuration (SAST/DAST scanners, WAF, SIEM,
  dependency scanners): tooling, complementary to `sentrux` and
  `/security-review`, not owned here.
- Infrastructure, network, cloud, and container hardening; secrets-manager
  operation: deployment and operations, not application code.
- Penetration testing and red-team methodology.
- Compliance and legal frameworks (SOC 2, PCI DSS, GDPR, HIPAA): governance, not
  coding discipline.

## Key decisions

- **One plugin, one skill** named `secure-coding`. Skill-only, no command or
  hook.
- **Prevention first, grounded in OWASP.** The centre of gravity is the
  developer applying proactive controls while coding, with the Top 10 as the
  risk catalogue to recognise. Detection tooling is referenced, not taught.
- **Standards current and sourced, not asserted.** Grounded in OWASP Top
  10:2025 (final release January 2026; the ten categories A01 to A10 including
  the new *Software Supply Chain Failures* at A03 and *Mishandling of
  Exceptional Conditions* at A10, with SSRF absorbed into Broken Access
  Control), OWASP Proactive Controls 2024 (C1 to C10, authorization promoted to
  the top), OWASP ASVS 5.0.0 (May 2025, roughly 350 requirements across 17
  chapters, three verification levels), and the secure-by-design principles of
  Saltzer and Schroeder (1975). Sourcing caveat: no invented verbatim
  quotations or page numbers beyond the short, verifiable phrasings and the
  category and control names gathered during research.
- **Mindset before checklist.** The eight-or-so secure-by-design principles are
  the reasoning frame; the proactive controls are the concrete moves; the Top 10
  is the failure catalogue. The skill presents them in that order so the reader
  can reason, not just comply.
- **ASVS as the verification standard.** ASVS 5.0.0 is presented as the
  requirement checklist to verify against (choose a level by risk: L1 baseline,
  L2 for most applications, L3 for high-value systems), complementing the Top 10
  awareness list. The two are held distinct: Top 10 raises awareness, ASVS
  verifies.
- **Examples in TypeScript only.** Consistent with the family (parameterized
  queries, Zod validation, argon2/bcrypt, security headers, SSRF allowlists,
  dependency auditing).
- **Do not roll your own crypto, and fail closed.** Two non-negotiable
  guardrails stated plainly, alongside server-side validation, least privilege,
  secrets never in code, keep dependencies patched, and never log secrets.

## Plugin structure

Mirrors the existing plugins, with a single skill:

```
plugins/secure-coding/
  .claude-plugin/plugin.json      # name, version 0.1.0, author, MIT license, homepage, keywords
  README.md                       # covers the skill
  LICENSE                         # MIT
  skills/secure-coding/
    SKILL.md                      # lean core: mindset, proactive controls, risk catalogue, practices
    references/
      secure-coding.md            # principles in full, Top 10:2025, controls, ASVS, TS practices, worked example
```

Writing conventions for all generated files: English, no em-dashes, words
written in full (standard acronyms such as OWASP, ASVS, CWE, API, JWT, CSRF,
CORS, SSRF, SBOM are fine).

## Plugin contents

### `secure-coding/SKILL.md` (lean core)

- Frontmatter: `name` plus a trigger-oriented `description` (writing, reviewing,
  or refactoring code that handles untrusted input, authentication,
  authorization, sessions, secrets, cryptography, database queries, file or URL
  handling, or error and exception paths; recognising or preventing an OWASP Top
  10 risk such as broken access control, injection, or a cryptographic failure;
  handling dependencies and the software supply chain; applying secure coding
  even when "secure coding" or "OWASP" is not named).
- **The secure-by-design mindset**: the distilled principles (least privilege,
  fail-safe defaults / fail closed, defence in depth, complete mediation,
  economy of mechanism, secure defaults, never trust input, minimise the attack
  surface, do not roll your own crypto).
- **Proactive controls**: the OWASP Proactive Controls 2024 (C1 to C10) as the
  "what to do while coding" checklist, one line each.
- **The risk catalogue**: the OWASP Top 10:2025 (A01 to A10) as the failures to
  recognise, one line each, cross-linked to the controls that prevent them.
- **Practice clusters**: access control and authorization; authentication and
  digital identity; input handling, injection, and output encoding;
  cryptography and secrets; secure configuration and defaults; dependencies and
  the software supply chain; error handling and exceptional conditions; security
  logging and monitoring; SSRF. One actionable line or two each.
- **Guardrails**: do not roll your own crypto; validate and authorize on the
  server; fail closed; least privilege by default; secrets never in code or
  version control; keep dependencies patched; never log secrets or sensitive
  data; no security by obscurity.
- **Relationship to other skills**: the cross-references listed under Scope.
- **Adapt to your context** section plus a pointer to the reference.

### `references/secure-coding.md` (depth, TypeScript)

- Sources: OWASP Top 10:2025; OWASP Top 10 Proactive Controls 2024; OWASP ASVS
  5.0.0; OWASP Cheat Sheet Series (as the practice-level source); Saltzer and
  Schroeder, "The Protection of Information in Computer Systems" (1975), for the
  design principles; CWE Top 25 as a cross-reference. Attribution without
  fabricated page numbers or invented verbatim quotations beyond the short,
  verifiable phrasings and the category and control names gathered during
  research.
- The secure-by-design principles in full, with their Saltzer and Schroeder
  origin and modern restatements.
- The OWASP Top 10:2025 catalogue: each of A01 to A10 with a short description,
  its typical cause, how to prevent it, and a TypeScript note; the 2025 changes
  called out (Supply Chain Failures new at A03, Mishandling of Exceptional
  Conditions new at A10, SSRF folded into Broken Access Control, Security
  Misconfiguration risen to A02).
- The Proactive Controls 2024 (C1 to C10) mapped to the practice clusters and to
  the Top 10 they mitigate.
- ASVS 5.0.0: the three verification levels and how to pick one by risk; using
  the standard as a per-feature checklist; how it complements the Top 10.
- Concrete TypeScript practices: parameterized queries and ORM-safe patterns;
  contextual output encoding against XSS; schema validation at the boundary with
  Zod; password hashing with argon2id or bcrypt and why not to hash with a plain
  digest; session and JWT pitfalls (algorithm confusion, missing expiry, storage
  choices); secrets via environment or a secret manager, never committed; secure
  headers (a helmet-style setup), CSRF tokens, and a restrictive CORS policy;
  rate limiting and lockout; SSRF prevention by allowlist and blocked internal
  ranges; dependency hygiene (lockfiles, `npm audit`, pinning, SBOM); structured
  security logging that records the security event without the secret or the
  personal data.
- One worked TypeScript walkthrough: a single endpoint handling untrusted input,
  shown applying validation, authorization, safe persistence, safe error
  handling, and an audit log entry, mapped back to the controls and the Top 10
  risks it closes.
- Trade-off notes with cross-references (hexagonal for trust boundaries,
  clean-code for error handling, testing-strategy and TDD for abuse-case tests,
  dependency-injection for secret wiring, and the future threat-modeling and
  supply-chain-security siblings).

## Research and validation approach

Content must be sourced, not written from memory.

- **Research pass done and ongoing.** The canonical facts were validated with
  WebSearch and WebFetch against the OWASP Top 10:2025 site (the ten categories
  and the 2025 changes), the OWASP Top 10 Proactive Controls 2024 site (C1 to
  C10), and the OWASP ASVS 5.0.0 release (version, scale, levels). Any further
  specific claim added during authoring is checked the same way, against OWASP
  primary sources and the OWASP Cheat Sheet Series for practice-level detail.
  Sourcing caveat: no invented verbatim quotations or page numbers.
- **Authoring tools.** The `plugin-dev:create-plugin` workflow and
  `plugin-dev:plugin-structure` for the plugin scaffold, and
  `skill-creator` / `plugin-dev:skill-development` for the skill structure and
  frontmatter, on top of the house format established by the sibling plugins.
- **Validation and review.** After authoring, the `plugin-dev:skill-reviewer`
  agent reviews the skill for triggering quality and the absence of overlap with
  its neighbours (the discipline must not drift into tooling, threat-modelling
  depth, or deep cryptography), and the `plugin-dev:plugin-validator` agent
  validates the plugin structure. Content is reviewed for accuracy against the
  OWASP sources, internal consistency, and the prevention-first, pragmatism, and
  composability framing.

## Marketplace and integration

- Add one entry to `.claude-plugin/marketplace.json` (name, source,
  description, version `0.1.0`).
- Add one row to the root `README.md` plugins table.
- Add reciprocal cross-references to `secure-coding` in the sibling plugins:
  `hexagonal-architecture` (ports and adapters as the trust boundary where the
  controls belong), `clean-code` (the security dimension of error handling), and
  `testing-strategy` (abuse-case and security tests in the portfolio), matching
  the existing cross-reference pattern.

## Success criteria

- One installable plugin following the existing structure and conventions, with
  a single focused skill.
- A lean, prevention-first `SKILL.md` with depth in `references/`: the
  secure-by-design mindset, the proactive controls, the Top 10:2025 risk
  catalogue, and the practice clusters, actionable in TypeScript from the
  reference alone.
- Standards are current and correctly attributed: Top 10:2025, Proactive
  Controls 2024, ASVS 5.0.0, and the Saltzer and Schroeder principles, with no
  fabricated quotations or page numbers.
- Ownership by territory is respected: `secure-coding` owns the developer-facing
  discipline; threat modelling, deep cryptography, supply-chain depth, security
  tooling, infrastructure, and compliance are referenced or deferred, not
  absorbed; cross-references run both ways with no duplication.
- The mindset, controls, and Top 10 are presented in a reasoning order (why,
  then what to do, then what to avoid), not as a bare checklist.
- Content grounded in the OWASP sources and reviewed by the
  `plugin-dev:skill-reviewer` and `plugin-dev:plugin-validator` agents.
- Registered in the marketplace and listed in the root README.
