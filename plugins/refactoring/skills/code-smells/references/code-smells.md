# Code smells reference

Source: Beck and Fowler, *Refactoring: Improving the Design of Existing Code*,
2nd edition, 2018, Chapter 3. All 24 smells are listed below, grouped into
the five pedagogical families used in the skill. The groupings are an
organising aid; they are not Fowler's own chapter structure. Every refactoring
name uses its 2nd-edition form.

---

## Smell-to-refactorings table

### Bloaters

| Smell               | Signal                                                                                                                                        | Why it hurts                                                                                                                                     | Recommended refactorings                                                                                                                                          |
|---------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Mysterious Name     | A function, variable, field, or class has a name that does not reveal its purpose                                                             | Forces every reader to infer intent from context; slows comprehension and invites misuse                                                         | Rename Function (Change Function Declaration), Rename Variable, Rename Field                                                                                      |
| Long Function       | A function is long enough that the reader cannot hold its full logic while reading it                                                         | Decomposition into well-named short functions makes intent explicit and enables reuse                                                            | Extract Function, Replace Temp with Query, Decompose Conditional, Replace Conditional with Polymorphism, Split Loop                                               |
| Long Parameter List | A function takes so many parameters that its call sites are hard to read and easy to misinvoke                                                | Too many parameters increase coupling, suggest the function does too much, and make call sites fragile                                           | Replace Parameter with Query, Preserve Whole Object, Introduce Parameter Object, Remove Flag Argument, Combine Functions into Class                               |
| Large Class         | A class has accumulated too many fields, methods, or lines of code                                                                            | Too many responsibilities make the class hard to understand, test, and extend without causing side effects                                       | Extract Class, Extract Superclass, Replace Type Code with Subclasses                                                                                              |
| Data Clumps         | The same cluster of two or more data items appears together in multiple parameter lists, fields, or local variables                           | The cluster represents a concept that belongs in its own object; extracting it removes the duplication and enables adding behaviour to the group | Extract Class, Introduce Parameter Object, Preserve Whole Object                                                                                                  |
| Primitive Obsession | Primitive values (strings, numbers, booleans) stand in for domain concepts where a small object would enforce constraints and carry behaviour | Primitives have no validation, no behaviour, and no type safety; they allow invalid states that a domain class would prevent                     | Replace Primitive with Object, Replace Type Code with Subclasses, Introduce Parameter Object, Replace Conditional with Polymorphism, Combine Functions into Class |

### Object-orientation abusers

| Smell                                         | Signal                                                                                                     | Why it hurts                                                                                                                      | Recommended refactorings                                          |
|-----------------------------------------------|------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------|
| Repeated Switches                             | The same switch or cascading if/else logic appears in multiple places, keyed on the same type or condition | Every new case requires hunting down and updating every copy of the switch; polymorphism consolidates the decision into one place | Replace Conditional with Polymorphism                             |
| Temporary Field                               | A field is set only under certain conditions and is empty or null the rest of the time                     | Other code must guard against the null or empty state; the field's lifecycle is invisible in the class signature                  | Extract Class, Introduce Special Case                             |
| Refused Bequest                               | A subclass inherits a large interface from its parent but ignores or overrides most of it                  | The inheritance hierarchy does not reflect the actual relationship; the subclass is not truly a specialisation of the parent      | Push Down Method, Push Down Field, Replace Subclass with Delegate |
| Alternative Classes with Different Interfaces | Two classes do similar things but expose different method signatures, preventing substitution or reuse     | Duplicate logic with no path to sharing; adding a common interface after the fact is harder than aligning upfront                 | Change Function Declaration, Move Function, Extract Superclass    |

### Change preventers

| Smell            | Signal                                                                                                                                  | Why it hurts                                                                                                              | Recommended refactorings                                                                                                                                                                |
|------------------|-----------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Divergent Change | A single class must be modified for several different, unrelated reasons (each business rule change touches a different set of methods) | Unrelated concerns interfere with each other; a change for one reason risks breaking another                              | Split Phase, Move Function, Extract Function, Extract Class                                                                                                                             |
| Shotgun Surgery  | A single logical change requires small edits scattered across many classes                                                              | The behaviour that belongs together is spread out; each change is a coordination problem across the whole codebase        | Move Function, Move Field, Combine Functions into Class, Combine Functions into Transform, Inline Function                                                                              |
| Global Data      | Variables or objects reachable from anywhere in the codebase with no access control                                                     | Any module can change global data; bugs can originate anywhere and are nearly impossible to trace                         | Encapsulate Variable                                                                                                                                                                    |
| Mutable Data     | Shared state that can be altered from many call sites, producing surprising side effects at a distance                                  | A change in one module silently breaks code in another that relied on the old value; reasoning about state becomes global | Encapsulate Variable, Split Variable, Separate Query from Modifier, Remove Setting Method, Replace Derived Variable with Query, Combine Functions into Class, Change Reference to Value |

