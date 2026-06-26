# domain-driven-design

A Claude Code plugin that helps apply domain-driven design pragmatically: three matched skills that work together, one for discovering the domain collaboratively, one for drawing the large-scale model and establishing boundaries, one for filling in the building blocks inside those boundaries. Apply them where domain complexity justifies the investment, not as a blanket mandate.

It stays generic on purpose: compose it with your own team conventions, context-mapping sessions, and naming rules.

## What it does

When you work with domain models, context boundaries, or rich business logic, the three bundled skills apply together. EventStorming discovers the domain; strategic design draws the boundaries; tactical design fills in the building blocks inside each bounded context.

### ddd-event-storming

When you run or prepare a domain-discovery workshop, explore an unfamiliar business process with domain experts, map a flow of domain events on a timeline, or hunt for bounded contexts and aggregates, this skill applies:

- EventStorming (Alberto Brandolini): a collaborative workshop format for exploring complex business domains, the discovery move that precedes DDD modelling. Its purpose is learning, not documentation.
- The three formats: Big Picture (find the boundaries), Process Modelling (understand one flow), Software Design (discover aggregates inside a bounded context).
- The orange-sticky notation and its command-aggregate-event grammar, plus the Big Picture recipe: chaotic exploration, enforce the timeline, pivotal events, hotspots, and the explicit walkthrough.
- How the output feeds the other two skills: pivotal events and emergent clusters become candidate bounded contexts and subdomains; the command-aggregate-event grammar surfaces candidate aggregates and domain events.
- Guardrails: a wall of stickies is not a deliverable; it is overkill for simple or CRUD-dominant domains; outcomes depend on skilled facilitation and the right people; remote works but is a compromise.

### ddd-strategic-design

When you draw context boundaries, define a shared language with domain experts, or decide where one model ends and another begins, this skill applies:

- Ubiquitous language: a rigorous, living language co-owned by developers and domain experts, consistent within one bounded context, not across the whole organisation.
- Bounded contexts: an explicit boundary within which one model and one ubiquitous language are consistent, with every crossing requiring explicit translation.
- Subdomain classification: core (build in-house, invest DDD depth), supporting (build simply or outsource), and generic (buy rather than build).
- Context mapping: the full pattern catalogue (anticorruption layer, open host service, published language, conformist, partnership, shared kernel, customer/supplier, separate ways).
- The buy-versus-build heuristic and the problem-space versus solution-space distinction.
- Guardrail: a bounded context is not a microservice. A bounded context is a model boundary and can live entirely inside a monolith; a microservice is a deployment unit.

### ddd-tactical-design

When you are modelling domain building blocks, choosing between entities and value objects, designing an aggregate, or reviewing code for an anemic domain model, this skill applies:

- Entities (identity-based equality) and value objects (attribute-based equality, immutable, use aggressively).
- Aggregates, aggregate roots, and Vernon's four rules: model true invariants in the consistency boundary, design small, reference other aggregates by identity, use eventual consistency outside the boundary.
- Domain events: first-class building blocks, named in the past tense and in the ubiquitous language.
- Repositories: collection-like abstractions over aggregate roots, not data access objects; interfaces live in the domain, implementations in infrastructure.
- Domain services: stateless, named for a domain concept, holding logic that belongs to no single entity or value object.
- Factories: encapsulate complex construction of aggregates, entities, or value objects; add one only when a simple constructor does not suffice (YAGNI).
- The anemic domain model anti-pattern: entities as data bags with all business rules in services bear the cost of a domain model without the benefit of behaviour close to the data it governs.

CQRS and event sourcing are out of scope; each is planned as a future plugin.

## Install

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install domain-driven-design@jh3ady-claude-plugins
```

## Adapt to your context

This plugin is a baseline, not a dogma. Layer your own conventions on top: how your team runs context-mapping sessions, naming conventions for bounded contexts and aggregates, which subdomain classification drives your folder structure. Declare those in your own `CLAUDE.md` or a higher-priority skill. The plugin does not impose them.

## License

Released under the [MIT License](LICENSE).
