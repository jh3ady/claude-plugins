# object-calisthenics

A Claude Code plugin that applies Jeff Bay's nine rules of object calisthenics
to the object-oriented code you write and review, pragmatically. Its value is
not re-teaching the principles behind each rule (the sibling plugins do that) but
carrying the exercise: the nine rules as concrete drills, applied strictly to
build habits and relaxed with judgement in production.

It stays generic on purpose: compose it with your own project conventions and
your team or personal rules.

## What it does

When you write or review object-oriented code, practise clean object-oriented
habits, decide how strictly to apply the rules, or spot primitive obsession,
deep nesting, message chains, or anemic objects, the bundled skill applies Bay's
nine rules as drills:

1. **One level of indentation per method**: extract nested blocks until the body is flat.
2. **Don't use the ELSE keyword**: return early with guard clauses, or dispatch through polymorphism.
3. **Wrap all primitives and strings**: give a domain primitive a type that names it and guards its invariants.
4. **First-class collections**: give a collection its own class so its behaviour has a home.
5. **One dot per line**: talk only to immediate collaborators (the Law of Demeter).
6. **Don't abbreviate**: write the full word; awkward names signal a class doing too much.
7. **Keep all entities small**: one clear responsibility per class and method.
8. **No more than two instance variables per class**: group related fields into their own objects.
9. **No getters, setters, or properties**: tell an object to act rather than pulling out its state (Tell Don't Ask).

The skill adds what the rules alone do not:

- **The exercise framing.** The rules are a training discipline, deliberately
  extreme, applied rigorously on a small greenfield project to build habits, then
  relaxed with judgement. They are guidelines, not an architectural mandate.
- **Concrete drills.** Each rule comes with the mechanics to satisfy it in
  TypeScript and the smell it targets.
- **When to relax.** Each rule has an explicit note on when softening it is the
  pragmatic choice in production.

## Relationship to other plugins

This skill owns the exercise and the drills. Each rule's underlying principle
lives in a sibling plugin:

- `clean-code`: naming (rule 6), small functions and classes (rules 1, 7), and
  encapsulation (rule 9).
- `solid-principles`: the Single Responsibility Principle and high cohesion
  behind small entities (rule 7) and the two-instance-variable bound (rule 8).
- `refactoring`: the mechanics that satisfy the rules (Extract Function, guard
  clauses, Encapsulate Collection, Hide Delegate) and the smells they target
  (Primitive Obsession, Message Chains).
- `domain-driven-design`: value objects behind wrapping primitives and
  first-class collections (rules 3, 4), and Tell Don't Ask behind no getters or
  setters (rule 9).
- `simple-design`: a complementary discipline. Simple design is the
  priority-ordered yardstick for the refactor step; object calisthenics is the
  habit-building exercise that trains the instincts it relies on.

Cross-references run both ways: this plugin points to each sibling for the
principle; the siblings point back for the drill that trains it. Nothing is
duplicated.

## Install

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install object-calisthenics@jh3ady-claude-plugins
```

## Adapt to your context

This plugin is a training discipline, not a dogma. Layer your own conventions on
top: decide which rules your team keeps as standing conventions and which stay
training-only, record exceptions with a reason, and configure naming, module,
and architecture rules in your own `CLAUDE.md` or a higher-priority skill. The
plugin does not impose them.

## License

Released under the [MIT License](LICENSE).
