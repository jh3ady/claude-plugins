# Get a Method under Test: Reference

Deeper background for the "Get a method under test" group in the
`legacy-dependency-breaking` skill. The skill body holds the one-line
summaries; this file holds the full mechanics, decision guidance, and worked
TypeScript examples for the techniques that open a seam inside a method body
so it can be exercised in a test.

The root problem in this group differs from the construction-dependency
problem in `get-a-class-into-a-harness.md`. Here the class can be
instantiated, but a hidden dependency buried in the method body blocks
testing: the method calls an external service, reads from the file system,
queries a database, or triggers a side effect the test environment cannot
tolerate. The techniques below create a seam between the method under test
and that dependency without altering the observable behaviour of the code
(Feathers, *Working Effectively with Legacy Code*, 2004, Chapter 10).

## Table of contents

1. [Subclass and Override Method (workhorse)](#1-subclass-and-override-method-workhorse)
2. [Extract and Override Call](#2-extract-and-override-call)
3. [Extract and Override Getter](#3-extract-and-override-getter)
4. [Extract and Override Factory Method (cross-reference)](#4-extract-and-override-factory-method-cross-reference)
5. [Parameterize Method](#5-parameterize-method)
6. [Break Out Method Object](#6-break-out-method-object)
7. [Adapt Parameter and Primitivize Parameter](#7-adapt-parameter-and-primitivize-parameter)
8. [Named-only: language-specific techniques not applicable to TypeScript](#8-named-only-language-specific-techniques-not-applicable-to-typescript)
9. [Closing note](#9-closing-note)
10. [Sources](#10-sources)

---

## 1. Subclass and Override Method (workhorse)

> **The central method-seam technique in object-oriented languages.** Reach for
> this first when the problematic dependency lives in a method the method under
> test calls via `this`.

### Intent

When the method under test calls another method on `this` that reaches out to a
real dependency (a network call, a database, a static utility), you make that
other method `protected` and override it in a test subclass. The test subclass
intercepts the call and returns or records a predictable value. The method under
test runs unchanged; only the behaviour of the called method is substituted.

This technique exploits the object seam: every call through `this` is a point
where the runtime dispatches to whichever subclass is in play. No modification
to the production call sites is needed (Feathers, *Working Effectively with
Legacy Code*, 2004, Chapter 25).

### Mechanism

1. Identify the method under test and the method it calls on `this` that holds
   the dependency you want to remove.
2. Change the visibility of the called method from `private` to `protected` if it
   is not already overridable. That is the only change to the production class.
3. In the test file, write a subclass of the class under test. Override the
   protected method. The override can return a hardcoded value, record the call
   for later assertion, throw a controlled exception, or do nothing.
4. Instantiate the test subclass in tests, not the production class. The method
   under test calls `this.theOverriddenMethod()`, which dispatches to the
   override.
5. Assert on the method under test's return value and on any state the override
   recorded.

### Example

```typescript
// Before: OrderService.processOrder() calls this.sendConfirmationEmail(), which
// makes a real SMTP call. The class can be constructed, but processOrder()
// cannot be tested without triggering that call.

class OrderService {
  processOrder(orderId: string, amount: number): string {
    if (amount <= 0) {
      throw new Error("Amount must be positive.");
    }
    this.sendConfirmationEmail(orderId); // real SMTP; no seam
    return `order-${orderId}-confirmed`;
  }

  private sendConfirmationEmail(orderId: string): void {
    // real SMTP call; cannot be suppressed in a unit test
  }
}
```

After changing `sendConfirmationEmail` to `protected` and overriding it in a
test subclass:

```typescript
class OrderService {
  processOrder(orderId: string, amount: number): string {
    if (amount <= 0) {
      throw new Error("Amount must be positive.");
    }
    this.sendConfirmationEmail(orderId);
    return `order-${orderId}-confirmed`;
  }

  // Changed from private to protected: the only production change.
  protected sendConfirmationEmail(orderId: string): void {
    // real SMTP call
  }
}

// Test subclass: overrides the protected method to capture calls instead of
// sending email.
class TestableOrderService extends OrderService {
  readonly emailedOrders: string[] = [];

  protected override sendConfirmationEmail(orderId: string): void {
    this.emailedOrders.push(orderId);
  }
}

test("processOrder returns a confirmation string for a valid amount", () => {
  const service = new TestableOrderService();
  const result = service.processOrder("ORD-88", 99);
  expect(result).toBe("order-ORD-88-confirmed");
  expect(service.emailedOrders).toEqual(["ORD-88"]);
});

test("processOrder throws when the amount is not positive", () => {
  const service = new TestableOrderService();
  expect(() => service.processOrder("ORD-89", 0)).toThrow(
    "Amount must be positive.",
  );
});
```

### Cost and risk

- **Low production change.** Only the visibility modifier of one method changes;
  no logic is altered.
- **Requires the method to be overridable.** TypeScript allows overriding any
  non-private, non-static method. If the method is `private`, changing it to
  `protected` is the necessary edit; that is the whole production change.
- **Inheritance coupling.** The test subclass depends on the production class
  hierarchy. If the signature of the overridden method changes, the test subclass
  must follow. This coupling is acceptable for a temporary scaffold; remove it
  once proper injection is in place.
- **Does not help with construction-time dependencies.** If the class cannot be
  instantiated in the test harness, address that first with the techniques in
  `get-a-class-into-a-harness.md`.

### When to prefer Subclass and Override Method

Reach for this technique first when a method under test calls another method on
`this` whose body touches a real dependency. It is broader than Extract and
Override Call because it replaces an entire existing method rather than
extracting a single inlined call. If the problematic behaviour is a one-liner
embedded directly in the method body (not already separated into its own
method), Extract and Override Call is the applicable move.

---

## 2. Extract and Override Call

### Intent

When a problematic call (to a static utility, a global function, or an inlined
expression) is embedded directly in the method under test and has no method of
its own to override, you extract exactly that call into a new protected method
and then override the new method in a test subclass. This is a narrower
intervention than Subclass and Override Method: instead of replacing a whole
collaborating method, you wrap a single call site (Feathers, *Working
Effectively with Legacy Code*, 2004, Chapter 25).

### Mechanism

1. Locate the exact statement or expression inside the method under test that you
   want to intercept. It is typically a static call, a module-level function, or
   an expression with a hard-to-control side effect.
2. Extract that statement into a new protected method. The method's parameters
   are the values the call needs; its return type is the type the call produces.
3. Replace the original inline expression with a call to the new protected method
   via `this`.
4. Write a test subclass that overrides the new protected method. The override
   returns a controllable value or records the arguments it receives.
5. Instantiate the test subclass in tests. The method under test calls
   `this.theExtractedMethod(...)`, which the override intercepts.

### Example

```typescript
// Before: InvoiceNotifier.notify() calls Logger.alert() -- a static call --
// inline. There is no instance method to override; the static call provides
// no object seam.

class Logger {
  static alert(message: string): void {
    // sends a page to on-call engineers; cannot be suppressed in a unit test
  }
}

class InvoiceNotifier {
  notify(invoiceId: string, amount: number): void {
    if (amount > 10_000) {
      Logger.alert(`High-value invoice ${invoiceId}: ${amount}`); // no seam
    }
    // ... remaining notification steps ...
  }
}
```

After extracting the static call into a protected method:

```typescript
class Logger {
  static alert(message: string): void {
    // sends a page to on-call engineers
  }
}

class InvoiceNotifier {
  notify(invoiceId: string, amount: number): void {
    if (amount > 10_000) {
      this.raiseAlert(`High-value invoice ${invoiceId}: ${amount}`);
    }
  }

  // Extracted and made protected: wraps the static call so a test subclass
  // can replace it.
  protected raiseAlert(message: string): void {
    Logger.alert(message);
  }
}

class TestableInvoiceNotifier extends InvoiceNotifier {
  readonly raisedAlerts: string[] = [];

  protected override raiseAlert(message: string): void {
    this.raisedAlerts.push(message);
  }
}

test("notify raises an alert when the invoice amount exceeds ten thousand", () => {
  const notifier = new TestableInvoiceNotifier();
  notifier.notify("INV-200", 15_000);
  expect(notifier.raisedAlerts).toEqual(["High-value invoice INV-200: 15000"]);
});

test("notify does not raise an alert for standard amounts", () => {
  const notifier = new TestableInvoiceNotifier();
  notifier.notify("INV-201", 500);
  expect(notifier.raisedAlerts).toHaveLength(0);
});
```

### Cost and risk

- **Adds one protected method to the production class.** That method is visible
  to subclasses. If it would surprise a reader, add a comment indicating it is a
  seam.
- **Narrowly scoped.** The extracted method isolates exactly the problematic
  call; other logic in the method under test is unaffected. This makes it safer
  and easier to review than overriding a broad collaborating method.
- **One step toward Subclass and Override Method.** If the problematic call is
  already in its own method (not inlined), skip the extraction and use Subclass
  and Override Method directly.

---

## 3. Extract and Override Getter

### Intent

When the method under test reads a field value or accesses a module-level
variable through a direct property read rather than a method call, you introduce
a protected getter that returns that value, then override the getter in a test
subclass to return a controllable substitute. This is the read-access
counterpart to Extract and Override Call (Feathers, *Working Effectively with
Legacy Code*, 2004, Chapter 25).

### Mechanism

1. Identify the field access or global variable read inside the method under test
   that you want the test to control.
2. Introduce a protected getter method on the production class. Its body returns
   the current value: `protected getConfig(): AppConfig { return appConfig; }`.
3. Replace the direct access inside the method under test with a call to the
   getter: `this.getConfig()` instead of `appConfig`.
4. Write a test subclass that overrides the getter to return whatever value the
   test scenario requires.

### Example

```typescript
// Before: FeatureGate.check() reads the module-level appConfig directly.
// A test cannot change what value the method sees without mutating the global,
// which would pollute other tests.

const appConfig = {
  enableNewPricingEngine: false,
};

class FeatureGate {
  check(featureName: string): boolean {
    if (featureName === "newPricingEngine") {
      return appConfig.enableNewPricingEngine; // direct global access; no seam
    }
    return false;
  }
}
```

After introducing the protected getter:

```typescript
const appConfig = {
  enableNewPricingEngine: false,
};

type AppConfig = { enableNewPricingEngine: boolean };

class FeatureGate {
  check(featureName: string): boolean {
    if (featureName === "newPricingEngine") {
      return this.getConfig().enableNewPricingEngine;
    }
    return false;
  }

  // Getter: the seam. Override in a test subclass to supply any config value.
  protected getConfig(): AppConfig {
    return appConfig;
  }
}

class TestableFeatureGate extends FeatureGate {
  constructor(private readonly config: AppConfig) {
    super();
  }

  protected override getConfig(): AppConfig {
    return this.config;
  }
}

test("check returns true when the feature is enabled in the config", () => {
  const gate = new TestableFeatureGate({ enableNewPricingEngine: true });
  expect(gate.check("newPricingEngine")).toBe(true);
});

test("check returns false when the feature is disabled in the config", () => {
  const gate = new TestableFeatureGate({ enableNewPricingEngine: false });
  expect(gate.check("newPricingEngine")).toBe(false);
});
```

### Cost and risk

- **Inheritance coupling.** The test subclass depends on the getter's return
  type. If the type changes, both the getter and the override must be updated.
- **Works best for a single access point.** When the field is read in many places
  inside the class, the getter centralises control of all of them, which is a
  benefit. If there are many unrelated globals each requiring their own getter,
  prefer injecting them through the constructor instead.
- **Natural stepping stone.** Once the getter exists, replacing it with a
  constructor parameter (Parameterize Constructor) and removing the getter
  entirely is a safe, mechanical follow-on that eliminates the subclassing
  requirement.

---

## 4. Extract and Override Factory Method (cross-reference)

The full mechanics of Extract and Override Factory Method are detailed in
`get-a-class-into-a-harness.md` (section 5), where the technique breaks a
construction dependency inside a constructor. Its role in this group is
narrower: when a method body (not a constructor) creates a collaborator with
`new` and that creation is the dependency you want to remove, extract the `new`
expression into a protected factory method on the class and override it in a
test subclass to return a substitute. The seam mechanism is identical to the
constructor case; only the site of the `new` expression differs.

---

## 5. Parameterize Method

### Intent

When a method resolves a dependency internally (by calling `new`, looking up a
singleton, or reading an internal default), you add a parameter for that
dependency so a test can pass a substitute directly. An overload signature
preserves the original call form for production callers (Feathers, *Working
Effectively with Legacy Code*, 2004, Chapter 25).

### Mechanism

1. Identify the dependency the method currently resolves internally: a `new`
   expression, a singleton accessor, or a hardcoded default value.
2. Extract an interface from that dependency if one does not already exist, so
   the parameter has a clean type.
3. Add a parameter of the interface type to the method and replace the internal
   resolution with the parameter.
4. Preserve the old signature by providing a production default: declare two
   overload signatures (one without the parameter, one with) and give the
   implementation signature a default value. Existing call sites that pass no
   second argument continue to receive the real dependency.
5. In tests, pass a substitute; assert on the result.

### Example

```typescript
// Before: OrderConfirmer.confirm() calls new Date() internally.
// Tests that assert on the output string cannot predict or control the
// timestamp, making them unreliable.

class OrderConfirmer {
  confirm(orderId: string): string {
    const timestamp = new Date().toISOString(); // internal construction; no seam
    return `${orderId} confirmed at ${timestamp}`;
  }
}
```

After adding a `Clock` parameter with a production default:

```typescript
interface Clock {
  now(): Date;
}

const systemClock: Clock = { now: () => new Date() };

class OrderConfirmer {
  // Overload: existing callers pass no second argument; production default is used.
  confirm(orderId: string): string;
  // Overload: tests pass a Clock substitute to control the timestamp.
  confirm(orderId: string, clock: Clock): string;
  // Implementation.
  confirm(orderId: string, clock: Clock = systemClock): string {
    const timestamp = clock.now().toISOString();
    return `${orderId} confirmed at ${timestamp}`;
  }
}

const fixedDate = new Date("2025-01-15T09:00:00.000Z");
const fixedClock: Clock = { now: () => fixedDate };

test("confirm includes the timestamp from the provided clock in the output", () => {
  const confirmer = new OrderConfirmer();
  const result = confirmer.confirm("ORD-7", fixedClock);
  expect(result).toBe("ORD-7 confirmed at 2025-01-15T09:00:00.000Z");
});
```

### Cost and risk

- **Method signature grows.** Even with an overload, the method now accepts an
  additional parameter with a production default. In a published API this is a versioning consideration.
- **No subclassing required.** This is a cleaner seam than Subclass and Override
  Method when the dependency is a value the method creates rather than a method
  it calls. The production class remains uninherited.
- **Natural escalation path.** If the same Clock is needed across multiple
  methods, promote it to a constructor parameter (Parameterize Constructor) to
  avoid threading it through every call site.

---

## 6. Break Out Method Object

### Intent

When a method is too long and tangled for a narrow seam (it creates multiple
dependencies internally, uses many locals, and is difficult to test because of
the combined weight of all those concerns), you move the entire method into its
own class. The new class receives the method's collaborators through its
constructor, making them injectable and the method's logic independently
testable (Feathers, *Working Effectively with Legacy Code*, 2004, Chapter 25).

### Mechanism

1. Identify the long, tangled method and list every dependency it creates
   internally: `new` expressions, singleton accesses, global reads.
2. Define an interface for each dependency that the test needs to substitute.
3. Create a new class (the method object) whose constructor receives those
   dependencies as interface-typed parameters.
4. Move the method's body into a `run()` method (or a descriptively named
   method) on the new class. Replace internal `new` expressions with the
   injected parameters.
5. Update the original class to delegate to the method object: instantiate it
   with real dependencies and call `run()`. The original method's public
   signature is unchanged.
6. In tests, instantiate the method object directly, passing fake implementations
   of the interfaces. The original class is not involved.

### Example

```typescript
// Before: BillingEngine.computeTotal() creates its own PriceCalculator and
// TaxResolver. Testing the method requires both real dependencies to be
// present, and neither can be substituted.

class PriceCalculator {
  basePrice(productId: string): number {
    // queries an external pricing service
    return 100;
  }
}

class TaxResolver {
  rateFor(region: string): number {
    // reads tax tables from a remote configuration store
    return 0.2;
  }
}

class BillingEngine {
  computeTotal(productId: string, region: string): number {
    const calc = new PriceCalculator(); // hard-coded construction; no seam
    const tax = new TaxResolver();      // hard-coded construction; no seam
    const base = calc.basePrice(productId);
    const rate = tax.rateFor(region);
    return base + base * rate;
  }
}
```

After breaking out a method object:

```typescript
interface PriceSource {
  basePrice(productId: string): number;
}

interface TaxSource {
  rateFor(region: string): number;
}

// The method object: receives collaborators through its constructor and runs
// the computation in isolation.
class TotalComputation {
  constructor(
    private readonly prices: PriceSource,
    private readonly taxes: TaxSource,
  ) {}

  run(productId: string, region: string): number {
    const base = this.prices.basePrice(productId);
    const rate = this.taxes.rateFor(region);
    return base + base * rate;
  }
}

// Production implementations: logic is unchanged; interfaces are now declared.
class PriceCalculator implements PriceSource {
  basePrice(productId: string): number {
    return 100; // external pricing service
  }
}

class TaxResolver implements TaxSource {
  rateFor(region: string): number {
    return 0.2; // remote configuration store
  }
}

// Original class delegates to the method object with real dependencies.
class BillingEngine {
  computeTotal(productId: string, region: string): number {
    return new TotalComputation(
      new PriceCalculator(),
      new TaxResolver(),
    ).run(productId, region);
  }
}

// Fakes used only in tests; they do not extend the production classes.
class FixedPriceSource implements PriceSource {
  constructor(private readonly price: number) {}

  basePrice(_productId: string): number {
    return this.price;
  }
}

class FixedTaxSource implements TaxSource {
  constructor(private readonly rate: number) {}

  rateFor(_region: string): number {
    return this.rate;
  }
}

test("TotalComputation adds the tax fraction to the base price", () => {
  const computation = new TotalComputation(
    new FixedPriceSource(200),
    new FixedTaxSource(0.1),
  );
  expect(computation.run("prod-1", "EU")).toBe(220); // 200 + 200 * 0.1
});
```

### Cost and risk

- **New class in the production codebase.** The method object lives alongside the
  original class. Name it after what it computes (`TotalComputation`,
  `DiscountEvaluation`) so its purpose is self-evident.
- **Delegation in the original class is not yet tested.** The one-liner that
  instantiates the method object and calls `run()` inside `BillingEngine` is
  covered only by an integration test. For most legacy codebases this is an
  acceptable interim state; the method object covers the logic.
- **Natural migration path.** Once the method object exists and is tested,
  accepting it as a constructor parameter on the original class (Parameterize
  Constructor) makes even the delegation testable and moves the design toward
  clean injection.

---

## 7. Adapt Parameter and Primitivize Parameter

### Intent

When the method under test takes a parameter whose type is hard to construct in
a test (a framework request object, a complex domain aggregate, a
platform-specific type), you have two options.

**Adapt Parameter**: introduce a narrow interface that captures only the fields
and methods the method actually uses. Tests pass a simple object literal or a
minimal fake that satisfies the interface; the real parameter type continues to
satisfy it structurally in TypeScript, so no change to production call sites is
needed (Feathers, *Working Effectively with Legacy Code*, 2004, Chapter 25).

**Primitivize Parameter**: when even an interface is more than necessary, extract
the primitive values the method actually reads from the parameter and replace
the parameter with those primitives directly. The original parameter type
disappears from the method signature. This is a more invasive change and is
appropriate only when the parameter type cannot be adapted.

### Mechanism (Adapt Parameter)

1. List every field or method on the parameter type that the method under test
   actually reads or calls.
2. Define a TypeScript interface with exactly those members. Name it after the
   role the parameter plays in the method, not after the concrete type.
3. Change the parameter type from the concrete type to the new interface.
4. In TypeScript, structural typing means the real parameter type already
   satisfies the interface as long as the members match. Adding an `implements`
   clause to the concrete type makes the relationship explicit and causes the
   compiler to catch future drift.
5. In tests, pass a simple object literal or a small inline class that satisfies
   the interface. No need to construct the full framework object.

### Example

```typescript
// Before: AccessChecker.isAllowed() takes an HttpRequest.
// HttpRequest is a framework class with many required constructor arguments;
// constructing one in a unit test is fragile, slow, and framework-dependent.

class HttpRequest {
  constructor(
    readonly userId: string,
    readonly permissions: string[],
    // ... many other framework-specific fields
  ) {}
}

class AccessChecker {
  isAllowed(request: HttpRequest, resource: string): boolean {
    return request.permissions.includes(`read:${resource}`);
  }
}
```

After adapting the parameter to a narrow interface:

```typescript
// Narrow interface: only the members the method actually uses.
interface CallerContext {
  readonly userId: string;
  readonly permissions: string[];
}

class AccessChecker {
  isAllowed(caller: CallerContext, resource: string): boolean {
    return caller.permissions.includes(`read:${resource}`);
  }
}

// Production: HttpRequest satisfies CallerContext structurally.
// The implements clause makes the contract explicit and compiler-checked.
class HttpRequest implements CallerContext {
  constructor(
    readonly userId: string,
    readonly permissions: string[],
  ) {}
}

test("isAllowed returns true when the caller holds the required permission", () => {
  const checker = new AccessChecker();
  const caller: CallerContext = {
    userId: "user-9",
    permissions: ["read:reports", "write:settings"],
  };
  expect(checker.isAllowed(caller, "reports")).toBe(true);
});

test("isAllowed returns false when the caller lacks the required permission", () => {
  const checker = new AccessChecker();
  const caller: CallerContext = { userId: "user-10", permissions: [] };
  expect(checker.isAllowed(caller, "reports")).toBe(false);
});
```

### Note on Primitivize Parameter

When the parameter type cannot be adapted (for example, a sealed third-party
class with no accessible interface), Primitivize Parameter extracts the specific
primitive values the method reads and replaces the parameter with those
primitives directly. For the example above, that would be
`isAllowed(userId: string, permissions: string[], resource: string)`. This
removes the dependency on the parameter type entirely. The cost is that every
call site must be updated to pass the extracted primitives rather than the
object; Adapt Parameter is therefore preferable when TypeScript's structural
typing allows it.

### Cost and risk

- **Adapt Parameter is low risk in TypeScript.** Structural typing means the
  production type already satisfies the interface without any change to its
  body; only the method signature changes.
- **Primitivize Parameter changes every call site.** It is a more invasive and
  disruptive change. Reserve it for cases where no interface can be defined over
  the parameter type.
- **Narrow interfaces have a secondary benefit.** They document exactly what the
  method needs from its parameter, which is useful design information independent
  of the testing goal. A narrow interface is also a candidate for an explicit
  port in a hexagonal architecture.

---

## 8. Named-only: language-specific techniques not applicable to TypeScript

These five techniques appear in the Feathers catalogue (Chapter 25) and are
listed here so the catalogue is complete. None applies to TypeScript because
TypeScript lacks the language or build mechanisms each technique requires.

- **Replace Function with Function Pointer (C only).** In C, a function pointer
  field can be swapped at runtime to replace a specific function call. TypeScript
  functions are already first-class values and can be passed as parameters or
  injected through interfaces; this low-level mechanism has no counterpart and no
  need.

- **Definition Completion (C and C++ only).** In C and C++, a type can be
  declared without a body, and a test-specific definition can be provided at link
  time. TypeScript has no separate declaration and definition phases and no link
  step; interfaces serve the same role at the type level without any build-time
  substitution.

- **Link Substitution (link-seam builds only).** At link time in compiled
  languages, a real library can be replaced with a test stub by changing the
  linker's search path. TypeScript compiles to JavaScript and is loaded by a
  module system at runtime; there is no static link step, so this technique does
  not apply. Jest module mocking achieves a related result through the module
  system, but that is a different mechanism operating at a different level.

- **Template Redefinition (C++ and generic-typed languages only).** In C++, a
  template can be re-instantiated with a test-specific type argument at compile
  time, effectively replacing a dependency through the type system. TypeScript
  generics are erased at compile time and do not support specialisation-based
  substitution; they provide type safety at the call site, not behavioural
  replacement.

- **Text Redefinition (interpreted languages such as Ruby only).** In languages
  where classes and methods are open and can be patched at runtime without
  compilation, a method can be replaced by assigning a new closure to the method
  name on the class or instance. TypeScript classes do not support open
  redefinition of compiled methods; the object-seam techniques above achieve the
  same isolation through subclassing and overriding.

---

## 9. Closing note

Subclass and Override Method is the workhorse of this group: it is the broadest
and most direct object seam, requiring only a visibility change to open. Reach
for Extract and Override Call or Extract and Override Getter when the dependency
is a single inlined call or a field read rather than a whole method. Parameterize
Method is the cleaner seam when the dependency is a value the method constructs
internally. When a method is too tangled for any of these narrow seams because it
creates multiple dependencies inline and the locals are too intertwined to
separate, Break Out Method Object is the appropriate move: it gives each
dependency its own injection point and makes the logic independently
instantiable. In every case the seam is scaffolding. Once the tests are green,
the clean destination is to inject the collaborator through the constructor or a
factory, making the dependency explicit and stable. See the
`dependency-injection` skill for that final step.

---

## 10. Sources

Michael Feathers, *Working Effectively with Legacy Code* (Prentice Hall, 2004).
Chapter 10: "I Can't Run This Method in a Test Harness" describes the
method-level dependency problem and the approach to opening a seam inside a
method body. Chapter 25: "Dependency-Breaking Techniques" is the primary
catalogue from which these techniques are drawn. Paraphrased throughout this
file; no page numbers cited.
