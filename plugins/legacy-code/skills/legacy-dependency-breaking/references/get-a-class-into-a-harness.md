# Get a Class into a Test Harness: Reference

Deeper background for the "Get a class into a test harness" group in the
`legacy-dependency-breaking` skill. The skill body holds the one-line
summaries; this file holds the full mechanics, decision guidance, and worked
TypeScript examples for the ten object-oriented techniques that break
construction dependencies so a class can be instantiated and exercised in a
test.

The root problem in this group is separation: the class cannot be constructed
in a test harness because its constructor acquires a resource, calls a
singleton, invokes a static initialiser, or triggers a side effect that the
test environment cannot tolerate. The techniques here create a seam between
the class and the dependency so the test can substitute something lightweight
(Feathers, *Working Effectively with Legacy Code*, 2004, Chapter 9).

## Table of contents

1. [Extract Interface](#1-extract-interface)
2. [Parameterize Constructor](#2-parameterize-constructor)
3. [Introduce Instance Delegator](#3-introduce-instance-delegator)
4. [Introduce Static Setter](#4-introduce-static-setter)
5. [Extract and Override Factory Method](#5-extract-and-override-factory-method)
6. [Supersede Instance Variable](#6-supersede-instance-variable)
7 and 8. [Pull Up Feature and Push Down Dependency](#7-and-8-pull-up-feature-and-push-down-dependency)
9 and 10. [Replace Global Reference with Getter and Encapsulate Global References](#9-and-10-replace-global-reference-with-getter-and-encapsulate-global-references)
11. [TypeScript guidance and the path to clean injection](#11-typescript-guidance-and-the-path-to-clean-injection)
12. [Sources](#12-sources)

---

## 1. Extract Interface

**Highest-value, lowest-risk technique in TypeScript.** Reach for this first
when the dependency is a class you own or can annotate.

### Intent

When a class depends on a concrete collaborator it cannot substitute in a
test, you define an interface over that collaborator's public surface, make
the production class implement it, and change the dependent class to hold the
interface type rather than the concrete type. Tests then supply lightweight
in-memory implementations of the interface instead of the real dependency.

This move is also the dependency-inversion step at the heart of hexagonal
architecture: the interface you extract is a port, and both the real adapter
and the test fake are interchangeable implementations of that port. See the
`hexagonal-architecture` skill for the broader architectural context.

### Mechanism

1. Identify the concrete collaborator that prevents the class under test from
   being constructed or exercised in a test.
2. Enumerate the methods of that collaborator that the dependent class actually
   calls. Only those methods belong in the interface; do not mirror the entire
   public surface.
3. Define a TypeScript interface with those methods. In TypeScript, structural
   typing means the production class already satisfies the interface without
   modification, but adding an explicit `implements` clause makes the contract
   visible and causes the compiler to catch future drift.
4. Change the dependent class's constructor parameter (or field) type from the
   concrete class to the new interface.
5. Write a fake implementation of the interface for tests: an in-memory class
   that stores or returns values without touching real infrastructure. Keep it
   as simple as possible.
6. In tests, pass the fake. In production, pass the real instance, usually via
   the composition root or a default parameter (see Parameterize Constructor).

### Example

```typescript
// Before: OrderRepository is hard-wired to DatabaseConnection.
// A test cannot substitute a faster alternative.

class DatabaseConnection {
  query(sql: string): string[] {
    // real SQL call against the production database
    return [];
  }
}

class OrderRepository {
  private readonly db: DatabaseConnection;

  constructor() {
    this.db = new DatabaseConnection(); // hard-coded; no seam
  }

  findByCustomer(customerId: string): string[] {
    return this.db.query(
      `SELECT id FROM orders WHERE customer_id = '${customerId}'`,
    );
  }
}
```

After extracting an interface:

```typescript
// Interface extracted from DatabaseConnection's used surface.
interface Database {
  query(sql: string): string[];
}

// Production implementation: body is unchanged; implements clause is the only addition.
class DatabaseConnection implements Database {
  query(sql: string): string[] {
    // real SQL call against the production database
    return [];
  }
}

// Repository now depends on the interface, not the concrete class.
class OrderRepository {
  constructor(private readonly db: Database) {}

  findByCustomer(customerId: string): string[] {
    return this.db.query(
      `SELECT id FROM orders WHERE customer_id = '${customerId}'`,
    );
  }
}

// Fake: in-memory implementation; no real infrastructure involved.
class FakeDatabase implements Database {
  private readonly rows: string[] = [];

  seedRows(...rows: string[]): void {
    this.rows.push(...rows);
  }

  query(_sql: string): string[] {
    return [...this.rows];
  }
}

test("findByCustomer returns all rows the database provides", () => {
  const db = new FakeDatabase();
  db.seedRows("order-1", "order-2");
  const repo = new OrderRepository(db);
  expect(repo.findByCustomer("cust-42")).toEqual(["order-1", "order-2"]);
});
```

### Cost and risk

- **Low risk.** If the production class already structurally satisfies the
  interface, no change is needed to its body; the compiler catches any mismatch
  immediately when `implements` is added.
- **Constructor signature changes.** If the dependent class previously
  constructed its own collaborator, that construction must move. Use a default
  parameter (Parameterize Constructor) to keep existing call sites unchanged.
- **New name in the codebase.** Consider co-locating the interface with the
  dependent class rather than with the concrete implementation, so the seam
  is visible where the dependency is consumed.

### When to prefer Extract Interface

Reach for Extract Interface first when the dependency is a class you own.
Combine it with Parameterize Constructor in the same edit to deliver the
interface through the constructor. If the dependency is a static method rather
than an instance, Extract Interface does not apply directly; use Introduce
Instance Delegator instead.

---

## 2. Parameterize Constructor

**Usually the fastest path to testability.** A default parameter keeps all
existing production call sites unchanged.

### Intent

When a class creates its dependency internally, you add a constructor
parameter for that dependency. The test passes a substitute; production
callers continue to call the constructor with no arguments because the
parameter defaults to the real implementation. No existing call site needs
updating.

### Mechanism

1. Identify the dependency that the constructor currently creates or looks up.
2. Extract an interface from that dependency if one does not yet exist (see
   Extract Interface).
3. Add a constructor parameter typed to the interface.
4. Set its default value to a call that creates the real implementation:
   `constructor(dep: Dep = new RealDep())`. Existing call sites that pass no
   argument continue to receive the real dependency.
5. Replace the internal creation of the dependency with the parameter value.
6. Write a test that passes a fake implementation; verify that the class uses
   it correctly.

### Example

```typescript
// Before: UserRegistration creates its own EmailService;
// tests cannot intercept the email call.

class EmailService {
  send(to: string, message: string): void {
    // real SMTP call
  }
}

class UserRegistration {
  private readonly emailService: EmailService;

  constructor() {
    this.emailService = new EmailService(); // hard-coded; no seam
  }

  register(email: string): void {
    // ... registration logic ...
    this.emailService.send(email, "Welcome to the platform.");
  }
}
```

After parameterizing the constructor:

```typescript
interface Mailer {
  send(to: string, message: string): void;
}

class EmailService implements Mailer {
  send(to: string, message: string): void {
    // real SMTP call
  }
}

class UserRegistration {
  private readonly emailService: Mailer;

  // Default keeps existing call sites unchanged: new UserRegistration() still works.
  constructor(emailService: Mailer = new EmailService()) {
    this.emailService = emailService;
  }

  register(email: string): void {
    this.emailService.send(email, "Welcome to the platform.");
  }
}

// Spy: captures sent messages for assertion without touching a real server.
class SpyMailer implements Mailer {
  readonly sent: Array<{ to: string; message: string }> = [];

  send(to: string, message: string): void {
    this.sent.push({ to, message });
  }
}

test("register sends a welcome email to the new user's address", () => {
  const mailer = new SpyMailer();
  const registration = new UserRegistration(mailer);
  registration.register("alice@example.com");
  expect(mailer.sent).toEqual([
    { to: "alice@example.com", message: "Welcome to the platform." },
  ]);
});
```

### Cost and risk

- **Minimal.** The production default means zero call sites need updating
  unless you choose to make the injection explicit at call sites as a follow-on
  refactor.
- **Constructor signature is now public API.** If the class is part of a
  published library, adding a parameter (even with a default) is a semver
  consideration.
- **Does not help when the constructor cannot accept parameters.** For example,
  when it is called by a framework that controls construction. In that case,
  use Extract and Override Factory Method or Supersede Instance Variable.

### When to prefer Parameterize Constructor

Prefer Parameterize Constructor when the dependency is created inside the
constructor and you can change the constructor signature. Combine with Extract
Interface to have a clean interface type for the parameter. If the constructor
is called by a framework or cannot be modified, use Extract and Override
Factory Method instead.

---

## 3. Introduce Instance Delegator

### Intent

Static calls cannot be overridden in subclasses and cannot be replaced by
injecting an alternative. When a class calls a static method that makes the
test environment unusable, you wrap the static call in a protected instance
method. A test subclass can then override that instance method and intercept
the call without touching the original class's logic.

### Mechanism

1. Identify the static call inside the class that blocks testing.
2. Introduce a new protected instance method on the class with any name that
   describes what the call does. Its body contains exactly the static call and
   returns the same type.
3. Replace the direct static call in the original method with a call to the
   new instance method: `this.log(...)` instead of `Logger.log(...)`.
4. Write a test subclass that extends the class under test and overrides the
   instance delegator. The override captures or suppresses the call rather than
   forwarding it to the static method.
5. Instantiate the test subclass in tests; the production class is never
   changed again.

### Example

```typescript
// Before: Logger.log is a static call; the test cannot intercept it
// or prevent it from writing to syslog.

class Logger {
  static log(message: string): void {
    // writes to the system log; not suppressible in a unit test
  }
}

class OrderProcessor {
  process(orderId: string): void {
    Logger.log(`Processing order ${orderId}`); // static call; no seam
    // ... remaining processing steps ...
  }
}
```

After introducing the instance delegator:

```typescript
class Logger {
  static log(message: string): void {
    // writes to the system log
  }
}

class OrderProcessor {
  // Delegator: wraps the static call so a test subclass can override it.
  protected log(message: string): void {
    Logger.log(message);
  }

  process(orderId: string): void {
    this.log(`Processing order ${orderId}`); // calls the instance method, not the static
    // ... remaining processing steps ...
  }
}

// Test subclass: overrides the delegator to capture log calls.
class TestableOrderProcessor extends OrderProcessor {
  readonly loggedMessages: string[] = [];

  protected override log(message: string): void {
    this.loggedMessages.push(message);
  }
}

test("process logs the order id before processing", () => {
  const processor = new TestableOrderProcessor();
  processor.process("ORD-101");
  expect(processor.loggedMessages).toContain("Processing order ORD-101");
});
```

### Cost and risk

- **Adds a protected method to production code.** The delegator is visible to
  subclasses. If the class is not designed for inheritance, document it as
  internal-to-testing until the dependency is resolved properly.
- **Inheritance creates coupling.** The test subclass is coupled to the
  production class hierarchy. If the production class changes its method
  signatures, the test subclass must follow.
- **Narrow fix.** This technique addresses only the static call itself. If
  the class also has construction-time dependencies, combine with Parameterize
  Constructor or Extract Interface.

### When to prefer Introduce Instance Delegator

Use Introduce Instance Delegator when the blocker is a static call rather than
an instance dependency. If the static call is the only problem, this technique
is faster than a full Extract Interface. If you control the class that owns
the static method, consider refactoring it to an instance method first, which
makes Parameterize Constructor or Extract Interface applicable instead.

---

## 4. Introduce Static Setter

> **Last resort.** Use only when injection is not viable. Prefer
> Parameterize Constructor or Extract Interface.

### Intent

When a singleton is constructed eagerly and its instance is accessible only
through a static accessor, tests cannot replace it with a substitute. Adding a
test-only static setter lets a test inject a fake before the code under
test runs. The setter introduces deliberate mutability into what is otherwise
treated as fixed global state.

### Mechanism

1. Identify the singleton class whose static accessor blocks testing.
2. Extract an interface from the singleton's used public surface so the field
   can hold either the real singleton or a fake (see Extract Interface).
3. Change the static field type from the concrete singleton class to the
   interface.
4. Add a static setter method (marked `@internal` or documented as test-only):
   it accepts an instance of the interface and assigns it to the static field.
5. Add a static reset method that restores the original instance. This is
   essential; failing to restore pollutes subsequent tests.
6. In tests, call the setter in `beforeEach` or at the start of the test, and
   call the reset in `afterEach` inside a `finally` block to guarantee
   restoration even when the test throws.

### Example

```typescript
// Before: ServiceLocator holds a singleton NotificationService
// that opens a real queue connection on construction.
// Tests cannot prevent that connection from being made.

class NotificationService {
  constructor() {
    // opens a real message-queue connection
  }

  send(userId: string, message: string): void {
    // publishes to the queue
  }
}

class ServiceLocator {
  private static readonly notifications: NotificationService =
    new NotificationService();

  static getNotifications(): NotificationService {
    return ServiceLocator.notifications;
  }
}

class OrderFulfillment {
  fulfill(orderId: string, userId: string): void {
    // ... fulfillment logic ...
    ServiceLocator.getNotifications().send(userId, `Order ${orderId} dispatched`);
  }
}
```

After introducing the static setter:

```typescript
interface Notifier {
  send(userId: string, message: string): void;
}

class NotificationService implements Notifier {
  constructor() {
    // opens a real message-queue connection
  }

  send(userId: string, message: string): void {
    // publishes to the queue
  }
}

class ServiceLocator {
  // Field is now the interface type so a fake can be substituted.
  private static notifications: Notifier = new NotificationService();

  static getNotifications(): Notifier {
    return ServiceLocator.notifications;
  }

  /**
   * @internal Last resort: test use only.
   * Save the existing instance via getNotifications() before calling this,
   * then restore it with resetForTest(original) in afterEach.
   */
  static setNotificationsForTest(notifier: Notifier): void {
    ServiceLocator.notifications = notifier;
  }

  /** @internal Restores the previously saved original instance. */
  static resetForTest(original: Notifier): void {
    ServiceLocator.notifications = original;
  }
}

class OrderFulfillment {
  fulfill(orderId: string, userId: string): void {
    ServiceLocator.getNotifications().send(userId, `Order ${orderId} dispatched`);
  }
}

class FakeNotifier implements Notifier {
  readonly sent: Array<{ userId: string; message: string }> = [];

  send(userId: string, message: string): void {
    this.sent.push({ userId, message });
  }
}

test("fulfill sends a dispatch notification to the affected user", () => {
  const original = ServiceLocator.getNotifications(); // save before substituting; no new construction in teardown
  const notifier = new FakeNotifier();
  ServiceLocator.setNotificationsForTest(notifier);
  try {
    const fulfillment = new OrderFulfillment();
    fulfillment.fulfill("ORD-55", "user-7");
    expect(notifier.sent).toEqual([
      { userId: "user-7", message: "Order ORD-55 dispatched" },
    ]);
  } finally {
    ServiceLocator.resetForTest(original); // restore the saved original; never leave the fake in place
  }
});
```

### Cost and risk

- **Test-induced mutability on global state.** Any test that fails to restore
  the singleton will corrupt every subsequent test in the same process. The
  `finally` block and a dedicated reset method are non-negotiable safeguards.
- **No help at construction time.** If the singleton is constructed with
  `new NotificationService()` in the class initialiser (as above), the real
  constructor still runs on module load. The setter only prevents subsequent
  uses from reaching it; it cannot prevent the initial construction side effect.
- **Hidden coupling.** Every class that calls `ServiceLocator.getNotifications()`
  is implicitly coupled to the singleton; none of that coupling is visible from
  the dependent class's interface. The long-term fix is to eliminate the service
  locator and use constructor injection throughout.

---

## 5. Extract and Override Factory Method

### Intent

When a class creates a dependency directly inside its constructor with `new`,
you cannot replace that object in a test without changing the constructor. If
adding a constructor parameter is not viable (for example, because the
constructor is called by a framework), you instead move the `new` expression
into a separate protected factory method. A test subclass overrides that method
and returns a lightweight substitute. The constructor now calls the overridable
method rather than calling `new` directly.

### Mechanism

1. Identify the `new` expression inside the constructor that creates the
   problematic dependency.
2. Extract an interface from the created type (see Extract Interface) so the
   factory method can declare a clean return type.
3. Change the constructor to call `this.createDependency()` instead of
   `new ConcreteType()`.
4. Add a protected method named after what it creates: `protected createGateway():
   PaymentGatewayPort { return new PaymentGateway(); }`. The production body
   creates the real instance.
5. In tests, write a subclass that overrides the factory method to return a
   fake. Access the fake after construction through the subclass.
6. Instantiate the test subclass in tests. Production code continues to
   instantiate the production class directly.

### Example

```typescript
// Before: PaymentGateway is hard-wired inside the constructor.
// Tests cannot substitute a lighter alternative.

class PaymentGateway {
  constructor() {
    // connects to the payment network
  }

  charge(amount: number): boolean {
    // real charge attempt
    return true;
  }
}

class OrderService {
  private readonly gateway: PaymentGateway;

  constructor() {
    this.gateway = new PaymentGateway(); // no seam; always creates the real gateway
  }

  placeOrder(amount: number): boolean {
    return this.gateway.charge(amount);
  }
}
```

After extracting the factory method:

```typescript
interface PaymentGatewayPort {
  charge(amount: number): boolean;
}

class PaymentGateway implements PaymentGatewayPort {
  constructor() {
    // connects to the payment network
  }

  charge(amount: number): boolean {
    return true;
  }
}

class OrderService {
  // Protected: the test subclass accesses it via the fakeGateway getter below.
  protected readonly gateway: PaymentGatewayPort;

  constructor() {
    this.gateway = this.createGateway(); // delegates to the overridable factory method
  }

  // Override in a test subclass to return a substitute.
  protected createGateway(): PaymentGatewayPort {
    return new PaymentGateway();
  }

  placeOrder(amount: number): boolean {
    return this.gateway.charge(amount);
  }
}

class FakePaymentGateway implements PaymentGatewayPort {
  readonly charges: number[] = [];

  charge(amount: number): boolean {
    this.charges.push(amount);
    return true;
  }
}

// Test subclass: overrides the factory method so the fake is injected at
// construction time. The fakeGateway getter exposes the stored reference.
class TestableOrderService extends OrderService {
  protected override createGateway(): PaymentGatewayPort {
    return new FakePaymentGateway();
  }

  // this.gateway is protected in the base class; the cast is safe because
  // createGateway() always returns FakePaymentGateway for this subclass.
  get fakeGateway(): FakePaymentGateway {
    return this.gateway as FakePaymentGateway;
  }
}

test("placeOrder calls charge on the gateway with the correct amount", () => {
  const service = new TestableOrderService();
  service.placeOrder(150);
  expect(service.fakeGateway.charges).toEqual([150]);
});
```

### Cost and risk

- **Requires marking the field protected.** If the class previously used
  `private readonly gateway`, it must become `protected readonly` so the test
  subclass can access it through the typed getter. This widens the visibility
  of an internal field.
- **Inheritance coupling.** The test subclass must be updated whenever the
  factory method's return type changes.
- **The production constructor still runs.** Only the `new PaymentGateway()`
  call is replaced; any other statements in the constructor still execute. This
  technique solves construction-time dependency creation, not all
  construction-time side effects.

### When to prefer Extract and Override Factory Method

Use this technique when the dependency is created with `new` inside the
constructor and Parameterize Constructor is not viable (for example, because
the framework controls construction). If Parameterize Constructor is viable,
prefer it: it is a simpler seam that does not require subclassing.

---

## 6. Supersede Instance Variable

> **Last resort.** Riskier than Parameterize Constructor. Use only when
> constructor parameterization is not viable and the real dependency's
> constructor side effects are acceptable during a test run.

### Intent

When a class assigns a dependency to an instance variable in its constructor
and you cannot change the constructor to accept a parameter (for example,
because there are too many call sites to update, or the constructor is called
by a framework), you add a test-only setter method that allows a test to
replace the value after construction. The test constructs the class normally,
then immediately calls the supersede method with a fake, before exercising any
behaviour.

### Mechanism

1. Identify the dependency assigned in the constructor that you need to
   replace in tests.
2. Extract an interface from that dependency (see Extract Interface) so the
   setter can accept an interface type rather than the concrete type.
3. Change the field from `private readonly` to `private` (removing `readonly`
   is required because the supersede method must be able to reassign it).
4. Change the field type from the concrete class to the interface.
5. Add a method (for example, `supersedeLogger(l: EventLogger): void`) that
   reassigns the field. Mark it `@internal` and document it as test-only.
6. In tests: construct the class (the real dependency's constructor still
   runs), call the supersede method with the fake, then exercise the class.

### Example

```typescript
// Before: PaymentProcessor creates its own AuditLogger.
// Dozens of call sites pass no arguments; adding a parameter would require
// updating every one of them.

class AuditLogger {
  constructor() {
    // reads configuration, opens an audit-database connection
  }

  log(event: string): void {
    // writes to the audit store
  }
}

class PaymentProcessor {
  private readonly logger: AuditLogger;

  constructor() {
    this.logger = new AuditLogger();
  }

  process(amount: number): void {
    this.logger.log(`Payment processed: ${amount}`);
    // ... payment logic ...
  }
}
```

After adding the supersede method:

```typescript
interface EventLogger {
  log(event: string): void;
}

class AuditLogger implements EventLogger {
  constructor() {
    // reads configuration, opens an audit-database connection
  }

  log(event: string): void {
    // writes to the audit store
  }
}

class PaymentProcessor {
  // No longer readonly: the supersede method must be able to reassign this field.
  private logger: EventLogger;

  constructor() {
    this.logger = new AuditLogger(); // still runs; side effects still occur
  }

  /**
   * @internal Last resort: test use only.
   * Prefer Parameterize Constructor when the constructor can accept a parameter.
   * The real AuditLogger is still constructed and its side effects still run.
   */
  supersedeLogger(logger: EventLogger): void {
    this.logger = logger;
  }

  process(amount: number): void {
    this.logger.log(`Payment processed: ${amount}`);
    // ... payment logic ...
  }
}

class FakeEventLogger implements EventLogger {
  readonly events: string[] = [];

  log(event: string): void {
    this.events.push(event);
  }
}

test("process logs the payment amount", () => {
  // The real AuditLogger is constructed here; its side effects still run.
  const processor = new PaymentProcessor();
  const fakeLogger = new FakeEventLogger();
  processor.supersedeLogger(fakeLogger); // replace after construction
  processor.process(250);
  expect(fakeLogger.events).toEqual(["Payment processed: 250"]);
});
```

### Cost and risk

- **The real dependency is always constructed.** Unlike Parameterize
  Constructor, which prevents the real object from being created in a test,
  Supersede Instance Variable cannot prevent the real `AuditLogger` from
  running. If that constructor opens a database connection or reads from the
  file system, those side effects still occur in every test. This is the
  primary reason the technique is a last resort.
- **Removes readonly protection.** The field must become mutable so that the
  supersede method can assign to it. This opens the field to accidental
  reassignment in production code, which readonly would have prevented.
- **Test order risk.** If the supersede call is accidentally omitted in a test,
  that test exercises the real dependency without realising it.

---

## 7 and 8. Pull Up Feature and Push Down Dependency

### Intent

**Pull Up Feature** addresses the case where a class inherits from a base that
carries a heavy dependency, and the feature you want to test lives in the
derived class alongside that dependency. You separate them by creating a new
abstract base class that contains only the testable feature, making the
dependency-touching behaviour abstract. Tests exercise the new base through a
lightweight subclass.

**Push Down Dependency** is the complementary move: the heavy dependency, which
was previously shared upward through a base class, is pushed down into the
specific concrete class that actually needs it. The base class or the extracted
parent is left dependency-free and testable.

In practice the two directions are often applied together: you pull the feature
up and push the dependency down in the same refactoring, achieving the same
result from two angles. The combined effect is a hierarchy where the testable
logic lives in a class that carries no dependency, and the dependency is
isolated in a leaf class.

### Mechanism

To **pull up** a feature:

1. Identify the method or methods on the class that contain the logic you want
   to test and that involve no call to the problematic dependency.
2. Create a new abstract base class. Move those methods to it. If the feature
   methods call any dependency-touching operations, declare those operations as
   `abstract` in the new base.
3. Change the original class to extend the new base and implement the abstract
   methods with the dependency-touching behaviour.
4. Write a lightweight test subclass of the new abstract base that provides
   stub implementations of the abstract methods. Test the pulled-up feature
   through that stub subclass.

To **push down** a dependency:

1. Identify a dependency that lives in a base class but is needed only by one
   or a subset of concrete subclasses.
2. Remove the dependency from the base class, making the relevant operations
   abstract.
3. Move the dependency and its operations into the concrete subclass that needs
   it.

### Example

```typescript
// Before: ReportGenerator extends DatabaseClient directly.
// The formatting feature (formatRow) and the database dependency are coupled
// in the same class. DatabaseClient cannot be constructed in a test.

class DatabaseClient {
  constructor() {
    // opens real database connections; cannot be created in a test
  }

  query(sql: string): string[] {
    return [];
  }
}

class ReportGenerator extends DatabaseClient {
  // Feature under test: pure logic, no database involvement.
  formatRow(row: string): string {
    return `| ${row} |`;
  }

  // Uses both the feature and the inherited dependency.
  generateReport(sql: string): string {
    return this.query(sql).map((r) => this.formatRow(r)).join("\n");
  }
}
```

After pulling up the feature and pushing down the dependency:

```typescript
// Feature pulled up: abstract base class with no dependency.
abstract class ReportFormatter {
  // Pure logic: can be tested without any database.
  formatRow(row: string): string {
    return `| ${row} |`;
  }

  // Abstract: dependency-touching behaviour delegated to the subclass.
  protected abstract fetchRows(sql: string): string[];

  // Template method: uses the pulled-up feature via the abstract hook.
  generateReport(sql: string): string {
    return this.fetchRows(sql).map((r) => this.formatRow(r)).join("\n");
  }
}

// Dependency pushed down: only DatabaseReportGenerator knows about the database.
class DatabaseClient {
  constructor() {
    // opens real database connections
  }

  query(sql: string): string[] {
    return [];
  }
}

class DatabaseReportGenerator extends ReportFormatter {
  private readonly db: DatabaseClient;

  constructor() {
    super();
    this.db = new DatabaseClient();
  }

  protected fetchRows(sql: string): string[] {
    return this.db.query(sql);
  }
}

// Test subclass of the abstract base: no DatabaseClient needed.
class StubReportFormatter extends ReportFormatter {
  constructor(private readonly rows: string[]) {
    super();
  }

  protected fetchRows(_sql: string): string[] {
    return this.rows;
  }
}

test("formatRow wraps the row content in pipe characters", () => {
  const formatter = new StubReportFormatter([]);
  expect(formatter.formatRow("data")).toBe("| data |");
});

test("generateReport joins all formatted rows with newlines", () => {
  const formatter = new StubReportFormatter(["row-a", "row-b"]);
  expect(formatter.generateReport("any sql")).toBe("| row-a |\n| row-b |");
});
```

### Cost and risk

- **Hierarchy restructuring.** Introducing an abstract base class changes the
  inheritance tree and may require updating all instantiation sites that used
  the original class name.
- **Abstract methods add a contract obligation.** Every future concrete subclass
  must implement the abstract methods, even when the implementation is trivial.
  If the hierarchy grows, this overhead accumulates.
- **Works well with template method.** The abstract base naturally expresses the
  template-method pattern: stable algorithm in the base, variable steps in
  subclasses. This is an architectural improvement, not just a testing scaffold.
- **Does not help when there is no inheritance.** If the class does not inherit
  from a dependency-laden base, use Parameterize Constructor or Extract
  Interface instead.

---

## 9 and 10. Replace Global Reference with Getter and Encapsulate Global References

### Intent

**Replace Global Reference with Getter** addresses the case where a class reads
a module-level or globally-scoped variable directly. Because the variable is
fixed at the module scope, the test cannot change what value the class sees.
You introduce a protected getter method that returns the global value. A test
subclass overrides the getter to return any value the test needs.

**Encapsulate Global References** goes further: instead of routing access
through a getter, you group the global variables behind an interface and pass
that interface into the class as a constructor parameter. The global is no
longer accessed at all inside the class; it is resolved at the composition
root and injected. This is the cleaner destination; Replace Global Reference
with Getter is a stepping stone toward it.

### Mechanism

For **Replace Global Reference with Getter**:

1. Identify each global or module-level variable that the class accesses
   directly and that the test needs to control.
2. Introduce a protected getter method on the class that returns the global.
   The getter body is just `return theGlobal;`.
3. Replace every direct reference to the global inside the class with a call
   to the getter: `this.getFeatureFlags()` instead of `featureFlags`.
4. Write a test subclass that overrides the getter to return whatever value the
   test scenario requires.

For **Encapsulate Global References**:

1. Define an interface that captures the shape of the global variables the
   class needs.
2. Declare the module-level constant with the interface type so the compiler
   verifies it satisfies the contract.
3. Add the interface as a constructor parameter (using Parameterize
   Constructor; keep a production default).
4. Replace all direct global accesses inside the class with reads from the
   constructor parameter.
5. In tests, pass an object literal or a stub that satisfies the interface;
   the global is never accessed in the test.

### Example

```typescript
// Before: CheckoutController reads the featureFlags global directly.
// A test cannot control which flag values the controller sees.

const featureFlags = {
  newCheckoutFlow: true,
  experimentalPricing: false,
};

class CheckoutController {
  start(): string {
    if (featureFlags.newCheckoutFlow) { // direct global access; no seam
      return "new-flow";
    }
    return "legacy-flow";
  }
}
```

**Technique 9: Replace Global Reference with Getter.** Wrap the global access in
a protected getter; a test subclass overrides it.

```typescript
const featureFlags = {
  newCheckoutFlow: true,
  experimentalPricing: false,
};

type FlagState = { newCheckoutFlow: boolean; experimentalPricing: boolean };

class CheckoutController {
  // Getter: the seam. Production body returns the real global.
  protected getFeatureFlags(): FlagState {
    return featureFlags;
  }

  start(): string {
    if (this.getFeatureFlags().newCheckoutFlow) {
      return "new-flow";
    }
    return "legacy-flow";
  }
}

// Test subclass: overrides the getter to supply any flag state the test needs.
class TestableCheckoutController extends CheckoutController {
  constructor(private readonly flags: FlagState) {
    super();
  }

  protected override getFeatureFlags(): FlagState {
    return this.flags;
  }
}

test("start returns new-flow when newCheckoutFlow is enabled", () => {
  const controller = new TestableCheckoutController({
    newCheckoutFlow: true,
    experimentalPricing: false,
  });
  expect(controller.start()).toBe("new-flow");
});

test("start returns legacy-flow when newCheckoutFlow is disabled", () => {
  const controller = new TestableCheckoutController({
    newCheckoutFlow: false,
    experimentalPricing: false,
  });
  expect(controller.start()).toBe("legacy-flow");
});
```

**Technique 10: Encapsulate Global References.** Define an interface, pass it
via the constructor. No subclassing required; the global is injected.

```typescript
interface FeatureFlags {
  readonly newCheckoutFlow: boolean;
  readonly experimentalPricing: boolean;
}

// Production constant typed to the interface; compiler verifies conformance.
const productionFlags: FeatureFlags = {
  newCheckoutFlow: true,
  experimentalPricing: false,
};

class CheckoutController {
  // Flags arrive via the constructor; no global access inside the class.
  constructor(private readonly flags: FeatureFlags) {}

  start(): string {
    if (this.flags.newCheckoutFlow) {
      return "new-flow";
    }
    return "legacy-flow";
  }
}

test("start returns new-flow when the flag is enabled", () => {
  const controller = new CheckoutController({
    newCheckoutFlow: true,
    experimentalPricing: false,
  });
  expect(controller.start()).toBe("new-flow");
});

test("start returns legacy-flow when the flag is disabled", () => {
  const controller = new CheckoutController({
    newCheckoutFlow: false,
    experimentalPricing: false,
  });
  expect(controller.start()).toBe("legacy-flow");
});

// Composition root: production callers pass the real global.
// const checkout = new CheckoutController(productionFlags);
```

### Cost and risk

- **Technique 9 still relies on inheritance.** The test subclass is coupled to
  the production class hierarchy; if the getter's return type changes, both
  must be updated.
- **Technique 10 is the cleaner destination** but requires changing the
  constructor signature. If many call sites exist, use a default parameter to
  keep them unchanged: `constructor(flags: FeatureFlags = productionFlags)`.
- **Multiple globals.** If the class reads several unrelated globals, encapsulate
  them into separate interfaces rather than bundling them into one. Bundling
  unrelated globals violates the Interface Segregation Principle and makes fakes
  harder to write.

---

## 11. TypeScript guidance and the path to clean injection

In TypeScript, Extract Interface and Parameterize Constructor are the right
first moves for almost every construction dependency. They introduce a minimal
seam with low production risk and point directly toward the clean architecture:
interfaces as ports, constructor injection as the wiring mechanism. Introduce
Static Setter and Supersede Instance Variable are last resorts, weighted by the
cost of test-induced mutability and the risk of cross-test state pollution;
reach for them only when the constructor cannot safely accept a parameter and
Extract and Override Factory Method is also not viable. When the scaffolding
techniques have served their purpose and the tests are green, replace them with
proper constructor injection as described in the `dependency-injection` skill:
the seams you opened are the dependency boundaries the final design should make
explicit and stable.

---

## 12. Sources

Michael Feathers, *Working Effectively with Legacy Code* (Prentice Hall, 2004).
Chapter 9: "I Can't Get This Class into a Test Harness" describes the
separation problem and the construction-dependency scenarios that motivate these
techniques. Chapter 25: "Dependency-Breaking Techniques" is the primary
catalogue from which these ten techniques are drawn. Paraphrased throughout
this file; no page numbers cited.