### Dispensables

| Smell                  | Signal                                                                                                              | Why it hurts                                                                                                             | Recommended refactorings                                                                         |
|------------------------|---------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------|
| Duplicated Code        | The same code structure appears in more than one place                                                              | Bugs must be fixed in every copy; copies diverge silently over time                                                      | Extract Function, Slide Statements, Pull Up Method                                               |
| Lazy Element           | A function or class does so little that the indirection adds no value                                               | Extra layers that carry no weight obscure the real logic and force readers to navigate unnecessary hops                  | Inline Function, Inline Class, Collapse Hierarchy                                                |
| Speculative Generality | Abstractions, hooks, or parameters added for anticipated future needs that have not materialised                    | The complexity costs are real and immediate; the benefits are hypothetical and may never arrive (YAGNI)                  | Collapse Hierarchy, Inline Function, Inline Class, Change Function Declaration, Remove Dead Code |
| Loops                  | A loop that transforms or filters a collection where a pipeline would express intent more directly                  | Loops mix iteration mechanics with the transformation logic; pipelines make the data flow explicit and composable        | Replace Loop with Pipeline                                                                       |
| Data Class             | A class that holds data but has no behaviour: only fields and getters/setters                                       | Other classes must implement the behaviour that belongs in the Data Class; the class fails to enforce its own invariants | Encapsulate Record, Remove Setting Method, Move Function, Extract Function, Split Phase          |
| Comments               | Comments that explain what the code does rather than why, substituting for code that could be made self-explanatory | The comment is a signal that the code is unclear; the fix is to make the code clear, not to document the obscurity       | Extract Function, Change Function Declaration, Introduce Assertion                               |

### Couplers

| Smell           | Signal                                                                                                                     | Why it hurts                                                                                                               | Recommended refactorings                                                                             |
|-----------------|----------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------|
| Feature Envy    | A function that reaches repeatedly into another class to access its data, showing more interest in that class than its own | The function belongs closer to the data it uses; keeping it away from that data fragments related logic                    | Move Function, Extract Function                                                                      |
| Message Chains  | A long sequence of navigation calls (a.getB().getC().getD()) to reach the value actually needed                            | Any change in the chain between A and D requires updating every caller that traverses it                                   | Hide Delegate, Extract Function, Move Function                                                       |
| Middle Man      | A class whose interface consists mostly of methods that do nothing but delegate to another class                           | The indirection adds no value; callers could talk to the real object directly                                              | Remove Middle Man, Inline Function, Replace Superclass with Delegate, Replace Subclass with Delegate |
| Insider Trading | Two classes that access each other's private or internal details more than their public interface intends                  | Hidden coupling makes each class harder to change without affecting the other; encapsulation is broken at the design level | Move Function, Move Field, Extract Class, Hide Delegate                                              |

---

## TypeScript examples

The following examples show the smell in its before state, name the refactoring
applied, and show the result. All examples use TypeScript.

### Long Function

A single function validates, calculates, and persists an order. The concerns
are tangled and the function cannot be understood in one reading.

```typescript
// Before: Long Function
function processOrder(order: Order): void {
    // validate
    if (!order.customerId) {
        throw new Error("Order must have a customer.");
    }
    if (order.items.length === 0) {
        throw new Error("Order must have at least one item.");
    }

    // calculate total
    let subtotal = 0;
    for (const item of order.items) {
        subtotal += item.price * item.quantity;
    }
    const discount = order.discountRate ?? 0;
    const total = subtotal * (1 - discount);

    // apply tax
    const tax = total * 0.2;
    const grandTotal = total + tax;

    // persist and notify
    db.save({...order, total: grandTotal});
    mailer.send(order.customerId, `Your order total is ${grandTotal}.`);
}
```

Apply **Extract Function** to each concern:

```typescript
// After: Extract Function applied
function validateOrder(order: Order): void {
    if (!order.customerId) {
        throw new Error("Order must have a customer.");
    }
    if (order.items.length === 0) {
        throw new Error("Order must have at least one item.");
    }
}

function calculateSubtotal(items: OrderItem[]): number {
    return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
}

function applyDiscountAndTax(subtotal: number, discountRate: number): number {
    const afterDiscount = subtotal * (1 - discountRate);
    return afterDiscount * 1.2;
}

function processOrder(order: Order): void {
    validateOrder(order);
    const grandTotal = applyDiscountAndTax(
        calculateSubtotal(order.items),
        order.discountRate ?? 0,
    );
    db.save({...order, total: grandTotal});
    mailer.send(order.customerId, `Your order total is ${grandTotal}.`);
}
```

---

### Duplicated Code

Two report classes share identical formatting logic.

