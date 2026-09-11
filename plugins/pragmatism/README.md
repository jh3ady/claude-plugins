# jh3ady-pragmatism

A Claude Code plugin that sits above every other principle in this
marketplace and decides how much of each a piece of work has earned. Every
sibling plugin says it is "applied pragmatically"; this one owns what that
means: a principle is paid for where its payoff, over the expected life of
the code, exceeds its cost, and not elsewhere.

It stays generic on purpose: compose it with your own project conventions and
your team or personal defaults.

## What it does

When you decide how much design, architecture, abstraction, process, or
technology a task deserves, when a request asks for more or less structure
than its lifespan justifies, when you choose a technology, when you judge
whether software is good enough to ship, or when you review code for
over-engineering or under-engineering, the bundled skill asks five questions
before any principle is applied:

1. **How long will this code live, and who will depend on it?** Software
   engineering is programming integrated over time; size the design to the
   expected lifespan and scale.
2. **If this decision is wrong, what does undoing it cost?** Decide cheaply
   reversible things fast; spend the design effort and the prototype on the
   few irreversible ones. Prefer code that is easy to replace over code that
   predicts the future.
3. **What does carrying this cost, and what does not having it cost?** Build,
   delay, carry, and repair, weighed against adding it later, with the design
   payoff line as the boundary between a legitimate shortcut and debt.
4. **Do we know how this will fail?** Boring technology with known failure
   modes first; novelty as a scarce budget spent deliberately.
5. **Who decides when it is good enough?** Quality is a requirement agreed
   with users, not the developer's private ideal; stop when it is met.

The skill also carries:

- **A response pattern for out-of-proportion requests.** Name the mismatch
  with evidence, deliver the proportionate version in full, name the concrete
  trigger that would reopen the decision. Never refuse, never lecture, and
  build the heavier version if the owner of the cost still wants it.
- **Small steps, tracer bullets, prototypes, and design it twice** as the
  ways to learn before committing to an expensive decision.
- **What pragmatism is not**: not sloppiness (the tactical tornado), not
  broken windows, not fashion in either direction, and not a licence to
  half-apply a principle that does belong.

## Sources

The Pragmatic Programmer (Thomas and Hunt, 20th Anniversary Edition), A
Philosophy of Software Design (Ousterhout), Software Engineering at Google
(Winters, Manshreck, Wright), Tidy First? (Beck), Choose Boring Technology
(McKinley), The Rise of Worse is Better (Gabriel), and Martin Fowler's bliki
entries on Yagni, the Design Stamina Hypothesis, and Technical Debt. Each is
cited, with links, in the bundled reference.

## Relationship to other plugins

This skill owns the sizing and the arbitration. Everything else lives in a
sibling:

- `simplicity-principles`: owns KISS, DRY, and YAGNI, the rule of three, and
  duplication versus the wrong abstraction: how lean a design is inside, once
  this skill has decided the design is worth the effort at all.
- `simple-design`: owns whether a design is simple enough, through Kent
  Beck's four rules in priority order.
- `design-patterns`: owns whether a pattern is earned, and when to refuse one.
- `refactoring`: owns the small-step mechanics and tidyings that keep code
  easy to change.
- `secure-coding`: owns the security floor that pragmatism never trades away.
- Each architecture or practice plugin (`hexagonal-architecture`,
  `domain-driven-design`, `cqrs`, `event-sourcing`, `modular-monolith`,
  `test-driven-development`, `testing-strategy`) owns its own rigour once
  this skill has sized it in.

Cross-references run both ways: this plugin points to each sibling for depth;
the siblings say "applied pragmatically" and point back here for what that
means.

## Install

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install jh3ady-pragmatism@jh3ady-claude-plugins
```

## Adapt to your context

This plugin is a baseline judgement, not a dogma. Declare your own defaults
(for example "hexagonal, DDD, and TDD by default") in your `CLAUDE.md`, and
this skill sizes them to each piece of work rather than removing them. Declare
the decisions your team treats as irreversible and the novelty budget it is
willing to spend, so the five questions have local answers.

## License

Released under the [MIT License](LICENSE).
