# Simplicity principles reference

The detailed reference behind the skill: canonical definitions, before/after
examples, and trade-off notes for KISS, DRY, and YAGNI.

Standards and sources:
- Andy Hunt and Dave Thomas, *The Pragmatic Programmer* (1999): the canonical
  DRY formulation.
- [KISS principle - Wikipedia](https://en.wikipedia.org/wiki/KISS_principle):
  origin, Kelly Johnson and Lockheed Skunk Works.
- [Don't repeat yourself - Wikipedia](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself):
  full DRY definition and the WET counterpart.
- [You aren't gonna need it - Wikipedia](https://en.wikipedia.org/wiki/You_aren%27t_gonna_need_it):
  YAGNI and its XP context.
- [The Wrong Abstraction - Sandi Metz (2016)](https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction):
  "Duplication is far cheaper than the wrong abstraction."
- [Simple Made Easy - Rich Hickey (InfoQ, Strange Loop 2011)](https://www.infoq.com/presentations/Simple-Made-Easy/):
  the simple/easy distinction and why simplicity must be constructed.
- [Yagni - Martin Fowler's bliki](https://martinfowler.com/bliki/Yagni.html):
  the four costs YAGNI avoids and when extensibility is still warranted.
- [Rule of three - Wikipedia](https://en.wikipedia.org/wiki/Rule_of_three_%28computer_programming%29):
  credited to Don Roberts, popularized by Martin Fowler in *Refactoring*.

---

## KISS: Keep It Simple, Stupid

"Keep it simple, stupid." Kelly Johnson, Lockheed Skunk Works, c. 1960.
U.S. Navy formalized "Project KISS" in 1960.

The origin is practical: Johnson handed design engineers a handful of tools
and required that the jet aircraft they were designing be repairable by an
average mechanic in field combat conditions using only those tools. Simplicity
was not an aesthetic preference; it was a survival constraint.

Albert Einstein's paraphrase captures the balance: "Make everything as simple
as possible, but not simpler."

### Smell

```python
def calculate_discount(order):
    # "Clever" solution using lambda, reduce, and bit operations
    discount = (
        lambda o: __import__('functools').reduce(
            lambda acc, item: acc + (item['price'] * (0.1 if o['tier'] & 1 else 0.05)),
            o['items'], 0
        )
    )(order)
    return round(discount, 2)
```

Technically correct, but the conditional logic and the tooling choice are
harder to read and debug than the problem requires.

### Fix

```python
def calculate_discount(order):
    rate = 0.10 if order['tier'] == 1 else 0.05
    discount = sum(item['price'] * rate for item in order['items'])
    return round(discount, 2)
```

The problem is the same; the solution exposes its intent.

### Trade-off: simple is not simplistic, and not the same as easy

"Simple" in the Kelly Johnson sense means the minimum complexity to meet the
actual need, no more. It does not mean "naive" or "easy to write." Rich
Hickey's distinction is useful here ([Simple Made Easy, Strange Loop 2011](https://www.infoq.com/presentations/Simple-Made-Easy/)): easy means familiar or close at hand;
simple means not compound, not entangled. Easy code can be deeply complex.
Simple code can be hard to write.

KISS guards against accidental cleverness: complexity introduced through
premature generalization, over-abstraction, or choosing a sophisticated tool
where a plain one would suffice. It does not guard against essential complexity;
some problems are inherently complex, and an honest representation of that
complexity is not a KISS violation.

The failure mode is over-engineering -- adding machinery that the current
requirement does not need, justified by anticipation. Anticipation is best
addressed by YAGNI; KISS is about the implementation choice once the scope is
settled.

---

## DRY: Don't Repeat Yourself

"Every piece of knowledge must have a single, unambiguous, authoritative
representation within a system." Andy Hunt and Dave Thomas, *The Pragmatic
Programmer*, 1999.

Hunt and Thomas applied the principle broadly: database schemas, test plans,
the build system, documentation, and source code. The target is knowledge
(semantically meaningful decisions), not text.

The WET counterpart: "write everything twice" (or "waste everyone's time").
A WET codebase defines the same concept -- a "comment" field -- across an
HTML label, a form input name, a variable name, a function parameter, and a
database column: five places to update when the concept changes.

### Smell

```typescript
function calculateTax(price: number): number {
  return price * 0.2; // VAT rate
}

function calculateShipping(weight: number): number {
  const vatRate = 0.2; // same knowledge, second place
  return weight * 5 * (1 + vatRate);
}

function printInvoice(price: number, weight: number): string {
  const tax = price * 0.2; // third place
  const shipping = weight * 5 * 1.2;
  return `Price: ${price}, Tax: ${tax}, Shipping: ${shipping}`;
}
```

The VAT rate (0.2) is knowledge. It appears in three places; a rate change
requires three edits and risks the three copies diverging.

### Fix

```typescript
const VAT_RATE = 0.2;

function calculateTax(price: number): number {
  return price * VAT_RATE;
}

function calculateShipping(weight: number): number {
  return weight * 5 * (1 + VAT_RATE);
}

function printInvoice(price: number, weight: number): string {
  const tax = calculateTax(price);
  const shipping = calculateShipping(weight);
  return `Price: ${price}, Tax: ${tax}, Shipping: ${shipping}`;
}
```

One authoritative source for the VAT rate; the rest derive from it.

### Trade-off: the rule of three and the wrong abstraction

This is the most important nuance in DRY. The principle targets knowledge, not
textual similarity. Two functions that share a loop shape but represent distinct
domain concepts should NOT be merged; merging couples them. The resulting
shared function grows conditionals every time the concepts diverge, which they
will.

Sandi Metz named this failure pattern precisely:

> "Duplication is far cheaper than the wrong abstraction."

The pattern she describes: a programmer extracts duplication and names an
abstraction. A new requirement makes the abstraction "almost" right. Rather
than reconsidering, the next programmer adds a parameter and a conditional.
Each new requirement adds more conditions. Eventually the code is
incomprehensible -- a condition-laden procedure mixing vaguely related ideas.
The fastest way forward, at that point, is back: inline the abstraction into
every caller, remove the irrelevant parts, and start fresh with current
understanding.

The rule of three (Don Roberts, popularized by Martin Fowler in *Refactoring*)
operationalizes the caution: the first instance is concrete, the second is a
warning, the third usually justifies extraction. Two similar-looking functions
may represent genuinely distinct knowledge. A third instance is usually enough
evidence of a real shared concept to make the abstraction's shape clear.

AHA (Avoid Hasty Abstractions, Kent C. Dodds) restates the corollary: prefer
duplication over a wrong abstraction; extract when the right abstraction is
evident.

DRY is about a single source of truth for knowledge, not the mechanical
removal of similar-looking code.

---

## YAGNI: You Aren't Gonna Need It

"Always implement things when you actually need them, never when you just
foresee that you will need them." Ron Jeffries, Extreme Programming (XP).

The phrase originated with Kent Beck on the C3 project. When teammates proposed
elaborate solutions for anticipated future needs, Beck replied: "you aren't
gonna need it." YAGNI is the XP practice of Simple Design: implement the
simplest design that satisfies the current requirement.

### Smell

```typescript
interface NotificationChannel {
  send(message: string): Promise<void>;
}

class EmailChannel implements NotificationChannel { /* ... */ }
class SmsChannel implements NotificationChannel { /* ... */ }   // not required yet
class PushChannel implements NotificationChannel { /* ... */ }  // not required yet

class NotificationService {
  constructor(private channels: NotificationChannel[]) {}
  // ...
}
```

Today only email is needed. The SMS and push channel implementations, the
interface, and the multi-channel loop are all presumptive. They carry
complexity, maintenance cost, and the risk that the real future requirement
will not fit the assumed shape.

### Fix

```typescript
class NotificationService {
  async sendEmail(message: string): Promise<void> {
    // Direct implementation for the one channel that is needed today.
  }
}
```

Refactor to the multi-channel design when the second channel becomes a real,
accepted requirement.

### Trade-off: when extensibility is genuinely warranted

Martin Fowler identifies four costs that YAGNI avoids:

- **Cost of build**: effort spent on features that are never used.
- **Cost of carry**: unused code adds complexity that slows every future change.
- **Cost of delay**: speculative features displace immediately valuable work.
- **Cost of repair**: speculative features rarely fit the eventual real
  requirement exactly; they need rework.

However, Fowler also notes: if adding flexibility does not actually increase
the complexity of the software, there is no reason to invoke YAGNI. A small
enhancement requiring minimal effort -- a lookup table instead of inline
literals for a concept that is clearly going to grow -- can substantially
reduce future cost without violating the principle.

Genuine, near-term, known extensibility at a real boundary can be warranted.
A second integration partner is confirmed in the product roadmap; extracting
an interface today has a clear, low carry cost and avoids a predictable
refactoring. That is a judgement call, not a YAGNI violation. What YAGNI
prohibits is the speculative case: "we might need this someday" with no
concrete driver.

The key question is not "might this be useful?" but: does the carry cost and
risk of wrong assumptions today exceed the cost of adding it later, given how
malleable the codebase is?

YAGNI is only viable when the engineering practices that enable easy change are
in place: continuous refactoring, automated testing, continuous integration.

---

## Pragmatism

KISS, DRY, and YAGNI are heuristics for managing complexity, not laws. Their
value is proportional to the scale and longevity of the system.

A small script or a proof of concept does not benefit from extracted constants
and plugin architectures. The cost of each principle (an extracted abstraction,
a deferred feature, a deliberate simplification) must be weighed against its
present payoff.

The three principles reinforce each other: YAGNI keeps the scope honest, KISS
keeps the implementation honest, DRY keeps the knowledge honest. Applied
together with the rule of three as the pacing mechanism for abstraction, they
resist the most common sources of premature complexity.

Over-application is as harmful as ignoring the principles. Match the level of
sophistication to the actual need.