```typescript
// Before: Duplicated Code
class CustomerReport {
    generate(customers: Customer[]): string {
        return customers
            .filter((c) => c.active)
            .map((c) => `${c.name}: ${c.email}`)
            .join("\n");
    }
}

class SupplierReport {
    generate(suppliers: Supplier[]): string {
        return suppliers
            .filter((s) => s.active)
            .map((s) => `${s.name}: ${s.email}`)
            .join("\n");
    }
}
```

Apply **Extract Function** to hoist the shared logic:

```typescript
// After: Extract Function applied
function formatActiveEntities(
    entities: Array<{ name: string; email: string; active: boolean }>,
): string {
    return entities
        .filter((e) => e.active)
        .map((e) => `${e.name}: ${e.email}`)
        .join("\n");
}

class CustomerReport {
    generate(customers: Customer[]): string {
        return formatActiveEntities(customers);
    }
}

class SupplierReport {
    generate(suppliers: Supplier[]): string {
        return formatActiveEntities(suppliers);
    }
}
```

---

### Long Parameter List

A function that constructs a user from eight independent primitives.

```typescript
// Before: Long Parameter List
function createUser(
    firstName: string,
    lastName: string,
    email: string,
    phone: string,
    street: string,
    city: string,
    country: string,
    role: string,
): User {
    // ...
}
```

Apply **Introduce Parameter Object** to group related data:

```typescript
// After: Introduce Parameter Object applied
interface Address {
    street: string;
    city: string;
    country: string;
}

interface CreateUserInput {
    firstName: string;
    lastName: string;
    email: string;
    phone: string;
    address: Address;
    role: string;
}

function createUser(input: CreateUserInput): User {
    // ...
}
```

---

### Feature Envy

A method on `Order` reaches repeatedly into `Customer` to compute a discount,
showing more interest in `Customer` than in `Order`.

```typescript
// Before: Feature Envy
class Order {
    constructor(private readonly customer: Customer) {
    }

    getCustomerDiscount(): number {
        if (this.customer.loyaltyYears > 5) return 0.15;
        if (this.customer.loyaltyYears > 2) return 0.1;
        if (this.customer.isPremium) return 0.05;
        return 0;
    }
}
```

Apply **Move Function** to relocate the method to the class it actually uses:

```typescript
// After: Move Function applied
class Customer {
    constructor(
        readonly loyaltyYears: number,
        readonly isPremium: boolean,
    ) {
    }

    discount(): number {
        if (this.loyaltyYears > 5) return 0.15;
        if (this.loyaltyYears > 2) return 0.1;
        if (this.isPremium) return 0.05;
        return 0;
    }
}

class Order {
    constructor(private readonly customer: Customer) {
    }

    getCustomerDiscount(): number {
        return this.customer.discount();
    }
}
```

---

### Primitive Obsession

A phone number is passed around as a raw string, with validation and formatting
logic duplicated at every use site.

```typescript
// Before: Primitive Obsession
function formatPhone(raw: string): string {
    const digits = raw.replace(/\D/g, "");
    if (digits.length !== 10) throw new Error("Invalid phone number.");
    return `(${digits.slice(0, 3)}) ${digits.slice(3, 6)}-${digits.slice(6)}`;
}

function sendSms(phone: string, message: string): void { /* ... */
}

function logContact(name: string, phone: string): void { /* ... */
}
```

Apply **Replace Primitive with Object** to encapsulate the constraint and
behaviour in a class:

```typescript
// After: Replace Primitive with Object applied
class PhoneNumber {
    private readonly digits: string;

    constructor(raw: string) {
        const digits = raw.replace(/\D/g, "");
        if (digits.length !== 10) {
            throw new Error("Invalid phone number.");
        }
        this.digits = digits;
    }

    format(): string {
        return `(${this.digits.slice(0, 3)}) ${this.digits.slice(3, 6)}-${this.digits.slice(6)}`;
    }

    toString(): string {
        return this.digits;
    }
}

function sendSms(phone: PhoneNumber, message: string): void { /* ... */
}

function logContact(name: string, phone: PhoneNumber): void { /* ... */
}
```

---

## Names changed in the 2nd edition

The following smells were renamed between the 1st edition (1999) and the
2nd edition (2018). Cross-references to other materials that use the old
names may be misleading.

| 1st edition name       | 2nd edition name  |
|------------------------|-------------------|
| Long Method            | Long Function     |
| Switch Statements      | Repeated Switches |
| Lazy Class             | Lazy Element      |
| Inappropriate Intimacy | Insider Trading   |
| Duplicate Code         | Duplicated Code   |

New smells introduced in the 2nd edition (not present in the 1st):
Mysterious Name, Global Data, Mutable Data, Loops.

Smells removed from the 2nd edition: Parallel Inheritance Hierarchies,
Incomplete Library Class.
