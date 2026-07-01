# Behavioral patterns reference

The detailed reference behind the skill: force or smell, when not to apply,
minimal TypeScript form, and composition notes for each of the eleven Gang of
Four behavioral patterns.

Standards and sources:

- Gamma, Helm, Johnson, Vlissides, *Design Patterns: Elements of Reusable
  Object-Oriented Software* (1994): the canonical source for all eleven patterns
  below, cited as Gamma et al. (1994).

---

## Chain of Responsibility

The smell is a request that must pass through a sequence of possible handlers,
where the correct handler is not known at the time the request is issued. Code
that hard-codes a long cascade of `if` / `else if` blocks, each delegating to
the next when it cannot act, is the signal: the chain of conditional logic
should be separated from the handlers themselves so both can vary independently.

Source: Gamma et al. (1994).

### When not to apply

When a single handler always takes the request, call it directly; no chain is
needed. When a small, fixed conditional adequately dispatches among two or three
alternatives that never change, a `switch` or a lookup table is simpler. The
chain adds indirection that pays off only when the handler set is open-ended or
varies at runtime.

### Minimal form

```typescript
type Handler<T> = (request: T) => boolean;

function chain<T>(handlers: Handler<T>[]): Handler<T> {
    return (request: T): boolean => {
        for (const handle of handlers) {
            if (handle(request)) return true;
        }
        return false;
    };
}

// Usage: each handler returns true to claim the request, false to pass it on.
const logHandler: Handler<string> = (req) => {
    if (req.startsWith("log:")) {
        console.log("Handled as log:", req);
        return true;
    }
    return false;
};

const auditHandler: Handler<string> = (req) => {
    if (req.startsWith("audit:")) {
        console.log("Handled as audit:", req);
        return true;
    }
    return false;
};

const dispatch = chain([logHandler, auditHandler]);
dispatch("log:user-login"); // handled by logHandler
dispatch("unknown");        // passes all handlers, returns false
```

The handler array is the minimal form. The class-based GoF form (each handler
holds a reference to the next) is the heavier alternative; it is justified when
a handler must decide dynamically at runtime which next handler to invoke, not
just whether to pass the request along.

### Composition

Chain of Responsibility has no strong dependency on the other architecture
plugins. When the chain is used to process incoming requests at the boundary of
an application (an HTTP middleware pipeline, for example), its placement at the
infrastructure boundary follows **`hexagonal-architecture`**.

---

## Command

The smell is an action that must be treated as a first-class value: passed to
a queue, stored in a log, held for later execution, or reversed with an undo
operation. When a function call is not enough because the action needs to
outlive the call site or be stored, the operation is a candidate for
reification as a Command.

Source: Gamma et al. (1994).

### When not to apply

When the action is invoked immediately at the call site and there is no need to
store, queue, or reverse it, call the function directly. Wrapping a function
in a Command object for its own sake adds indirection without a payoff.

### Minimal form

```typescript
// Minimal form: a closure.
// The closure captures its context and can be stored or called later.
type Command = () => void;

function createRenameCommand(target: { name: string }, newName: string): Command {
    return () => {
        target.name = newName;
    };
}

// Usage: store the command in a queue for deferred execution.
const doc = {name: "Report v1"};
const commandQueue: Command[] = [];

const cmd = createRenameCommand(doc, "Report v2");
commandQueue.push(cmd); // stored for later
cmd();                  // executes: doc.name is now "Report v2"
```

```typescript
// Object form: justified when undo is required, because the command must carry
// both the forward action and the reverse action together.
interface UndoableCommand {
    execute(): void;

    undo(): void;
}

class RenameCommand implements UndoableCommand {
    private readonly previousName: string;

    constructor(
        private readonly target: { name: string },
        private readonly newName: string,
    ) {
        this.previousName = target.name;
    }

    execute(): void {
        this.target.name = this.newName;
    }

    undo(): void {
        this.target.name = this.previousName;
    }
}
```

**FALSE FRIEND.** The `cqrs` plugin also uses the word "command", but for a
different purpose: a CQRS command is a write-model message that crosses the
command bus and is dispatched to a handler, enforcing command-query separation.
The two concepts share only the word. A GoF Command is a reified action (a
closure or an object that captures an operation so it can be passed, queued,
logged, or undone). A CQRS command is a data transfer object representing
intent, consumed by a command handler in a separated write model. Do not
conflate them. For the CQRS command bus, handler wiring, and command-query
separation boundary, see the **`cqrs`** skill.

### Composition

