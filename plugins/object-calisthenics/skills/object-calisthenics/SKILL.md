---
name: object-calisthenics
description: This skill should be used when practising or drilling clean object-oriented habits, when deciding how strictly to apply the nine rules, when recognising primitive obsession, deep nesting, message chains, or anemic objects, or when writing or reviewing object-oriented code, applying Jeff Bay's object calisthenics, even when they are not explicitly mentioned. It carries the exercise framing and the concrete drill for each rule; each rule's underlying principle is owned by a sibling plugin.
---

# Object calisthenics

Jeff Bay's nine rules are a training discipline, not a competing principle set.
They are deliberately extreme: apply them rigorously as an exercise to build
object-oriented habits (Bay's framing is a small greenfield project, on the
order of the first thousand lines), then relax them with judgement in production.
They are guidelines that sharpen instincts, not an architectural mandate.

Each rule trains a principle that a sibling plugin owns in depth (see the
ownership map). This skill owns the exercise and the concrete drill for each
rule: how to satisfy it, and when relaxing it is the right call.

## The nine rules

Stated as drills. In the exercise, apply each without compromise.

1. **One level of indentation per method**: a method nests loops and
   conditionals -> extract the inner blocks into named methods until the body is
   flat.
2. **Don't use the ELSE keyword**: an `else` (or an `else if` ladder) carries
   the alternative path -> return early with guard clauses, or use polymorphism
   or a lookup, so each path is a straight line.
3. **Wrap all primitives and strings**: a bare `number`, `string`, or `boolean`
   carries domain meaning and rules -> wrap it in a small type that names the
   concept and guards its invariants.
4. **First-class collections**: a class holds a collection plus logic that
   operates on it -> give the collection its own class, so its behaviour has a
   home.
5. **One dot per line**: a line reaches through one object to another
   (`a.getB().getC().do()`) -> talk only to immediate collaborators; ask the
   neighbour to do the work (Law of Demeter).
6. **Don't abbreviate**: a name is shortened (`calc`, `mgr`, `e`) -> write the
   full word; a name that is hard to write in full usually signals a class doing
   too much.
7. **Keep all entities small**: a class or method has grown long -> split it;
   in the exercise, aim for short classes and short methods, few per package.
8. **No more than two instance variables per class**: a class accumulates
   fields -> group related fields into their own objects, forcing high cohesion.
9. **No getters, setters, or properties**: code pulls state out to decide for
   an object -> tell the object to act on its own state (Tell Don't Ask).

## When to relax

The rules are a whetstone, not a cage. Once the habits are internalised,
production code keeps the ones that pay their way: wrapping a genuinely
meaningful primitive, flattening a tangled conditional, telling instead of
asking. Others soften against real constraints: a data transfer object at a
boundary may expose fields; a third instance variable may be the honest shape of
a concept; a framework may require accessors. Relaxing a rule is a judgement
call, made from having done the exercise, not an excuse to skip it.

## Ownership map

This skill owns the exercise and the drills. Each rule's principle lives
elsewhere:

- **Rules 1, 2** (indentation, no else) -> `refactoring` (Decompose Conditional,
  Replace Nested Conditional with Guard Clauses, Extract Function) and
  `clean-code` (small functions).
- **Rules 3, 4** (wrap primitives, first-class collections) ->
  `domain-driven-design` (value objects) and `refactoring` (the Primitive
  Obsession smell, Encapsulate Collection).
- **Rule 5** (one dot per line) -> `clean-code` and `refactoring` (the Message
  Chains smell, Hide Delegate) for the Law of Demeter.
- **Rule 6** (don't abbreviate) -> `clean-code` (naming).
- **Rule 7** (small entities) -> `clean-code` (small functions and classes) and
  `solid-principles` (the Single Responsibility Principle).
- **Rule 8** (two instance variables) -> `solid-principles` (SRP, high cohesion).
- **Rule 9** (no getters/setters) -> `clean-code` and `domain-driven-design`
  (Tell Don't Ask, a rich domain model that encapsulates its state).

Pairs with `simple-design`: that skill is the priority-ordered yardstick for the
refactor step; this one is the habit-building exercise that feeds it.

## Adapt to your context

This skill stays generic on purpose. Layer your own conventions on top:

- Decide which rules your team applies as standing conventions and which stay
  training-only, and record the exceptions with a reason.
- Add naming, module, and architecture rules in your own `CLAUDE.md` or a
  higher-priority skill. This skill does not impose them.

## Reference

For the origin and sourcing, each rule's target smell, a TypeScript before/after
drill, its "when to relax" note and the sibling that owns the underlying
principle, and how the rules compound, read `references/object-calisthenics.md`.
