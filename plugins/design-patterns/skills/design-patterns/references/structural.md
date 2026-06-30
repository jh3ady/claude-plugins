# Structural patterns reference

The detailed reference behind the skill: force or smell, when not to apply,
minimal TypeScript form, and composition notes for each of the seven Gang of
Four structural patterns.

Standards and sources:
- Gamma, Helm, Johnson, Vlissides, *Design Patterns: Elements of Reusable
  Object-Oriented Software* (1994): the canonical source for all seven patterns
  below, cited as Gamma et al. (1994).

---

## Adapter

The smell is a dependency you do not control whose interface does not match
the interface the rest of the codebase expects. The client defines a port, the
service provides a plug, and the two shapes differ. Rather than changing the
client (which means touching many call sites) or forking the service (which
means owning two diverging copies), a thin wrapping object translates one shape
into the other without either side needing to change.

Source: Gamma et al. (1994).

### When not to apply

When you control both sides of the mismatch, changing one interface to match
the other is simpler and cheaper. Wrapping is the right choice when the
external side is fixed: a third-party library, a platform API, or a legacy
component you are not authorised to change. A wrapper for a mismatch you could
eliminate at the source is unnecessary indirection.

### Minimal form

```typescript
// Target interface expected by the client.
interface EmailSender {
  send(to: string, subject: string, body: string): Promise<void>;
}

// Adaptee: a third-party SDK with a different shape.
class ThirdPartyMailer {
  sendMail(options: {
    recipient: string;
    title: string;
    content: string;
  }): Promise<void> {
    return Promise.resolve(); // real implementation omitted
  }
}

// Adapter: wraps the adaptee and exposes the target interface.
class MailerAdapter implements EmailSender {
  constructor(private readonly mailer: ThirdPartyMailer) {}

  send(to: string, subject: string, body: string): Promise<void> {
    return this.mailer.sendMail({ recipient: to, title: subject, content: body });
  }
}
```

A wrapping object (the object adapter form) is the idiomatic TypeScript choice;
the class-based inheritance form (class adapter) is rarely useful and is
deliberately omitted here.

### Composition

This entry defines Adapter as a generic mechanism: a wrapper that translates an
incompatible interface into the one the client expects. The
**`hexagonal-architecture`** skill owns the driving and driven boundary adapter
application. When an Adapter implements a port at the edge of the hexagon, its
placement in the infrastructure layer, its relationship to the port interface,
and the direction of the dependency are governed by that skill, not this one.
Point there for the hexagonal application; this entry is the generic mechanism.

---

## Bridge

The smell is a class hierarchy that has grown in two orthogonal directions at
once. Adding a new abstraction variant requires duplicating all implementation
variants, and adding a new implementation variant requires touching all
abstraction variants. The two axes of variation are entangled in a single
inheritance tree, and the tree grows combinatorially.

Source: Gamma et al. (1994).

### When not to apply

When only one implementation exists today, Bridge is speculative abstraction
(YAGNI). The two-hierarchy separation pays off only when both axes of variation
are real and present. A second hierarchy for a single implementation is pure
overhead. Wait until a genuine second implementation is needed before
introducing the Bridge.

### Minimal form

```typescript
// Implementation side: the interface that varies independently.
interface Renderer {
  renderCircle(radius: number): void;
  renderRectangle(width: number, height: number): void;
}

const svgRenderer: Renderer = {
  renderCircle:    (r) => { /* SVG circle */    },
  renderRectangle: (w, h) => { /* SVG rect */   },
};

const canvasRenderer: Renderer = {
  renderCircle:    (r) => { /* canvas arc */       },
  renderRectangle: (w, h) => { /* canvas fillRect */ },
};

// Abstraction side: holds a reference to the implementation.
abstract class Shape {
  constructor(protected readonly renderer: Renderer) {}
  abstract draw(): void;
}

class Circle extends Shape {
  constructor(private readonly radius: number, renderer: Renderer) {
    super(renderer);
  }
  draw(): void { this.renderer.renderCircle(this.radius); }
}

class Rectangle extends Shape {
  constructor(
    private readonly width:  number,
    private readonly height: number,
    renderer: Renderer,
  ) {
    super(renderer);
  }
  draw(): void { this.renderer.renderRectangle(this.width, this.height); }
}
```