The generic GoF mechanism (reifying a request as an object or closure) is
defined here. The **`cqrs`** skill owns the command bus and the
command-query separation boundary; those are different concepts that share the
word "command" and nothing else.

---

## Interpreter

The smell is a domain that defines a small grammar of sentences, and the
grammar must be evaluated programmatically. A rules engine, a query language,
or a formula evaluator where the input is structured text or a syntax tree
points toward the Interpreter pattern.

Source: Gamma et al. (1994).

### When not to apply

Almost always. Interpreter is the strongest-guardrail behavioral pattern in
this catalogue. Building a correct interpreter requires defining a grammar, a
parser, and an evaluation strategy; all three are non-trivial. Reach for a
real parser library (a PEG parser, a parser combinator, or an established
grammar tool) before building an interpreter from scratch. For rule evaluation,
a data-driven approach (a table of rules evaluated against a context object)
is simpler and easier to extend than a class hierarchy of expression nodes.
Only when the grammar is tiny, stable, and the data-driven approach does not
fit should you consider this pattern.

### Minimal form

```typescript
// A tiny expression grammar: numbers, variables, and addition only.
interface Expression {
    interpret(context: Record<string, number>): number;
}

class NumberExpression implements Expression {
    constructor(private readonly value: number) {
    }

    interpret(_context: Record<string, number>): number {
        return this.value;
    }
}

class VariableExpression implements Expression {
    constructor(private readonly name: string) {
    }

    interpret(context: Record<string, number>): number {
        return context[this.name] ?? 0;
    }
}

class AddExpression implements Expression {
    constructor(
        private readonly left: Expression,
        private readonly right: Expression,
    ) {
    }

    interpret(context: Record<string, number>): number {
        return this.left.interpret(context) + this.right.interpret(context);
    }
}

// Evaluates: x + 5
const expression: Expression = new AddExpression(
    new VariableExpression("x"),
    new NumberExpression(5),
);
console.log(expression.interpret({x: 3})); // 8
```

Keep the example small. As soon as the grammar grows beyond a handful of node
types, a proper parser and an abstract syntax tree are the better investment.

### Composition

Interpreter has no strong dependency on the other architecture plugins. When
the interpreted language expresses domain eligibility rules (business policies,
qualification criteria), the **`domain-driven-design`** skill's Specification
pattern is often a simpler alternative that expresses the same intent as a
composable predicate object rather than an evaluatable syntax tree.

---

## Iterator

The smell is a collection whose internal structure is hidden but whose elements
must be traversed by callers. A class that exposes the traversal mechanism as
part of its public API (a `hasNext` / `next` pair, or an index-based loop)
leaks internal structure to callers.

Source: Gamma et al. (1994).

### When not to apply

In TypeScript, you almost never hand-roll an iterator from scratch. The
language provides first-class iteration via `Symbol.iterator`, generator
functions, and `for...of`. Implement `Symbol.iterator` (or
`Symbol.asyncIterator` for async sequences) on a class, and callers get
`for...of`, spread syntax, destructuring, and `Array.from` for free. A
generator function is the minimal and idiomatic form for producing a sequence.
Reach for a custom iterator class only in the rare case that a generator does
not express the traversal naturally.

### Minimal form

```typescript
// Generator function: the idiomatic TypeScript form for a lazy sequence.
function* range(start: number, end: number, step: number = 1): Generator<number> {
    for (let i = start; i < end; i += step) {
        yield i;
    }
}

for (const value of range(0, 10, 2)) {
    console.log(value); // 0, 2, 4, 6, 8
}

// Implementing Symbol.iterator on a class so callers use for...of directly.
class NumberRange {
    constructor(
        private readonly start: number,
        private readonly end: number,
    ) {
    }

    [Symbol.iterator](): Generator<number> {
        return range(this.start, this.end);
    }
}

for (const n of new NumberRange(1, 4)) {
    console.log(n); // 1, 2, 3
}
```

The GoF class-based iterator (a separate `ConcreteIterator` class with
`hasNext` and `next` methods) is the historical form; use the generator or
`Symbol.iterator` form in TypeScript. Both satisfy the same intent.

### Composition

Iterator has no strong dependency on the other architecture plugins. Async
iterators (`Symbol.asyncIterator`, `for await...of`) are the natural form for
traversing an event stream, a query result cursor, or a paginated API; those
sequences appear at the infrastructure boundary governed by
**`hexagonal-architecture`**.

---

## Mediator

