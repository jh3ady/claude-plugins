---
name: ddd-strategic-design
description: Apply the strategic design half of domain-driven design (DDD) when drawing context boundaries, defining a ubiquitous language with domain experts, classifying subdomains as core, supporting, or generic, mapping relationships between bounded contexts (anticorruption layer, open host service, conformist, partnership, shared kernel), or deciding where one model ends and another begins, even when the terms "DDD", "bounded context", or "ubiquitous language" are not used. Also covers the problem space versus solution space distinction, the buy-versus-build heuristic, and context-map patterns. Also applies when a domain-driven design request does not specify strategic or tactical scope, because establishing bounded context boundaries and agreeing on a ubiquitous language is the natural starting point of any DDD engagement.
---

# Strategic design (DDD)

Strategic design is the half of domain-driven design that shapes the problem and solution spaces before any tactical
code is written. It answers three questions: what language do the team and domain experts share? where does one
consistent model end and another begin? how do separate models integrate? Applied well, strategic design focuses
engineering effort on what matters (the core domain) and keeps complexity from spreading across the codebase. Apply it
pragmatically, not as a blanket mandate.

## Ubiquitous language

A rigorous, living language co-owned by domain experts and developers, used in speech, diagrams, code, and tests. It
evolves as the team deepens its understanding of the domain. Key misconception: ubiquitous language is not one glossary
for the whole organisation. It is consistent only within a single bounded context. The same word can legitimately mean
different things in two separate contexts; that is a feature, not a problem to eliminate.

## Bounded context

An explicit boundary within which one model and its ubiquitous language are consistent. The boundary manifests
concretely: a team, a codebase, a database schema. One bounded context owns one ubiquitous language; one ubiquitous
language implies one bounded context. Nothing crosses that boundary without explicit translation.

## Subdomains

Subdomains are the problem-space lens; bounded contexts are the solution-space answer (Vernon, Implementing Domain-Driven Design, 2013). The recommended ideal is one
bounded context per subdomain. Classify each subdomain to drive investment decisions:

- **Core**: complex and the source of competitive advantage. Build in-house with the best team. This is where DDD
  tactical depth pays off.
- **Supporting**: necessary but not complex; does not differentiate the product. Build simply or outsource.
- **Generic**: complex but solved; standard tools or off-the-shelf products handle it (authentication, billing, email).
  Buy rather than build.

The buy-versus-build heuristic follows from the classification: spend engineering excellence on the core, and resist the
pull of over-engineering supporting and generic subdomains.

## Context mapping

A context map records the relationships between bounded contexts and the translation patterns in place. Patterns by
role:

**Upstream (produces the model):**

- **Open Host Service (OHS)**: the upstream publishes a formal, versioned API that downstream consumers rely on.
- **Published Language (PL)**: a shared, well-documented exchange format, typically paired with OHS.

**Downstream (consumes the model):**

- **Conformist**: the downstream adopts the upstream model as-is, no translation.
- **Anticorruption Layer (ACL)**: the downstream translates the upstream model into its own language, protecting its
  domain from foreign concepts.

**Symmetric:**

- **Partnership**: two teams commit to evolve together; changes are coordinated.
- **Shared Kernel**: a small, explicitly shared subset of the model, co-owned and co-evolved.

**Other:**

- **Customer/Supplier**: the upstream (supplier) acknowledges the downstream (customer) as a stakeholder; priorities are
  negotiated.
- **Separate Ways**: no integration; each context solves the problem independently.
- **Big Ball of Mud**: an existing tangled system with no clear boundaries; acknowledge it on the map, wrap it, do not
  model its internals.

## Guardrails

Match the investment to the subdomain:

- Pour DDD depth into the core domain only. A supporting subdomain is not a tactical playground; a generic subdomain
  deserves a purchased solution, not a hand-crafted model.
- If a system is a big ball of mud, wrap it with an anticorruption layer. Modelling its internals spreads the mud.
- If a slice is pure CRUD with no domain logic, introducing bounded contexts, a ubiquitous language, and context maps is
  over-engineering. Start with strategic design only when the domain justifies it.
- A bounded context is not a microservice. A bounded context is the widest sensible model boundary and can live entirely
  inside a monolith. A microservice is a deployment unit; it should not span more than one bounded context, but one
  bounded context may contain several. See the `modular-monolith` skill.

## Relationship to other skills

- **`modular-monolith`**: module boundaries inside a monolith are the primary place where bounded context boundaries are
  expressed. That skill covers how modules are structured, isolated, and composed; this skill identifies what the
  boundaries mean and where they should lie.
- **`hexagonal-architecture`**: the anticorruption layer lives at an adapter boundary in the hexagonal model. The
  application core of a bounded context is the domain model; hexagonal architecture is the structural pattern that
  protects it from infrastructure and from foreign models. These skills compose directly.
- **`ddd-event-storming`**: the sibling skill for the collaborative domain-discovery workshop that usually precedes
  context mapping. Pivotal events and emergent event clusters surface the candidate bounded contexts and subdomains this
  skill then formalises. Run an EventStorming session first when the domain is not yet well understood.
- **CQRS and event sourcing**: tactical and infrastructure patterns that commonly appear inside bounded contexts. Out of
  scope here; planned as a future plugin.

## Adapt to your context

This skill stays generic on purpose. Layer your own conventions on top: how your team runs context-mapping sessions,
naming conventions for bounded contexts and integration events, which subdomain classification drives your module
structure. Declare those in your own `CLAUDE.md` or a higher-priority skill, which overrides this baseline. This skill
does not impose them.

## Reference

For canonical definitions with sources, the full context-map pattern catalogue with examples, ubiquitous language as
living documentation, the problem/solution space distinction in depth, TypeScript modelling of bounded contexts and
anticorruption layers, and the full guardrail analysis, read `references/ddd-strategic-design.md`.
