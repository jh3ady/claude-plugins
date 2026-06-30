# refactoring

A Claude Code plugin that encodes Martin Fowler's *Refactoring*, 2nd ed. (with Kent Beck, 2018) in three matched skills: one for the method (the discipline of improving design without changing observable behaviour), one for diagnosing code smells (the 24 patterns from Chapter 3 that signal structural problems), and one for the catalogue of named moves (the complete set of refactorings grouped by the book's seven chapters). Together they cover the full cycle: recognising when to refactor, diagnosing which move to apply, and executing it safely with a test net in place.

It stays generic on purpose: compose it with your own team conventions for naming, step size, and preferred moves in your language or framework.

## What it does

When you want to improve the internal structure of existing code without changing its observable behaviour, need to diagnose a structural problem and choose the right move, or want to apply a specific named refactoring safely, the three bundled skills apply together. The method skill covers the discipline; the code-smells skill covers the diagnostic signals; the catalogue skill covers the mechanics of each named move.

### refactoring-method

When you are improving the design of existing code and need to know how to approach the work, when to refactor, or how to execute a series of behaviour-preserving steps safely, this skill applies:

- Definition: a refactoring (noun) is a specific change to the internal structure of software that does not change its observable behaviour; to refactor (verb) is to restructure by applying a series of such changes.
- The two hats: adding function and refactoring are distinct modes that cannot be mixed in a single step; when both happen together, any test failure becomes untraceable.
- When to refactor: opportunistic modes (preparatory, comprehension, litter-pickup) cover most refactoring; the rule of three gives duplication a bounded lease before an abstraction is due; planned sessions are the exception, not the default.
- Self-testing code as prerequisite: refactoring without a test net is guesswork; if the code lacks tests, apply the `legacy-code` skill first to establish a characterization test net, then return here.
- Small-step mechanics: compile and run the full test suite after each move; if any test fails, undo immediately and diagnose before proceeding; reversibility is the point.

### code-smells

When you recognise a structural problem in code and need to name it and identify which refactoring moves address it, this skill applies:

- 24 named smells from Chapter 3 (co-authored with Kent Beck) grouped into five families: Bloaters (code grown too large to understand comfortably), Object-orientation abusers (misuse of object-oriented mechanisms), Change preventers (forces that make a single logical change cascade across many edits), Dispensables (code that adds no value and should be removed), and Couplers (excessive or inappropriate dependencies between classes).
- Each smell names the signal, explains why it hurts, and points to the specific named refactorings from the catalogue that address it.
- Smells are triggers for investigation, not mandates to refactor; context determines whether and how to act, and the rule of three applies.

### refactoring-catalog

When you know which move to apply and need its condensed mechanics or a TypeScript example, this skill applies. Every chapter carries condensed mechanics and TypeScript examples:

- A first set of refactorings (Chapter 6): the everyday moves Fowler reaches for most often, including Extract Function, Inline Function, Extract Variable, Introduce Parameter Object, Combine Functions into Class, and Split Phase.
- Encapsulation (Chapter 7): moves that tighten access boundaries, including Encapsulate Record, Replace Primitive with Object, Extract Class, and Hide Delegate.
- Moving features (Chapter 8): moves that relocate code to where it belongs, including Move Function, Move Field, Split Loop, and Replace Loop with Pipeline.
- Organizing data (Chapter 9): moves that improve how data is named, scoped, and represented, including Split Variable, Replace Derived Variable with Query, and Change Reference to Value.
- Simplifying conditional logic (Chapter 10): moves that make branches easier to read, including Decompose Conditional, Replace Nested Conditional with Guard Clauses, and Replace Conditional with Polymorphism.
- Refactoring APIs (Chapter 11): moves that make functions easier and safer to call, including Separate Query from Modifier, Remove Flag Argument, and Replace Function with Command.
- Dealing with inheritance (Chapter 12): moves that restructure class hierarchies, including Pull Up Method, Replace Type Code with Subclasses, and Replace Subclass with Delegate.

## Relationship to other plugins

- `test-driven-development`: refactoring is the third step of red-green-refactor; the self-testing code discipline that TDD establishes is the prerequisite for safe refactoring. The two skills compose naturally: TDD governs when and what to write; this plugin governs how to improve structure once the bar is green.
- `legacy-code`: when the code to be refactored has no tests, that plugin covers how to install a characterization test net first via seams and enabling points. Once the bar is green, the refactoring plugin takes over as a peer discipline. Refactoring is the step that `legacy-code` explicitly delegates to; the two are independent, applied in sequence rather than in hierarchy.
- `clean-code`: many code smells name what clean code avoids; Mysterious Name and Long Function are central `clean-code` concerns. Refactoring is the mechanical how; clean code names the target quality.
- `solid-principles`: smells such as Feature Envy and Insider Trading signal violations of the Single Responsibility and Dependency Inversion principles. Refactoring moves such as Extract Class and Move Function are mechanical applications of these principles under the constraint of existing code. The smells point toward the principles; refactoring is the mechanism for reaching them.
- `simplicity-principles`: Duplicated Code, Lazy Element, and Speculative Generality are the targets that YAGNI, DRY, and KISS work to prevent. Refactoring is the how; simplicity principles name the destination.

## Install

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install refactoring@jh3ady-claude-plugins
```

## Adapt to your context

This plugin is a baseline, not a dogma. Your team will have its own conventions for naming extracted functions, agreed limits on step size before committing, preferred moves in your language or framework, and thresholds for tolerating certain smells (longer functions in test files, accepted global configuration constants, or Data Classes kept as simple value containers). Declare those in your own `CLAUDE.md` or a higher-priority skill. The plugin does not impose them.

## License

Released under the [MIT License](LICENSE).