The smell is a set of components that must communicate with each other but
have grown so intertwined that each component holds direct references to many
others. Adding a new component requires updating multiple existing ones. The
communication topology becomes a dense mesh rather than a star.

Source: Gamma et al. (1994).

### When not to apply

When the number of collaborators is small (two or three), direct references
between them are clearer than routing through a central coordinator. The
indirection a Mediator introduces hides the flow: it is harder to trace which
component reacts to which event when all interaction is routed through a single
hub. Apply Mediator only when the mesh of direct references is genuinely painful
and the set of collaborators is large enough that centralising their interaction
is a net simplification.

### Minimal form

```typescript
// Mediator: the central coordinator that dispatches events between components.
class EventMediator {
    private readonly handlers = new Map<string, Array<(payload: unknown) => void>>();

    on(type: string, handler: (payload: unknown) => void): void {
        const existing = this.handlers.get(type) ?? [];
        this.handlers.set(type, [...existing, handler]);
    }

    emit(type: string, payload: unknown): void {
        const registered = this.handlers.get(type) ?? [];
        for (const handler of registered) {
            handler(payload);
        }
    }
}

// Two components that interact only through the mediator; neither holds a
// reference to the other.
class FormComponent {
    constructor(private readonly mediator: EventMediator) {
    }

    submit(data: Record<string, string>): void {
        this.mediator.emit("form:submitted", data);
    }
}

class ValidationComponent {
    constructor(mediator: EventMediator) {
        mediator.on("form:submitted", (payload) => {
            const data = payload as Record<string, string>;
            console.log("Validating:", data);
        });
    }
}

const mediator = new EventMediator();
const form = new FormComponent(mediator);
const validation = new ValidationComponent(mediator); // constructed for its subscription side effect

form.submit({username: "alice"}); // ValidationComponent reacts via mediator
```

### Composition

Mediator has no strong dependency on the other architecture plugins. When the
interaction being mediated crosses module boundaries in a modular monolith, the
**`modular-monolith`** skill governs how modules communicate (through public
APIs or an event bus) and takes precedence over a direct Mediator
implementation.

---

## Memento

The smell is an object whose state must be checkpointed and later restored, for
undo, rollback, or snapshot purposes. Exposing the internal fields directly to
let a caretaker save and restore them breaks encapsulation; the object's
internal structure leaks into the caretaker.

Source: Gamma et al. (1994).

### When not to apply

When there is no undo, rollback, or checkpoint requirement, do not capture
state. Serialising an object's state and storing the result has a memory and
complexity cost. Introduce Memento only when the undo or restore behaviour is
a confirmed requirement.

### Minimal form

```typescript
// Snapshot type: the captured state, immutable by convention.
interface EditorState {
    readonly content: string;
    readonly cursorPosition: number;
}

class Editor {
    private content: string = "";
    private cursorPosition: number = 0;

    type(text: string): void {
        this.content += text;
        this.cursorPosition = this.content.length;
    }

    // Returns the current state as an immutable snapshot.
    snapshot(): EditorState {
        return {content: this.content, cursorPosition: this.cursorPosition};
    }

    // Applies a previously captured snapshot, discarding current state.
    restore(state: EditorState): void {
        this.content = state.content;
        this.cursorPosition = state.cursorPosition;
    }
}

// Caretaker: holds snapshots without knowing their internal structure.
const editor = new Editor();
editor.type("Hello");

const saved: EditorState = editor.snapshot(); // checkpoint
editor.type(", world");
editor.restore(saved); // undo: back to "Hello"
```

### Composition

The snapshot-and-restore idea scales up directly into event sourcing. In the
**`event-sourcing`** skill, a snapshot is a Memento applied to the event store:
rather than replaying all events from the beginning to reconstruct an
aggregate's state, the store periodically persists a snapshot of the
aggregate's current state, from which replay can begin. Point there when the
use case is an event-sourced aggregate rather than a simple undo buffer.

---

## Observer

The smell is a subject that must notify an open-ended set of dependents when
its state changes, where the subject should not know which dependents exist or
how many there are. Hard-coding the notification calls inside the subject
couples it to its observers and makes adding a new observer require changing
the subject.

Source: Gamma et al. (1994).

### When not to apply

When there is only one synchronous caller, pass the result directly or use a
callback parameter. Over-eventing turns straightforward call sequences into a
tracing puzzle: a change triggers an event, which triggers a handler, which
triggers another event. Apply Observer when the set of dependents is genuinely
open-ended, decoupled from the subject, and varies independently.

### Minimal form

