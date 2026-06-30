---
name: test-driven-development
description: This skill should be used when implementing a feature, fixing a bug, or changing behaviour, before writing the implementation, applying test-driven development (TDD) following the red-green-refactor cycle in the classical (Detroit) style that verifies state through the public API instead of interactions with mocks. Use it whenever you write or design a test, decide what to test, drive a use case or domain rule test-first, weigh a mock against a stub or an in-memory implementation (a "fake"), or find a test breaking after a refactor that changed no behaviour, even when "TDD" is not said. Covers the iron law (a failing test first), testing behaviour not implementation (the unit is a behaviour, not a class), preferring real objects and in-memory implementations over mocks, contract tests, and guardrails against over-mocking. Not a testing-tooling helper: it skips runners, assertion libraries, coverage, CI config, suite parallelisation, and end-to-end setup.
---

# Test-Driven Development

Test-driven development means writing the test first, watching it fail, then
writing the minimal code to pass. The point of watching it fail is not ritual:
a test you never saw fail proves nothing, because it might be testing the wrong
thing, testing nothing, or passing for a reason unrelated to the behaviour you
care about. Seeing red first is the only evidence that the test can detect the
absence of the feature.

This skill follows the **classical** style of TDD, also called the **Detroit**
or **classicist** school (some authors also call it Chicago), traced to the
project where Kent Beck's extreme programming and TDD were born. Its defining
choice, in Martin Fowler's
terms, is to "use real objects if possible and a double if it's awkward to use
the real thing", and to check correctness by **state verification**: examine
the state of the system and its collaborators after the exercise, rather than
asserting which calls were made. The opposite school (mockist, or London)
replaces every interesting collaborator with a mock and verifies interactions.
The two diverge precisely on mocks, which is where most confusion comes from.

## The iron law

No production code without a failing test first. If you wrote implementation
before its test, the test that follows passes immediately and proves nothing.
The honest move is to set the code aside, write the test, watch it fail, and
reintroduce the code to make it pass. This is not dogma for its own sake: it is
the only way the test earns its keep as a regression guard and as a record of
intent.

The legitimate exceptions, agreed with the human, are throwaway spikes meant to
be deleted, generated code, and configuration. A spike is fine for learning;
just throw it away and start again under TDD, rather than keeping it and
writing tests around what you already built.

## Red, green, refactor

The cycle is three small steps, repeated:

1. **Red.** Write one test for one behaviour you do not yet have. Give it a name
   that states the behaviour. Run it and watch it fail, and read the failure: it
   must fail because the behaviour is missing, not because of a typo, a wiring
   error, or a wrong import. A test that errors instead of failing, or that
   passes straight away, is testing the wrong thing; fix the test before going
   on.
2. **Green.** Write the simplest code that makes the test pass. Not the general
   solution, not the configurable one, not the one that anticipates next week:
   just enough. Over-building here is how speculative complexity (the kind YAGNI
   warns against) sneaks in under cover of "while I'm here".
3. **Refactor.** With the test green, improve the design: remove duplication,
   sharpen names, extract a helper. Change the structure, never the behaviour,
   and keep every test green throughout. This is where the design is actually
   made, which is why skipping it slowly rots a codebase even when every test
   passes.

Then the next failing test for the next behaviour. Keep the test output pristine
along the way: a wall of warnings hides the one failure that matters.

## Getting to green: fake it, triangulate, or just type it

Kent Beck's *Test-Driven Development: By Example* names three main strategies
for making a red test pass, chosen by how sure you are of the implementation:

- **Obvious Implementation.** When you know the answer and can type it quickly,
  write the real code. Beck calls this "second gear" and warns that the moment an
  unexpected red bar appears, you should downshift to a smaller step.
- **Fake It.** When you do not yet know how to implement it, return a constant
  that satisfies the assertion, watch the bar go green, then replace the
  constant with real logic, usually under pressure from a second test. The
  hardcoded constant duplicates the literal in the test, and removing that
  duplication in the refactor step is what drives out the real implementation.
- **Triangulate.** When the right abstraction is genuinely unclear, refuse to
  generalise until a second, differing example forces it. Two concrete cases
  triangulate towards the general form. It is the most conservative and the
  slowest; reach for it only when faking and refactoring do not make the design
  obvious.

You oscillate between these: obvious implementations while confident, then
downshift to faking and triangulating the instant you are surprised. This is
what Beck means by "TDD is not about taking teeny-tiny steps, it is about being
able to take teeny-tiny steps". The value is the option to shrink the step when
in trouble, not an obligation to always crawl.

Beck's green-bar **Fake It** (a hardcoded constant in the production code) is
unrelated to the test-double **fake** (an in-memory implementation, in the
ladder below). Same word, different thing: one is how you grow the
implementation, the other is what stands in for a slow dependency.

## Work from a test list

