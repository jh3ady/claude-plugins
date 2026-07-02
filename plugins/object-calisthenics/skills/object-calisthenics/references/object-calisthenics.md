# Object calisthenics reference

The detailed reference behind the skill: the origin, and for each of the nine
rules the smell it targets, a TypeScript before/after drill, when relaxing it is
the pragmatic choice, and the sibling that owns the underlying principle.

Standards and sources:
- Jeff Bay, "Object Calisthenics", in *The ThoughtWorks Anthology* (Pragmatic
  Bookshelf, 2008): the original nine rules and the exercise framing.
- [Object Calisthenics - William Durand](https://williamdurand.fr/2013/06/03/object-calisthenics/):
  a widely used summary of the nine rules and their rationale.
- The rules restate principles owned by the sibling plugins; each rule below
  names its owner.

---

## The exercise

Bay presented object calisthenics as an exercise, not a rulebook. The nine rules
are intentionally severe; the discipline is to apply them without compromise on
a small, new object-oriented project (commonly cited as the first thousand lines
or so) so that better instincts become automatic. Afterwards, in real code, the
rules are relaxed with judgment: they are guidelines aimed at readability,
maintainability, and encapsulation at a granular level, not architectural
mandates. The point of the strict phase is the muscle it builds, not permanent
adherence.

The rules compound. Small entities (rule 7), at most two instance variables
(rule 8), wrapped primitives (rule 3), and no getters (rule 9) push together
toward value objects and Tell Don't Ask; one dot per line (rule 5) reinforces
the same encapsulation from the calling side. Doing them together is what makes
the exercise more than the sum of nine constraints.

---

## Rule 1: One level of indentation per method

**Smell.** Nested loops and conditionals in one method; the eye has to track
several levels of scope at once.

**Drill.** Extract each inner block into a named method until the body is flat.

```typescript
// Before
function report(teams: Team[]): string[] {
  const lines: string[] = [];
  for (const team of teams) {
    for (const player of team.players) {
      if (player.isActive) {
        lines.push(`${team.name}: ${player.name}`);
      }
    }
  }
  return lines;
}

// After
function report(teams: Team[]): string[] {
  return teams.flatMap((team) => activeLines(team));
}

function activeLines(team: Team): string[] {
  return team.players
    .filter((player) => player.isActive)
    .map((player) => `${team.name}: ${player.name}`);
}
```

**When to relax.** A single, shallow extra level in an otherwise tiny method is
not worth a new name. Extract when the nesting hides intent, not on reflex.

**Owner.** `refactoring` (Extract Function) and `clean-code` (small functions).

## Rule 2: Don't use the ELSE keyword

**Smell.** Conditional ladders where each branch mutates a shared result; the
happy path is buried.

**Drill.** Return early with guard clauses, or dispatch through polymorphism or a
lookup, so each path reads top to bottom.

```typescript
// Before
function fee(account: Account): number {
  let result;
  if (account.isClosed) {
    result = 0;
  } else if (account.isPremium) {
    result = 5;
  } else {
    result = 10;
  }
  return result;
}

// After
function fee(account: Account): number {
  if (account.isClosed) return 0;
  if (account.isPremium) return 5;
  return 10;
}
```

**When to relax.** A single balanced `if/else` returning two values can be
clearer than two returns, and a ternary is fine for a small expression. The
target is shallow, readable flow, not the literal absence of the keyword.

**Owner.** `refactoring` (Replace Nested Conditional with Guard Clauses,
Decompose Conditional, Replace Conditional with Polymorphism).

## Rule 3: Wrap all primitives and strings

**Smell.** Primitive obsession: a `number` or `string` that carries domain
meaning and rules travels the code raw, unvalidated and interchangeable with any
other primitive.

**Drill.** Wrap it in a small type that names the concept and guards its
invariants.

```typescript
// Before
function transfer(amountInCents: number): void { /* ... */ }

// After
class Money {
  private constructor(private readonly cents: number) {}

  static ofCents(cents: number): Money {
    if (!Number.isInteger(cents) || cents < 0) {
      throw new Error("Money must be a non-negative integer number of cents");
    }
    return new Money(cents);
  }

  plus(other: Money): Money {
    return new Money(this.cents + other.cents);
  }
}

function transfer(amount: Money): void { /* ... */ }
```

**When to relax.** A primitive with no rules and no domain meaning (a loop
counter, a raw flag with no invariant) does not need a wrapper. Wrap concepts,
not every scalar.

**Owner.** `domain-driven-design` (value objects) and `refactoring` (the
Primitive Obsession smell).

## Rule 4: First-class collections

**Smell.** A class holds a raw array plus the logic that operates on it, and that
logic leaks to every caller that touches the array.

**Drill.** Give the collection its own class, so its behaviour has a home and the
raw array stays private.

```typescript
// Before
class Team {
  readonly players: Player[] = [];
}
// callers write: team.players.filter(p => p.isActive).length

// After
class Roster {
  constructor(private readonly players: Player[]) {}

  activeCount(): number {
    return this.players.filter((player) => player.isActive).length;
  }

  add(player: Player): Roster {
    return new Roster([...this.players, player]);
  }
}

class Team {
  constructor(private readonly roster: Roster) {}
}
```

**When to relax.** A short-lived local array inside one method needs no wrapper.
The rule targets collections that are fields with behaviour, not every array.

**Owner.** `refactoring` (Encapsulate Collection) and `domain-driven-design`
(a collection wrapper is often a value object).

## Rule 5: One dot per line

**Smell.** Message chains: `order.getCustomer().getAddress().getCity()`. The
caller knows the shape of objects two or three hops away and breaks when any of
them changes.

**Drill.** Talk only to immediate collaborators; ask the neighbour to answer the
question (the Law of Demeter).

```typescript
// Before
const city = order.getCustomer().getAddress().getCity();

// After
const city = order.shippingCity();
// Order asks its Customer, which asks its Address; each hop stays local.
```

**When to relax.** Fluent builders and pipelines (`query.where(...).orderBy(...)`)
and standard library chains return the same abstraction at each step and do not
violate Demeter; the rule targets reaching through foreign object graphs, not
method chaining as such.

**Owner.** `clean-code` and `refactoring` (the Message Chains smell, Hide
Delegate).

## Rule 6: Don't abbreviate

**Smell.** Shortened names (`calc`, `mgr`, `svc`, `e`). Either the name is used
so often that it hints at duplication, or it is hard to name in full because the
thing does too much.

**Drill.** Write the full word. If the full name is awkwardly long, the fix is
usually a better-scoped class, not a shorter name.

```typescript
// Before
function calcTot(ords: Order[]): number { /* ... */ }

// After
function calculateTotal(orders: Order[]): number { /* ... */ }
```

**When to relax.** Established domain and convention names stay: `id`, `url`,
`http`, a loop `i` in a tiny scope. Clarity is the goal, not verbosity for its
own sake.

**Owner.** `clean-code` (naming).

## Rule 7: Keep all entities small

**Smell.** A class or method has grown long enough that no one holds it in their
head at once.

**Drill.** Split by responsibility. In the exercise, aim for short methods, short
classes, and few classes per package, so each unit has a single clear job.

**When to relax.** The specific line counts Bay suggests are training targets,
not production law. Keep the intent (one clear responsibility per unit) and let
the exact size follow the domain.

**Owner.** `clean-code` (small functions and classes) and `solid-principles`
(the Single Responsibility Principle).

## Rule 8: No more than two instance variables per class

**Smell.** A class with many fields is usually several concepts fused together,
with low cohesion.

**Drill.** Group related fields into their own objects until each class holds at
most two. This is the most aggressive rule; its purpose is to force the
extraction of hidden concepts.

```typescript
// Before
class User {
  constructor(
    private firstName: string,
    private lastName: string,
    private street: string,
    private city: string,
    private postalCode: string,
  ) {}
}

// After
class User {
  constructor(
    private readonly name: FullName,
    private readonly address: Address,
  ) {}
}
```

**When to relax.** Two is a deliberately severe training bound. In production the
real target is high cohesion; a class with three genuinely cohesive fields is
fine. Use the rule to discover extractions, not to ban a third field on
principle.

**Owner.** `solid-principles` (SRP, high cohesion).

## Rule 9: No getters, setters, or properties

**Smell.** Anemic objects: code pulls an object's state out to make a decision
that the object should make itself (feature envy).

**Drill.** Move the behaviour to the object that owns the data; tell it to act
rather than asking for its state (Tell Don't Ask).

```typescript
// Before
if (account.getBalance() < amount.getValue()) {
  throw new Error("Insufficient funds");
}
account.setBalance(account.getBalance() - amount.getValue());

// After
account.withdraw(amount); // Account checks its own balance and throws if short.
```

**When to relax.** Data transfer objects, serialization boundaries, and view
models legitimately expose data; some frameworks and ORMs require accessors.
Apply the rule to domain objects that have behaviour, and let boundary data
structures be plain.

**Owner.** `clean-code` and `domain-driven-design` (Tell Don't Ask, a rich
domain model that encapsulates its state).

---

## Pairing with simple design

Object calisthenics and `simple-design` are complementary craft disciplines.
Simple design is the priority-ordered yardstick applied during the refactor step
(passes the tests, reveals intention, no duplication, fewest elements); object
calisthenics is a habit-building exercise whose concrete constraints train the
instincts that make a design reveal intention and stay small. Do the exercise to
build the habits; use simple design as the running standard once they are
internalised.
