# Test-Driven Development: Reference

Deeper background for the `test-driven-development` skill. The skill body holds
the working rules; this file holds the history, the canonical definitions, the
trade-off analyses, and the worked examples, with sources.

## Table of contents

1. [The two schools of TDD](#1-the-two-schools-of-tdd)
2. [The test-double taxonomy](#2-the-test-double-taxonomy)
3. [The when-to-double decision](#3-the-when-to-double-decision)
4. [State verification versus interaction verification](#4-state-verification-versus-interaction-verification)
5. [Keeping in-memory implementations faithful: contract tests](#5-keeping-in-memory-implementations-faithful-contract-tests)
6. [The two meanings of "unit"](#6-the-two-meanings-of-unit)
7. [Testing behaviour, not implementation](#7-testing-behaviour-not-implementation)
8. [Scope: the pyramid, the trophy, and the inner loop](#8-scope-the-pyramid-the-trophy-and-the-inner-loop)
9. [Sources](#9-sources)

---

## 1. The two schools of TDD

There are two long-standing styles of test-driven development, and they differ
on one axis: what to do with a collaborator the system under test depends on.

**Classical (Detroit, Chicago, classicist).** Traced to the C3 project at
Chrysler, where Kent Beck's extreme programming and TDD took shape (hence
"Detroit"). The classical practitioner uses real objects wherever practical and
substitutes a test double only when the real collaborator is awkward to use.
Correctness is judged by **state verification**: run the behaviour, then inspect
the resulting state of the system and its collaborators. Martin Fowler states
the rule plainly: "The classical TDD style is to use real objects if possible
and a double if it's awkward to use the real thing."

**Mockist (London).** Associated with Steve Freeman and Nat Pryce and codified
in *Growing Object-Oriented Software, Guided by Tests*. The mockist replaces
collaborators with mocks as a matter of course ("a mockist TDD practitioner
will always use a mock for any object with interesting behavior") and judges
correctness by **behaviour verification**: assert that the system made the
expected calls on its collaborators.

The two also tend to differ in direction. Classical TDD leans **inside-out**:
build the domain, then the layers around it. Mockist TDD leans **outside-in**:
start at the entry point and drive downward, discovering collaborator interfaces
as you mock them.

Fowler, having described both fairly, states his own preference: "I don't see
any compelling benefits for mockist TDD, and am concerned about the consequences
of coupling tests to implementation." This skill takes the same position. The
practical cost of the mockist style is that tests become coupled to the call
structure of the code, so they break when you refactor internals even though no
observable behaviour changed.

---

## 2. The test-double taxonomy

"Test Double" is Gerard Meszaros's umbrella term (from *xUnit Test Patterns*)
for any object that stands in for a production object during a test. There are
five kinds. Fowler reproduces Meszaros's definitions; the wording below follows
them.

- **Dummy.** Objects "passed around but never actually used. Usually they are
  just used to fill parameter lists." A dummy carries no behaviour; it only
  satisfies a signature.
- **Fake.** Objects that "actually have working implementations, but usually
  take some shortcut which makes them not suitable for production (an
  InMemoryTestDatabase is a good example)." This is the crucial one for the
  classical style. A fake is a **real, working implementation**; it runs the
  logic, it just shortcuts something (memory instead of disk, a fixed clock
  instead of the system clock). Because the word "fake" undersells a real
  implementation, this skill prefers the term **in-memory implementation** for
  the common case and notes "fake" as the literature's label.
- **Stub.** Provides "canned answers to calls made during the test, usually not
  responding at all to anything outside what's programmed in for the test." A
  stub returns fixed values; it does not implement real behaviour.
- **Spy.** "Stubs that also record some information based on how they were
  called. One form of this might be an email service that records how many
  messages it was sent."
- **Mock.** "Pre-programmed with expectations which form a specification of the
  calls they are expected to receive. They can throw an exception if they
  receive a call they don't expect and are checked during verification to
  ensure they got all the calls they were expecting." Of the five, "only mocks
  insist upon behavior verification".

Google's *Software Engineering at Google* gives the same ordering as a
preference, from most faithful to least: a **real implementation** first; when
that is impractical, a **fake**; and **stubbing and interaction testing** only
as a last resort. It frames a fake as "a lightweight implementation of an API
that behaves similar to the real implementation but isn't suitable for
production", and advises that "interaction testing should be avoided when
possible". This is the ladder the skill encodes.

---

## 3. The when-to-double decision

Walk this decision for each collaborator of the behaviour under test.

1. **Is it fast, in-process, and deterministic?** Then it is not awkward. Use
   the real object. Value objects, entities, domain services, and pure
   functions are always real; doubling them tests the double, not the code.
2. **Is it slow, networked, non-deterministic, or outside the process, but
   defined by a contract you own?** Write an **in-memory implementation** of
   that contract and use it. This is the common case for repositories, clocks,
   id generators, notifiers, and gateways. You then test the real use case or
   domain behaviour through its public surface, with the in-memory
   implementation standing in for the slow edge. No mock appears.
3. **Do you need a state the real or in-memory implementation cannot easily
   reach, almost always a failure path?** Use a **stub** to return that canned
   error for the single test that exercises the failure. Keep it to error and
   edge injection; a stub on the happy path is a smell.
4. **Is the interaction itself the observable behaviour, at a true boundary you
   do not own?** Then, and only then, use a **mock** and verify the
   interaction: a message published to a broker, an email handed to a delivery
   service. Cooper's rule: "avoid mocks at all costs, use them only to isolate
   the tests on the module boundaries."

The ladder is ordered by fidelity. Each rung down is less like the real thing
and more coupled to implementation, so stop at the highest rung that works.

---

## 4. State verification versus interaction verification

The two schools verify correctness differently, and the difference drives
everything else.

**State verification** asks: after the behaviour runs, what is true? Assert on
returned values and on the resulting state, read back through the public API.
Fowler: a classic test "only cares about the final state, not how that state
was derived". Such a test does not know, and does not care, how many times a
collaborator was called.

**Interaction (behaviour) verification** asks: did the system make the right
calls? Assert that `repository.save` was called once with these arguments. This
ties the test to the call structure. Fowler: "Mockist tests are thus more
coupled to the implementation of a method. Changing the nature of calls to
collaborators usually cause a mockist test to break."

The consequence is refactoring resilience. The whole value of the refactor step
is that you can restructure internals freely while the tests hold the behaviour
steady. State-verified tests deliver that, because they assert only the
observable result. Interaction-verified tests undercut it, because reorganising
the internals changes the calls and so changes what the tests assert, even when
behaviour is unchanged. This is why a state-first style and an aggressive
refactor habit reinforce each other.

---

## 5. Keeping in-memory implementations faithful: contract tests

The standing objection to in-memory implementations is fidelity: a hand-written
in-memory store can diverge from the real database and pass tests production
would fail. The classical answer is the **contract test**.

Write one test suite against the **interface** (the contract), expressed in
terms no implementation detail leaks into. Run that same suite against both the
in-memory implementation and the real one. If both pass, the in-memory
stand-in is a **verified** substitute and your fast tests mean what they claim.

Google's practice states the requirement directly: "a fake should maintain
fidelity to the API contracts of the real implementation. For any given input
to an API, a fake should return the same output and perform the same state
changes of its corresponding real implementation", and "a fake must have its
own tests to ensure that it conforms to the API of its corresponding real
implementation". Ownership follows: "the team that owns the real implementation
should write and maintain a fake", so the two evolve together. Fidelity is
judged "from the perspective of the test": a fake may legitimately skip a rare
behaviour the contract makes no promise about.

A sketch in TypeScript, with the contract suite parameterized over the
implementation under test:

```typescript
// One suite, written against the OrderRepository contract, run against any
// implementation. Both the in-memory and the real adapter must satisfy it.
function orderRepositoryContract(
  name: string,
  makeRepository: () => Promise<OrderRepository>,
) {
  describe(name, () => {
    test("returns null for an unknown id", async () => {
      const repository = await makeRepository();
      expect(await repository.findById(OrderId.of("missing"))).toBeNull();
    });

    test("round-trips a saved order", async () => {
      const repository = await makeRepository();
      const order = Order.placed(OrderId.of("order-1"));
      await repository.save(order);
      expect(await repository.findById(OrderId.of("order-1"))).toEqual(order);
    });
  });
}

// The in-memory implementation: fast, runs in every TDD cycle.
orderRepositoryContract(
  "InMemoryOrderRepository",
  async () => new InMemoryOrderRepository(),
);

// The real adapter: same suite, run against real infrastructure in the outer
// loop (slower, fewer runs). Passing both is what makes the in-memory stand-in
// trustworthy.
orderRepositoryContract(
  "PostgresOrderRepository",
  async () => {
    const pool = await connectToTestDatabase();
    return new PostgresOrderRepository(pool);
  },
);
```

One subtlety the round-trip test must guard: an in-memory implementation should
clone on write (and/or on read) rather than store and return the caller's own
reference. If it hands back the exact instance it was given, `toEqual` passes by
identity and the suite silently misses the aliasing and serialisation defects a
real adapter would expose (a caller mutating a returned object would also mutate
the store). Treat "does not leak its internal reference" as part of the
contract, and assert it.

Keep this distinct from **consumer-driven contract testing** (Pact-style)
between services: that verifies a provider meets a consumer's expectations
across a network boundary, a different problem from in-memory-versus-real
parity.

---

## 6. The two meanings of "unit"

"Unit test" carries two readings, and the crossed wires between them cause real
confusion.

**Reading A: the unit is the code under test (a class or method).** This is the
common informal reading, and it pushes people toward one test class per
production class and toward mocking every collaborator to isolate "the unit".

**Reading B: the unit is the test's isolation.** This is Kent Beck's original
meaning. "Unit" describes the test, not the target: unit tests are independent
of one another and order-independent, each constructing its own fixture from
scratch, so they "should return the same results regardless of the order in
which they are run". Under this reading, isolation is isolation *from other
tests*, not isolation of the code from its collaborators.

Fowler sits in between and is explicit that the boundary is situational:
"Although I start with the notion of the unit being a class, I often take a
bunch of closely related classes and treat them as a single unit." For the
resulting styles he borrows Jay Fields's terminology: classicists prefer
**sociable** tests (real collaborators exercised together), mockists prefer
**solitary** tests (every collaborator doubled).

This skill uses Reading B and the sociable style: the unit under test is a
behaviour or module exposed through a public API, the test is isolated from
other tests, and real collaborators run together inside it.

---

## 7. Testing behaviour, not implementation

Ian Cooper's talk "TDD, Where Did It All Go Wrong" diagnoses how the classical
discipline drifted into brittle, implementation-coupled tests, and prescribes
the return to behaviour. The core claims:

- "Test module behaviours, not implementations."
- "The unit under test is not a class nor a method, it is a module." The module
  is tested through its public API, and its internals are free to change.
- "The trigger to add a new test is not the creation of a new method, nor the
  creation of a new class. The trigger is implementing a new requirement." You
  do not test-drive classes into existence one test each; you test-drive
  behaviours, and classes appear (and disappear) in the refactor step.
- "Avoid mocks at all costs, use them only to isolate the tests on the module
  boundaries."

The throughline with the rest of this reference: if the unit is a behaviour
behind a public API, then real collaborators naturally run together (sociable
tests), state verification is the natural way to assert the outcome, and mocks
retreat to the genuine boundaries. The schools, the doubles ladder, and the
verification style are one coherent position, not separate preferences.

---

## 8. Scope: the pyramid, the trophy, and the inner loop

TDD is an **inner loop**: red-green-refactor at the level of behaviours and
modules. It is not the whole test strategy, and this skill does not try to be.

The **test pyramid** (Mike Cohn, popularized by Fowler) is the standard
argument for keeping the slow tests a minority: "you should have many more
low-level Unit Tests than high level Broad Stack Tests running through a GUI",
because end-to-end UI tests are "brittle, expensive to write, and time
consuming to run". Fowler adds a caveat worth remembering: "If my high level
tests are fast, reliable, and cheap to modify, then lower-level tests aren't
needed", so the shape serves the goal (fast feedback, cheap change), it is not
an end in itself.

The **testing trophy** (Kent C. Dodds) rebalances the middle toward integration
tests, on the reasoning that "the more your tests resemble the way your software
is used, the more confidence they can give you", and that the aim is return on
investment where "'return' is 'confidence' and 'investment' is 'time'". Its
slogan: "Write tests. Not too many. Mostly integration."

The pyramid and the trophy **disagree on the centre of gravity** (unit base
versus integration middle), but they **agree the end-to-end tier stays small**.
The classical, sociable unit tests this skill produces already touch several
real collaborators, so they blur the unit/integration line and sit comfortably
between the two positions. Integration tests (a real adapter against real
infrastructure), end-to-end tests, and acceptance tests belong to the outer
loop and are out of scope here; they are the minority tier in either model.

---

## 9. Sources

- Martin Fowler, "Mocks Aren't Stubs":
  https://martinfowler.com/articles/mocksArentStubs.html
- Martin Fowler, "TestDouble":
  https://martinfowler.com/bliki/TestDouble.html
- Martin Fowler, "UnitTest":
  https://martinfowler.com/bliki/UnitTest.html
- Martin Fowler, "TestPyramid":
  https://martinfowler.com/bliki/TestPyramid.html
- Ian Cooper, "TDD, Where Did It All Go Wrong":
  https://www.infoq.com/presentations/tdd-original/
- Kent Beck, "Test Desiderata":
  https://medium.com/@kentbeck_7670/test-desiderata-94150638a4b3
- Kent C. Dodds, "The Testing Trophy and Testing Classifications":
  https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications
- Kent C. Dodds, "Write tests. Not too many. Mostly integration.":
  https://kentcdodds.com/blog/write-tests
- *Software Engineering at Google*, Chapter 13 (Test Doubles):
  https://abseil.io/resources/swe-book/html/ch13.html
- Gerard Meszaros, *xUnit Test Patterns: Refactoring Test Code*, for the
  canonical test-double taxonomy (definitions reproduced via Fowler above).