Hold the work in a list, not in your head. The red-green-refactor cycle above
runs once per test; the test list is the outer loop that feeds it. Beck's "Canon
TDD" frames that loop as: write a list of the test scenarios you want to cover;
turn exactly one into a concrete, runnable test; change the code to make it and
all previous tests pass, adding scenarios to the list as you discover them
rather than chasing them now; optionally refactor (whenever getting to green
left duplication or a design worth improving); repeat until the list is empty.
The list is your working memory and your "are we done?" signal: done is an empty
list. When a tangential idea appears mid-cycle, park it on the list and stay on
the test you are on.

## Test behaviour, not implementation

The most consequential rule in this style, and the heart of Ian Cooper's "TDD,
Where Did It All Go Wrong", is that you test **behaviours**, not classes or
methods. The unit under test is a **behaviour or a module exposed through its
public API**, not a single class. As Cooper puts it: "the unit under test is
not a class nor a method, it is a module", and "the trigger to add a new test
is not the creation of a new method, nor the creation of a new class. The
trigger is implementing a new requirement."

This matters because tests bound to implementation detail break for the wrong
reasons. A test that asserts *what* the system produces survives any refactor
that preserves behaviour; a test that asserts *how* it was produced (which
methods were called, in what order) breaks the moment you reorganise the
internals, even though nothing a user cares about changed. Fowler makes the
same point: a classic test "only cares about the final state, not how that
state was derived", so it does not couple you to the call structure.

A practical consequence: do not reach for one test class per production class.
Drive tests from requirements, let several classes collaborate behind the
behaviour you are testing, and let the internal shape emerge in the refactor
step. Following Jay Fields's terminology, Fowler calls these **sociable** tests
(real collaborators exercised together), as opposed to the **solitary** tests
the mockist school prefers.

Note that "unit" here means an **isolated test**, in the sense Kent Beck's test
desiderata emphasise (tests independent of one another, order-independent, each
building its own fixture), not "a test of one class". The two readings of the
word are a common source of crossed wires.

## The test-double ladder: prefer real, then in-memory

When the real collaborator is awkward to use directly (slow, networked,
non-deterministic, or reaching outside the process), substitute it, but climb
down this ladder and stop as soon as one rung works. The order is deliberate:
fidelity decreases and coupling-to-implementation increases as you descend.

1. **The real object.** If a collaborator is fast, in-process, and
   deterministic, use it. A value object, a domain rule, a pure function: never
   double these. Most of your domain falls here.
2. **An in-memory implementation.** For a dependency defined by a contract (a
   repository, a clock, a notifier, a gateway), write a real, working
   implementation backed by memory: an array instead of a database, a fixed
   instant instead of the system clock. The literature calls this a **fake**,
   but the word undersells it: it genuinely runs the logic and honours the
   contract, it just takes a production-unsuitable shortcut. Google's
   engineering practice frames it the same way, "a lightweight implementation of
   an API that behaves similar to the real implementation but isn't suitable for
   production", and ranks a real implementation first, then a fake, ahead of any
   stubbing or interaction testing. This rung is where most substitution should
   land. You test the real use case or domain logic through its public surface,
   with in-memory implementations standing in for the slow edges, and you mock
   nothing.
3. **A stub**, only for the narrow case below.
4. **A mock**, only at a true boundary, and only when the interaction *is* the
   behaviour.

```typescript
// A contract the use case depends on.
interface OrderRepository {
  save(order: Order): Promise<void>;
  findById(id: OrderId): Promise<Order | null>;
}

// An in-memory implementation: a real, working implementation, not a mock.
// It honours the contract; it just keeps orders in a Map instead of a database.
class InMemoryOrderRepository implements OrderRepository {
  private readonly orders = new Map<string, Order>();

  async save(order: Order): Promise<void> {
    this.orders.set(order.id.value, order);
  }

  async findById(id: OrderId): Promise<Order | null> {
    return this.orders.get(id.value) ?? null;
  }
}

// The test drives the real behaviour through its public API and verifies state.
// No mock, no interaction assertions: it asks "what is true afterwards?".
test("confirming an order marks it confirmed and persists it", async () => {
  const orders = new InMemoryOrderRepository();
  const confirmOrder = new ConfirmOrder(orders);
  await orders.save(Order.placed(OrderId.of("order-1")));

  await confirmOrder.execute(OrderId.of("order-1"));

  const stored = await orders.findById(OrderId.of("order-1"));
  expect(stored?.isConfirmed).toBe(true);
});
```

In TypeScript specifically, structural typing makes in-memory implementations
cheap: a stand-in only has to satisfy the interface shape, so honouring a
contract costs almost nothing. The canonical over-mocking trap to avoid is
`vi.mock` or `jest.mock` on internal modules, which doubles collaborators you
own and couples the test to module structure; reserve module mocking for true
boundaries, and prefer passing an in-memory implementation through the
constructor.

## State verification over interaction verification