```typescript
type Listener<T> = (event: T) => void;

class EventEmitter<T> {
    private readonly listeners: Set<Listener<T>> = new Set();

    subscribe(listener: Listener<T>): () => void {
        this.listeners.add(listener);
        return () => this.listeners.delete(listener); // returns an unsubscribe function
    }

    emit(event: T): void {
        for (const listener of this.listeners) {
            listener(event);
        }
    }
}

// Usage: a subject that notifies observers of state changes.
interface PriceChangedEvent {
    productId: string;
    newPrice: number;
}

const priceChanges = new EventEmitter<PriceChangedEvent>();

const unsubscribe = priceChanges.subscribe((event) => {
    console.log(`Price for ${event.productId} is now ${event.newPrice}`);
});

priceChanges.emit({productId: "sku-42", newPrice: 19.99});
unsubscribe(); // clean up when the listener is no longer needed
```

The built-in `EventTarget` (browser and Node.js 18+) is a platform-level
alternative for DOM-integrated scenarios; prefer it over a hand-rolled emitter
when the target environment supports it.

### Composition

Domain events in the **`domain-driven-design`** skill are Observer applied at
the domain level: an aggregate raises an event when something significant
happens, and multiple handlers react to that event within or across bounded
contexts. The projection-driving events in the **`event-sourcing`** skill are
Observer at the store level: the event store emits persisted events that
projections consume to build read models. Both specialised applications use
the same generic mechanism defined here; the placement, routing, and
consistency guarantees belong to those skills.

---

## State

The smell is an object whose behaviour changes dramatically based on its
internal state, expressed as a tangle of `if` / `switch` blocks scattered
across its methods. Every method checks the state flag and branches on it.
Adding a new state means touching every method.

Source: Gamma et al. (1994).

### When not to apply

When there are only two states and one flag, a simple conditional is clearer
than a state map or state object. The State pattern pays its cost when three or
more states exist, each with meaningfully different behaviour across several
methods, and the transitions between them are non-trivial.

### Minimal form

```typescript
type TrafficLightState = "red" | "yellow" | "green";

interface StateHandlers {
    action(): void;

    nextState(): TrafficLightState;
}

const stateMap: Record<TrafficLightState, StateHandlers> = {
    red: {action: () => console.log("Stop"), nextState: () => "green"},
    green: {action: () => console.log("Go"), nextState: () => "yellow"},
    yellow: {action: () => console.log("Slow"), nextState: () => "red"},
};

class TrafficLight {
    private state: TrafficLightState = "red";

    act(): void {
        stateMap[this.state].action();
    }

    transition(): void {
        this.state = stateMap[this.state].nextState();
    }
}
```

### Composition

State and Strategy share the same structure: a context delegates to an
interchangeable behaviour object (or function). The distinction is intent.
Strategy selects an algorithm from outside at configuration time; the context
typically does not change its strategy at runtime. State changes its own
behaviour as a consequence of internal transitions; the context manages the
transition itself. Same shape, different purpose. When you are unsure which
applies, ask: who drives the switch? External configuration means Strategy;
internal transition logic means State.

---

## Strategy

The smell is a family of algorithms that must be interchangeable at runtime,
expressed as branching logic inside a single class or function. The class knows
too much about each algorithm variant, and adding a new variant requires
modifying the class.

Source: Gamma et al. (1994).

### When not to apply

When there is only one algorithm and no identified variation point, introducing
a Strategy is speculative abstraction. A function parameter that nobody ever
passes a different value to is not a Strategy; it is indirection without a
payoff. Wait for a real, identified variation point: a new payment provider
you must support, a notification channel chosen at runtime by the user, a
sorting algorithm that changes per environment. A real, identified variation
point makes Strategy the correct answer, not over-engineering. The fault is
anticipating variation that does not yet exist.

### Minimal form

```typescript
// Minimal form: a function parameter.
// The caller supplies the algorithm; no interface declaration required.
type SortStrategy<T> = (items: T[]) => T[];

function processItems<T>(items: T[], sort: SortStrategy<T>): T[] {
    return sort([...items]);
}

const ascending: SortStrategy<number> = (arr) => [...arr].sort((a, b) => a - b);
const descending: SortStrategy<number> = (arr) => [...arr].sort((a, b) => b - a);

processItems([3, 1, 2], ascending);  // [1, 2, 3]
processItems([3, 1, 2], descending); // [3, 2, 1]
```

