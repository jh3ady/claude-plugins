---
name: ddd-event-storming
description: This skill should be used when running or preparing a collaborative domain-discovery workshop, exploring a complex or unfamiliar business process with domain experts, mapping a flow of domain events on a timeline to learn how a business behaves, hunting for candidate bounded contexts and aggregates, or turning a wall of workshop sticky notes into a domain model, applying EventStorming even when the term "EventStorming" is not used. Also covers the three formats (Big Picture, Process Modelling, Software Design), the coloured-sticky notation and its command-aggregate-event grammar, and how workshop output feeds strategic design and tactical design. Also applies whenever a domain is poorly understood and the right first move is to explore it collaboratively before drawing boundaries or writing code.
---

# EventStorming

EventStorming is a workshop format for collaborative exploration of complex business domains, invented by Alberto
Brandolini around 2013. It is the discovery move that comes before domain-driven design modelling: a room (or a virtual
board) full of domain experts and developers, an unlimited modelling surface, and a wall of sticky notes that reconstruct
how the business actually behaves over time. It is deliberately low-tech and high-touch. Its purpose is learning, not
documentation: it surfaces what the team does not yet understand, where people disagree, and where the real boundaries
of the domain lie. Brandolini's point is blunt (paraphrased): it is developers' ignorance of the domain, not the domain
experts' knowledge, that ends up deployed into production. Apply it where the domain is genuinely unclear, not as a
ritual for every feature.

## The three formats

EventStorming is a family of formats at different zoom levels (eventstorming.com; Avanscoperta). Pick the one that
matches the question you are trying to answer:

- **Big Picture**: broad exploration of an entire business line with many stakeholders. The goal is a shared, end-to-end
  picture and the discovery of where the interesting boundaries and problems are. This is where bounded contexts start
  to emerge.
- **Process Modelling**: a focused look at one end-to-end process, adding the people, systems, and decisions around the
  flow of events. Interdisciplinary but narrower than Big Picture.
- **Software Design**: the detailed, rigorous level that introduces the full command-aggregate-event grammar. This is
  the format with a direct relationship to DDD: it discovers aggregates and the internals of a single bounded context,
  and feeds tactical design.

The formats chain naturally: Big Picture to find the boundaries, Process Modelling to understand a chosen flow, Software
Design to model the slice you will build.

## The notation

EventStorming uses coloured sticky notes on a timeline that flows left to right. The colours below are the de facto
community convention (the ddd-crew EventStorming cheat sheet, aligned with Brandolini); treat them as a shared default,
not a rigid standard.

- **Domain Event (orange)**: something relevant that happened in the domain, written as a verb in the past tense
  (`Order Placed`, `Payment Received`). Events are the backbone; everything else is added around them.
- **Command (blue)**: the action, decision, or intent that causes an event. Often issued by a person.
- **Actor / User (small yellow)**: the person or role that issues a command. Small, to distinguish it from the aggregate.
- **Aggregate (large yellow)**: the unit of business logic a command is sent to and that emits the resulting event.
  Modern practice often relabels this note "business rule" or "constraint" to avoid jargon with non-technical
  participants; in DDD terms it is the aggregate.
- **Policy (lilac)**: reactive logic, "whenever <event> then <command>". The automation glue that links an event to the
  next command.
- **Read Model (green)**: the information an actor needs to make a decision before issuing a command.
- **External System (pink)**: a system outside the scope being modelled, treated as a black box that receives commands
  and produces events.
- **Hotspot (vivid pink or red, rotated)**: a problem, inconsistency, disagreement, or open question. Capture it and
  keep moving; do not stop the flow to resolve it.

Two common mistakes: confusing the two yellows (the actor is the small one, the aggregate the large one), and treating
the hotspot colour as fixed. A hotspot is "a vivid attention-grabbing note, rotated"; the exact hue varies between
sources.

### The grammar (Software Design level)

At the Software Design level the notes wire together into the flow Brandolini calls the picture that explains it all:

```
Read Model (green) informs an Actor (small yellow),
who issues a Command (blue),
sent to an Aggregate (large yellow) [or an External System (pink)],
which emits a Domain Event (orange),
which a Policy (lilac) reacts to ("whenever this event...")
by triggering the next Command, and the loop continues.
```

This grammar is the bridge to tactical design: each command-aggregate-event triple is a candidate aggregate with its
behaviour made explicit.

## The Big Picture recipe

