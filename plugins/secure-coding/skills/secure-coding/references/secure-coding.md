# Secure Coding: Reference

Deeper background for the `secure-coding` skill. The skill body holds the
working rules; this file holds the secure-by-design principles in full, the
OWASP Top 10:2025 catalogue, the Proactive Controls 2024 mapping, the ASVS 5.0.0
verification levels, concrete TypeScript practices, and a worked walkthrough,
with sources. This skill is the developer-facing discipline of building security
in: design-time threat modelling, deep cryptography, security tooling, and
infrastructure hardening live with their owners or with future siblings and are
referenced, not repeated, here.

## Table of contents

1. [Sources](#sources)
2. [The secure-by-design principles](#the-secure-by-design-principles)
3. [The OWASP Top 10:2025 catalogue](#the-owasp-top-102025-catalogue)
4. [The Proactive Controls 2024](#the-proactive-controls-2024)
5. [ASVS 5.0.0 as the verification standard](#asvs-500-as-the-verification-standard)
6. [Concrete TypeScript practices](#concrete-typescript-practices)
7. [A worked walkthrough](#a-worked-walkthrough)
8. [Trade-offs and cross-references](#trade-offs-and-cross-references)

---

## Sources

The claims in this reference trace to the following, cited by attribution
without page numbers. Category and control names are quoted verbatim from the
OWASP projects; no other verbatim quotations or page numbers are invented.

- OWASP Top 10:2025 (final release January 2026), the standard awareness
  document for web application security risks:
  https://owasp.org/Top10/2025/
- OWASP Top 10 Proactive Controls (2024), the developer-facing companion:
  https://top10proactive.owasp.org/
- OWASP Application Security Verification Standard (ASVS) 5.0.0 (May 2025):
  https://owasp.org/www-project-application-security-verification-standard/
- OWASP Cheat Sheet Series, for practice-level guidance:
  https://cheatsheetseries.owasp.org/
- Jerome H. Saltzer and Michael D. Schroeder, "The Protection of Information in
  Computer Systems" (Proceedings of the IEEE, 1975), for the design principles.
- CWE Top 25 Most Dangerous Software Weaknesses, as a cross-reference to the
  concrete weakness behind each risk: https://cwe.mitre.org/top25/
- NIST SP 800-63 (Digital Identity Guidelines), referenced by ASVS 5.0.0 for
  password and authentication rules:
  https://pages.nist.gov/800-63-3/

Standards move. The versions above are current as of mid-2026 (Top 10:2025,
Proactive Controls 2024, ASVS 5.0.0). Re-check the OWASP project pages before
treating any specific number or ranking as current.

## The secure-by-design principles

Saltzer and Schroeder (1975) set out eight design principles for protection
mechanisms. They predate the web and still hold; every modern control list is a
restatement of them.

- **Economy of mechanism**: keep the design as small and simple as possible. A
  small mechanism can be reviewed and reasoned about; a large one hides flaws.
- **Fail-safe defaults**: base access decisions on permission, not exclusion. The
  default is no access; access is granted explicitly. This is "fail closed".
- **Complete mediation**: every access to every object is checked for authority.
  Do not check once and cache the answer forever; re-check when authority can
  change.
- **Open design**: security must not depend on the secrecy of the design or the
  code, only on the secrecy of keys. This is the rejection of security by
  obscurity, and the argument for standard, vetted cryptography.
- **Separation of privilege**: require more than one condition to grant access
  where the stakes justify it (for example multi-factor authentication, or two
  approvals for a sensitive action).
- **Least privilege**: every subject operates with the minimum privileges needed
  to complete its task, for the minimum time.
- **Least common mechanism**: minimise mechanisms shared by more than one user or
  depended on by all, because shared mechanisms are shared attack paths.
- **Psychological acceptability**: the secure path must be the easy path. If the
  control is painful, people route around it, so usability is a security
  property.

Two further pragmatic notions from the same work are worth keeping: **work
factor** (raise the cost of an attack above its value) and **compromise
recording** (if you cannot prevent, at least reliably record, which is the root
of security logging).

The skill body distils these into a working mindset (least privilege, fail
closed, defence in depth, complete mediation, economy of mechanism, secure
defaults, never trust input, minimise the attack surface, do not roll your own
crypto). Defence in depth is not in the original eight but follows from them: no
single mechanism is trusted to be perfect, so controls are layered.

## The OWASP Top 10:2025 catalogue

The Top 10 is an awareness document: the most critical risks, ranked from a
large dataset of real findings. The 2025 edition (final release January 2026)
was built from analysis of more than 175,000 CVE records plus practitioner
surveys, and each category maps to specific CWEs. The notable changes from 2021:
**Software Supply Chain Failures** is new at A03; **Mishandling of Exceptional
Conditions** is new at A10; **Security Misconfiguration** rose to A02; and
server side request forgery was absorbed into **Broken Access Control** at A01.

### A01 Broken Access Control

- **What**: a user acts outside their intended permissions: reads another user's
  record, calls an admin action, or reaches an internal resource (SSRF now sits
  here). The most serious risk, ranked first.
- **Cause**: authorization missing, applied only in the user interface, or keyed
  on client-supplied data.
- **Prevent**: enforce on the server, deny by default, check object ownership
  (not just that the caller is logged in), and centralise the decision. Control
  C1.
- **TypeScript**: never trust an `id` or `role` from the request body; look up
  the resource and confirm the authenticated subject owns or may act on it.

### A02 Security Misconfiguration

- **What**: insecure defaults, verbose errors, open cloud storage, unpatched
  sample or debug features, missing hardening.
- **Cause**: shipping the framework or platform defaults, leaving development
  settings in production.
- **Prevent**: hardened, repeatable configuration; remove sample and debug
  endpoints; no default credentials; disable stack traces to clients. Control C5.
- **TypeScript**: set `NODE_ENV=production`, disable framework debug output, and
  drive configuration from validated environment variables, not hardcoded flags.

### A03 Software Supply Chain Failures (new in 2025)

- **What**: compromise entering through dependencies, build tooling, or
  distribution: a malicious package, a typosquat, a poisoned build step.
- **Cause**: unvetted or unpinned dependencies, no integrity verification of the
  build.
- **Prevent**: lockfiles, pinning, integrity hashes, dependency auditing, an
  SBOM, and verified provenance for what you ship. Controls C6 and C2.
- **TypeScript**: commit the lockfile, run `npm audit` (or the equivalent) in CI,
  pin versions, and prefer `npm ci` over `npm install` in the build.

### A04 Cryptographic Failures

- **What**: sensitive data exposed because cryptography is weak, misused, or
  absent (plaintext transport, a plain hash for passwords, a hardcoded key).
- **Cause**: rolling your own, choosing outdated algorithms, mismanaging keys.
- **Prevent**: standard algorithms and libraries, encryption in transit (TLS) and
  at rest where needed, proper key and secret management. Control C2.
- **TypeScript**: hash passwords with argon2id or bcrypt, use the platform crypto
  library for anything cryptographic, and keep keys out of the code.

### A05 Injection

- **What**: untrusted data is interpreted as code or a query: SQL injection,
  command injection, and cross-site scripting (XSS).
- **Cause**: building a query or a document by string concatenation with
  untrusted input.
- **Prevent**: parameterized queries or a safe ORM, validation at the boundary,
  and contextual output encoding for XSS. Control C3.
- **TypeScript**: never interpolate user input into SQL; use parameter
  placeholders. Encode output for the context (HTML, attribute, URL, JavaScript).

### A06 Insecure Design

- **What**: the vulnerability is in the design itself, so no amount of correct
  coding fixes it (for example a password-reset flow that leaks whether an
  account exists).
- **Cause**: security not considered at design time; no threat model.
- **Prevent**: threat model proportionately, choose secure patterns, and write
  abuse-case tests. Control C4. See the threat-modelling cross-reference.
- **TypeScript**: this is a design activity, not a code idiom; the fix is a
  better flow, verified by an abuse-case test.

### A07 Authentication Failures

- **What**: weaknesses in proving identity: credential stuffing, weak passwords,
  broken session management, guessable tokens.
- **Cause**: home-grown authentication, no rate limiting, sessions that never
  expire.
- **Prevent**: strong authentication, multi-factor where it matters, safe session
  and token handling, lockout and rate limiting, NIST-aligned password rules.
  Control C7.
- **TypeScript**: prefer a vetted identity provider or library; if you must
  build, rotate session identifiers on login and expire them.

### A08 Software or Data Integrity Failures

- **What**: code or data trusted without verifying its integrity: an unsigned
  update, deserialization of untrusted data, a compromised pipeline.
- **Cause**: assuming an artifact or payload is genuine without checking.
- **Prevent**: verify signatures and integrity, avoid unsafe deserialization,
  secure the pipeline. Controls C2 and C6.
- **TypeScript**: never deserialize untrusted input into live objects; validate
  the shape (schema) before use and verify integrity of anything downloaded.

### A09 Security Logging and Alerting Failures

- **What**: attacks succeed unseen because security events are not logged,
  monitored, or alerted on.
- **Cause**: no audit trail, logs without the right events, or no alerting.
- **Prevent**: log authentication, access-control, and validation failures with
  enough context to investigate; alert on the patterns that matter; never log the
  secret itself. Control C9.
- **TypeScript**: emit structured security events (actor, action, outcome,
  correlation identifier) to a log the operations team actually watches.

### A10 Mishandling of Exceptional Conditions (new in 2025)

- **What**: unsafe behaviour on error paths: failing open, leaking stack traces
  or internal detail, inconsistent state after a partial failure.
- **Cause**: error handling that reveals detail to the attacker or grants access
  when a check throws.
- **Prevent**: fail closed, catch every path, return a generic message to the
  client and the detail only to the log, keep state consistent. Control C3.
- **TypeScript**: a thrown authorization check must deny, not fall through; the
  `catch` returns a generic 500 and logs the cause server-side.

## The Proactive Controls 2024

The Proactive Controls are the developer-facing companion to the Top 10: what to
do, rather than what goes wrong. The 2024 edition promoted authorization to the
top. Each control maps to the risks it mitigates and to the practice clusters in
the skill body.

| Control | Name | Mitigates |
| --- | --- | --- |
| C1 | Implement access control | A01 |
| C2 | Use cryptography to protect data | A04, A08 |
| C3 | Validate all input and handle exceptions | A05, A10 |
| C4 | Address security from the start | A06 |
| C5 | Secure by default configurations | A02 |
| C6 | Keep your components secure | A03, A08 |
| C7 | Secure digital identities | A07 |
| C8 | Leverage browser security features | A05 (XSS) |
| C9 | Implement security logging and monitoring | A09 |
| C10 | Stop server side request forgery | A01 (SSRF) |

## ASVS 5.0.0 as the verification standard

The Top 10 raises awareness; the Application Security Verification Standard
verifies. ASVS 5.0.0 (May 2025) is a catalogue of roughly 350 requirements
across 17 chapters, modernised for current practice (updated cryptography
guidance including post-quantum considerations, password rules aligned with NIST
SP 800-63, dedicated chapters for web frontend security and self-contained
tokens).

Requirements are grouped into three verification levels; choose one by risk.

- **L1 (baseline)**: the minimum, verifiable through black-box testing. Suitable
  for low-assurance applications.
- **L2 (standard)**: the level most applications that handle personal or business
  data should target. The recommended default.
- **L3 (advanced)**: for the highest-value systems (payments, health, critical
  infrastructure), where a breach is severe.

Use ASVS as a per-feature checklist: pick the level, then for the feature you are
building, walk the relevant chapter (authentication, access control, validation,
cryptography, and so on) and confirm each requirement is met or consciously
waived. Where the Top 10 tells you what to fear, ASVS tells you what to check.

## Concrete TypeScript practices

Idiomatic, framework-neutral examples. Adapt to your stack.

### Validate at the boundary (C3, A05, A10)

Parse untrusted input into a typed value at the edge; reject anything that does
not match. A schema library makes the boundary explicit.

```ts
import { z } from "zod";

const CreateOrder = z.object({
  productId: z.string().uuid(),
  quantity: z.number().int().positive().max(100),
});

export function parseCreateOrder(body: unknown) {
  // Throws on any mismatch; downstream code receives a fully typed value.
  return CreateOrder.parse(body);
}
```

### Parameterized queries (C3, A05)

Never build SQL by concatenation. Use placeholders, or a query builder or ORM
that parameterizes for you.

```ts
// Safe: the driver sends the value separately from the statement.
await pool.query("SELECT * FROM orders WHERE id = $1 AND owner_id = $2", [
  orderId,
  userId,
]);

// Unsafe: string interpolation is injectable. Never do this.
// await pool.query(`SELECT * FROM orders WHERE id = '${orderId}'`);
```

### Authorization, checked on the server, on every request (C1, A01)

Confirm the authenticated subject may act on the specific object, not merely that
they are logged in.

```ts
async function getOrderForUser(orderId: string, userId: string) {
  const order = await orders.findById(orderId);
  // Fail closed: absent or not owned means denied, not "maybe".
  if (!order || order.ownerId !== userId) {
    throw new ForbiddenError();
  }
  return order;
}
```

### Password hashing (C2, C7, A04, A07)

Use a memory-hard, salted, adaptive hash. Never a plain digest such as SHA-256.

```ts
import argon2 from "argon2";

const hash = await argon2.hash(password, { type: argon2.argon2id });
const ok = await argon2.verify(hash, candidate); // constant-time comparison
```

### Secrets from the environment, never in code (C2, A04)

Load and validate secrets at startup; supply them to components at the
composition root (see `dependency-injection`).

```ts
const Env = z.object({
  DATABASE_URL: z.string().url(),
  JWT_SIGNING_KEY: z.string().min(32),
});
const env = Env.parse(process.env); // fail fast if a secret is missing
```

### Security headers, CSRF, and CORS (C8, A05)

Set safe response headers, a content security policy, secure cookie flags, a
CSRF token for state-changing requests, and a restrictive CORS allowlist.

```ts
import helmet from "helmet";
app.use(helmet()); // sensible security headers, including a CSP baseline
app.use(cors({ origin: ["https://app.example.com"], credentials: true }));
// Session cookies: httpOnly, secure, sameSite: "lax" or "strict".
```

### Server side request forgery (C10, A01)

When the server fetches a user-supplied URL, allowlist the host and block
internal and metadata ranges; do not follow redirects blindly.

```ts
const ALLOWED_HOSTS = new Set(["images.example.com"]);

function assertFetchable(url: URL) {
  if (!ALLOWED_HOSTS.has(url.hostname)) throw new ForbiddenError();
  // Also block link-local and metadata addresses such as 169.254.169.254.
}
```

### File uploads (C3, A05, A08)

Treat an upload as hostile input plus hostile storage. Validate type and size,
store outside the web root under a generated name, and never execute it.

```ts
const Upload = z.object({
  mimeType: z.enum(["image/png", "image/jpeg"]), // allowlist, do not infer from the name
  size: z.number().int().positive().max(5_000_000),
});

function safeStoredName(original: string) {
  const ext = path.extname(original).toLowerCase();
  // Generated name defeats path traversal and client-controlled filenames.
  return `${crypto.randomUUID()}${ext === ".png" || ext === ".jpg" ? ext : ".bin"}`;
}
```

### Safe error handling (C3, A10)

Fail closed, log the detail server-side, and return a generic message.

```ts
try {
  return await handle(request);
} catch (err) {
  logger.error({ err, correlationId }, "request failed"); // detail stays here
  return reply.status(500).send({ error: "Internal Server Error" }); // generic
}
```

### Dependency hygiene (C6, A03, A08)

Commit the lockfile, install reproducibly, audit in CI, and keep an SBOM.

```bash
npm ci            # reproducible install from the lockfile
npm audit         # fail the build on known vulnerabilities
npm sbom          # or a dedicated tool, to record what you ship
```

### Security logging without secrets (C9, A09)

Record the event and the outcome; never the credential or the personal data.

```ts
logger.info(
  { actor: userId, action: "login", outcome: "failure", correlationId },
  "authentication attempt",
); // no password, no token, no full personal record
```

## A worked walkthrough

One endpoint, "create an order for the authenticated user", built with the
controls in place. Follow the numbered controls back to the sections above.

```ts
app.post("/orders", requireAuth, async (request, reply) => {
  const userId = request.user.id; // from a verified session or token (C7)

  // 1. Validate untrusted input at the boundary (C3 / A05, A10).
  const input = CreateOrder.parse(request.body);

  // 2. Authorize the specific action for this subject (C1 / A01).
  const product = await products.findById(input.productId);
  if (!product || !product.isAvailableTo(userId)) {
    throw new ForbiddenError(); // fail closed (A10)
  }

  try {
    // 3. Persist with a parameterized query, no concatenation (C3 / A05).
    const order = await orders.create({ ...input, ownerId: userId });

    // 4. Log the security-relevant event without sensitive data (C9 / A09).
    logger.info(
      { actor: userId, action: "order.create", outcome: "success", orderId: order.id },
      "order created",
    );

    return reply.status(201).send({ id: order.id });
  } catch (err) {
    // 5. Handle the exceptional path safely (C3 / A10): log detail, return generic.
    logger.error({ err, actor: userId, action: "order.create", outcome: "failure" }, "order failed");
    return reply.status(500).send({ error: "Internal Server Error" });
  }
});
```

What this closes: input validation stops injection and malformed data (A05,
A10); server-side ownership checks stop broken access control (A01); the
parameterized query stops SQL injection (A05); the structured log gives
detection without leaking secrets (A09); the error path fails closed and returns
a generic message (A10). Secrets (the database URL, the token key) arrived from
the validated environment at the composition root, never from the code (A04).
The dependency on `products` and `orders` is a boundary that a threat model would
examine for A06.

## Trade-offs and cross-references

- **Rigour follows risk.** ASVS L3 and a full threat model fit a payment
  service; an internal read-only tool needs neither. Over-applying controls has a
  cost (complexity, friction) that the psychological-acceptability principle warns
  against: if the secure path is too painful, people route around it.
- **`hexagonal-architecture`**: the ports and adapters are the trust boundaries.
  Validation, authentication, and authorization belong where an adapter admits
  untrusted data into the core. That skill owns the boundary; this one places the
  control on it.
- **`clean-code`**: owns disciplined error handling in general; this skill owns
  its security dimension (A10) and the rule that errors never leak detail.
- **`testing-strategy`** and **`test-driven-development`**: abuse-case and
  security tests belong in the portfolio and can be driven test-first. This skill
  says what to test for (each risk above); those own how to test it.
- **`dependency-injection`**: secrets and credentials are supplied at the
  composition root, never hardcoded in the components that consume them.
- **Threat modelling**: referenced from Insecure Design (A06). Model risk
  proportionately at design time. A future `threat-modeling` sibling could own
  STRIDE, attack trees, and data flow diagrams in depth.
- **Supply chain**: touched here as A03 and C6. A future `supply-chain-security`
  sibling could own SBOM tooling, provenance, and SLSA levels in depth.
- **Tooling**: the `sentrux` MCP and the `/security-review` command detect issues
  after the fact; this skill prevents them while coding. Detection and prevention
  are complementary, not substitutes.