```typescript
// Interface form: justified when the strategy carries state across calls or
// when several related strategies share more than one method.
interface PricingStrategy {
    calculatePrice(basePrice: number, quantity: number): number;

    label(): string;
}

class BulkDiscountStrategy implements PricingStrategy {
    constructor(
        private readonly threshold: number,
        private readonly discount: number,
    ) {
    }

    calculatePrice(basePrice: number, quantity: number): number {
        return quantity >= this.threshold
            ? basePrice * quantity * (1 - this.discount)
            : basePrice * quantity;
    }

    label(): string {
        return `bulk discount (${this.discount * 100}% off)`;
    }
}

class StandardPricingStrategy implements PricingStrategy {
    calculatePrice(basePrice: number, quantity: number): number {
        return basePrice * quantity;
    }

    label(): string {
        return "standard pricing";
    }
}
```

### Composition

Strategy is usually wired by a dependency-injection container or composition
root: the concrete strategy is created once and injected into the context that
uses it. That is the Dependency Inversion Principle (DIP) and Open/Closed
Principle (OCP) from **`solid-principles`** in action: the context depends on
the abstraction (the function type or the interface), and the concrete variant
is provided by the **`dependency-injection`** infrastructure. When you reach
for Strategy at a real variation point, you are making the OCP and DIP moves
simultaneously; those principles provide the rationale, and this pattern
provides the mechanism.

---

## Template Method

The smell is two or more algorithms that share the same sequence of steps but
differ in one or two of those steps. The skeleton is duplicated across the
variants; only the varying steps differ. Factoring out the skeleton eliminates
the duplication without merging the varying parts.

Source: Gamma et al. (1994).

### When not to apply

When inheritance is heavier than the problem warrants, prefer passing the
varying steps as function parameters (composition over inheritance). A function
that accepts callbacks for the varying steps achieves the same skeleton-with-
variation without requiring a subclass. Subclasses are justified when the
varying steps need access to protected state or when the class hierarchy already
exists and extension is the natural boundary.

### Minimal form

```typescript
import {readFileSync} from "fs";

// Preferred: a function accepting callbacks for the varying steps.
// Composition over inheritance; the idiomatic TypeScript form.
function processFile(
    filePath: string,
    options: {
        parse: (raw: string) => unknown[];
        validate: (records: unknown[]) => unknown[];
        persist: (records: unknown[]) => void;
    },
): void {
    const raw = readFileSync(filePath, "utf8"); // fixed step
    const records = options.parse(raw);             // varying
    const valid = options.validate(records);      // varying
    options.persist(valid);                         // varying
}
```

```typescript
import {readFileSync} from "fs";

// Class form: the GoF subclass form; use when the varying steps need access
// to shared protected state or when a class hierarchy is already in place.
abstract class FileProcessor {
    process(filePath: string): void {
        const raw = readFileSync(filePath, "utf8"); // fixed step
        const records = this.parse(raw);               // varying
        const valid = this.validate(records);        // varying
        this.persist(valid);                           // varying
    }

    protected abstract parse(raw: string): unknown[];

    protected abstract validate(records: unknown[]): unknown[];

    protected abstract persist(records: unknown[]): void;
}

class CsvFileProcessor extends FileProcessor {
    protected parse(raw: string): unknown[] {
        return raw.split("\n").map((line) => line.split(","));
    }

    protected validate(records: unknown[]): unknown[] {
        return records.filter((r) => Array.isArray(r) && r.length > 0);
    }

    protected persist(records: unknown[]): void {
        console.log("Persisting", records.length, "records");
    }
}
```

### Composition

Strategy is the composition-based alternative to Template Method: instead of
defining the skeleton in a base class and filling in the steps through
subclasses, Strategy passes the varying steps as function parameters or injected
collaborators. When the varying steps are stateless functions, prefer Strategy
(the function-parameter form) over Template Method (the subclass form). The
distinction matters for testability: a function parameter can be replaced in
isolation; a protected method requires a subclass in tests.

---

## Visitor

The smell is an object structure whose elements are stable but whose operations
multiply over time. Adding a new operation requires touching every element
class to add a method for it, even though the operation logic is unrelated to
the element's own responsibility.

Source: Gamma et al. (1994).

### When not to apply

TypeScript discriminated unions combined with an exhaustive `switch` usually
beat the double-dispatch ceremony of the classical Visitor. When the element
set is small and the type information is available at compile time, a
discriminated union and a `switch` block are simpler, more readable, and
statically checked by the compiler. The exhaustive `switch` (where TypeScript
flags an unhandled case as a compile error when `noImplicitReturns` is on or
the union is narrowed to `never`) provides the same safety as a Visitor
dispatch without the class hierarchy. Reach for the classical Visitor only
when the element set is fixed and stable, the operations multiply, and the
element objects are large classes that cannot easily be converted to a union.