The two axes (shapes and renderers) vary independently: adding a new renderer
requires no changes to the shape classes, and adding a new shape requires no
changes to the renderer implementations.

### Composition

Bridge has no strong dependency on the other architecture plugins. When the
implementation side of a Bridge corresponds to a driven port (an external
rendering engine, a storage backend), its placement at the infrastructure
boundary follows **`hexagonal-architecture`**.

---

## Composite

The smell is code that handles leaves and containers differently despite the
fact that clients want to treat them uniformly. A document that contains
sections, which contain paragraphs, which contain words should allow any level
to be rendered, exported, or word-counted through the same call. Branching on
"is this a leaf or a container?" throughout the traversal is the signal that
the structure should be unified behind a single interface.

Source: Gamma et al. (1994).

### When not to apply

When the structure is not genuinely recursive (no real part-whole hierarchy),
Composite adds a shared interface and recursive traversal for no benefit. A
flat list of items is not a tree; treating it as one is forced uniformity.
Reach for Composite only when the depth is unbounded or unknown at compile
time and uniformity across levels is a real requirement.

### Minimal form

```typescript
interface FileSystemNode {
  name(): string;
  size(): number;
}

// Leaf: no children.
class File implements FileSystemNode {
  constructor(
    private readonly _name: string,
    private readonly _size: number,
  ) {}

  name(): string { return this._name; }
  size(): number { return this._size; }
}

// Composite: contains other nodes of the same interface.
class Directory implements FileSystemNode {
  private readonly children: FileSystemNode[] = [];

  constructor(private readonly _name: string) {}

  add(node: FileSystemNode): void { this.children.push(node); }

  name(): string { return this._name; }
  size(): number {
    return this.children.reduce((sum, n) => sum + n.size(), 0);
  }
}

// Client code treats File and Directory uniformly through FileSystemNode.
function printSize(node: FileSystemNode): void {
  console.log(`${node.name()}: ${node.size()} bytes`);
}
```

### Composition

Composite has no strong dependency on the other architecture plugins. When the
composite represents a domain structure (a bill of materials, an organisational
hierarchy, a nested menu), its identity, invariants, and root ownership are
governed by **`domain-driven-design`**.

---

## Decorator

The smell is behaviour that must be added to an object dynamically, or in
different combinations depending on context, without changing the object's
interface or subclassing it. Subclassing fails here because the combinations
grow exponentially: logging plus caching plus retry is three separate concerns
that should compose independently rather than multiply into subclasses.

Source: Gamma et al. (1994).

### When not to apply

When only one fixed additional behaviour is needed, writing it inline or
extracting a single function is simpler and sufficient. Decorator pays off when
the additional behaviours are optional, composable, or independently
replaceable. Stacking more than two or three decorators increases cognitive
load; at that point, consider whether a middleware pipeline with explicit
composition is clearer than nested wrapping.

### Minimal form

```typescript
// Define simple request/response types so the example is self-contained.
interface Request  { method: string; url: string; }
interface Response { status: number; }

// Functional form: the idiomatic TypeScript choice.
// A higher-order function wraps a function and preserves its signature exactly.
type Handler = (request: Request) => Promise<Response>;

function withLogging(handler: Handler): Handler {
  return async (request) => {
    console.log(`${request.method} ${request.url}`);
    const response = await handler(request);
    console.log(`${response.status}`);
    return response;
  };
}

function withRetry(maxAttempts: number, handler: Handler): Handler {
  return async (request) => {
    for (let attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await handler(request);
      } catch (error) {
        if (attempt === maxAttempts) throw error;
      }
    }
    // Unreachable for maxAttempts >= 1; satisfies the TypeScript return type.
    throw new Error("unreachable");
  };
}

// Decorators stack by composition; order reads left-to-right.
declare const baseHandler: Handler;
const handler = withLogging(withRetry(3, baseHandler));
```

