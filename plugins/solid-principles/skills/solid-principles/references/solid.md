# SOLID principles reference

The detailed reference behind the skill: canonical definitions, before/after
examples, and "when not to apply" notes for each of the five SOLID principles.

Standards and sources:
- Robert C. Martin, *Design Principles and Design Patterns* (2000):
  the paper that unified SRP, OCP, LSP, ISP, and DIP into a single framework.
- Barbara Liskov, *Data Abstraction and Hierarchy* (1987):
  the original LSP formulation.
- [SOLID on Wikipedia](https://en.wikipedia.org/wiki/SOLID)
- [SOLID Design Principles Explained (DigitalOcean)](https://www.digitalocean.com/community/conceptual-articles/s-o-l-i-d-the-first-five-principles-of-object-oriented-design)
- [Why SOLID principles are still the foundation for modern software architecture (Stack Overflow Blog)](https://stackoverflow.blog/2021/11/01/why-solid-principles-are-still-the-foundation-for-modern-software-architecture/)
- [Single Responsibility Principle deep dive (LogRocket Blog)](https://blog.logrocket.com/single-responsibility-principle-srp/)

---

## SRP: Single Responsibility Principle

"There should never be more than one reason for a class to change."
(Robert C. Martin, 2000)

A class, module, or function should have one cohesion boundary: one set of
related behaviors with one reason to change. Multiple unrelated concerns
belong in separate units.

### Smell

```typescript
class UserService {
  hashPassword(password: string): string { /* crypto logic */ }
  saveUser(user: User): void { /* SQL INSERT */ }
  sendWelcomeEmail(user: User): void { /* SMTP call */ }
}
```

Three independent reasons to change: cryptographic policy, database schema,
and email template. A change to any one concern forces a re-test of the
others.

### Fix

```typescript
class AuthService {
  hashPassword(password: string): string { /* crypto logic */ }
}

class UserRepository {
  save(user: User): void { /* SQL INSERT */ }
}

class EmailService {
  sendWelcomeEmail(user: User): void { /* SMTP call */ }
}

class UserService {
  constructor(
    private auth: AuthService,
    private repo: UserRepository,
    private email: EmailService,
  ) {}

  register(user: User, password: string): void {
    const hashed = this.auth.hashPassword(password);
    this.repo.save({ ...user, password: hashed });
    this.email.sendWelcomeEmail(user);
  }
}
```

### When not to apply

"One method per class" misreads SRP. A class may have many methods if they
all serve the same cohesion boundary. Splitting at too fine a granularity
produces class explosion: dozens of tiny classes whose boundaries are
unclear, making a single change touch more files than the original monolith
would have. Apply SRP when you observe two genuinely independent reasons to
change, not speculatively.

---

## OCP: Open/Closed Principle

"Software entities should be open for extension, but closed for
modification." (Bertrand Meyer, 1988; popularized by Robert C. Martin, 2000)

Existing, working code should not need to change when new behavior is added.
Extend via new types, strategies, or decorators rather than editing
conditionals.

### Smell

```typescript
class AreaCalculator {
  sum(shapes: Shape[]): number {
    return shapes.reduce((total, shape) => {
      if (shape.type === "circle") {
        return total + Math.PI * shape.radius ** 2;
      } else if (shape.type === "rectangle") {
        return total + shape.width * shape.height;
      }
      // Adding a triangle forces editing this method.
      return total;
    }, 0);
  }
}
```

### Fix

```typescript
interface Shape {
  area(): number;
}

class Circle implements Shape {
  area(): number { return Math.PI * this.radius ** 2; }
}

class Rectangle implements Shape {
  area(): number { return this.width * this.height; }
}

class Triangle implements Shape {
  area(): number { return (this.base * this.height) / 2; }
}

class AreaCalculator {
  sum(shapes: Shape[]): number {
    return shapes.reduce((total, shape) => total + shape.area(), 0);
  }
}
```

Adding `Triangle` requires no change to `AreaCalculator`.

### When not to apply

Premature OCP abstraction is the classic over-engineering failure. If there
is only one shape today, the interface and dispatch add indirection with no
present payoff. Follow the rule of three: abstract after you see a pattern
repeated, not before. The first case is concrete, the second is a warning,
the third justifies the abstraction.

---

## LSP: Liskov Substitution Principle

"Functions that use pointers or references to base classes must be able to
use objects of derived classes without knowing it."
(Barbara Liskov, 1987; formulated by Robert C. Martin, 2000)

Subtypes must honor the behavioral contract of their supertype: same return
types, no stronger preconditions, no weaker postconditions. A caller that
holds a reference to the base type must never need a special case for a
subtype.

### Smell

```typescript
class AreaCalculator {
  sum(shapes: Shape[]): number { /* returns a scalar */ }
}

class VolumeCalculator extends AreaCalculator {
  // Overrides sum() to return an array; breaks the parent contract.
  sum(shapes: Shape[]): number[] { /* returns an array */ }
}

// Crashes when handed a VolumeCalculator:
outputter.render(calculator.sum(shapes));
```

### Fix

```typescript
class VolumeCalculator extends AreaCalculator {
  // Honor the parent return type.
  sum(shapes: Shape[]): number {
    return shapes.reduce((total, shape) => total + shape.volume(), 0);
  }
}
```

If a subtype cannot honor the parent contract, prefer composition over
inheritance: hold the shared behavior as a dependency rather than inheriting.

### When not to apply

LSP is only relevant when inheritance is in use. If a codebase prefers
composition over inheritance (the standard modern recommendation), LSP rarely
applies. Applying it as a checklist item to a flat, compositional design is
noise. Its real signal is: if a call site needs a runtime type check to handle
a subtype correctly, the inheritance hierarchy is wrong.

---

## ISP: Interface Segregation Principle

"Clients should not be forced to depend upon interface methods that they do
not use." (Robert C. Martin, 2000)

Prefer narrow, cohesive interfaces over fat interfaces that bundle unrelated
capabilities. A class that implements an interface should genuinely satisfy
every method in it.

### Smell

```typescript
interface Shape {
  area(): number;
  volume(): number; // meaningless for 2D shapes
}

class Square implements Shape {
  area(): number { return this.side ** 2; }
  volume(): number { throw new Error("not supported"); } // forced stub
}
```

### Fix

```typescript
interface TwoDimensionalShape {
  area(): number;
}

interface ThreeDimensionalShape {
  area(): number;
  volume(): number;
}

class Square implements TwoDimensionalShape {
  area(): number { return this.side ** 2; }
}

class Cube implements ThreeDimensionalShape {
  area(): number { return 6 * this.side ** 2; }
  volume(): number { return this.side ** 3; }
}
```

### When not to apply

ISP taken too far produces interface explosion: one interface per method,
each with a single implementation, even where no client ever needed the
separation. The deciding factor is not implementation count but client need:
split interfaces only when there are genuinely distinct clients that use
different subsets of behavior, or when a boundary role (testing seam,
architectural port) justifies the separation. Over-segregation without that
reason is speculative indirection.

---

## DIP: Dependency Inversion Principle

"High-level modules should not depend on low-level modules. Both should
depend on abstractions. Abstractions should not depend on details. Details
should depend on abstractions." (Robert C. Martin, 2000)

Business logic should not be coupled to infrastructure choices. Introduce a
seam (interface or abstract type) and inject the concrete implementation.

### Smell

```typescript
class PasswordReminder {
  private db: MySQLConnection;

  constructor() {
    this.db = new MySQLConnection(); // hard-coded; untestable, inflexible
  }

  remindUser(userId: string): void {
    const user = this.db.query(`SELECT * FROM users WHERE id = ?`, userId);
    // ... send reminder
  }
}
```

Switching databases, or testing `PasswordReminder` in isolation, requires
modifying `PasswordReminder` itself.

### Fix

```typescript
interface DatabaseConnection {
  query(sql: string, ...params: unknown[]): unknown;
}

class MySQLConnection implements DatabaseConnection {
  query(sql: string, ...params: unknown[]): unknown { /* ... */ }
}

class PasswordReminder {
  constructor(private db: DatabaseConnection) {}

  remindUser(userId: string): void {
    const user = this.db.query(`SELECT * FROM users WHERE id = ?`, userId);
    // ... send reminder
  }
}

// Production: new PasswordReminder(new MySQLConnection())
// Test:       new PasswordReminder(new InMemoryConnection())
```

### When not to apply

DIP should not be read as "never depend on concrete classes." The deciding
question is not how many implementations exist today. It is whether there is a
real seam with a present reason: an architectural boundary you are inverting (a
port over an external system such as a database, message broker, or third-party
API), a genuine testing seam, or a contract you want to stabilize. An interface
with a single implementation at such a boundary is DIP done correctly, not
speculation.

What is speculative is adding an interface over an internal collaborator that
has no boundary role, no second implementation in sight, and no testing or
inversion reason, purely to look SOLID. That adds indirection with no present
payoff.

---

## Pragmatism

SOLID principles are heuristics for managing coupling and cohesion, not laws.
Their value is proportional to the complexity and longevity of the system.

A small script or a proof-of-concept does not benefit from multiple layers of
abstraction. The cost of each principle (indirection, extra types, cognitive
load) must be weighed against its present payoff. Over-application is as
harmful as ignoring the principles entirely.

As Stack Overflow Blog notes, the principles endure because they address
constants in software development: code is written and modified by people,
code is organized into modules, and code serves internal or external clients.
The principles serve these human and organizational realities, not the
reverse.

Match the level of sophistication to the actual need.