Verify the result, not the choreography. Ask "what is true after the exercise?"
and assert on returned values and resulting state, rather than asserting that
the system called `repository.save` exactly once with these arguments. State
assertions describe the contract the caller relies on; interaction assertions
describe the implementation, and so they break under refactoring that changed
no behaviour. This is the concrete reason the classical school keeps tests
durable through aggressive refactoring: the tests do not know how the work was
done.

## Keep in-memory implementations faithful

The honest objection to in-memory implementations is that they can drift from
the real thing and pass tests production would fail. The answer is a **contract
test**: one shared test suite written against the interface, run against *both*
the in-memory implementation and the real one. If both pass the same suite, the
in-memory stand-in is a faithful (a "verified") substitute, and your fast tests
mean what they claim. As the Google engineering practice puts it, "a fake
should maintain fidelity to the API contracts of the real implementation", and
"a fake must have its own tests to ensure that it conforms". Whoever owns the
real implementation owns the in-memory one and its contract test, so the two
move together. Keep this distinct from consumer-driven contract testing
(Pact-style) between services, which solves a different problem.

## Stubs and mocks: the narrow top of the ladder

- **Stubs** return canned answers. Their one legitimate use in this style is
  forcing a state that a real or in-memory implementation cannot easily reach,
  almost always an **error or failure path**: "what does the use case do when
  the gateway throws?". Reaching for stubs on the happy path is a smell; it
  usually means you are testing implementation detail or that an in-memory
  implementation would serve better.
- **Mocks** verify interactions, and they belong only where the interaction
  genuinely *is* the observable behaviour, at a true boundary you do not own: a
  message actually published to a broker, an email actually handed to a
  delivery service. Cooper's guidance is to "avoid mocks at all costs, use them
  only to isolate the tests on the module boundaries". Mocking internal
  collaborators is the dominant way tests become brittle.

## Scope: TDD is the inner loop

This skill is the inner red-green-refactor loop, which operates at the level of
behaviours and modules. That is deliberately not the whole test strategy.
Integration tests (a real adapter against real infrastructure), end-to-end
tests, and acceptance tests live in an outer loop and are out of scope here. The
test pyramid is the reason to keep them a minority: broad, slow tests are
"brittle, expensive to write, and time consuming to run", so the bulk of your
tests should be the fast behaviour tests this loop produces. (The testing-trophy
view rebalances towards integration; both agree the end-to-end tier stays small.
Classical sociable tests, which touch several real collaborators, already sit
comfortably between the two.)

## Guardrails

- **Do not over-mock.** A test that mocks everything tests the mocks, not the
  code, and couples you to implementation. Prefer real objects and in-memory
  implementations; if a test needs heavy mocking, the design is too coupled,
  which is feedback, not a problem to be solved with more mocks.
- **Do not test implementation detail.** If a refactor that changed no behaviour
  breaks a test, the test was asserting "how", not "what". Rewrite it against
  the public behaviour.
- **Do not write one test class per production class.** Drive from requirements;
  let collaborators work together behind the behaviour under test.
- **Do not skip red.** A test written after the code, or never seen failing,
  has not been shown to detect anything. Watch it fail for the right reason.
- **Do not gold-plate in green.** Minimal code to pass. Generalise only when a
  new failing test demands it; this is YAGNI applied to the cycle itself.
- **Listen to hard-to-test code.** A test that is painful to write is telling
  you the design is hard to use. Fix the design (smaller surface, injected
  dependencies), do not paper over it with elaborate test scaffolding.

## Relationship to other skills

- **`hexagonal-architecture`**: the ports it defines are exactly the contracts
  you back with in-memory implementations, and its driving ports are the public
  surfaces you test behaviour through. The two pair naturally, but this skill is
  architecture-agnostic and does not require hexagonal (or any) layering.
- **`domain-driven-design`** (tactical design): entities, value objects, and
  domain services are the real objects you never double; aggregates are tested
  through their public behaviour, with repositories backed by in-memory
  implementations.
- **`simplicity-principles`**: the green step is YAGNI and KISS in miniature
  (minimal code to pass), and the refactor step is where DRY and the rule of
  three apply.
- **`clean-code`** and **`solid-principles`**: the refactor step is where these
  are applied; dependency inversion in particular is what makes the in-memory
  ladder possible.

## Adapt to your context

This skill stays generic on purpose. Layer your own conventions on top: your
test runner and assertion library, your file and naming conventions for tests,
your fixture and builder helpers, and where you draw the line for an
integration test. Declare those in your own `CLAUDE.md` or a higher-priority
skill, which overrides this baseline. This skill does not impose them.

## Reference

For the two schools and their history, the full test-double taxonomy with
canonical definitions, the state-versus-interaction analysis, a worked
contract-test example running one suite against both an in-memory and a real
implementation, the two meanings of "unit", the pyramid-versus-trophy debate,
and the full when-to-double decision walkthrough, read
`references/test-driven-development.md`.
