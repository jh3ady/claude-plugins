---
name: pragmatism
description: This skill should be used when deciding how much design, architecture, abstraction, process, or technology a piece of work deserves, when a request asks for more (or less) structure than its lifespan and scale justify, when weighing any principle (SOLID, DDD, hexagonal, CQRS, event sourcing, TDD, clean code) against the cost of applying it here and now, when choosing or replacing a technology, when judging whether software is good enough to ship, or when reviewing code for over-engineering or under-engineering, applying pragmatism even when the word is never used. It defines what "applied pragmatically" means for every sibling principle, namely sizing by expected lifespan and scale, reversibility over prediction, the cost of carry, boring technology, and good-enough software as a requirement negotiated with users, never as an excuse for sloppiness.
---

# Pragmatism

Every principle in this marketplace is "applied pragmatically". This skill
owns what that phrase means. A principle is not true or false; it has a cost
and a payoff, and both depend on the code it is applied to. Pragmatism is the
discipline of paying for a principle only where its payoff, over the expected
life of the code, exceeds its cost. It cuts both ways: it refuses the
speculative abstraction, and it refuses the shortcut that will be paid for
ten times over.

The sibling plugins own the depth of each principle. This skill owns only the
arbitration: how much of any of them this piece of work has earned.

## The questions before any principle

Ask these in order. Their answers set the budget; the principles then spend it.

1. **How long will this code live, and who will depend on it?** Software
   engineering is programming integrated over time. A script run by one
   person for a month and a service that forty customers will pay for over a
   decade deserve different levels of rigour, and the same principle applied
   to both is wrong for one of them. Size the design to the expected lifespan
   and scale, not to the team's habits or the fashion of the year.
2. **If this decision is wrong, what does undoing it cost?** Most software
   decisions are cheaply reversible, so there is little value in agonising
   over them: decide, ship, observe, adjust. Spend the design effort, the
   second opinion, and the prototype on the few decisions that are expensive
   to reverse (a database, a public API contract, a message schema, a
   framework at the core). Good design is easier to change than bad design;
   when the future is uncertain, make the code easy to replace rather than
   trying to predict what it will need.
3. **What does carrying this cost, and what does not having it cost?** A
   presumptive feature or structure has a cost of build, a cost of delay (the
   work it displaces), a cost of carry (every future change reads and works
   around it), and a cost of repair if the guess was wrong. Weigh those
   against the cost of adding it later, which is usually smaller than feared
   when the code is easy to change. Below the design payoff line, speed can
   legitimately beat design quality; above it, the trade-off is illusory and
   the shortcut is simply debt.
4. **Do we know how this will fail?** Prefer the technology whose failure
   modes are known. New technology carries unknown unknowns, and the cost of
   operating a system for years vastly exceeds the inconvenience of building
   it with boring parts. Treat novelty as a scarce budget: spend it
   deliberately, on the one place where it buys something the boring option
   cannot.
5. **Who decides when it is good enough?** Quality is a requirement, agreed
   with the people who use and pay for the software, not a private ideal of
   the developer. Working software with rough edges today usually beats
   perfect software later. Stop when the agreed requirement is met; do not
   spoil a working program with embellishment.

## How to respond when the ask is out of proportion

Requests often carry a level of sophistication that does not match the
answers above, in either direction. Do not refuse, and do not lecture. Do this:

1. **Name the mismatch in one or two sentences, with the evidence**: the
   lifespan, the scale, the reversibility, or the operational cost that the
   request does not account for.
2. **Deliver the proportionate version in full.** The user asked for working
   software, not for a debate. Build the right-sized thing, and build it well:
   proportionate never means half-finished.
3. **Name the concrete trigger that would reopen the decision**: a signed
   second customer, a second consumer of the data, a measured throughput, a
   scheduled job replacing a manual one. A trigger keeps the door open
   without paying to hold it open.

If the user hears the concern and still wants the heavier version, build it.
Pragmatism sizes the recommendation; it does not override the decision of
the person who owns the cost.

## Small steps and learning before committing

Feedback rate is the speed limit. Take small, deliberate steps, checking for
feedback and adjusting before the next one; do not design for a future you
cannot see. When a decision is expensive to reverse, learn before committing:
a **tracer bullet** (a thin, end-to-end, kept slice that proves the shape
works) or a **prototype** (a disposable experiment that answers one question)
buys evidence far cheaper than a big design. Considering at least two
genuinely different designs before choosing one is cheap and almost always
improves the result.

## What pragmatism is not

**It is not sloppiness.** Pragmatism trades speculative structure for
speed, never correctness, tests that prevent data loss, or security at a
trust boundary. A developer who pumps out working code with no design at
all is being tactical, not pragmatic; the shortcuts compound into complexity
that slows every later change. Spend a steady fraction of effort on design
and tidying so that today's speed does not become next quarter's tax.

**It is not living with broken windows.** One tolerated hack signals that
nobody cares, and the decay accelerates. Fix or board up the broken window
when you see it. The judgement pragmatism asks for is about how much
structure to build, not about whether to keep what exists in good order.

**It is not fashion, in either direction.** Do what works, not what is
fashionable: neither the microservices the conference promoted nor the
contrarian pride of refusing every abstraction. A principle earns its place
by its payoff here, and only by that.

**It is not a licence to skip the sibling principles.** When the budget says
a principle applies, apply it fully and well, as its own plugin describes.
Half-applied hexagonal architecture costs more than none.

## Ownership map

This skill owns the sizing and the arbitration. Everything else lives with a
sibling:

- **Do less within a design** (KISS, DRY, YAGNI, the rule of three, the wrong
  abstraction) -> `simplicity-principles`. This skill decides whether the
  design deserves the effort at all; that one decides how lean it is inside.
- **Whether a design is simple enough** (the four rules, in priority order)
  -> `simple-design`.
- **Whether a pattern is earned** (when to apply, when to refuse) ->
  `design-patterns`.
- **How to keep code easy to change** (small-step mechanics, tidying) ->
  `refactoring`.
- **The security floor that is never traded away** -> `secure-coding`.
- **The rigour of any specific architecture or practice** -> its own plugin
  (`hexagonal-architecture`, `domain-driven-design`, `cqrs`, `event-sourcing`,
  `modular-monolith`, `test-driven-development`, `testing-strategy`).

## Adapt to your context

This skill stays generic on purpose. Layer your own conventions on top:

- Declare your defaults (for example "hexagonal, DDD, and TDD by default")
  in your own `CLAUDE.md`; this skill then sizes them to each piece of work
  rather than removing them.
- Declare the decisions your team considers irreversible, and the novelty
  budget it is willing to spend, so the questions above have local answers.

## Reference

For the sources, the tips and chapters behind each question, the cost
model of a presumptive feature, the tactical versus strategic distinction,
Worse is Better as a trade-off rather than a creed, a worked example sizing
the same feature at three lifespans, and detailed trade-off notes, read
`references/pragmatism.md`.