A Big Picture session runs through these activities, roughly in this order (present them as a flow, not a rigid
pipeline; Brandolini interleaves several in practice):

1. **Chaotic exploration**: everyone writes domain events on orange stickies, in the past tense, and places them roughly
   along the timeline, in parallel and without coordination. It is meant to feel messy; structure comes later.
2. **Enforce the timeline**: sort the events into one coherent left-to-right flow, merging duplicates and surfacing gaps,
   branches, and inconsistencies. The first real conversations happen here.
3. **People and systems**: add the actors, external systems, and read models around the flow.
4. **Pivotal events and hotspots**: mark the few most significant events that split the timeline into phases (pivotal
   events, often highlighted with a vertical line), and capture problems and questions as hotspots without stopping to
   solve them.
5. **Explicit walkthrough**: narrate the timeline out loud to validate the story, often walking it backwards from
   outcome to cause to expose missing steps.

### Logistics that matter

- **Unlimited modelling surface**: a long paper roll on a wall (Brandolini suggests roughly eight to twelve metres),
  to remove the artificial limit of a normal diagram. Online, a single large board.
- **The right people**: invite both the people who know the questions to ask (typically developers) and the people who
  know the answers (domain experts). Without both, the session learns nothing new.
- **Standing, no chairs, plenty of orange stickies and markers**: keep people on their feet, moving, and contributing
  in parallel. The low-fi notation is deliberate, to lower the barrier to participation.

## How the output feeds DDD

EventStorming is the discovery technique; strategic and tactical design are what you do with what it reveals.

- **To strategic design**: clusters of events, the phases delimited by pivotal events, and divergences in how people name
  the same event reveal candidate **bounded contexts** and **subdomains**. Disagreement about a term is a signal that a
  context boundary runs through it. See the `ddd-strategic-design` skill.
- **To tactical design**: the command-aggregate-event grammar of the Software Design level surfaces candidate
  **aggregates**, and the orange events become **domain events** in the model. See the `ddd-tactical-design` skill.
- **Ubiquitous language**: the workshop is where the language is distilled, because the model is built in the domain
  experts' own words and disagreements are made visible and resolved.

## Guardrails

- EventStorming is a discovery and learning activity, not a deliverable. The wall of stickies is the residue of a
  conversation, not a specification. Convert what matters into a context map, an aggregate design, or notes; do not
  treat the photo of the wall as the model.
- It is overkill for a simple, well-understood, or CRUD-dominant domain. If the team already shares the language and the
  flow is obvious, a workshop adds ceremony without insight. Reserve it for domains that are genuinely complex or
  contested.
- Outcomes depend heavily on facilitation and on the right people being present. A neutral facilitator who keeps the
  timeline moving and cuts long side-debates into hotspots is essential; a session without real domain experts produces
  confident fiction.
- Resist too much precision too early. The exploratory phases are meant to be broad and messy; introducing the rigorous
  grammar before the big picture is understood kills the exploration.
- Remote works but is a compromise. Brandolini is candid that "there is still no such thing as remote EventStorming":
  virtual boards make everything too tidy, lose the parallel side-conversations, and leave the facilitator "almost
  completely blind" to body language. Prefer co-location for Big Picture; lean on tools (Miro, Mural) when you must, with
  extra discipline in naming and structure.

## Relationship to other skills

- **`ddd-strategic-design`**: the natural next step after a Big Picture session, where the candidate bounded contexts
  and ubiquitous language the workshop surfaces are formalised into a context map and subdomain classification.
- **`ddd-tactical-design`**: the next step after a Software Design session, where the candidate aggregates and domain
  events are modelled as entities, value objects, aggregates, and domain events in code.
- **`modular-monolith`**: bounded contexts discovered through EventStorming are usually first expressed as modules.

## Adapt to your context

This skill stays generic on purpose. Layer your own conventions on top: your sticky-colour palette and any extra notes
your team uses, whether you run sessions in person or remotely and with which tool, how you capture and triage hotspots,
and how workshop output is converted into models and tickets. Declare those in your own `CLAUDE.md` or a higher-priority
skill, which overrides this baseline. This skill does not impose them.

## Reference

For the full notation catalogue with the grammar diagram, the three formats compared, the Big Picture recipe in depth,
the design-level grammar mapped to TypeScript tactical building blocks, the bridge to strategic and tactical design, the
remote-facilitation analysis, and attributed sources, read `references/ddd-event-storming.md`.
