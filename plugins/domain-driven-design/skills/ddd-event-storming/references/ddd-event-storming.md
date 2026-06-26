# DDD EventStorming reference

The detailed reference behind the skill: the origin and purpose of EventStorming, the three formats compared, the full
notation catalogue and its command-aggregate-event grammar, the Big Picture recipe with facilitation logistics, the
bridge from workshop output to strategic and tactical DDD (with a TypeScript mapping), the remote-facilitation analysis,
and a pragmatic account of when a workshop is the wrong tool, all with attributed sources.

Standards and sources:

- Alberto Brandolini, *Introducing EventStorming* (Leanpub, in progress,
  [leanpub.com/introducing_eventstorming](https://leanpub.com/introducing_eventstorming)): the primary book by the
  inventor. The book is the canonical source; the quotations used here are taken from Brandolini's freely available
  pages, not from the paywalled book text.
- Alberto Brandolini, [eventstorming.com](https://www.eventstorming.com/): the official site, with the canonical
  one-line definition and the catalogue of formats.
- Alberto Brandolini, *EventStorming in COVID-19 times* (2020,
  [blog.avanscoperta.it](https://blog.avanscoperta.it/2020/03/26/eventstorming-in-covid-19-times/)): the author's own
  analysis of remote facilitation and its limits.
- Avanscoperta, [EventStorming resource page](https://www.avanscoperta.it/en/eventstorming/): Brandolini's company;
  the three formats, their purposes, and the bounded-context and aggregate outcomes.
- ddd-crew, [EventStorming Glossary and Cheat Sheet](https://ddd-crew.github.io/eventstorming-glossary-cheat-sheet/):
  the de facto community reference for the notation, aligned with Brandolini's practice.
- Vaughn Vernon, *Domain-Driven Design Distilled* (2016): chapter 7 presents EventStorming as a fast, low-cost way to
  begin DDD modelling.
- Vlad Khononov, *Learning Domain-Driven Design* (2021): chapter 12 walks EventStorming end to end and ties it to
  bounded contexts and aggregates.

---

## 1. Origin and purpose

EventStorming was created by Alberto Brandolini around 2013 and first described in his post *Introducing Event Storming*.
The official definition on his site is deliberately broad:

> EventStorming is a flexible workshop format for collaborative exploration of complex business domains.
> ([eventstorming.com](https://www.eventstorming.com/))

Two properties of that definition carry the whole technique. It is a **workshop**: a live, time-boxed, collaborative
activity, not a diagram produced by one person at a desk. And its subject is **complex business domains**: the technique
earns its cost where understanding is genuinely hard to come by, not where the flow is already obvious to everyone.

The motivating problem is a knowledge-transfer failure. The people who understand the domain (domain experts) and the
people who build the software (developers) hold different, partial models, and the gaps between them are invisible until
they surface as defects. Brandolini's widely quoted aphorism captures the consequence: it is not the domain experts'
knowledge that gets deployed to production, but the developers' ignorance of the domain (paraphrase of Brandolini's
well-known formulation). EventStorming exists to make that ignorance visible early, while it is still cheap to fix, by
reconstructing the domain's behaviour collaboratively on a wall.

The output is **learning, not documentation**. The wall of stickies is the residue of a conversation. Its value is in the
shared understanding it produces, the disagreements it exposes, and the boundaries it reveals, not in the artefact
itself.

---

## 2. The three formats

Brandolini frames EventStorming as a family of formats at different zoom levels (eventstorming.com; Avanscoperta). Three
are canonical and recurring.

| Format | Zoom level | Purpose | Typical audience |
|---|---|---|---|
| Big Picture | Whole business line | Build a shared end-to-end picture, surface diverging perspectives, and discover where the interesting boundaries and problems are. | Large, cross-stakeholder group (often fifteen to thirty people). Best in person. |
| Process Modelling | One end-to-end process | Understand an existing process or design a new one, adding the people, systems, read models, and policies around the flow of events. | Smaller interdisciplinary team. |
| Software Design | A single bounded context | Introduce the rigorous command-aggregate-event grammar to discover aggregates and design the internals of a context. | Developers and modellers, with an experienced facilitator. |

Only the Software Design level has a direct, deep relationship with DDD tactical patterns. Big Picture and Process
Modelling are domain-exploration tools whose output happens to be extremely useful for strategic design.

The formats **chain**: run a Big Picture session to find the boundaries, a Process Modelling session to understand a
chosen flow in detail, and a Software Design session to model the slice you are about to build. Do not start at the
Software Design level for a domain you do not yet understand broadly; the precision will get in the way of the
exploration.

### A note on "EventStorming for retrospectives" and other flavours

Brandolini and the community describe further applications (onboarding new team members, probing the feasibility of a
new business model, redesigning a legacy system). These are uses of the formats above rather than additional canonical
levels. A distinct "retrospective" format is a community variation, not part of Brandolini's canonical three-level list;
treat the three formats above as the stable core.

---

## 3. The notation

The notation is a small set of coloured sticky notes placed on a timeline that flows left to right. The colours are the
de facto convention from the ddd-crew cheat sheet, which is aligned with Brandolini's practice. They are a shared
default, not a rigid standard; teams adapt them, and that is fine as long as the legend is explicit on the wall.

| Note | Colour | Meaning |
|---|---|---|
| Domain Event | Orange | Something relevant that happened in the domain, written as a verb in the past tense. The backbone of the model. |
| Command | Blue | The action, decision, or intent that causes an event. Often issued by a person. |
| Actor / User | Small yellow | The person or role that issues a command. Small, to distinguish it from the aggregate. |
| Aggregate | Large yellow | The unit of business logic a command targets and that emits the event. Often relabelled "business rule" or "constraint" with non-technical participants. |
| Policy | Lilac | Reactive logic: "whenever &lt;event&gt; then &lt;command&gt;". The automation that links an event to the next command. |
| Read Model | Green | The information an actor consults to make a decision before issuing a command. |
| External System | Pink | A system outside the modelled scope, treated as a black box that receives commands and produces events. |
| Hotspot | Vivid pink or red, rotated | A problem, inconsistency, disagreement, or open question. Captured and left in place; not resolved on the spot. |
| Pivotal Event | An orange event marked with a vertical line | One of the few most significant events that split the timeline into phases. Not a separate colour. |

### Accuracy notes

- **The two yellows.** The single most common notation mistake is confusing the small yellow actor with the large yellow
  aggregate. They differ by size, not hue. Keep the actor visibly small.
- **The hotspot colour is not fixed.** Sources disagree on the exact hue (neon pink, dark red, purple). What is canonical
  is that a hotspot is a vivid, attention-grabbing note, usually rotated forty-five degrees so it stands out against the
  orderly timeline. Treat the rotation, not the exact colour, as the signal.
- **"Aggregate" is becoming "constraint".** Current practice often relabels the large yellow note to avoid jargon with
  business stakeholders. In DDD terms it is still the aggregate; the relabelling is a facilitation choice, not a change
  of meaning.

### The grammar (Software Design level)

At the Software Design level the notes form a repeating structure that Brandolini calls "the picture that explains it
all":

```
        Read Model (green)
              | informs
              v
Actor (small yellow) --issues--> Command (blue)
                                     |
                                     v
                   Aggregate (large yellow) --or--> External System (pink)
                                     | emits
                                     v
                          Domain Event (orange)
                                     | reacted to by
                                     v
                          Policy (lilac)  "whenever this event..."
                                     | triggers
                                     v
                          next Command (blue) --> (loop continues)
```

Read in narrative: an actor consults a read model to decide, then issues a command; the command is handled by an
aggregate (or sent to an external system), which emits one or more domain events; a policy reacts to an event and
triggers the next command, closing the loop; domain events also update the read models that actors consult. Every
command-aggregate-event triple on the wall is a candidate aggregate with its behaviour already made explicit, which is
exactly the bridge to tactical design (section 5).

---

## 4. The Big Picture recipe

A Big Picture session moves through the activities below. Present them as a flow, not a strict numbered pipeline:
Brandolini interleaves several of them in practice, and the ordering shifts with the room.

1. **Chaotic exploration.** Everyone writes domain events on orange stickies, in the past tense, and places them roughly
   along the timeline, in parallel and without coordination. The phase is meant to feel chaotic. Structure is imposed
   later; forcing order too early suppresses the divergent knowledge the phase exists to surface.
2. **Enforce the timeline.** Merge the scattered local sequences into one coherent left-to-right flow. Duplicates
   collapse, gaps appear, and branches and alternative paths become visible. This sorting pass is where the first real
   cross-discipline conversations happen.
3. **People and systems.** Add the actors and roles who drive the flow, the external systems involved, and the read
   models that inform decisions.
4. **Pivotal events and hotspots.** Mark the few pivotal events that divide the timeline into business phases, usually
   with a vertical line. Capture problems, disagreements, and open questions as hotspots and leave them in place; the
   facilitator's job is to convert a long side-debate into a hotspot and keep the timeline moving.
5. **Explicit walkthrough.** Narrate the timeline out loud, with a narrator and the room as audience, to validate that
   the story holds together. Walking the timeline backwards, from outcome to cause, is a reliable way to expose missing
   steps and hidden assumptions.

### Facilitation logistics that matter

These are genuine parts of Brandolini's practice, not incidental preferences:

- **Unlimited modelling surface.** A long paper roll on a wall, on the order of eight to twelve metres, gives "the
  illusion of an unlimited modelling surface" and removes the artificial constraint that a normal diagram imposes.
  Online, the equivalent is a single very large board.
- **The right people in the room.** Invite both the people who know the questions to ask, typically developers, and the
  people who know the answers, the domain experts. A session missing either side cannot learn anything new; it only
  records what one group already believed.
- **Standing, no chairs, no laptops.** Remove tables and chairs so people stay on their feet, move around, and use the
  whole surface. The low-fi sticky-note notation is a deliberate leveller: it lets anyone contribute without tooling or
  notation training, and keeps contribution parallel rather than bottlenecked on one person at a keyboard.
- **A generous supply of orange stickies and markers.** Domain events dominate, so the orange stock runs out first.

---

## 5. From workshop to model: the bridge to DDD

EventStorming is the discovery technique; strategic and tactical design are what the team does with what it reveals.

### To strategic design: bounded contexts and ubiquitous language

Three signals from a Big Picture wall point at bounded context boundaries:

- **Clusters of events.** Groups of events that belong together and interact little with the rest of the timeline are
  candidate contexts.
- **Pivotal events.** The phase transitions they mark frequently coincide with context boundaries, because a business
  phase change is often also a change of model and responsibility.
- **Vocabulary divergence.** When participants use the same word for different things, or different words for the same
  thing, the disagreement is a signal that a context boundary runs through that term. Making such disagreements visible
  is one of the technique's core values.

Avanscoperta states the outcome directly: a Big Picture exploration yields valuable insight toward a sensible
decomposition into bounded contexts, handed to the technical team as follow-up work. The workshop is also where the
ubiquitous language is distilled, because the model is built in the domain experts' own words. Take these candidates
into the `ddd-strategic-design` skill to formalise the context map and subdomain classification.

### To tactical design: aggregates and domain events

The Software Design level produces tactical building blocks almost directly. Each command-aggregate-event triple is a
candidate **aggregate** with a command it accepts and an event it emits; the orange notes are the **domain events** of
the model; the lilac policies are the eventual-consistency reactions between aggregates. A design-level slice maps to
TypeScript tactical building blocks (see the `ddd-tactical-design` skill) like this:

```typescript
// Command (blue): an intent, named in the ubiquitous language.
type PlaceOrder = {
  readonly customerId: CustomerId
  readonly lines: ReadonlyArray<OrderLine>
}

// Domain event (orange): something that happened, past tense.
type OrderPlaced = {
  readonly orderId: OrderId
  readonly placedAt: Date
}

// Aggregate (large yellow): receives the command, enforces the rule, emits the event.
class Order {
  static place(command: PlaceOrder): { order: Order; event: OrderPlaced } {
    if (command.lines.length === 0) {
      throw new EmptyOrderError() // the business rule the yellow note stands for
    }
    const order = new Order(/* ... */)
    return { order, event: { orderId: order.id, placedAt: order.placedAt } }
  }
}

// Policy (lilac): "whenever OrderPlaced, then reserve stock", an eventual-consistency reaction.
// Handles the event from one aggregate and issues a command to another.
function onOrderPlaced(event: OrderPlaced): ReserveStock {
  return { orderId: event.orderId }
}
```

The mapping is a starting point, not an automatic translation. The workshop tells you which aggregates and events exist
and how they relate; the `ddd-tactical-design` skill governs how to model them well (entity versus value object, the
consistency boundary, small aggregates, references by identity).

### Where EventStorming sits relative to the other DDD skills

Vaughn Vernon presents EventStorming in *Domain-Driven Design Distilled* (2016) as a fast, low-cost way to begin DDD
modelling, engaging domain experts and developers together and discovering misunderstandings early. Vlad Khononov
devotes a chapter of *Learning Domain-Driven Design* (2021) to it, tying the workshop output to bounded contexts and
aggregates. The consistent message across both is that EventStorming is the on-ramp to DDD: it precedes and feeds both
the strategic and the tactical halves.

---

## 6. Remote facilitation

Remote EventStorming is possible but is a compromise, and Brandolini is candid about why. In *EventStorming in COVID-19
times* (2020) he writes:

> In case you wondered, I haven't really changed my mind: there is still no such thing as remote EventStorming.
> ([blog.avanscoperta.it](https://blog.avanscoperta.it/2020/03/26/eventstorming-in-covid-19-times/))

His specific reservations, all from that article, are worth keeping in mind when a session has to be remote:

- The unlimited surface becomes a liability rather than an asset: it is easy to get lost on virtual surfaces that are
  genuinely unlimited, so naming and structuring conventions must be agreed up front.
- The facilitator loses the room. "Keep in mind that the facilitator is almost completely blind at this moment and can't
  help as much as in the real version", and "Funny faces and rolling eyes are not working remotely." The body-language
  cues a facilitator relies on to sense confusion or disagreement are gone.
- Parallel side-conversations, a major source of value in the physical format, mostly disappear; partly recoverable with
  breakout rooms.
- Digital tidiness flattens the signal. "Unfortunately, digital tools tend to make everything too tidy and nothing
  really stands out", and "For example, Miro doesn't allow stickies to rotate, and comments look so polite." The rotated,
  messy hotspot that grabs attention on a paper wall does not survive a tidy virtual board.

Practical stance: prefer co-location for Big Picture sessions, where broad exploration and parallel conversation matter
most. When remote is unavoidable, use a large shared board (Miro and Mural have Brandolini-authored templates for Process
Modelling and Software Design), impose naming discipline, use breakout rooms to recover parallel conversations, and
compensate deliberately for the facilitator's reduced visibility.

---

## 7. When not to run an EventStorming session

EventStorming is a tool for managing domain complexity and uncertainty. Where neither is present, it adds ceremony
without insight.

- **The domain is simple or CRUD-dominant.** If the flow is a few forms and a save, with no contested vocabulary and no
  hidden process, there is nothing to discover. A workshop produces a wall that restates what everyone already knew.
  This is practitioner consensus rather than a single citable rule, but it is consistent with the technique's stated
  purpose: it exists for *complex* business domains.
- **The right people cannot attend.** The technique's value depends on having both the question-askers and the
  answer-holders present. A session run without real domain experts produces confident fiction that is worse than no
  model, because it carries the authority of a workshop.
- **No skilled facilitation is available.** Outcomes depend heavily on a neutral facilitator who keeps the timeline
  moving, parks long debates as hotspots, and protects the chaotic phase from premature ordering. Poor facilitation can
  damage the initiative and sour the team on the technique.
- **The team wants a deliverable, not a conversation.** EventStorming is not a specification format. If what is needed is
  a documented decision, run the session to reach shared understanding, then convert the result into a context map, an
  aggregate design, or notes. Do not treat the photo of the wall as the artefact.

The same restraint that governs the rest of domain-driven design applies here: spend the heavyweight collaborative
modelling on the core domain, where understanding is hard-won and competitive advantage lives, and keep it away from
supporting and generic subdomains that do not justify the cost.

---

## Sources

- Alberto Brandolini, *Introducing EventStorming*, Leanpub (in progress).
  [https://leanpub.com/introducing_eventstorming](https://leanpub.com/introducing_eventstorming)
- Alberto Brandolini, *EventStorming* (official site).
  [https://www.eventstorming.com/](https://www.eventstorming.com/)
- Alberto Brandolini, *EventStorming in COVID-19 times*, Avanscoperta blog, 2020.
  [https://blog.avanscoperta.it/2020/03/26/eventstorming-in-covid-19-times/](https://blog.avanscoperta.it/2020/03/26/eventstorming-in-covid-19-times/)
- Avanscoperta, *EventStorming*.
  [https://www.avanscoperta.it/en/eventstorming/](https://www.avanscoperta.it/en/eventstorming/)
- ddd-crew, *EventStorming Glossary and Cheat Sheet*.
  [https://ddd-crew.github.io/eventstorming-glossary-cheat-sheet/](https://ddd-crew.github.io/eventstorming-glossary-cheat-sheet/)
- Vaughn Vernon, *Domain-Driven Design Distilled*, Addison-Wesley, 2016.
- Vlad Khononov, *Learning Domain-Driven Design*, O'Reilly, 2021.