### Minimal form

```typescript
// Preferred: a discriminated union with an exhaustive switch.
// TypeScript narrows the type in each branch; the never guard in the default
// branch produces a compile error if a new Shape variant is added without
// updating the switch.
type Shape =
    | { kind: "circle"; radius: number }
    | { kind: "rectangle"; width: number; height: number }
    | { kind: "triangle"; base: number; height: number };

function area(shape: Shape): number {
    switch (shape.kind) {
        case "circle":
            return Math.PI * shape.radius ** 2;
        case "rectangle":
            return shape.width * shape.height;
        case "triangle":
            return 0.5 * shape.base * shape.height;
        default: {
            const _exhaustive: never = shape;
            return _exhaustive;
        }
    }
}

function perimeter(shape: Shape): number {
    switch (shape.kind) {
        case "circle":
            return 2 * Math.PI * shape.radius;
        case "rectangle":
            return 2 * (shape.width + shape.height);
        case "triangle":
            return shape.base + shape.height + Math.hypot(shape.base, shape.height); // assumes a right triangle
        default: {
            const _exhaustive: never = shape;
            return _exhaustive;
        }
    }
}
```

```typescript
// Classical Visitor form: justified when the element set is a stable class
// hierarchy that cannot easily be expressed as a discriminated union.
interface ShapeVisitor {
    visitCircle(circle: Circle): number;

    visitRectangle(rectangle: Rectangle): number;
}

interface VisitableShape {
    accept(visitor: ShapeVisitor): number;
}

class Circle implements VisitableShape {
    constructor(readonly radius: number) {
    }

    accept(visitor: ShapeVisitor): number {
        return visitor.visitCircle(this);
    }
}

class Rectangle implements VisitableShape {
    constructor(readonly width: number, readonly height: number) {
    }

    accept(visitor: ShapeVisitor): number {
        return visitor.visitRectangle(this);
    }
}

class AreaVisitor implements ShapeVisitor {
    visitCircle(circle: Circle): number {
        return Math.PI * circle.radius ** 2;
    }

    visitRectangle(rect: Rectangle): number {
        return rect.width * rect.height;
    }
}

class PerimeterVisitor implements ShapeVisitor {
    visitCircle(circle: Circle): number {
        return 2 * Math.PI * circle.radius;
    }

    visitRectangle(rect: Rectangle): number {
        return 2 * (rect.width + rect.height);
    }
}
```

### Composition

Visitor has no strong dependency on the other architecture plugins. When the
elements being visited are domain objects (an order line, a product, a
discount), their structure and invariants are governed by
**`domain-driven-design`**, and the preferred form is a discriminated union or
a value object rather than a Visitor hierarchy.

---

## Choosing within this group

**Strategy versus State versus Template Method:** all three address variation
in behaviour, but they differ in who drives the variation and how the skeleton
is structured. Strategy selects an algorithm from outside; the caller provides
the variant at construction or call time. State drives its own variation
internally; the context transitions between states as a result of its own
operations. Template Method defines a fixed skeleton in one place and delegates
the varying steps to subclasses or callbacks; the skeleton does not change,
only the steps. A quick diagnostic: if the variation is chosen externally at
configuration time, reach for Strategy. If the variation is driven by internal
transitions at runtime, reach for State. If the variation lives in specific
steps of a fixed sequence, reach for Template Method (or the function-callback
form of it, which is Strategy applied to multiple steps at once).

**Command versus Observer:** both involve reactions to events, but Command is
imperative (it encapsulates an action to be executed later) while Observer is
declarative (it registers a listener that reacts when the subject changes).
Command is for queueing, logging, and undo; Observer is for broadcasting state
changes to an open-ended set of listeners.

**Chain of Responsibility versus Mediator:** Chain passes a request along a
sequence until one handler claims it; each handler knows only its successor.
Mediator centralises interaction so that collaborators communicate through a
single coordinator; each collaborator knows only the mediator.

---

## Sources

- Gamma, Helm, Johnson, Vlissides, *Design Patterns: Elements of Reusable
  Object-Oriented Software* (1994). All eleven behavioral patterns above
  (Chain of Responsibility, Command, Interpreter, Iterator, Mediator, Memento,
  Observer, State, Strategy, Template Method, Visitor) are defined in this
  work, cited here as Gamma et al. (1994).
