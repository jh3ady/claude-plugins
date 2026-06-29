# Add Behaviour Without Touching Existing Code: Reference

Deeper background for the "Add behaviour without touching existing code" group in
the `legacy-dependency-breaking` skill. The skill body holds the one-line
summaries; this file holds the full mechanics, decision guidance, and worked
TypeScript examples for the four techniques that let you grow new, tested
behaviour alongside untested legacy code.

Each technique embodies the same principle: the legacy tangle does not grow, and
every new line of code starts life under test (Feathers, *Working Effectively with
Legacy Code*, 2004, Chapter 6).

## Table of contents

1. [Sprout Method](#1-sprout-method)
2. [Sprout Class](#2-sprout-class)
3. [Wrap Method](#3-wrap-method)
4. [Wrap Class](#4-wrap-class)
5. [Choosing within this group](#5-choosing-within-this-group)
6. [Sources](#6-sources)

---

## 1. Sprout Method

### Intent

Reach for Sprout Method when you must add new logic inside an existing method that
you cannot currently get under test. Rather than editing the untested body, you
write the new logic as a separate, fully tested method on the same class and add a
single call to it from the host method. The host method gains one new call site and
nothing else in it changes. The new method is the only code you test at this point;
the host method remains untested but also remains unedited except for that one call.

This technique is the right choice when the host class can still be instantiated in
a test harness (possibly with minimal stubs for its constructor dependencies) but
the host method's body is too tangled or side-effect-laden to exercise as a whole.

### Mechanism

1. Identify the exact piece of new logic you need to add and draw a clear boundary
   around it: what are its inputs, and what does it produce?
2. Write the new logic as a new public method on the host class. Name it after what
   it computes or produces, not after where it will be called from.
3. Write tests for the new method in isolation. If the class constructor requires
   heavy dependencies, supply minimal no-op stubs so you can instantiate the class;
   the test targets the new method directly and does not call the host method.
4. Once all tests for the new method pass, add exactly one call to it at the
   appropriate point in the host method's body. Change no other line of the host
   method.
5. Verify that the application behaves correctly end to end. The new method is
   covered by its own tests; the host method is left for future characterization
   work (see the sibling skill `legacy-code-changes`).

### Example

New requirement: after each order is submitted, produce a packing-slip string for
the warehouse print queue. The existing `submit` method is too tangled to test.

```typescript
interface OrderLine {
  sku: string;
  quantity: number;
}

interface Order {
  id: string;
  lines: OrderLine[];
}

// legacyPrintQueue is a module-level singleton; assumed to exist.
declare const legacyPrintQueue: { enqueue(document: string): void };

// Before: submit() handles the whole order lifecycle but has no tests.
// A new requirement asks for a packing-slip string after each submission.
class OrderProcessor {
  submit(order: Order): void {
    // ~120 lines: inventory reservation, payment charging,
    // legacy EDI integration. Untested; do not edit.
  }
}

// After: two new calls added to submit(); nothing else in the method changed.
class OrderProcessor {
  submit(order: Order): void {
    // All existing lines: unchanged.
    const slip = this.buildPackingSlip(order.lines); // NEW
    legacyPrintQueue.enqueue(slip);                  // NEW
  }

  // The sprout: tested independently; depends only on its own parameter.
  buildPackingSlip(lines: OrderLine[]): string {
    const rows = lines.map((l) => `${l.sku} x${l.quantity}`).join("\n");
    return `PACKING SLIP\n${rows}`;
  }
}

// Tests target the sprout only; submit() is never called.
// OrderProcessor has no constructor arguments here, so no stub is needed.
test("buildPackingSlip lists each line with its quantity", () => {
  const processor = new OrderProcessor();
  const lines: OrderLine[] = [
    { sku: "WIDGET-A", quantity: 3 },
    { sku: "GADGET-B", quantity: 1 },
  ];
  expect(processor.buildPackingSlip(lines)).toBe(
    "PACKING SLIP\nWIDGET-A x3\nGADGET-B x1",
  );
});

test("buildPackingSlip with a single line", () => {
  const processor = new OrderProcessor();
  expect(processor.buildPackingSlip([{ sku: "PART-Z", quantity: 10 }])).toBe(
    "PACKING SLIP\nPART-Z x10",
  );
});
```

When the class constructor does require heavy dependencies (a database adapter, an
external service client), supply a no-op stub for each so the instance can be
created in the test. The test still targets only the sprouted method.

```typescript
interface LegacyPersister {
  commit(orderId: string): void;
}

class NullLegacyPersister implements LegacyPersister {
  commit(_orderId: string): void { /* no-op */ }
}

class OrderProcessor {
  constructor(private readonly persister: LegacyPersister) {}

  submit(order: Order): void {
    this.persister.commit(order.id);
    // ... more untested lines ...
    const slip = this.buildPackingSlip(order.lines); // NEW
    legacyPrintQueue.enqueue(slip);                  // NEW
  }

  buildPackingSlip(lines: OrderLine[]): string {
    const rows = lines.map((l) => `${l.sku} x${l.quantity}`).join("\n");
    return `PACKING SLIP\n${rows}`;
  }
}

// The stub satisfies the constructor; the test still targets buildPackingSlip.
test("buildPackingSlip lists each line with its quantity", () => {
  const processor = new OrderProcessor(new NullLegacyPersister());
  const lines: OrderLine[] = [{ sku: "WIDGET-A", quantity: 3 }];
  expect(processor.buildPackingSlip(lines)).toBe("PACKING SLIP\nWIDGET-A x3");
});
```

The host method `submit` is left entirely untested. The new method `buildPackingSlip`
is fully covered. That asymmetry is intentional: the legacy tangle does not grow,
and the new behaviour starts life under test.

### Cost and risk

- **The host method stays untested.** The rest of `submit` remains a risk area; a
  regression in those lines will not be caught by the new tests.
- **The sprout is public by necessity.** Making `buildPackingSlip` public exposes it
  as part of the class interface. If the class is part of a public API, callers may
  depend on the sprout directly. A code comment marking it as internal until the
  host is brought under test reduces that risk.
- **Minimal coupling.** Because the sprout depends only on its own parameters, it
  carries no coupling to the host method's internal state. This makes it safe to
  promote later to its own class or to inline it once the host method is testable.

### When to prefer Sprout Method over the others

Use Sprout Method over Sprout Class when the host class can be instantiated in a
test, even with stubs; it is the simpler of the two sprouting approaches. Prefer
it over Wrap Method when the new logic belongs at a specific internal point in the
host method's flow rather than unconditionally before or after the entire method.

---

## 2. Sprout Class

### Intent

Reach for Sprout Class when the host class itself cannot be instantiated in a test
harness, typically because its constructor opens real resources that make
construction impossible in isolation: a database connection pool, a network socket,
a file-system handle, or a globally-registered singleton. In that situation, even
Sprout Method fails because there is no way to create an instance of the class to
call the new method on. The solution is to put the new logic in an entirely new
class that carries none of those dependencies, write full TDD tests for it
independently, and add a small number of lines to the host class that construct and
use the new class.

### Mechanism

1. Identify the new behaviour and its data needs. The key question is: can this
   logic stand alone in a class of its own without reaching back into the host
   class's private state?
2. Write the new class. Keep it entirely free of the heavy dependencies that make
   the host class untestable. Pass everything it needs as constructor parameters or
   method arguments.
3. Write tests for the new class with full TDD: write a failing test, make it pass,
   refactor. No stubs or special infrastructure are needed because the new class has
   none of the problematic dependencies.
4. In the host class, add the minimum necessary code to construct the new class and
   call the method that contains the new behaviour. Keep the addition as small as
   possible: two or three lines at most.
5. Verify application behaviour end to end. The new class is fully tested; the host
   class is unchanged except for the minimal addition.

### Example

New requirement: record an audit entry every time a report is dispatched for
scheduling. The host class constructs its own database pool and SMTP client, making
it impossible to instantiate in a test.

```typescript
// DatabasePool and SmtpMailer are legacy types that open real connections
// on construction; they are declared here to make the example self-contained.
declare class DatabasePool {
  constructor(host: string);
  query(sql: string, params: unknown[]): string;
}
declare class SmtpMailer {
  constructor(host: string);
  send(to: string, content: string): void;
}

// Module-level audit log, assumed to exist.
declare const auditLog: { write(entry: string): void };

// The host class: cannot be instantiated without real infrastructure.
class ReportScheduler {
  private readonly db: DatabasePool;
  private readonly mailer: SmtpMailer;

  constructor() {
    this.db = new DatabasePool("production");      // opens real connections
    this.mailer = new SmtpMailer("smtp.corp.com"); // opens a real socket
  }

  schedule(reportId: string, recipientEmail: string): void {
    const content = this.db.query(
      "SELECT content FROM reports WHERE id = ?",
      [reportId],
    );
    this.mailer.send(recipientEmail, content);
  }
}
```

The constructor makes `ReportScheduler` impossible to instantiate in a test. Sprout
Method cannot help because there is no way to get an instance. Instead, put the
new audit logic in a new class with no such dependencies:

```typescript
// The sprout class: no heavy dependencies; fully testable in isolation.
class ScheduleAuditEntry {
  readonly reportId: string;
  readonly recipientEmail: string;
  readonly scheduledAt: Date;

  constructor(reportId: string, recipientEmail: string, scheduledAt: Date) {
    this.reportId = reportId;
    this.recipientEmail = recipientEmail;
    this.scheduledAt = scheduledAt;
  }

  toLogLine(): string {
    return (
      `[${this.scheduledAt.toISOString()}] ` +
      `scheduled ${this.reportId} for ${this.recipientEmail}`
    );
  }
}

// Host class after: three new lines in schedule(); nothing else changed.
class ReportScheduler {
  private readonly db: DatabasePool;
  private readonly mailer: SmtpMailer;

  constructor() {
    this.db = new DatabasePool("production");
    this.mailer = new SmtpMailer("smtp.corp.com");
  }

  schedule(reportId: string, recipientEmail: string): void {
    // NEW: construct the sprout class, write the audit entry.
    const entry = new ScheduleAuditEntry(reportId, recipientEmail, new Date());
    auditLog.write(entry.toLogLine());

    // Original lines: unchanged.
    const content = this.db.query(
      "SELECT content FROM reports WHERE id = ?",
      [reportId],
    );
    this.mailer.send(recipientEmail, content);
  }
}

// Full TDD for the new class; no stubs needed because it has no heavy dependencies.
test("toLogLine includes the report id, recipient, and ISO timestamp", () => {
  const fixed = new Date("2024-03-15T09:00:00.000Z");
  const entry = new ScheduleAuditEntry("rpt-42", "alice@example.com", fixed);
  expect(entry.toLogLine()).toBe(
    "[2024-03-15T09:00:00.000Z] scheduled rpt-42 for alice@example.com",
  );
});

test("toLogLine uses the supplied recipient email", () => {
  const fixed = new Date("2024-03-15T09:00:00.000Z");
  const entry = new ScheduleAuditEntry("rpt-99", "bob@example.com", fixed);
  expect(entry.toLogLine()).toBe(
    "[2024-03-15T09:00:00.000Z] scheduled rpt-99 for bob@example.com",
  );
});
```

The new class is self-contained and fully covered by tests. `ReportScheduler` is
untouched except for the three new lines.

### Cost and risk

- **The host class remains untested.** `ReportScheduler`'s core logic is still
  behind a wall of real infrastructure dependencies. The new behaviour is safe, but
  regressions in the original logic remain invisible to the test suite.
- **A new class appears in the codebase.** This can feel like over-engineering when
  the new logic is small. Accept that temporary awkwardness; it resolves when the
  host class is eventually brought under test and the sprout class is either folded
  back in or promoted to a permanent independent type.
- **The addition touches the host method.** Even adding three lines to an untested
  method carries a small risk of misplacing them. Keep the additions minimal,
  place them carefully (before or after the original logic, rarely interleaved),
  and verify end-to-end behaviour after the change.

### When to prefer Sprout Class over the others

Use Sprout Class over Sprout Method when the host class cannot be instantiated in a
test at all. If you can get an instance (even with stubs), the simpler Sprout Method
is preferable. Use Sprout Class over Wrap Class when the new logic is a genuinely
new, independent concern running alongside the existing flow rather than an
interception of the existing operation's inputs or outputs.

---

## 3. Wrap Method

### Intent

Reach for Wrap Method when you need to run new behaviour unconditionally before or
after an existing method, without changing anything inside that method. Rather than
editing the untested body, you give the original implementation a new name, write a
new method that uses the original public name, and have the wrapper call the renamed
original alongside the new tested step. Callers see no change: they still call the
same method name and get the same return type.

Use Wrap Method over Sprout Method when you need the new behaviour to run around
the entire method rather than at a specific internal point, or when you cannot
safely add even a single line to the host method body.

### Mechanism

There are two forms. Choose based on whether callers must remain unaware of the
change.

**Form 1: rename-and-wrap (callers unchanged).** This is the common form.

1. Rename the existing method by adding a suffix or prefix (for example, `save`
   becomes `saveCore`). Make it private. The renamed method is an exact copy of the
   original; do not change a single line of its body.
2. Create a new method with the original public name and the same parameter and
   return types as the original.
3. Write the new behaviour as a separate tested method (or inline it in the wrapper
   if it is trivial). Test it in isolation before wiring it into the wrapper.
4. In the new wrapper method, call the renamed original and call the new behaviour
   in the required order (before, after, or both). Return the original method's
   return value unchanged.
5. Verify that all callers, which still invoke the original name, compile and
   behave correctly.

**Form 2: new-name form (callers updated).** Use this when the original method
cannot be renamed; for example, it satisfies an interface that you do not yet wish
to change, or it is the target of a reflection or decorator mechanism.

1. Leave the original method entirely unchanged.
2. Write a new method with a new name that calls the original and adds the new
   behaviour.
3. Update every call site to use the new name.
4. Test the new method independently.

### Example

New requirement: after every payment charge, record an audit string for compliance.
The existing `charge` method must not be touched; it is too tangled to test.

```typescript
interface PaymentResult {
  success: boolean;
  transactionId: string;
}

// Before: charge() is the public API; its body is complex and untested.
class PaymentService {
  charge(amount: number, cardToken: string): PaymentResult {
    // ~100 lines: external HTTP calls, retries, error mapping.
    // Do not edit.
    return { success: true, transactionId: "txn-abc" };
  }
}
```

**Form 1: rename-and-wrap.**

```typescript
class PaymentService {
  // Renamed: original body moved here, unchanged.
  private chargeCore(amount: number, cardToken: string): PaymentResult {
    // ~100 lines: unchanged.
    return { success: true, transactionId: "txn-abc" };
  }

  // New public wrapper; callers are unaffected.
  charge(amount: number, cardToken: string): PaymentResult {
    const result = this.chargeCore(amount, cardToken);
    this.auditRecord(amount, result); // new tested step runs after
    return result;
  }

  // The new tested behaviour: depends only on its own parameters.
  auditRecord(amount: number, result: PaymentResult): string {
    const status = result.success ? "ok" : "fail";
    return `charged ${amount} [${status}] txn=${result.transactionId}`;
  }
}

// Tests target auditRecord in isolation; charge() and chargeCore() are not called.
// PaymentService has no constructor parameters here, so no stub is needed.
test("auditRecord describes a successful charge", () => {
  const service = new PaymentService();
  expect(
    service.auditRecord(150, { success: true, transactionId: "txn-1" }),
  ).toBe("charged 150 [ok] txn=txn-1");
});

test("auditRecord describes a failed charge", () => {
  const service = new PaymentService();
  expect(
    service.auditRecord(150, { success: false, transactionId: "txn-2" }),
  ).toBe("charged 150 [fail] txn=txn-2");
});
```

**Form 2: new-name form.** Use this when `charge` cannot be renamed because it
satisfies an interface (for example, `PaymentGateway`).

```typescript
// charge() is kept exactly as-is; all call sites that need audit move to
// chargeWithAudit().
class PaymentService {
  charge(amount: number, cardToken: string): PaymentResult {
    // ~100 lines: unchanged.
    return { success: true, transactionId: "txn-abc" };
  }

  chargeWithAudit(amount: number, cardToken: string): PaymentResult {
    const result = this.charge(amount, cardToken);
    this.auditRecord(amount, result);
    return result;
  }

  auditRecord(amount: number, result: PaymentResult): string {
    const status = result.success ? "ok" : "fail";
    return `charged ${amount} [${status}] txn=${result.transactionId}`;
  }
}
```

In Form 2 every former call site that used `charge` must be updated to
`chargeWithAudit`. The original `charge` method is left intact and continues to
satisfy any interface it implements.

### Cost and risk

- **The original method body stays untested.** `chargeCore` (in Form 1) or the
  original `charge` (in Form 2) is never exercised by the new tests. A regression
  in those lines remains invisible.
- **Renaming changes the method's presence in interfaces (Form 1).** If the original
  method was declared in an interface, making it private and renaming it breaks the
  contract. Use Form 2 in that situation, or extract a narrower interface before
  applying the wrap.
- **The wrapper itself carries no logic and is not independently tested.** Its
  correctness depends on wiring the two calls in the right order. Keep the wrapper
  body as short as possible: the call to the original, the call to the new
  behaviour, and the return.
- **Form 2 requires updating call sites.** If the method is called in many places,
  the mechanical update adds risk. Consider Wrap Class in that situation.

### When to prefer Wrap Method over the others

Use Wrap Method over Sprout Method when the new behaviour must run around the
whole method rather than at a specific internal step. Prefer Wrap Class over Wrap
Method when the new behaviour must apply to several methods on the class, or when
you need a seam at the type level without modifying the original class at all.

---

## 4. Wrap Class

### Intent

Reach for Wrap Class when you need to add behaviour that surrounds calls to an
entire class rather than a single method, or when you want to introduce a clean
seam without modifying the original class at all. Using the Decorator pattern, you
write a new class that implements the same interface as the original, holds a
reference to the original instance, and delegates every call to it while adding new
behaviour before or after. The original class is not changed in any way. The new
decorator is what goes under test.

Wrap Class is the most structurally isolated of the four techniques: it requires
no modifications to the original class, not even a rename.

### Mechanism

1. Identify the interface (or base type) that both the original class and the
   wrapper must satisfy. If no such interface exists, extract one now: pull out only
   the methods callers depend on. In TypeScript, structural typing means the
   original class need not explicitly declare that it implements the interface; any
   object whose shape satisfies it is a valid implementation.
2. Write the wrapper class. Its constructor receives the original instance as a
   parameter typed to the interface. It implements the interface itself.
3. For each method in the interface, write a delegation: call the same method on the
   inner instance and return its result. Add the new behaviour at the appropriate
   point (before the delegation, after, or both) in the method or methods where it
   is needed.
4. Write the new behaviour as a separate method on the wrapper (or inline if
   trivial) and test it independently before wiring it into the delegation.
5. Write tests for the wrapper class, supplying a spy or stub for the inner
   instance. Verify that delegation occurs and that the new behaviour runs at the
   right point.
6. At the composition root, replace construction of the original with construction
   of the wrapper around the original:
   `new WrapperClass(new OriginalClass(...))`. Callers that hold the interface type
   see no change.

### Example

New requirement: prefix every generated report with a title header. The existing
`LegacyReportGenerator` is complex and untested; it must not be modified.

```typescript
interface ReportData {
  title: string;
  rows: string[];
}

interface ReportGenerator {
  generate(data: ReportData): string;
}

// Original: complex, untested; do not touch.
class LegacyReportGenerator implements ReportGenerator {
  generate(data: ReportData): string {
    // Complex legacy template engine. Not under test.
    return `<report>${data.rows.join("")}</report>`;
  }
}

// Wrap Class: a decorator that adds a header without touching the original.
class HeaderReportGenerator implements ReportGenerator {
  constructor(private readonly inner: ReportGenerator) {}

  generate(data: ReportData): string {
    const header = this.buildHeader(data.title);
    return header + this.inner.generate(data);
  }

  // The new tested behaviour: depends only on its own parameter.
  buildHeader(title: string): string {
    return `=== ${title} ===\n`;
  }
}

// Stub inner: satisfies the interface; returns a fixed string.
class StubReportGenerator implements ReportGenerator {
  generate(_data: ReportData): string {
    return "STUB_CONTENT";
  }
}

// Tests for the new behaviour in isolation.
test("buildHeader wraps the title with equals signs and a newline", () => {
  const generator = new HeaderReportGenerator(new StubReportGenerator());
  expect(generator.buildHeader("Sales Q1")).toBe("=== Sales Q1 ===\n");
});

// Tests for the wrapper's delegation and composition.
test("generate prepends the header to the inner generator's output", () => {
  const generator = new HeaderReportGenerator(new StubReportGenerator());
  const result = generator.generate({ title: "Sales Q1", rows: [] });
  expect(result).toBe("=== Sales Q1 ===\nSTUB_CONTENT");
});

test("generate delegates to the inner generator with the original data", () => {
  const calls: ReportData[] = [];
  // TypeScript structural typing: an object literal satisfies ReportGenerator.
  const spy: ReportGenerator = {
    generate(data) {
      calls.push(data);
      return "INNER_RESULT";
    },
  };
  const generator = new HeaderReportGenerator(spy);
  const data: ReportData = { title: "T", rows: ["r1"] };
  generator.generate(data);
  expect(calls).toHaveLength(1);
  expect(calls[0]).toBe(data);
});

// Composition root: original class is unchanged; only the wiring changes.
const generator: ReportGenerator = new HeaderReportGenerator(
  new LegacyReportGenerator(),
);
```

`LegacyReportGenerator` is not modified. `HeaderReportGenerator` is fully tested.
The `ReportGenerator` interface at every call site is unchanged.

### Cost and risk

- **Every method in the interface must be delegated.** If the interface has many
  methods, the wrapper must implement all of them even if only one carries the new
  behaviour. This is mechanical work but it adds boilerplate for large interfaces.
  Consider narrowing the interface (Interface Segregation Principle) if only a
  subset of methods is actually depended upon.
- **The original class is still untested.** The wrapper tests verify the new
  behaviour and the delegation; they do not exercise `LegacyReportGenerator`'s
  internal logic.
- **Requires a shared interface.** If the original class does not already satisfy an
  interface, you must extract one first. In TypeScript, that extraction rarely
  requires changing the original class itself because of structural typing.
- **Stackable by design.** Because both the original and the wrapper implement the
  same interface, multiple decorators can be composed. This is an advantage when
  several independent behaviours need to be added without coupling them to each
  other.

### When to prefer Wrap Class over the others

Use Wrap Class over Wrap Method when the new behaviour must apply to several methods
on the class, or when you need a seam at the type level without modifying the
original class at all. Prefer it over Sprout Class when the new behaviour is an
interception of an existing operation (running before or after it) rather than a new
independent concern running alongside it. If only a single method needs wrapping and
the class can be modified, Wrap Method is simpler and avoids introducing a new type.

---

## 5. Choosing within this group

The four techniques split along two axes: **where the new code lives** (on the
existing class, or in a new type) and **how the new code relates to the old code**
(running alongside it at a specific internal point, or running around it as a whole).

**Method versus class.** Sprout Method and Wrap Method keep the new code on the
existing class. Sprout Class and Wrap Class put the new code in a new type. Choose
the class-level techniques when the existing class cannot be instantiated in a test,
when the new concern is substantial enough to merit its own type, or when you need
a seam without any modification to the original class.

**Sprout versus Wrap.** Both Sprout techniques add new behaviour that runs alongside
the existing code without changing it. Sprout places the call at a specific internal
point in the host method's flow. Wrap surrounds the entire method or class,
unconditionally, before or after. Choose Sprout when the new behaviour belongs at a
particular step in the existing logic. Choose Wrap when the new behaviour is
positional relative to the whole method or the whole class, or when you cannot
safely add even a single line to the existing method body.

A routing guide:

- Can the host class be instantiated in a test (even with stubs)?
  - Yes, and new logic belongs at a specific internal point: **Sprout Method**.
  - Yes, and new logic runs around the whole method: **Wrap Method**.
- Can the host class not be instantiated at all?
  - New logic is an independent concern running alongside: **Sprout Class**.
  - New logic intercepts the existing operation: **Wrap Class**.
- Must the change leave the original class completely unmodified?
  - **Wrap Class** (and choose a new interface if one does not yet exist).
- Must the new behaviour apply to several methods on the class?
  - **Wrap Class**.

All four leave the legacy tangle untouched except for the minimum necessary wiring.
Sprout and Wrap are not compromises; they are the correct tool when the requirement
is genuinely additive. When the change is a correction to existing logic rather than
an addition, these techniques cannot sidestep the need to bring that existing logic
under test first (see the sibling skill `legacy-code-changes` for the full
five-step algorithm).

---

## 6. Sources

Michael Feathers, *Working Effectively with Legacy Code* (Prentice Hall, 2004),
Chapter 6: "I Don't Have Much Time and I Have to Change It." Sprout Method,
Sprout Class, Wrap Method, and Wrap Class are described and contrasted in that
chapter. Paraphrased throughout this file; no page numbers cited.
