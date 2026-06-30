# Creational patterns reference

The detailed reference behind the skill: force or smell, when not to apply,
minimal TypeScript form, and composition notes for each of the five Gang of
Four creational patterns.

Standards and sources:
- Gamma, Helm, Johnson, Vlissides, *Design Patterns: Elements of Reusable
  Object-Oriented Software* (1994): the canonical source for all five patterns
  below, cited as Gamma et al. (1994).

---

## Abstract Factory

The smell is code that constructs families of related products in multiple
places, or a conditional that switches on a "platform" or "theme" token to
create different but related objects together. When objects in a family must
remain consistent with one another (a button and a checkbox that both belong
to the same UI toolkit skin, for example), scattered construction lets the
family fall out of sync. Abstract Factory centralises the family contract
behind a single interface of factory functions.

Source: Gamma et al. (1994).

### When not to apply

When only one product family exists today, introducing an Abstract Factory
is speculative abstraction (YAGNI). A factory interface with one
implementation is indirection without payoff. Wait until a genuine second
family appears.

### Minimal form

```typescript
interface Button   { render(): void; }
interface Checkbox { render(): void; }

interface UIFactory {
  createButton():   Button;
  createCheckbox(): Checkbox;
}

// Two concrete families as plain objects of factory functions.
const webFactory: UIFactory = {
  createButton:   () => ({ render: () => { /* web button */ } }),
  createCheckbox: () => ({ render: () => { /* web checkbox */ } }),
};

const mobileFactory: UIFactory = {
  createButton:   () => ({ render: () => { /* mobile button */ } }),
  createCheckbox: () => ({ render: () => { /* mobile checkbox */ } }),
};

function renderUI(factory: UIFactory): void {
  factory.createButton().render();
  factory.createCheckbox().render();
}
```

An object of factory functions (plain TypeScript) is usually sufficient.
A class hierarchy pays off only when factory state or polymorphic override
is required.

### Composition

The generic mechanism (a shared interface that produces a family of related
objects) is defined here. The **`domain-driven-design`** skill owns the
aggregate factory specialisation: when a factory guards the invariants of an
aggregate root, its placement in the domain layer and its relationship to the
aggregate are governed by that skill, not this one.

---

## Builder

The smell is a constructor with five or more parameters, especially when
many are optional or must be combined in specific ways. Call sites become
hard to read and error-prone: positional arguments are easy to transpose,
and optional parameters produce a combinatorial spread of overloads.

Source: Gamma et al. (1994).

### When not to apply

When the parameter count is small or all parameters are required, an options
object (TypeScript destructuring with defaults) is simpler and sufficient.
Reach for a fluent Builder only when construction genuinely spans many steps
with ordering constraints, intermediate validation, or a reuse pattern where
the same configuration is used to produce multiple objects.

### Minimal form

```typescript
// Preferred: an options object handles most cases.
interface QueryOptions {
  table:   string;
  filter?: string;
  limit?:  number;
  offset?: number;
}

function buildQuery(options: QueryOptions): string {
  const { table, filter = "1=1", limit = 100, offset = 0 } = options;
  return `SELECT * FROM ${table} WHERE ${filter} LIMIT ${limit} OFFSET ${offset}`;
}

// buildQuery({ table: "users", filter: "active = true", limit: 20 });

// Heavier alternative: a fluent builder, justified when construction spans
// steps with ordering constraints or inter-step validation.
class QueryBuilder {
  private options: QueryOptions = { table: "" };

  from(table: string): this   { this.options.table = table;    return this; }
  where(filter: string): this { this.options.filter = filter;  return this; }
  take(limit: number): this   { this.options.limit = limit;    return this; }
  skip(offset: number): this  { this.options.offset = offset;  return this; }
  build(): string             { return buildQuery(this.options); }
}
```

### Composition

Builder does not require a strong cross-reference to another plugin. When
the object being built is a domain aggregate, the construction logic and
invariant enforcement belong to the `domain-driven-design` skill.

---

## Factory Method

The smell is a conditional that branches on a type code to instantiate
different concrete classes, where the branching logic must be duplicated
whenever a new type is added. The caller knows which type to create, but
the creation decision and the resulting object's interface should be
decoupled from the caller's own responsibility.

Source: Gamma et al. (1994).

### When not to apply

When a plain function or a parameter already expresses the variation clearly,
introducing a class hierarchy is unnecessary machinery. A function that
returns an object literal, or a parameter that accepts a ready-made
collaborator, achieves the same decoupling with less indirection.

### Minimal form

```typescript
type Channel = "email" | "sms" | "push";

interface Notification {
  send(message: string): void;
}

// A plain factory function: the idiomatic TypeScript form.
function createNotification(channel: Channel): Notification {
  switch (channel) {
    case "email": return { send: (msg) => { /* send email */ } };
    case "sms":   return { send: (msg) => { /* send SMS */   } };
    case "push":  return { send: (msg) => { /* send push */  } };
  }
}

// Usage: const n = createNotification("email"); n.send("Welcome");
```

The class-based GoF form (a Creator class with a `createProduct()` method
overridden in subclasses) is rarely the right shape in TypeScript; a function
or a registry object achieves the same intent with less ceremony.

### Composition

