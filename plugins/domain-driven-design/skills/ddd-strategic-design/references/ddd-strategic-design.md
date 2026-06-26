# DDD strategic design reference

The detailed reference behind the skill: canonical definitions for ubiquitous language and bounded contexts,
subdomain classification with the buy-versus-build heuristic, the full nine-pattern context-map catalogue with
accuracy notes on role symmetry, the bounded context versus microservice distinction, and a pragmatic analysis
of when strategic DDD is overkill, all with attributed sources.

Standards and sources:

- Eric Evans, *Domain-Driven Design: Tackling Complexity in the Heart of Software* (2003): the foundational text
  introducing ubiquitous language, bounded context, context mapping, and subdomain classification.
- Eric Evans, *Domain-Driven Design Reference* (2015,
  [domainlanguage.com](https://www.domainlanguage.com/wp-content/uploads/2016/05/DDD_Reference_2015-03.pdf)):
  the condensed, freely available reference; adds Partnership and Big Ball of Mud to the context-map catalogue.
- Vaughn Vernon, *Implementing Domain-Driven Design* (2013): the problem space versus solution space distinction
  and the subdomain-to-bounded-context alignment analysis.
- Vaughn Vernon, *Domain-Driven Design Distilled* (2016): the accessible condensed treatment.
- Martin Fowler, [UbiquitousLanguage](https://martinfowler.com/bliki/UbiquitousLanguage.html) and
  [BoundedContext](https://martinfowler.com/bliki/BoundedContext.html) bliki entries: canonical short
  definitions used across the community.
- Vlad Khononov, *Learning Domain-Driven Design* (2021, [vladikk.com](https://vladikk.com/)): the
  buy-versus-build heuristic; the bounded-context-is-not-a-microservice analysis.
- Brian Foote and Joseph Yoder, *Big Ball of Mud* (1997,
  [laputan.org](http://www.laputan.org/mud/)): original coinage of the term, predating DDD.
- Microsoft, [Bounded Context pattern](https://learn.microsoft.com/en-us/azure/architecture/microservices/model/bounded-context)
  and [microservices architecture guidance](https://learn.microsoft.com/en-us/azure/architecture/microservices/):
  boundary versus deployment-unit analysis.

---

## 1. Ubiquitous language

The ubiquitous language is the shared, rigorous vocabulary that domain experts and developers construct together
and then use without exception in every artefact: code, tests, documentation, and conversation. Evans introduced
the concept in *Domain-Driven Design* (2003) as the mechanism by which the gap between a domain expert's mental
model and a developer's implementation model collapses into a single, consistent model. Fowler's bliki entry describes ubiquitous language as the term Evans uses for the practice of building up a
common, rigorous language between developers and users
([Fowler, UbiquitousLanguage](https://martinfowler.com/bliki/UbiquitousLanguage.html)).

Three qualities define the language:

**Rigour.** Vague synonyms and hedging phrases are eliminated. When a domain expert says "order" in one sentence
and "purchase" in the next, the team asks which word the model uses and commits to that word alone. Terms that
conflict, or that one expert uses with a different meaning from another, are resolved through explicit
conversation, not left ambiguous in the code. If the code says `Order` and the domain expert says "purchase
request," one of them is wrong, and resolving the discrepancy is part of the modelling work.

**Co-ownership.** The language belongs to the domain expert and the developer equally. If a developer coins a
term that the domain expert does not recognise, the term is wrong. If the team has silently reinterpreted a
domain expert's term into something the expert would not recognise, the implementation is wrong. Neither side
holds unilateral authority over the vocabulary.

**Living.** As the team deepens its understanding of the domain, the language deepens with it. A term that felt
right in month one may prove to conflate two distinct concepts the domain expert distinguishes in practice. When
that happens, the model is revised, the language is revised, and the code follows. Evans treats this evolution
as central, not incidental: the language is the model, not a label applied after the model is built.

### The scope misconception

The most common and most costly misconception is that "ubiquitous" means company-wide. It does not. Evans is
explicit on this point, and Fowler echoes it: the ubiquitous language is consistent within a single bounded
context, and the same word can legitimately mean different things across two separate bounded contexts. A term
forced to carry the same meaning across the whole organisation either becomes so broad that it conveys nothing,
or it imports assumptions from one context into another where they do not hold. The per-context scope is not a
limitation to work around; it is the mechanism that keeps each model coherent.

---

## 2. Bounded context

A bounded context is an explicit boundary within which one model and one ubiquitous language hold without
contradiction. Fowler's bliki entry describes a bounded context as the explicit boundary within which a
particular domain model applies
([Fowler, BoundedContext](https://martinfowler.com/bliki/BoundedContext.html)).

The boundary is real and physical. It manifests as a team, a codebase, a database schema, a deployment unit,
or a combination of these. What matters is that the line exists and that nothing crosses it without explicit
translation.

### Polysemy as signal

The clearest sign that two bounded contexts are being conflated into one is polysemy: the same word carrying
two different meanings in the same model. Consider the word "meter." In an energy-billing context, a meter is a
physical device that records energy consumption. In a customer-experience context run by the same utility
company, a meter is an account-level attribute: something the customer has installed, characterised by its
type (smart or analog) and the tariffs associated with it. The billing team cares about meter readings,
calibration intervals, and replacement cycles. The customer team cares about whether the customer qualifies for
a smart-meter upgrade and what self-service options apply.

Forcing both meanings into one shared "Meter" entity produces a domain model that serves neither context well:
fields irrelevant to billing appear alongside fields that customer experience never uses. The correct response
is not to find a single definition that covers both uses. The correct response is to name the boundary and
model each context's Meter precisely for its own language, with explicit translation at the integration point.

This is a polyseme: a single word carrying distinct meanings in different contexts. Polysemy is not a naming
failure to fix with a better word; it is a signal that a model boundary exists and should be made explicit.

### One language, one context

The relationship between ubiquitous language and bounded context is one-to-one. One bounded context owns one
ubiquitous language; one ubiquitous language implies one bounded context. This relationship is both a
constraint and a compass. If your model has a term that means two distinct things, you have at least two
contexts sharing an undeclared boundary: separate them. If you have two names for what is demonstrably the
same concept and the same team uses both, you have a terminology disagreement to resolve within one context.
Context mapping (section 4) handles the case where two contexts happen to model the same real-world concept
differently and need to integrate.

### When not to apply

Introducing explicit bounded contexts is architectural overhead. On a small application with one team, one
codebase, and a domain simple enough that one model is genuinely coherent across all its use cases, the effort
of defining and enforcing context boundaries produces no payoff. Apply the framing when the domain is rich
enough that a single model would have to contort itself to cover all its uses, or when multiple teams work on
different parts of the system independently.

---

## 3. Subdomains

A subdomain is a segment of the business problem space. Bounded contexts are the solution-space answer to that
problem space. This distinction is Vernon's framing in *Implementing Domain-Driven Design* (2013): a subdomain
is discovered by analysing the business; a bounded context is designed by the team. The ideal, articulated by
Evans and reinforced by Vernon, is a one-to-one correspondence: one bounded context per subdomain. In practice,
legacy systems and organisational history frequently produce many-to-one or one-to-many relationships, and the
context map (section 4) records that reality.

### Classification

Evans's classification of subdomains into three types drives investment decisions across the product portfolio:

**Core subdomain.** The part of the domain where the business derives its competitive advantage. A core
subdomain is both complex and unique to the company: it cannot be bought, because no off-the-shelf product
offers a competitive version of it, and it must not be outsourced, because the expertise developed while
building it is itself a strategic asset. This is where DDD tactical depth, rich domain models, carefully
cultivated ubiquitous language, and the best engineering capacity belong.

**Supporting subdomain.** Necessary for the business to operate, but not the source of competitive advantage.
A supporting subdomain is often moderately complex, but its logic is specific to the company without being
strategic. Build it simply, tolerate plain CRUD where the logic is thin, and resist the pull of over-engineering
it with tactical DDD patterns it does not justify.

**Generic subdomain.** Complex in the general sense but not unique. Authentication, email delivery, billing,
analytics platforms, and identity management all qualify. The problem is solved in the market. Buy a solution,
integrate an open-source library, or use a managed service. Building a generic subdomain from scratch is
nearly always a misallocation of core-team capacity.

### The buy-versus-build heuristic

Khononov sharpens the classification into a practical decision rule in *Learning Domain-Driven Design* (2021):
if a subdomain is generic, the market already provides a solution that is better and cheaper than what you
would build; buy it. If it is supporting, build simply, because the domain logic does not justify deep
investment. If it is core, build it in-house with full engineering rigour, because this is the work that
differentiates the product.

The heuristic is not purely about cost. A generic subdomain might cost very little to build and a fair amount
to integrate. The case for buying it still holds: attention spent on generic problems is attention not given
to the core domain, and that opportunity cost is the real argument.

### The 1:1 ideal versus messy reality

A clean portfolio has one bounded context for each subdomain: the core has one richly modelled bounded context,
each supporting subdomain has its own, and each generic subdomain is handled by an external service with an
anticorruption layer at the integration point. Real systems, especially those with significant legacy, rarely
match this picture. A monolithic codebase may contain three or four subdomains in one bounded context with no
explicit boundary between them. A generic subdomain may have been built in-house years ago and now carries
business logic too intertwined to extract cleanly. The context map records the current reality; the strategic
direction is toward the ideal. Refactoring toward cleaner boundaries is incremental, not a flag-day rewrite.

---

## 4. Context mapping

A context map is a visual or documented record of the relationships between bounded contexts and the
integration and translation patterns in place between them. Evans introduced the concept in *Domain-Driven
Design* (2003) as a way to make the political and technical reality of a system explicit, without pretending
that all teams have equal authority or that all integrations are clean. The context map is a living document;
it records the world as it is, not as the architect wishes it were.

The DDD Reference (2015) provides the canonical catalogue of nine patterns. Two of those nine, Partnership and
Big Ball of Mud, were not in the 2003 book and were added in the 2015 Reference edition.

### The nine patterns

The table below gives a one-line description and the role for each pattern. Role accuracy matters: treating an
asymmetric pattern as symmetric, or labelling a system state as a two-team relationship, produces misleading
context maps.

| Pattern | Role | Description |
|---|---|---|
| Partnership | Symmetric | Two teams commit to coordinate their releases and model evolution together. Neither team is upstream or downstream; changes are planned jointly and both teams are mutually accountable for keeping the integration working. |
| Shared Kernel | Symmetric | A small, explicitly agreed subset of the domain model is co-owned by two teams. Changes to the shared kernel require consent from both sides; neither team modifies it unilaterally. |
| Customer/Supplier | Asymmetric (upstream/downstream) | The upstream team (supplier) holds the model authority and the schedule leverage. The downstream team (customer) has standing to articulate its needs and to negotiate priority, but the supplier retains the final say over what the model provides and when. |
| Conformist | Asymmetric (downstream) | The downstream team adopts the upstream model as-is, with no translation. The upstream has no particular obligation to the downstream; the downstream simply conforms to whatever the upstream provides. |
| Anticorruption Layer (ACL) | Asymmetric (downstream) | The downstream team translates the upstream model into its own language via an isolating layer, protecting its domain from foreign concepts. The upstream is consumed but not allowed to dictate the downstream model. |
| Open Host Service (OHS) | Asymmetric (upstream) | The upstream team publishes a formal, versioned protocol or API that downstream consumers can rely on, designed for external consumption rather than for any one consumer's specific shape. |
| Published Language (PL) | Asymmetric (upstream/shared format) | A well-documented, shared exchange format, typically paired with an Open Host Service. The language is defined and maintained upstream; downstream consumers translate to and from it at their own boundaries. |
| Separate Ways | No integration | The bounded contexts have no integration; each solves its own problem independently. This is chosen deliberately when the cost or complexity of integration exceeds the value it would provide. |
| Big Ball of Mud | System state (not a two-team relationship) | An existing system with no discernible bounded contexts, tangled dependencies, and no consistent model. It is acknowledged on the map as a reality to work around. The term was coined by Foote and Yoder (1997), predating DDD; its inclusion in the context-map catalogue (DDD Reference, 2015) formalises how to treat such systems in a strategic map. |

### Accuracy notes

Two of the nine patterns are symmetric: Partnership and Shared Kernel. In both, neither team holds unilateral
authority over the shared model or the shared schedule; changes require coordination and mutual consent.

Customer/Supplier is not symmetric. The supplier (upstream) holds the model authority and the schedule
leverage. The customer (downstream) has the right to articulate its needs and negotiate, but the supplier is
not obligated to accommodate every request. The name "Customer/Supplier" can suggest a service relationship
where the customer drives; in the DDD sense, the supplier drives and the customer negotiates.

Separate Ways is not a relationship between teams managing a shared model; it is the deliberate absence of
integration. It is chosen when the integration cost or complexity is higher than the value of sharing.

Big Ball of Mud is a system state: it describes a poorly bounded, tangled existing system. It is not a pattern
that two teams choose for their collaboration. A team that places a big ball of mud on the context map is
acknowledging an uncontrolled legacy, not describing a deliberate design relationship. The right strategic
response is to wrap it with an anticorruption layer and to avoid modelling its internals (see section 6).

### Pseudo-structural example: a context map sketch

A context map does not need to be a formal diagram. A textual sketch captures the same essential information:

```
[Billing Context]         --OHS/PL-->       [Customer Portal Context]
[Customer Portal Context] --ACL-->          [Legacy CRM (Big Ball of Mud)]
[Tax Authority API]       --Conformist-->   [Billing Context]
[Billing Context]     <--Partnership-->     [Notifications Context]
```

The labels capture who the upstream is, what translation pattern is in place, and where anticorruption layers
need to be built. A fuller context map adds team ownership, deployment boundaries, and change-frequency notes,
but even this stripped version surfaces the political and technical shape of the system. Noticing that
[Customer Portal Context] needs an ACL against the legacy CRM is the kind of architectural decision the map
exists to make explicit and deliberate.

---

## 5. Bounded context versus microservice and module

A bounded context is a model boundary: the widest scope within which one ubiquitous language is consistent and
one domain model applies. A microservice is a deployment boundary: an independently deployable runtime unit
with its own process and network interface. These two concepts are not the same, and conflating them produces
systems that are either overpartitioned (one microservice per aggregate, with all the distributed-systems cost
that entails) or underpartitioned (one microservice spanning two domains, which reintroduces the coupling
that microservices are meant to eliminate).

Khononov states the constraint plainly in *Learning Domain-Driven Design* (2021): a bounded context is the
upper bound of a microservice, not the lower bound. A microservice should not span more than one bounded
context, because that would require one deployment unit to own two inconsistent models. But a single bounded
context may contain multiple services, or live entirely inside a monolith or a module. The direction of the
constraint matters: one microservice can serve at most one bounded context; one bounded context can be served
by any number of services, or by none, if it lives inside a larger deployment unit.

Microsoft's microservices architecture guidance reinforces the same principle from the deployment side: each
microservice should implement a single bounded context, and the bounded context determines the service's
responsibility and its API surface. Letting deployment topology drive model boundaries, rather than the
reverse, inverts the correct relationship and produces either artificial seams inside a coherent domain or
missing seams between genuinely distinct domains.

### Bounded contexts inside a modular monolith

The most common deployment of a bounded context is not a microservice but a module inside a monolith. A module
in a well-structured modular monolith is the physical expression of a bounded context: it has its own public
interface, its own internal model, and its own data, and it communicates with other modules only through
explicit contracts. The `modular-monolith` skill covers how modules are structured, isolated, and composed.
This skill identifies what the boundaries mean and where they should lie.

The practical consequence is that "we are in a monolith" does not justify delaying bounded context discipline,
and "we use microservices" does not automatically mean bounded contexts are already defined correctly. A
well-modularised monolith with clean context boundaries is easier to extract into services later, and simpler
to operate in the meantime. Premature decomposition into microservices before the domain is understood well
enough to draw stable boundaries is a common and expensive architectural mistake; the context map, including
its Big Ball of Mud entries, often reflects its aftermath.

### When not to apply

If a project has a single subdomain, one team, and a domain simple enough that one model covers all its use
cases without contradiction, introducing bounded context boundaries between modules is premature. The boundary
discipline earns its cost when either the domain is rich enough to strain a single model or the organisation
is large enough that separate teams must work independently.

---

## 6. When strategic DDD is overkill

Strategic DDD is a set of tools for managing complexity. Applied where the complexity does not exist, the
tools add process and modelling overhead without producing a domain worth protecting. Three situations call for
restraint.

### Simple and CRUD-dominant domains

If a bounded context is substantially a data-entry screen, a list view, and a save operation, there is no
domain model to speak of, no competing meanings for domain terms, and no team boundary that a context map
would illuminate. Applying strategic DDD in this case produces a ubiquitous language workshop for concepts the
team already understands, a context map with one box, and a bounded context that is just the module by another
name. Match the approach to the problem: plain layered code, or even a thin controller backed by a repository,
is the right tool for a CRUD slice. Start with strategic design only when the domain genuinely justifies it.

### Invest deep modelling only in the core

The subdomain classification (section 3) is itself the guardrail. DDD depth, meaning rich domain modelling,
bounded context discipline, and context mapping, belongs in the core subdomain. Supporting subdomains deserve
simpler treatment. Generic subdomains belong to off-the-shelf solutions behind an anticorruption layer.
Applying the full strategic toolkit to a supporting subdomain is gold-plating. Applying it to a generic
subdomain is usually a symptom of the "not invented here" tendency that the generic classification exists to
resist. The buy-versus-build heuristic (Khononov, 2021) encodes this discipline: resist the pull of building
what you can buy, and focus engineering depth where it creates competitive advantage.

### Wrapping the big ball of mud

When a system on the context map is a big ball of mud (no clear boundaries, tangled dependencies, no
consistent model), the correct strategic response is to wrap it, not to model it. Modelling the internals of a
big ball of mud spreads the mud: the foreign and inconsistent concepts of the legacy system begin to appear in
the domain models of the surrounding contexts. An anticorruption layer at the integration boundary translates
only the data the downstream context needs, expressed in the downstream context's own terms, and keeps the
remainder of the legacy internals quarantined.

The term "Big Ball of Mud" predates DDD. Foote and Yoder coined it in their 1997 paper to describe the
sprawling, haphazardly structured systems that result from expedient development without architectural
discipline. Evans incorporated the concept into context mapping in the DDD Reference (2015) to give teams a
formal way to acknowledge, on the map, that they are dealing with such a system. Acknowledging it is the first
step; wrapping it is the second; modelling its internals is not the third.

---

## Sources

- Eric Evans, *Domain-Driven Design: Tackling Complexity in the Heart of Software*, Addison-Wesley, 2003.
- Eric Evans, *Domain-Driven Design Reference: Definitions and Pattern Summaries*, 2015.
  [https://www.domainlanguage.com/wp-content/uploads/2016/05/DDD_Reference_2015-03.pdf](https://www.domainlanguage.com/wp-content/uploads/2016/05/DDD_Reference_2015-03.pdf)
- Vaughn Vernon, *Implementing Domain-Driven Design*, Addison-Wesley, 2013.
- Vaughn Vernon, *Domain-Driven Design Distilled*, Addison-Wesley, 2016.
- Martin Fowler, *UbiquitousLanguage*, martinfowler.com.
  [https://martinfowler.com/bliki/UbiquitousLanguage.html](https://martinfowler.com/bliki/UbiquitousLanguage.html)
- Martin Fowler, *BoundedContext*, martinfowler.com.
  [https://martinfowler.com/bliki/BoundedContext.html](https://martinfowler.com/bliki/BoundedContext.html)
- Vlad Khononov, *Learning Domain-Driven Design*, O'Reilly, 2021.
  [https://vladikk.com/](https://vladikk.com/)
- Brian Foote and Joseph Yoder, *Big Ball of Mud*, 1997.
  [http://www.laputan.org/mud/](http://www.laputan.org/mud/)
- Microsoft, *Bounded Context pattern*, Azure Architecture Center.
  [https://learn.microsoft.com/en-us/azure/architecture/microservices/model/bounded-context](https://learn.microsoft.com/en-us/azure/architecture/microservices/model/bounded-context)
- Microsoft, *Design a microservices architecture*, Azure Architecture Center.
  [https://learn.microsoft.com/en-us/azure/architecture/microservices/](https://learn.microsoft.com/en-us/azure/architecture/microservices/)
