# Simple design reference

The detailed reference behind the skill: the canonical origin, each rule's one
crucial nuance, the ordering question, a worked TypeScript example applying the
four rules in sequence, and trade-off notes.

Standards and sources:
- Kent Beck, *Extreme Programming Explained: Embrace Change* (1999): the XP
  practice of simple design and the original formulation of the rules.
- [Beck Design Rules - Martin Fowler's bliki](https://martinfowler.com/bliki/BeckDesignRules.html):
  the four rules in priority order, and the note on the order of the middle two.
- [XP Simplicity Rules - c2 wiki](https://wiki.c2.com/?XpSimplicityRules):
  the older wiki formulation ("runs all the tests", "no duplication", "reveals
  intention", "fewest elements").
- Corey Haines, *Understanding the Four Rules of Simple Design* (2014): the
  book-length treatment that popularised, for the four rules, the emphasis on
  duplication of knowledge rather than of text (rooted in DRY as stated by Hunt
  and Thomas), built on the Conway's Game of Life exercise.
- Robert C. Martin, *Clean Code* (2008): lists the same rules but orders
  "no duplication" before "reveals intention".

---

## Origin and the canonical formulation

Kent Beck introduced simple design as an Extreme Programming practice: rather
than design the whole system up front, keep the design of the code that exists
as simple as possible, and let the design of the system emerge through
continuous refactoring. He gave four criteria for "simple". Martin Fowler
states them, in priority order, as:

1. Passes the tests
2. Reveals intention
3. No duplication
4. Fewest elements

Beck's own wording in *Extreme Programming Explained* is more verbose and has
been paraphrased many ways; an older c2 wiki version orders the middle two rules
differently. Fowler's four-line statement above is the form in common use, and
the one this plugin adopts.

The rules describe a property of code, checked and improved continuously, not a
phase of a project. Simple design is the target of the refactor step of the
red-green-refactor loop (see `test-driven-development` and `refactoring`).

## The rules, each with its crucial nuance

### 1. Passes the tests

The design must do what it is supposed to do, and that behaviour must be
verified. An elegant design that does not work is worthless; correctness is the
non-negotiable floor. This rule is why simple design presupposes self-testing
code: without tests, the other three rules cannot be pursued safely, because
every change risks silent breakage.

Owned in depth by `test-driven-development` (writing the failing test first,
keeping code self-testing) and `refactoring` (never refactor without a green
suite).

### 2. Reveals intention

The code should make its intent obvious to the next reader: what it does and
why, not merely how. This is about names, shapes, and structure that
communicate. The nuance: "reveals intention" is measured against a human
reader, not a compiler. Code that is correct and free of duplication can still
fail this rule by being cryptic.

Owned in depth by `clean-code` (naming, intent-revealing code and comments).

### 3. No duplication

Every piece of knowledge should have a single, authoritative representation.
The one distinction that matters when arbitrating: this is duplication of
**knowledge**, not of **text**, so similar-looking code is not necessarily
duplicated. The depth (the rule of three, duplication versus the wrong
abstraction) is owned by `simplicity-principles`; defer to it rather than
re-deriving the nuance here.

### 4. Fewest elements

Remove any class, method, or layer of indirection that the first three rules do
not require. Two boundaries keep this rule from being misread, and they are this
plugin's to draw: "fewest elements" targets the fewest moving parts (concepts,
indirections), not the fewest characters, so it is not code golf; and it removes
superfluous structure that exists **now**, which is distinct from YAGNI's
refusal to build structure for a speculative **future** need. A seam the current
design genuinely relies on is not a superfluous element. The YAGNI side is owned
by `simplicity-principles`; the mechanics of safe removal by `refactoring`.

## The ordering question

The rules are in **priority order**: "passes the tests" takes precedence over
everything, so correctness is never traded for any of the other three.

The order of the middle two rules is contested, and deliberately so. Fowler
puts "reveals intention" before "no duplication" and considers the choice
immaterial:

> "I've always seen their order as unimportant, since they feed off each other
> in refining the code."

Robert C. Martin, in *Clean Code*, lists "no duplication" before "reveals
intention". The disagreement does not matter in practice: removing duplication
usually clarifies intent, and clarifying intent usually exposes real
duplication. This plugin adopts Fowler's order as its default and treats the
2-3 sequence as not worth fighting over.

For the rare genuine conflict, Beck's tie-breaker (quoted by Fowler) is
explicit:

> "In the rare case they are in conflict (in tests are the only examples I can
> recall), empathy wins over some strictly technical metric."

Optimise for the next reader, not for a metric.

## Worked example: the four rules in sequence

A single refactoring, applied to working code, driven up the rules in order.

### Starting point (rule 1 already satisfied)

The function works and is covered by tests, so rule 1 holds. But the intent is
opaque, the VAT rate is duplicated, and the branches repeat the same
calculation.

```typescript
function total(
  lines: { price: number; qty: number }[],
  vip: boolean,
): number {
  let s = 0;
  for (const l of lines) s += l.price * l.qty;
  if (vip) return s - s * 0.1 + (s - s * 0.1) * 0.2;
  return s + s * 0.2;
}
```

### Rule 2: reveal intention

Name the concepts the code is really about: line amounts, a subtotal, a VIP
discount, VAT. The reader should now see the domain, not arithmetic.

```typescript
function orderTotal(lines: OrderLine[], customerIsVip: boolean): number {
  const subtotal = lines.reduce(
    (sum, line) => sum + line.price * line.quantity,
    0,
  );
  const discounted = customerIsVip ? subtotal - subtotal * 0.1 : subtotal;
  return discounted + discounted * 0.2;
}
```

### Rule 3: remove duplication of knowledge

The VAT rate (0.2) and the VIP discount rate (0.1) are knowledge. Give each a
single authoritative source, and express "apply VAT" once.

```typescript
const VAT_RATE = 0.2;
const VIP_DISCOUNT_RATE = 0.1;

function orderTotal(lines: OrderLine[], customerIsVip: boolean): number {
  const subtotal = lines.reduce(
    (sum, line) => sum + line.price * line.quantity,
    0,
  );
  const discounted = customerIsVip
    ? subtotal * (1 - VIP_DISCOUNT_RATE)
    : subtotal;
  return discounted * (1 + VAT_RATE);
}
```

### Rule 4: fewest elements

Extract the two ideas that now earn a name of their own (summing line amounts,
applying VAT), and stop there. No speculative `PricingStrategy` interface, no
configuration object for a single rate: those would be elements the current
requirement does not need.

```typescript
const VAT_RATE = 0.2;
const VIP_DISCOUNT_RATE = 0.1;

function orderTotal(lines: OrderLine[], customerIsVip: boolean): number {
  const subtotal = sumLineAmounts(lines);
  const discounted = customerIsVip
    ? subtotal * (1 - VIP_DISCOUNT_RATE)
    : subtotal;
  return withVat(discounted);
}

function sumLineAmounts(lines: OrderLine[]): number {
  return lines.reduce((sum, line) => sum + line.price * line.quantity, 0);
}

function withVat(amount: number): number {
  return amount * (1 + VAT_RATE);
}
```

Each step moved up exactly one rule, on code that stayed green throughout. The
final design was not planned in advance; it emerged from applying the rules.

## Trade-off notes

**Intention versus duplication.** When deduplicating would obscure meaning, or
two fragments look alike but encode different decisions, prefer intention and
leave the apparent duplication. Similar-looking code is not duplicated
knowledge. This is the practical face of "duplication is far cheaper than the
wrong abstraction" (Sandi Metz); see `simplicity-principles` for the full
treatment and the rule of three as the pacing mechanism for extraction.

**Fewest elements versus useful seams.** Rule 4 targets superfluous structure,
not every abstraction. A port that isolates the domain from infrastructure (see
`hexagonal-architecture`) or a seam introduced to get legacy code under test
(see `legacy-code`) is an element the current design relies on, not dead weight.
Removing a genuinely load-bearing seam in the name of "fewest elements" trades a
real need for a count. The mechanics of safe removal, when an element truly is
superfluous, belong to `refactoring`.

**Emergent design versus no design.** Simple design does not mean zero
forethought; it means the detailed structure emerges from refactoring rather
than from big up-front design. High-level architecture decisions (bounded
contexts, module boundaries) still belong up front and are owned by the
architecture plugins. Simple design governs the shape of the code within those
boundaries.

**Simple design as a whole.** The four rules reinforce one another: tests make
change safe, intention keeps the code readable, no-duplication keeps knowledge
single-sourced, fewest-elements keeps the whole honest. Applied together during
the refactor step, in priority order, they are how a simple design is reached
and kept, one small step at a time.