```typescript
// Class form: heavier alternative; justified when the decorator must carry
// state across calls or when many collaborators share the same interface.
interface Logger {
  log(level: "info" | "warn" | "error", message: string): void;
}

class TimestampLogger implements Logger {
  constructor(private readonly inner: Logger) {}

  log(level: "info" | "warn" | "error", message: string): void {
    this.inner.log(level, `[${new Date().toISOString()}] ${message}`);
  }
}
```

The functional higher-order form is the minimal choice; the class form pays its
cost only when state or an explicit shared interface is needed.

### Composition

The functional higher-order wrapping form connects naturally to the patterns in
**`references/modern-idioms.md`**, where middleware composition and function
wrapping are first-class idioms. The class form satisfies the Open/Closed
Principle (adding behaviour without modifying the wrapped object), described in
**`solid-principles`**.

---

## Facade

The smell is client code that must coordinate many calls across a wide subsystem
to accomplish a single logical operation. The client knows too much about the
subsystem's internal structure, and every new caller must rediscover the same
sequence of calls. A change inside the subsystem then requires searching for
every caller who relied on that internal knowledge.

Source: Gamma et al. (1994).

### When not to apply

When the subsystem is already small or coherent, a Facade adds a layer with no
benefit. An extra indirection between two objects that work together cleanly
adds navigation cost without reducing coupling. Apply Facade when the subsystem
genuinely has many moving parts that callers should not need to know about.

### Minimal form

```typescript
// Wide subsystem with three internal services.
class InventoryService {
  reserve(productId: string, quantity: number): void { /* reserve */ }
}

class PaymentService {
  charge(accountId: string, amount: number): string { return "tx-id"; }
}

class ShippingService {
  schedule(transactionId: string, address: string): void { /* schedule */ }
}

// Facade: exposes a single clear entry point for the "place order" operation.
class OrderFacade {
  constructor(
    private readonly inventory: InventoryService,
    private readonly payment:   PaymentService,
    private readonly shipping:  ShippingService,
  ) {}

  placeOrder(
    productId:  string,
    quantity:   number,
    accountId:  string,
    amount:     number,
    address:    string,
  ): void {
    this.inventory.reserve(productId, quantity);
    const transactionId = this.payment.charge(accountId, amount);
    this.shipping.schedule(transactionId, address);
  }
}
```

### Composition

