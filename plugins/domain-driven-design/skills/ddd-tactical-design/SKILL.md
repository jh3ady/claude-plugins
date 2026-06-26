---
name: ddd-tactical-design
description: Apply the tactical design half of domain-driven design (DDD) when modelling domain building blocks, deciding whether a concept is an entity or a value object, designing an aggregate and its consistency boundary, selecting a repository or a domain service, reviewing code for an anemic domain model, or expressing a rich domain inside one bounded context, even when the terms "DDD", "aggregate", "entity", or "value object" are not used. Also covers Vernon's four aggregate design rules, the repository-versus-DAO and domain-service-versus-application-service distinctions, domain events, and factories. Also applies when a domain-driven design request does not specify strategic or tactical scope, because modelling the building blocks that express a rich domain inside a bounded context is the complementary second half of any DDD engagement alongside strategic design.
---

# Tactical design (DDD)

Tactical design is the half of domain-driven design that provides the building blocks for expressing a rich domain model inside one bounded context. Where strategic design draws the map, tactical design fills in the terrain: entities, value objects, aggregates, domain events, repositories, domain services, factories, and modules. These building blocks encode the ubiquitous language directly in code and enforce the rules of the domain without leaking them into infrastructure. Apply them pragmatically; not every subdomain warrants the full set.

## Entity

An entity is a concept whose identity persists through time and across different representations. Two entity instances with the same attributes but different identifiers are not equal; two instances with the same identifier are the same entity regardless of how their attributes have changed. Equality is identity-based. The identity may be a UUID, a natural key, or a domain-assigned value, but it must be explicit and stable.

## Value object

A value object is a concept defined entirely by its attributes. There is no meaningful identity beyond those attributes: two value objects with the same attributes are interchangeable. Value objects are immutable; any change produces a new instance. Operations on a value object are side-effect-free. Use value objects aggressively: they make the domain model expressive and reduce the number of entities that must be tracked.

## Aggregate and aggregate root

An aggregate is a cluster of entities and value objects treated as a single unit for the purposes of data changes. One entity in the cluster is the aggregate root; all external references point only to the root. The aggregate boundary is the consistency and transaction boundary: the invariants that must hold after any operation are invariants within one aggregate, and a single transaction must not span more than one aggregate boundary.

Vernon's four rules for aggregate design (Effective Aggregate Design, 2011):

1. Model true invariants in the consistency boundary. If a rule must hold atomically, the objects it spans belong in the same aggregate. If it can be satisfied eventually, they do not.
2. Design small aggregates. A large aggregate invites contention, increases transaction cost, and hides the true invariants. Default to small and grow only when a real invariant forces it.
3. Reference other aggregates by identity, not by direct object reference. This keeps boundaries explicit and prevents loading an entire object graph by traversal.
4. Use eventual consistency outside the boundary. When a change in one aggregate must cause a change in another, do it through a domain event and an asynchronous handler, not by including both aggregates in one transaction.

## Domain event

A domain event represents something that happened in the domain that domain experts care about and that other parts of the system may need to react to. It is named in the past tense and in the ubiquitous language (for example, `OrderPlaced` or `PaymentRefunded`). Domain events are a first-class tactical building block, not infrastructure plumbing.

Note: CQRS (Command Query Responsibility Segregation) and event sourcing are separate patterns that frequently appear alongside domain events, but they are distinct concerns. Both are out of scope here and planned as a future plugin.

## Repository

A repository is a collection-like abstraction that provides access to aggregate roots as though they were held in memory. Provide one repository per aggregate root, not per entity. A repository is not a DAO (data access object): a DAO is a thin wrapper around a persistence technology, while a repository belongs to the domain layer and expresses a domain intention (find the order for this customer, collect all unpaid invoices). The interface is defined in the domain; the implementation lives in the infrastructure layer. See the `hexagonal-architecture` skill, which classifies a repository interface as a secondary (driven) port.

## Domain service

A domain service holds domain logic that belongs to no single entity or value object. It is stateless and named for a domain concept, not a technical one. A domain service is not the same as an application service: an application service orchestrates a use case (coordinates a domain service, a repository, and infrastructure) but contains no business rules. When logic involves multiple aggregates or requires external input to compute a domain answer, a domain service is the right home.

## Factory

A factory encapsulates the logic required to create a valid, consistent entity, value object, or whole aggregate when that construction logic is too complex for a constructor. When a simple constructor suffices, do not add a factory (YAGNI). A factory differs from a repository: a factory creates a new instance; a repository retrieves an existing one.

## Modules

A module is a named, cohesive, low-coupling partition of the domain model whose name belongs to the ubiquitous language. Group concepts that change together and that domain experts reason about together; keep concepts with different lifecycles or different owners in separate modules.

## Guardrails

- The anemic domain model is an anti-pattern. If your entities are data bags and all the business rules live in services, you bear the cost of a domain model (extra types, mappings, indirection) without the benefit (behaviour close to the data it governs). Push behaviour into entities and value objects.
- Prefer small aggregates. The instinct to group related concepts into one large aggregate is almost always wrong. Follow Vernon's second rule until a real invariant forces a larger boundary.
- Not every entity is an aggregate root, and not every aggregate root needs a repository. Promote an entity to aggregate root only when it must own a consistency boundary. Add a repository only when you need to find or store that root independently.
- Do not apply tactical DDD to CRUD slices. If a slice has no invariants, no complex creation logic, and no domain events, the full building-block set is over-engineering. See the `ddd-strategic-design` skill on matching investment to the subdomain classification.

## Relationship to other skills

- **`hexagonal-architecture`**: a repository interface is a secondary (driven) port; its implementation is a driven adapter. The domain model lives in the application core. These two skills compose directly; consult `hexagonal-architecture` for the structural wiring.
- **`dependency-injection`**: domain services and repositories declared as interfaces in the domain are injected at the composition root. See `dependency-injection` for constructor injection patterns and the over-injection smell.
- **`clean-code` and `solid-principles`**: naming domain concepts after the ubiquitous language, keeping methods small, and applying the Single Responsibility Principle to domain services are covered there. Those skills govern the implementation quality of the building blocks this skill defines.
- **`ddd-strategic-design`**: the sibling skill. Strategic design answers where the model boundary lies and what the ubiquitous language is; tactical design fills in the building blocks inside that boundary. Apply strategic design first.

## Adapt to your context

This skill stays generic on purpose. Layer your own conventions on top: how your team names aggregate roots and domain events, your folder layout for modules, which building blocks you use by default in core versus supporting subdomains. Declare those in your own `CLAUDE.md` or a higher-priority skill, which overrides this baseline. This skill does not impose them.

## Reference

For canonical definitions with sources, TypeScript examples for each building block, detailed aggregate design analysis, the full repository-versus-DAO and domain-service-versus-application-service comparisons, factory patterns, and the anemic domain model anti-pattern in depth, read `references/ddd-tactical-design.md`.
