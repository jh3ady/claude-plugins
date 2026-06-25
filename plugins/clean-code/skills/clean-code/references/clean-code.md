# Clean code reference

The detailed reference behind the skill: canonical rules, before/after examples,
and over-application cautions for each of the five clean code areas.

Standards and sources:
- Robert C. Martin, *Clean Code: A Handbook of Agile Software Craftsmanship*,
  Prentice Hall, 2008: the canonical reference for all five areas.
- Wojteklu, [Summary of Clean Code by Robert C. Martin](https://gist.github.com/wojteklu/73c6914cc446146b8b533c0988cf8d29)
  (GitHub Gist): widely cited community summary.
- Daniel Gerber, [Clean Code: The Good, the Bad and the Ugly](https://gerlacdt.github.io/blog/posts/clean_code/)
  (programming blog): balanced technical critique covering dogmatism, fragmentation, and
  boundary over-application.
- Bugzmanov, [Clean Code Critique, Chapter 6: Boundaries](https://bugzmanov.github.io/cleancode-critique/chapter_6):
  technical critique of the boundaries and abstraction advice.
- Code4IT, [Clean code tips: Error Handling](https://www.code4it.dev/blog/clean-code-error-handling/):
  practical walkthrough of exceptions vs. status codes and null avoidance.
- Vivek Khatri, [Chapter 8: Boundaries, Clean Code](https://vivekkhatri.com/chapter-8-boundaries-clean-code-robert-c-martin/):
  summary of the adapter/wrapper and learning-tests patterns.

---

## Naming

Names should reveal intent: what a thing is, what it does, and why it exists.
A reader should never need to look elsewhere to understand what a name means.

### Smell

```python
d = 0         # elapsed time in days
tmp = user    # user being processed for billing
flg = True    # whether the request has been authenticated
```

Single-letter names, generic placeholders (`tmp`, `data`, `obj`), and unexplained
abbreviations force the reader to hold mental context that the name should carry itself.
The comment becomes load-bearing, meaning the name has failed.

### Fix

```python
elapsed_time_in_days = 0
billing_user = user
is_authenticated = True
```

Names encode purpose: unit, role, and boolean convention (`is_`, `has_`, `can_`).
The comment disappears because the name carries the intent.

### Over-application caution

Not every short name is wrong. Conventional loop indices (`i`, `j`, `k`), well-known
abbreviations in their domain (`url`, `id`, `ctx`, `err`), and local variables inside a
three-line closure can be short without harming readability. The failure mode is verbosity
theater: expanding `i` to `loopIterationIndex`, or renaming a standard `e` exception to
`caughtExceptionDuringProcessing`. Names should be as long as necessary to convey intent,
and no longer.

### Verbs signal outcome and cost

Beyond its subject, a method name should reveal two things:

- Outcome: whether the result may be absent. `find_*` may return nothing, so model absence
  as a value (an `Optional`, an empty collection, a Null Object, or a domain `Result`).
  `get_*` and `require_*` promise a value or raise. Choose the prefix that matches the real
  contract, so callers know whether they must handle absence.
- Cost: whether the call is a cheap in-memory access or reaches for an external resource.
  `get_*` reads as a cheap accessor with no surprising effects. `load_*`, `read_*`, and
  `fetch_*` announce that the call touches disk, network, or another external source, so it
  may be slow and may fail.

The two axes compose, and which one a name should foreground depends on the layer. Behind a
repository port the input/output is abstracted away, so the outcome axis leads: `find_user`
may be absent and `get_user` guarantees a user, even though both query a database. At an
infrastructure boundary that visibly performs input/output, the cost axis leads: a method
that reads a file now is `load_config` or `read_config`, not `get_config`. Naming such a
method `get_*` hides the cost the caller most needs to see, the same failure as a name whose
comment is load-bearing.

---

## Functions

A function should do one thing, do it at one level of abstraction, and do it well.
Prefer few arguments; functions with many parameters are harder to understand and test.

### Smell

```python
def process_user(user, db, mailer, audit_log, send_email=True, dry_run=False):
    # validate, persist, email, audit: all in one place, 80+ lines
    if not dry_run:
        db.save(user)
    if send_email and not dry_run:
        mailer.send(user)
    audit_log.record(user, dry_run=dry_run)
```

Flag arguments (`send_email`, `dry_run`) announce that the function does more than one thing.
A giant body mixing persistence, notification, and auditing has multiple independent reasons
to change. The six-parameter signature is a signal that responsibilities have merged.

### Fix

```python
def validate_user(user): ...
def persist_user(user, db): ...
def notify_user(user, mailer): ...
def audit_user(user, audit_log): ...

def register_user(user, db, mailer, audit_log):
    validate_user(user)
    persist_user(user, db)
    notify_user(user, mailer)
    audit_user(user, audit_log)
```

Each function does one thing. The orchestrating function reads as a sequence of steps at a
consistent level of abstraction.

### Over-application caution

"Functions should be small... and smaller than that" (Martin) taken literally produces
excessive fragmentation: a coherent flow split into many one-liners that scatter logic and
force the reader to jump constantly between methods to reconstruct the algorithm. Research summarized
in *Code Complete* (McConnell) does not support very short functions as uniformly beneficial.
The real goal is a single level of abstraction per function, not a line-count target. A
30-line function that does one clear thing at one abstraction level is better than a dozen
3-line helpers whose relationship is obscure. Robert C. Martin himself cautions that
over-applying single responsibility to the point of creating too many tiny classes and
methods is itself a form of dogmatism to avoid.

---

## Comments

Comments explain why the code does something that the code itself cannot convey: rationale,
caveats, non-obvious constraints, trade-offs, and intent. What the code does should be
legible from the code itself.

### Smell

```python
# increment counter
counter += 1

# check if user is eligible
if is_eligible(user):
    process(user)

# TODO: fix this later
spirits_total = base_price * 1.73
```

Redundant comments restate what the code already says clearly. Commented-out dead code
accumulates as noise. TODOs without a ticket or owner rot indefinitely. The magic number
`1.73` is unexplained, which is the real problem here, not the presence of a comment.

### Fix

```python
# SPIRITS_EXCISE_MULTIPLIER: product-specific tax factor defined in the pricing policy.
# Update this constant whenever the applicable rate changes.
SPIRITS_EXCISE_MULTIPLIER = 1.73
spirits_total = base_price * SPIRITS_EXCISE_MULTIPLIER

counter += 1            # no comment needed; the line is self-explanatory
if is_eligible(user):   # no comment needed; the function name carries the intent
    process(user)
```

Keep comments that capture rationale, cite external constraints, or flag non-obvious
decisions. Delete comments that merely describe mechanics already visible in the code.

### Over-application caution

"Comments are always failures" (Martin, paraphrased) sets an unrealistic bar. The useful
range of comments is wider: explaining a non-obvious algorithm, recording a deliberate
performance trade-off, citing a specification or standard, or warning about a subtle
interaction with external behavior. The smell is redundant comments that add noise without
insight, and dead or commented-out code that should be deleted. The fix is not to ban
comments; it is to write comments that earn their place by revealing something the code
cannot reveal on its own.

---

## Error handling

Reserve exceptions for genuinely exceptional conditions, a violated invariant or a technical
failure, and prefer them over error-code return values there. Model expected absence as a
value rather than null. Keep the error path separate from the business logic so each reads
on its own.

### Smell

```python
# The absence contract is implicit: the signature does not say this can be empty,
# so every caller improvises its own null guard.
def find_user(user_id):
    return db.query(user_id)  # a user or None, but nothing in the type says so

# Caller handles absence ad hoc, inline, nested with the business logic:
user = find_user(request.user_id)
if user is not None:
    billing = find_billing(user)
    if billing is not None:
        process(billing)
# nothing decides what an absent user means; the gap is silently skipped
```

The problem is not that `find_user` can come back empty, that is a legitimate outcome. It is
that the contract is implicit (the signature does not announce that absence is possible) and
unowned: every call site reinvents a null guard, the guards nest into the business logic, and
an absent value silently means nothing happened.

### Fix

```python
# Repository: absence is a normal result, expressed as a value (not null, not an exception)
def find_user(user_id: str) -> Optional[User]:
    return db.query(user_id)

# Application boundary: it decides that, for this flow, a missing user is an error.
# The business logic reads top to bottom; the error path stays separate.
def charge_user(user_id: str) -> Receipt:
    user = find_user(user_id)
    if user is None:
        raise UserNotFoundError(user_id)  # a violated invariant for this use case
    return process_billing(user)

# Outer boundary translates the exception once, not at every call site:
try:
    return charge_user(request.user_id)
except UserNotFoundError as e:
    return not_found_response(e)
```

The repository expresses absence as a value (here `Optional`, elsewhere an empty collection
or the Null Object pattern), so no caller has to guard against raw null. Whether a missing
value is an error is a decision for the boundary that owns the use case, not for the lookup
itself: it raises only when absence breaks an invariant for that flow. A repository method
that throws on every miss turns an expected outcome into exception-driven control flow.

The decision is symmetric. An expected or foreseeable absence is a value: return an
`Optional`, an empty collection, a Null Object, or a domain `Result`. A broken invariant or
a failed technical operation is an exception: raise it, because returning null or an error
sentinel there lets a corrupted state spread silently and unchecked.

```python
# load_*, not get_*: this reaches for an external resource (see the Naming section).
# A missing required key is a fatal setup error, not a normal outcome, so it raises.
def load_config(path: str) -> Config:
    raw = read_file(path)                 # raises if the file is unreadable
    if "database_url" not in raw:
        raise ConfigError(f"missing required key 'database_url' in {path}")
    return Config(raw)
```

### Over-application caution

Language and context matter. In Go, returning `(value, error)` pairs is idiomatic. In Rust,
`Result<T, E>` and `Option<T>` are the standard. In functional languages, `Maybe` types
express absence without null. Martin's advice is grounded in Java's exception model and does
not translate universally. The over-application failure is treating "always throw an
exception" as language-agnostic law, producing exception-driven control flow for conditions
that are not actually exceptional. A lookup that is expected to sometimes find nothing is
not an exceptional condition; raising an error for it may surprise callers and complicate
testing. Match the error-handling idiom to the language and to the actual semantics of the
operation.

---

## Boundaries and abstractions

Insulate your code from third-party libraries and external systems behind a thin abstraction
layer (adapter or wrapper). Write learning tests to document expected behavior and detect
breaking changes when a dependency updates.

### Smell

```python
import stripe

# Third-party calls scattered across a dozen modules:
stripe.api_key = settings.STRIPE_KEY
charge = stripe.Charge.create(
    amount=amount_cents, currency="usd", source=token
)
if charge.status != "succeeded":
    raise ValueError(charge.failure_message)
```

Stripe's API types, error classes, and calling convention appear in multiple places. A Stripe
SDK update or a switch to a different payment processor requires editing every call site.

### Fix

```python
# A single boundary file:
class PaymentGateway:
    def charge(self, amount_cents: int, token: str) -> PaymentResult:
        try:
            result = stripe.Charge.create(
                amount=amount_cents, currency="usd", source=token
            )
            return PaymentResult(success=True, charge_id=result.id)
        except stripe.error.StripeError as e:
            raise PaymentError(str(e)) from e
```

The rest of the codebase depends on `PaymentGateway` and `PaymentResult`, not on Stripe.
The wrapper is the only file to update when the payment provider changes.

Pair the wrapper with learning tests that exercise the third-party library's contract
directly, so a library update that breaks an assumption fails a focused test rather than
manifesting as a production bug.

### Over-application caution

Not every third-party call warrants a custom abstraction layer. Wrapping a stable standard
library (`datetime`, `fs`, `ArrayList`) adds indirection without a boundary payoff. The
deciding question is volatility and coupling risk: does the third party change its API in
ways that would cascade through the codebase? Is there a realistic possibility of swapping
it out? An unnecessary abstraction layer over a stable, single-use dependency is speculative
indirection, the same failure mode as DIP over-application. As the Bugzmanov critique notes,
Martin sometimes conflates data hiding with meaningful abstraction, producing interfaces that
obfuscate rather than create behavioral contracts. A boundary layer earns its cost when there
is a real boundary to protect.

---

## Pragmatism

Clean code heuristics are tools for making code easier to read and change, not laws to
follow uniformly. Their value is proportional to the complexity, team size, and longevity
of the system.

A small script or a proof of concept does not benefit from a hierarchy of tiny methods,
mandatory wrapper classes, and zero comments. The cost of each heuristic (indirection,
verbosity, abstraction layers, extra files) must be weighed against its present payoff.

Over-application is as harmful as ignoring the heuristics entirely. Match the level of
sophistication to the actual need.