The generic pattern (defer the choice of concrete type to a function or
method) is defined here. The **`domain-driven-design`** skill owns the
aggregate factory specialisation: when a factory method guards the
invariants of an aggregate, ensuring that the aggregate is never constructed
in an invalid state, its placement in the domain layer and its relationship
to the aggregate root are governed by that skill.

---

## Prototype

The smell is construction from scratch that is expensive, lossy, or verbose
when you already have a correctly configured instance and need a fresh copy
of it. Repeating the construction sequence risks divergence, and directly
copying fields by hand is brittle when the type gains new fields.

Source: Gamma et al. (1994).

### When not to apply

Prototype is the rarest of the GoF creational patterns in TypeScript. Object
spread (`{ ...original }`) handles shallow copies of plain objects, and
`structuredClone` handles deep copies of serialisable objects. Reach for an
explicit `clone()` method only when the type is a class with behaviour, or
when the copy semantics need to be defined precisely (deciding which fields
are deep-copied versus shared). Mutable shared state after a shallow clone
is a common trap: if nested objects are shared by reference, mutating one
copy mutates the other.

### Minimal form

```typescript
class DocumentTemplate {
  constructor(
    public readonly title:    string,
    public readonly sections: readonly string[],
  ) {}

  clone(): DocumentTemplate {
    // Deep-copy sections so the clone is fully independent.
    return new DocumentTemplate(this.title, [...this.sections]);
  }
}

const base = new DocumentTemplate("Quarterly Report", ["Introduction", "Findings"]);
const copy = base.clone(); // independent instance, same shape
```

For plain data objects without behaviour, prefer `structuredClone(original)`
over an explicit `clone()` method.

### Composition

Prototype has no strong dependency on the other architecture plugins. When
a domain entity or value object requires copying semantics, those semantics
(what identity means, what is shared versus copied) belong to the
**`domain-driven-design`** skill.

---

## Singleton

The force is a resource or coordinator that must exist exactly once within a
process: a configuration store, a connection pool, a logger. Every part of
the system must reach the same instance.

Source: Gamma et al. (1994).

### When not to apply

Almost always. The classic GoF Singleton (a class with a private constructor
and a static `instance` accessor) is the strongest guardrail pattern in this
catalogue. It couples every caller to the class itself, makes the dependency
invisible (callers do not declare it; they reach for a global), makes tests
order-dependent (one test's mutation leaks into the next), and makes the
instance impossible to replace in isolation.

Two better alternatives exist:

1. A module-level constant: a module is a natural singleton in Node.js and
   browser environments. Exporting a constant from a module provides the
   same shared instance with no class machinery, no hidden state, and no
   global coupling. Callers import explicitly; the dependency is visible.

2. A single instance wired at the composition root: create one instance and
   pass it through the dependency-injection graph. Every consumer receives it
   as a constructor parameter; the single-instance guarantee lives at the
   composition root, not inside the class. This is the form recommended for
   objects that need to be replaced in tests.

Reach for the GoF Singleton only when you have no DI framework or module
system and you genuinely cannot pass the instance through. Document the
reason; treat it as a last resort.

### Minimal form

```typescript
// Preferred: a module-level constant.
// config.ts
export const config = Object.freeze({
  apiUrl:      process.env["API_URL"]      ?? "https://api.example.com",
  timeout:     Number(process.env["TIMEOUT"] ?? 5000),
  databaseUrl: process.env["DATABASE_URL"] ?? "postgres://localhost/app",
});

// Any module that needs it imports explicitly:
// import { config } from "./config";
// No hidden global; the dependency is declared at the import site.
```

```typescript
// Also acceptable: a single instance created at the composition root and
// injected into every consumer that needs it.
// main.ts (composition root)
import { config } from "./config";
import { DatabasePool } from "./database-pool";
import { UserRepository } from "./user-repository";
import { UserService } from "./user-service";

const pool = new DatabasePool(config.databaseUrl);           // created once
const repo = new UserRepository(pool);                       // injected
const service = new UserService(repo);                       // injected
```

The GoF class form (private constructor, static `instance`) is intentionally
omitted here: if you find yourself reaching for it, reach for one of the two
alternatives above first.

### Composition

Lifetime management (deciding that a collaborator lives for the whole process,
or for a request, or for a session) belongs to the **`dependency-injection`**
skill. That skill owns how the single instance is created, scoped, and wired.
This skill only defines what Singleton means as a GoF pattern and why it is
almost always the wrong implementation choice.

---

## Choosing within this group

When you need to create a single object and the concrete type depends on
context, Factory Method (a function) is the minimal form. When you need a
family of related objects to be created together, Abstract Factory adds the
consistency guarantee. When the object requires many optional or ordered
construction steps, prefer an options-object constructor first; add a fluent
Builder only when step ordering or inter-step validation justifies the extra
machinery. When you need an independent copy of an existing instance, prefer
`structuredClone` or object spread for plain data, and add an explicit
`clone()` method only when the copy semantics need to be defined precisely.
When you need a single shared instance, use a module-level constant or wire
one instance at the DI composition root; avoid the GoF Singleton class.

---

## Sources

- Gamma, Helm, Johnson, Vlissides, *Design Patterns: Elements of Reusable
  Object-Oriented Software* (1994). All five creational patterns above
  (Abstract Factory, Builder, Factory Method, Prototype, Singleton) are
  defined in this work, cited here as Gamma et al. (1994).
