# Testing Strategy: Reference

Deeper background for the `testing-strategy` skill. The skill body holds the
working rules; this file holds the history of the shapes, the tier taxonomy, the
size-versus-scope distinction, the two meanings of "contract test", and a worked
TypeScript walkthrough, with sources. This is the macro outer loop: the inner
red-green-refactor cycle and the test-double ladder live in
`test-driven-development` and are referenced, not repeated, here.

## Table of contents

1. [Sources](#sources)
2. [The shapes, and where they came from](#the-shapes-and-where-they-came-from)
3. [The tiers](#the-tiers)
4. [Size versus scope](#size-versus-scope)
5. [Pyramid versus trophy](#pyramid-versus-trophy)
6. [Contract testing: two different things with one name](#contract-testing-two-different-things-with-one-name)
7. [Coverage](#coverage)
8. [Flaky tests](#flaky-tests)
9. [A worked walkthrough](#a-worked-walkthrough)
10. [Trade-offs and cross-references](#trade-offs-and-cross-references)

---

## Sources

The claims in this reference trace to the following, cited by attribution
without page numbers.

- Mike Cohn, *Succeeding with Agile: Software Development Using Scrum*
  (Addison-Wesley, 2009), for the test automation pyramid (unit, service,
  user interface).
- Martin Fowler, "TestPyramid":
  https://martinfowler.com/bliki/TestPyramid.html
- Ham Vocke, "The Practical Test Pyramid", on Martin Fowler's site:
  https://martinfowler.com/articles/practical-test-pyramid.html
- Kent C. Dodds, "The Testing Trophy and Testing Classifications" (2018):
  https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications
- Kent C. Dodds, "Write tests. Not too many. Mostly integration.":
  https://kentcdodds.com/blog/write-tests
- Alister Scott, "Introducing the Software Testing Ice-Cream Cone
  (Anti-Pattern)", on the WatirMelon blog:
  https://watirmelon.blog/testing-pyramids/
- André Schaffer, "Testing of Microservices", Spotify Engineering (2018), for
  the testing honeycomb:
  https://engineering.atspotify.com/2018/01/testing-of-microservices
- Fabio Pereira, "Introducing the Software Testing Cupcake (Anti-Pattern)",
  Thoughtworks (2014):
  https://www.thoughtworks.com/insights/blog/introducing-software-testing-cupcake-anti-pattern
- Titus Winters, Tom Manshreck, and Hyrum Wright (editors), *Software
  Engineering at Google*, Chapter 11 (Testing Overview), for test sizes and
  test scope: https://abseil.io/resources/swe-book/html/ch11.html
- Martin Fowler, "TestCoverage":
  https://martinfowler.com/bliki/TestCoverage.html
- Ian Robinson, "Consumer-Driven Contracts: A Service Evolution Pattern", on
  Martin Fowler's site:
  https://martinfowler.com/articles/consumerDrivenContracts.html
- The Pact documentation, for the consumer-driven contract workflow between
  deployed services: https://docs.pact.io

---

## The shapes, and where they came from

Every popular diagram of a test suite names the same trade-off between the
confidence a test buys and the cost it charges. The shapes differ in where they
put the centre of gravity, and each was drawn for a particular kind of system.

### The pyramid

The test automation pyramid comes from Mike Cohn's *Succeeding with Agile*
(2009). It has three layers: many **unit** tests at the base, fewer **service**
tests in the middle, and fewest **user interface** tests at the top. Cohn
sketched the idea with Lisa Crispin around 2003 and 2004, and it reached a wide
audience through his book and through Martin Fowler's writing.

Fowler distils the pyramid to two essential points. First, "you should have many
more low-level Unit Tests than high level Broad Stack Tests running through a
GUI", because broad user-interface tests are "brittle, expensive to write, and
time consuming to run". Second, higher-level tests are a **second line of
defence**: they exist to catch the wiring and integration faults the lower tiers
cannot see, not to re-check the logic the lower tiers already cover. Fowler also
warns against reading the layer names too literally, and adds a caveat that
matters: "If my high level tests are fast, reliable, and cheap to modify, then
lower-level tests aren't needed." The shape serves fast feedback and cheap
change; it is not an end in itself.

### The practical test pyramid

Ham Vocke's "The Practical Test Pyramid", on Fowler's site, is the modern
restatement. Its message is that the word "unit" is ill-defined and not worth
fighting over: the value of the pyramid is in thinking about **categories** of
test and their trade-offs, not in defending a canonical definition of a unit.
Keep the shape and the taper; drop the pedantry about labels. Vocke's practical
advice is to write tests at different granularities, push detail down to the
cheapest level that can hold it, and avoid duplicating the same check at several
levels.

### The testing trophy

Kent C. Dodds proposed the **testing trophy** in 2018 for front-end JavaScript
applications. Reading from the base up it has four tiers: **static** analysis
(types and linting), **unit**, **integration**, and **end-to-end**, with the
integration tier deliberately the widest. The trophy is integration-weighted
because in a typical front-end application the units are thin (a component, a
reducer, a small function) and most defects live in how those pieces are wired
together. Its guiding principle is the **resemblance principle**: "the more your
tests resemble the way your software is used, the more confidence they can give
you." Dodds frames the whole exercise as return on investment, where the return
is confidence and the investment is time, and compresses the advice to a slogan:
"Write tests. Not too many. Mostly integration."

### The ice-cream cone

Alister Scott named the **ice-cream cone** as the pyramid's anti-pattern: the
pyramid turned upside down. A large scoop of manual and user-interface tests
sits on top, a thinner layer of integration tests below, and almost no unit
tests at the base, balanced on a cone of automated unit checks that barely
exists. It melts for the reasons the pyramid predicts: it is slow to run,
brittle under change, and pushes verification to the most expensive tier, so
feedback arrives late and, because the top-tier tests fail for spurious reasons,
the suite stops being trusted.

### Honeycomb and cupcake

Two further shapes are context-specific variants of the same trade-off. The
**testing honeycomb** comes from Spotify Engineering (André Schaffer, "Testing
of Microservices", 2018): for a small microservice, most of the risk is not in
the service's own logic but in how it integrates with its neighbours, so the
honeycomb makes integrated tests the widest band, keeps implementation-detail
(unit) tests small, and keeps end-to-end tests a thin sliver. The **testing
cupcake** comes from Fabio Pereira at Thoughtworks (2014): it is an anti-pattern,
a bulge at every level (too many manual and user-interface tests piled on top of
adequate lower tiers) that appears when separate teams add their own layer of
tests without collaborating on where each check belongs. Both are worth knowing
as reference points, but neither replaces the judgement of matching the shape to
the system in front of you.

---

## The tiers

The shapes are drawn in terms of tiers, and the tier names are used loosely in
the field. Precise working definitions:

- **Unit.** Exercises one behaviour through its public surface. It is the
  cheapest and fastest tier and pinpoints a fault to a small region of code, but
  it proves nothing about how components are wired together. Whether a unit test
  touches several real collaborators (**sociable**) or doubles all of them
  (**solitary**) is a separate axis owned by `test-driven-development`; this
  skill takes the classical, sociable default, where a unit test drives a
  behaviour with its real in-process collaborators and only doubles the slow or
  non-deterministic edges.
- **Integration.** Exercises a component against a **real** collaborator it does
  not own in memory: a database through its real adapter, a message broker, a
  file system. It buys confidence that a seam actually holds, and it costs setup
  and run time. In a hexagonal codebase, integration tests live at the adapters,
  where a port meets real infrastructure.
- **Contract.** Pins the agreement at a boundary so the two sides of it can
  evolve independently without a slow cross-boundary test on every change. The
  word carries two distinct meanings, separated below.
- **End-to-end.** Drives the whole assembled system through its real entry point
  (an HTTP request, a UI interaction). It buys the highest realism and costs the
  most: the slowest runs and the most flakiness, so it stays a small minority
  reserved for a few critical paths.
- **Acceptance.** Expresses a business rule in the language of the domain, so a
  non-programmer can read it as the definition of done. It buys a shared,
  readable specification and costs the collaboration to keep it honest.
  Acceptance is about the **language and audience** of the test, not its
  granularity: an acceptance test can be implemented at any tier.

The sociable-versus-solitary distinction, the test-double ladder (real object,
then in-memory implementation, then stub, then mock), and how to keep a fast test
faithful all belong to `test-driven-development`. This skill decides how many
tests of each tier to hold and where each behaviour is best checked.

---

## Size versus scope

*Software Engineering at Google* (Chapter 11) separates two axes that the
unit/integration/end-to-end vocabulary tangles together.

**Size** is how a test runs and what resources it is allowed to touch, defined
so that it can be enforced mechanically and so that speed and determinism are
predictable:

| Size   | Runs on          | May use            | Network            | Typical target |
| ------ | ---------------- | ------------------ | ------------------ | -------------- |
| Small  | single process   | no filesystem/DB   | none               | ~60s           |
| Medium | single machine   | threads, blocking  | localhost only     | ~300s          |
| Large  | anywhere         | unrestricted       | any                | ~900s          |

**Scope** is a different question: how much code a test actually exercises, from
a single function (narrow) through a module to the whole system (broad).

The two axes are independent, and that independence is the useful part. A
broad-scoped test that drives an endpoint through several layers can still be
**small** if it doubles out its out-of-process dependencies, so it runs in one
process with no network and stays fast and deterministic. Conversely a
narrow-scoped test that checks one function can be **large** if it insists on a
real database over the network. Google optimises for speed and determinism, and
prefers to classify a test by its size (what it may do, hence how fast and
reliable it is) rather than by the traditional unit/integration labels (how much
it happens to touch), because size is what actually governs whether the suite is
fast and trustworthy. Choose size and scope deliberately and separately: decide
how much code a test should exercise to buy the confidence you want, then keep it
at the smallest size that scope allows.

---

## Pyramid versus trophy

The pyramid and the trophy are often set against each other as if one had to
win. They do not: they are context-dependent answers to the same
return-on-investment question, and they agree on more than they dispute.

They **disagree on the centre of gravity**. The pyramid puts the widest band at
the unit base and is the better fit for a service with rich domain logic, where
most of the risk is in the rules and the units are worth testing directly and in
number. The trophy puts the widest band at the integration tier and is the
better fit for a front-end JavaScript application, where the units are thin and
most defects hide in the wiring between them; it rebalances towards integration
precisely because a unit test of a trivial component buys little confidence.

They **agree on the extremes**. Both keep end-to-end tests a small minority, for
the same reason: that tier is the slowest and the most flaky, so it is reserved
for a handful of critical paths. Both also want the bulk of the suite to be fast
and deterministic.

The dispute is narrower than it looks once you notice where the classical,
sociable unit tests this ecosystem produces actually sit. A sociable test drives
a behaviour with its real in-process collaborators, so it already blurs the line
between "unit" and "integration": it is unit-sized (one process, no network) but
covers a slice of scope wider than a single function. That style sits
comfortably between the pyramid and the trophy, which is why the choice between
the two shapes is usually a matter of degree rather than a real fork. The
inner-loop mechanics of those sociable tests, and the doubles that keep them
fast, belong to `test-driven-development`.

---

## Contract testing: two different things with one name

"Contract test" names two genuinely different techniques that solve two
different problems. Confusing them is common and costly, so keep them apart.

### The in-memory contract test (owned by `test-driven-development`)

The first meaning is a **within-process fidelity** check: keeping a fast
in-memory double honest against the real implementation it stands in for. This
technique, the in-memory contract test, is owned by `test-driven-development`
(see its "Keep in-memory implementations faithful" section); this skill needs
only the ownership boundary, not the mechanism. The problem it solves is
**double fidelity within a single process**.

### The consumer-driven contract test (owned here)

The second meaning is a **between-services drift** check, and it is a portfolio
decision this skill owns. When two deployed services communicate over a network,
the naive way to catch a breaking change is a cross-service end-to-end test that
boots both and exercises the integration. Those tests are slow, non-deterministic
(two deployables, a network, shared state), and they fail late. The
consumer-driven contract test (the Pact-style workflow; see Ian Robinson's
"Consumer-Driven Contracts" and the Pact documentation) replaces them with fast,
deterministic tests:

1. The **consumer** writes a test against a local mock of the provider, declaring
   the requests it makes and the responses it relies on. Running that test
   generates a **contract** (a pact): a machine-readable record of the
   consumer's expectations.
2. The contract is published to the provider's team.
3. In the **provider's** build, the contract is replayed against the real
   provider: each recorded request is sent and each recorded expectation is
   verified against the real response.
4. If a provider change breaks an expectation some consumer relies on, the
   provider's build fails, before deployment, naming the consumer that would
   break.

The two techniques share a name and nothing else. The in-memory contract test
verifies **double fidelity within a process** (does my fast stand-in behave like
the real implementation?). The consumer-driven contract test verifies
**integration drift between services** (does the real provider still meet what
its consumers depend on?). One keeps a test double honest; the other lets two
independently deployed services evolve without a slow end-to-end suite between
them.

A minimal, tool-agnostic sketch of a consumer expectation, showing the shape and
status the consumer relies on:

```typescript
// The consumer (our order service) declares what it needs from the payment
// provider: a POST /charges that, for a valid charge, answers 200 with a body
// carrying a payment id and a status the consumer branches on. Only the fields
// the consumer actually reads belong in the contract.
interface ExpectedChargeResponse {
  paymentId: string;
  status: "captured" | "declined";
}

const paymentProviderExpectation = {
  given: "a customer with a valid card",
  uponReceiving: "a charge for order-1",
  withRequest: {
    method: "POST" as const,
    path: "/charges",
    body: { orderId: "order-1", amountCents: 4200, currency: "EUR" },
  },
  willRespondWith: {
    status: 200,
    body: {
      paymentId: "pay_123",
      status: "captured",
    } satisfies ExpectedChargeResponse,
  },
};
```

Replayed in the provider's build, this asserts that a valid charge still returns
`200` with a `paymentId` and a `status` of `"captured"`. If the provider renames
`paymentId`, drops the `captured` status, or starts answering `202`, the
provider's build fails, not our end-to-end suite at three in the morning. The
contract deliberately records only the fields the consumer reads, so the provider
stays free to add and change everything else.

---

## Coverage

Coverage is a diagnostic, not a grade. Martin Fowler's position ("TestCoverage")
is that coverage is "a useful tool for finding untested parts of a codebase" but
"of little use as a numeric statement of how good your tests are". The reason is
that a coverage percentage measures which lines were **executed** while the tests
ran, not whether their behaviour was **asserted**: a test that calls a function
and checks nothing raises coverage without buying any confidence.

The failure mode is making the percentage a target. That is Goodhart's law: when
a measure becomes a target, it ceases to be a good measure. Gate a build on a
coverage number and teams meet the number the cheapest way, with assertion-free
tests that execute lines to colour them green, which degrades the suite while the
metric improves. Use coverage the way Fowler intends: read it to find the gaps
worth testing, write behaviour tests for the ones that matter, and never grade
the suite or gate the build by the number.

---

## Flaky tests

A flaky test passes and fails without any change to the code under test. It is
worse than no test, because it erodes trust in the **whole** suite: once a red is
assumed to be noise, the team starts ignoring reds, and a real failure hides
among the false ones until it reaches production.

The common causes are all forms of hidden non-determinism:

- **Shared state** between tests, so the result depends on what ran before.
- **Real time**: a test that reads the system clock, sleeps, or races a timeout.
- **Order dependence**: a test that passes alone but fails when the runner
  reorders or parallelises the suite.
- **The real network** or another live, out-of-process dependency whose latency
  and availability the test cannot control.

The discipline has two rules. First, do not adopt **rerun-until-green** as
policy: retrying a flaky test until it passes launders a real defect into a green
bar and trains the team to distrust reds. Second, when a test turns flaky,
**quarantine** it out of the signal path so it stops poisoning the suite, then
**fix the root cause** or delete it. The isolation properties that prevent
flakiness in the first place are the strategy's own concern: each test builds
its own fixture, controls its own clock, depends on no other test, and touches no
uncontrolled network. A good strategy refuses to keep a flickering test in the
trusted suite.

---

## A worked walkthrough

Take one feature, "confirm an order", and place its tests across the tiers. The
point is that each check lands at exactly one tier, chosen for the confidence it
buys, and nothing is duplicated.

The domain rule is: an order may be confirmed only once its payment is captured;
confirming an unpaid order is an error. The feature also persists the confirmed
order, calls an external payment provider, and is reachable through an HTTP
endpoint.

### Unit (sociable): the domain rule

The rule itself is pure logic, so it belongs at the cheapest tier, with real
value objects and no doubles.

```typescript
// Unit, sociable: real Order, Money, Payment; no doubles. Fast, deterministic,
// and it pinpoints a broken rule to the domain.
describe("Order.confirm", () => {
  test("a captured payment confirms a placed order", () => {
    const order = Order.placed(OrderId.of("order-1"), Money.euros(4200));

    const confirmed = order.confirm(Payment.captured("pay_123"));

    expect(confirmed.status).toBe("confirmed");
  });

  test("an order cannot be confirmed without a captured payment", () => {
    const order = Order.placed(OrderId.of("order-1"), Money.euros(4200));

    expect(() => order.confirm(Payment.declined())).toThrow(
      "cannot confirm an order without a captured payment",
    );
  });
});
```

Both branches of the rule are checked here, once, where they are cheapest to
check. No higher tier repeats them.

### Integration: the repository adapter

Persistence is a seam against real infrastructure, so it is tested at the
integration tier against a real database. This runs the same contract suite the
in-memory implementation must also satisfy (that in-memory-versus-real parity is
owned by `test-driven-development`); here it exercises the real adapter.

```typescript
// Integration: the real Postgres adapter against a real (test) database. Buys
// confidence that the seam holds; it does not re-check the confirmation rule.
describe("PostgresOrderRepository", () => {
  test("round-trips a confirmed order", async () => {
    const pool = await connectToTestDatabase();
    const repository = new PostgresOrderRepository(pool);
    const order = Order.placed(OrderId.of("order-1"), Money.euros(4200)).confirm(
      Payment.captured("pay_123"),
    );

    await repository.save(order);

    expect(await repository.findById(OrderId.of("order-1"))).toEqual(order);
  });
});
```

This test asserts that saving and loading preserve the order. It says nothing
about when an order may be confirmed; that is the unit test's job.

### Consumer-driven contract: the payment provider

The feature calls an external payment provider across a network. Rather than a
slow cross-service end-to-end test, the consumer declares what it relies on (the
`paymentProviderExpectation` from the previous section) and generates a contract.
That contract is replayed in the payment provider's build: if the provider stops
returning a `captured` status or renames `paymentId`, the provider's build fails
and names our service as the affected consumer. Our build stays fast and
deterministic, and the integration drift is caught at the boundary that changed.

### End-to-end: one critical path

Finally, one end-to-end test proves the assembled system serves the critical
path a customer actually walks: place a paid order, hit the real endpoint, get a
confirmation.

```typescript
// End-to-end: one happy path through the real HTTP entry point. Slow and broad,
// so kept to a single critical path; the branches live in the cheaper tiers.
describe("POST /orders/:id/confirm (end-to-end)", () => {
  test("confirms a paid order and answers 200", async () => {
    const app = await startTestApp();
    await seedPaidOrder(app, "order-1");

    const response = await app.inject({
      method: "POST",
      url: "/orders/order-1/confirm",
    });

    expect(response.statusCode).toBe(200);
    expect(response.json()).toMatchObject({ status: "confirmed" });
  });
});
```

### Why nothing is duplicated

Each tier answers a question no other tier answers. The unit test owns the
confirmation rule and both its branches. The integration test owns persistence
fidelity. The consumer-driven contract test owns the agreement with the payment
provider. The end-to-end test owns one proof that the wiring holds for the
critical path. The failure-path branch (an unpaid order is rejected) is checked
only at the unit tier, because that is where it is cheapest and clearest;
re-checking it end-to-end would triple the cost and the flakiness for no extra
confidence. That is the whole strategy in miniature: push each check to the
cheapest tier that proves it, and let the higher tiers be a thin second line of
defence for the wiring the lower tiers cannot see.

---

## Trade-offs and cross-references

This skill decides the shape of the portfolio; several neighbouring skills own
the mechanics it defers to.

- **`test-driven-development`** owns the inner loop. Red-green-refactor, testing
  behaviour through the public API, the sociable-versus-solitary distinction, the
  test-double ladder (real object, then in-memory implementation, then stub, then
  mock), and the in-memory contract test that keeps a double faithful all live
  there. This skill sits above that loop and decides the portfolio those tests
  form.
- **`hexagonal-architecture`** defines the ports that integration tests cross. An
  integration test exercises a real adapter against real infrastructure at a
  port; this skill decides how many such tests to hold relative to unit and
  end-to-end tests.
- **`legacy-code`** owns characterization tests, the entry point when adding
  tests to code with none: pin the current behaviour first, then change it
  safely. This skill frames where those tests sit in the wider portfolio.
- **`refactoring`** owns self-testing code, the prerequisite that makes any
  strategy possible: without a trustworthy suite there is no safety net to
  balance. This skill decides the shape and balance of that suite.
- **`domain-driven-design`** owns the ubiquitous language that acceptance tests
  speak at the outer tier of the portfolio. A future behaviour-driven-development
  plugin could own acceptance tests and Gherkin in depth; until then, keep
  acceptance tests readable in the domain's language and implemented at the
  cheapest tier that still expresses the rule.