At the architecture level, this same idea appears in two places: a
**`modular-monolith`** module's public API (the narrow surface a module exposes
to other modules, hiding its internal services and repositories) and a
**`screaming-architecture`** feature entry point (the single class or function
that names and drives a feature's use case). Both are Facade applied to a
bounded scope; the generic mechanism is defined here, and its architectural
placement is governed by those plugins.

---

## Flyweight

The smell is a large number of fine-grained objects consuming more memory than
is acceptable, where most of an object's state is identical across instances
(intrinsic state) and only a small portion varies per use site (extrinsic
state). Sharing the intrinsic part across instances reduces total memory at the
cost of separating the two kinds of state.

Source: Gamma et al. (1994).

### When not to apply

Almost always. Flyweight is the strongest-guardrail structural pattern in this
catalogue. It is an optimisation: it adds a shared cache, separates intrinsic
from extrinsic state, and makes object creation indirect. All of that adds
complexity. Introduce it only when a memory problem has been measured and
traced to object proliferation; do not introduce it because objects are small or
plentiful in theory. Speculative application is premature optimisation as
described in **`simplicity-principles`**: pay the complexity cost only when the
measurement demands it.

### Minimal form

```typescript
interface GlyphStyle {
  readonly fontFamily: string;
  readonly fontSize:   number;
  readonly bold:       boolean;
}

// Flyweight factory: returns a shared instance for each unique style combination.
class GlyphStyleCache {
  private readonly cache = new Map<string, GlyphStyle>();

  get(fontFamily: string, fontSize: number, bold: boolean): GlyphStyle {
    const key = `${fontFamily}-${fontSize}-${String(bold)}`;
    if (!this.cache.has(key)) {
      this.cache.set(key, { fontFamily, fontSize, bold });
    }
    return this.cache.get(key)!;
  }
}

// Extrinsic state (position, character) lives with the glyph, not the style.
interface Glyph {
  readonly character: string;
  readonly x:         number;
  readonly y:         number;
  readonly style:     GlyphStyle; // shared flyweight
}
```

Before reaching for this pattern, confirm two things: (1) a profiler shows the
memory use is a real problem traceable to object proliferation, and (2) the
shared objects are genuinely immutable, because mutating a shared flyweight
corrupts every user of that instance.

### Composition

Flyweight has no strong dependency on the other architecture plugins. Its
primary relationship is with **`simplicity-principles`**: if the complexity cost
of introducing Flyweight cannot be justified by a measured problem, simplicity
wins.

---

## Proxy

The smell is a cross-cutting concern (access control, lazy initialisation,
logging, caching, or remote communication) that must be interposed in front of
an object without the client knowing about it. The client should interact with
the proxy through the same interface it would use with the real object; the
concern is handled transparently.

Source: Gamma et al. (1994).

### When not to apply

When there is no cross-cutting concern to interpose, a Proxy is indirection for
its own sake. If the concern is specific to one call site, handle it there
inline. If it spans many call sites, consider whether a Decorator (which also
wraps, but to add behaviour rather than to control access) or a middleware
pipeline is a better fit for the intent.

### Minimal form

```typescript
// Target interface shared by the real object and the proxy.
interface DataStore {
  read(key: string):               Promise<string | undefined>;
  write(key: string, value: string): Promise<void>;
}

// Caching proxy: returns a cached value when available; writes through and
// invalidates the cache on write.
class CachingDataStoreProxy implements DataStore {
  private readonly cache = new Map<string, string>();

  constructor(private readonly real: DataStore) {}

  async read(key: string): Promise<string | undefined> {
    if (this.cache.has(key)) {
      return this.cache.get(key);
    }
    const value = await this.real.read(key);
    if (value !== undefined) {
      this.cache.set(key, value);
    }
    return value;
  }

  async write(key: string, value: string): Promise<void> {
    this.cache.delete(key); // invalidate before delegating
    return this.real.write(key, value);
  }
}
```

```typescript
// JavaScript Proxy: a language-level alternative for dynamic interception
// without a shared interface, suited to logging or validation shells.
function withLogging<T extends object>(target: T): T {
  return new Proxy(target, {
    get(obj, prop) {
      const value = Reflect.get(obj, prop) as unknown;
      if (typeof value === "function") {
        return (...args: unknown[]) => {
          console.log(`calling ${String(prop)}`);
          return (value as (...a: unknown[]) => unknown).apply(obj, args);
        };
      }
      return value;
    },
  });
}
```

### Composition

Proxy has no strong dependency on the other architecture plugins. When a Proxy
controls access to a driven port (a remote service, a database adapter), its
placement at the infrastructure boundary follows **`hexagonal-architecture`**.
When the concern being interposed is access control or authorisation, the rules
governing that concern are a domain concept whose placement and naming belong to
**`domain-driven-design`**.

---

## Choosing within this group

Adapter, Decorator, and Proxy all wrap an object; the distinction is intent.
An Adapter changes the interface so the client can use a dependency it could not
reach before. A Decorator preserves the interface and layers new behaviour on
top; the client cannot tell it is talking to a Decorator. A Proxy also
preserves the interface, but the reason for wrapping is access control, lazy
loading, caching, or remote indirection, not behaviour enrichment. When you
reach for a wrapper, ask first: am I fixing a shape mismatch (Adapter), adding
behaviour (Decorator), or interposing a cross-cutting concern (Proxy)?

Bridge is sometimes confused with Adapter: Adapter fixes an existing mismatch
after the fact; Bridge separates two axes of variation from the start to prevent
the mismatch from forming in the first place.

Composite is distinct from all three wrappers: it composes objects of the same
interface into a recursive tree so that leaves and branches can be treated
uniformly, rather than wrapping one object in another.

---

## Sources

- Gamma, Helm, Johnson, Vlissides, *Design Patterns: Elements of Reusable
  Object-Oriented Software* (1994). All seven structural patterns above
  (Adapter, Bridge, Composite, Decorator, Facade, Flyweight, Proxy) are defined
  in this work, cited here as Gamma et al. (1994).
