---
name: secure-coding
description: This skill should be used when writing, reviewing, or refactoring code that handles untrusted input, authentication, authorization, sessions, secrets, cryptography, database queries, file uploads, or outbound URLs and requests, when shaping error and exception paths, when adding or updating dependencies and reasoning about the software supply chain, or when recognising and preventing an OWASP Top 10 risk such as broken access control, injection, a cryptographic failure, or a security misconfiguration, applying secure coding even when "secure coding", "OWASP", or "AppSec" is not named. Covers the secure-by-design mindset (Saltzer and Schroeder), the OWASP Proactive Controls 2024 as the what-to-do-while-coding checklist, the OWASP Top 10:2025 as the risk catalogue, ASVS 5.0.0 as the verification standard, and concrete practices with TypeScript specifics. This is the developer-facing discipline of building security in: it defers design-time threat modelling, deep cryptography, and security tooling to their owners.
---

# Secure Coding

Security is a property you design and code in from the start, not a test run at
the end. The question while coding is not "will the scanner flag this?" but "who
is the attacker, what do they control, and what stops them here?". Untrusted
input, an authorization check, a secret, a database query, an outbound request:
each is a place where a control belongs or a vulnerability appears. This skill
is the developer-facing discipline of putting those controls in place.

It grounds itself in current OWASP standards and the historical secure-by-design
principles, and it stays knowledge rather than tooling: it composes with, but
does not replace, a scanner (such as the `sentrux` MCP) or a diff auditor (such
as the `/security-review` command). Those detect; this prevents.

## The secure-by-design mindset

The reasoning frame, distilled from Saltzer and Schroeder (1975) and their
modern restatements. Reason with these before reaching for a checklist.

- **Least privilege**: grant the minimum access a subject needs, no more, and
  for no longer than needed.
- **Fail-safe defaults, fail closed**: default to denying access; on error, deny
  rather than allow. Allow only what is explicitly permitted.
- **Complete mediation**: check authority on every access to every object, not
  once and then cached forever.
- **Defence in depth**: layer independent controls so one failure does not breach
  the system.
- **Economy of mechanism**: keep security logic small and simple; complexity is
  where flaws hide.
- **Secure defaults**: the out-of-the-box configuration is the safe one; security
  is not an opt-in the user must remember.
- **Never trust input**: treat everything crossing a trust boundary (user,
  network, file, environment, another service) as hostile until validated.
- **Minimise the attack surface**: fewer entry points, features, and permissions
  mean less to defend.
- **Do not roll your own crypto**: use vetted libraries and standard
  constructions; never invent a cipher, a hash scheme, or a token format.

## Proactive controls (OWASP, 2024)

What to do while coding. The OWASP Top 10 Proactive Controls (2024), C1 to C10:

- **C1 Implement access control**: enforce authorization on every request, deny
  by default, check ownership not just authentication.
- **C2 Use cryptography to protect data**: standard algorithms, protect data in
  transit and at rest, manage keys and secrets properly.
- **C3 Validate all input and handle exceptions**: validate at the boundary
  against an allowlist, and handle every error path safely.
- **C4 Address security from the start**: threat model proportionately, choose
  secure designs and libraries early.
- **C5 Secure by default configurations**: ship hardened defaults, remove sample
  and debug endpoints, no default credentials.
- **C6 Keep your components secure**: track, pin, and patch dependencies; watch
  the supply chain.
- **C7 Secure digital identities**: strong authentication, safe session and token
  handling, sensible password and multi-factor rules.
- **C8 Leverage browser security features**: security headers, a content security
  policy, cookie flags, CSRF and CORS controls.
- **C9 Implement security logging and monitoring**: record security-relevant
  events, enough to detect and investigate, without logging secrets.
- **C10 Stop server side request forgery**: validate and allowlist outbound URLs;
  block requests to internal ranges and metadata endpoints.

## The risk catalogue (OWASP Top 10:2025)

The failures to recognise and prevent. Each maps to the controls above.

- **A01 Broken Access Control**: missing or bypassable authorization (now
  including SSRF). Prevent with C1.
- **A02 Security Misconfiguration**: unsafe defaults, exposed debug or admin
  surfaces. Prevent with C5.
- **A03 Software Supply Chain Failures** (new in 2025): compromised or
  unvetted dependencies and build inputs. Prevent with C6.
- **A04 Cryptographic Failures**: weak, misused, or absent cryptography. Prevent
  with C2.
- **A05 Injection**: untrusted data interpreted as code or a query (SQL, command,
  XSS). Prevent with C3.
- **A06 Insecure Design**: the flaw is in the design, not the code. Prevent with
  C4 and threat modelling.
- **A07 Authentication Failures**: weak identity, session, or credential
  handling. Prevent with C7.
- **A08 Software or Data Integrity Failures**: unverified updates, deserialization
  of untrusted data. Prevent with C2 and C6.
- **A09 Security Logging and Alerting Failures**: blind to attacks in progress.
  Prevent with C9.
- **A10 Mishandling of Exceptional Conditions** (new in 2025): unsafe error
  paths that leak detail or fail open. Prevent with C3.

Top 10 raises awareness; **ASVS 5.0.0** verifies. Use the OWASP Application
Security Verification Standard as a per-feature checklist, picking a level by
risk: L1 baseline, L2 for most applications, L3 for high-value systems. The
reference maps the levels and the practices.

## Practice clusters

- **Access control and authorization**: check on the server, on every request,
  deny by default, verify object ownership, never trust a client-side role.
- **Authentication and digital identity**: hash passwords with argon2id or
  bcrypt (never a plain digest), expire and rotate sessions and tokens, offer
  multi-factor, avoid JWT algorithm confusion.
- **Input handling, injection, output encoding**: validate at the boundary
  against a schema and an allowlist; use parameterized queries; encode output for
  its context to stop XSS.
- **Cryptography and secrets**: standard libraries and constructions; secrets in
  the environment or a secret manager, never in code or version control.
- **Secure configuration and defaults**: hardened defaults, no sample or debug
  endpoints in production, no default credentials, least-privilege service
  accounts.
- **Dependencies and the software supply chain**: lockfiles, pinning, `npm audit`
  or equivalent, an SBOM, prompt patching.
- **Error handling and exceptional conditions**: fail closed, catch every path,
  return a generic message to the client and the detail only to the log.
- **Security logging and monitoring**: log the security event (who, what, when,
  outcome) without the secret or the personal data.
- **Server side request forgery**: allowlist outbound hosts, block internal and
  metadata ranges, do not follow redirects blindly.

## Guardrails

- **Do not roll your own crypto.** Use vetted libraries and standard
  constructions.
- **Validate and authorize on the server.** Client-side checks are for user
  experience, never for security.
- **Fail closed.** On any error or ambiguity, deny rather than allow.
- **Least privilege by default.** Grant the minimum, widen only with reason.
- **Secrets never in code or version control.** Environment or secret manager
  only.
- **Keep dependencies patched.** An unpatched known vulnerability is the easiest
  way in.
- **Never log secrets or sensitive data.** Logs are read by many and retained
  long.
- **No security by obscurity.** A hidden endpoint or a secret algorithm is not a
  control.

## Relationship to other skills

- **`hexagonal-architecture`**: the ports and adapters are the trust boundaries.
  Input validation, authentication, and authorization belong exactly where
  untrusted data crosses an adapter into the core. That skill owns the boundary
  structure; this one places the controls on it.
- **`clean-code`**: owns disciplined error handling in general. This skill owns
  its security dimension: the mishandling of exceptional conditions (A10) and
  never leaking sensitive detail through an error.
- **`testing-strategy`** and **`test-driven-development`**: where security and
  abuse-case tests sit in the portfolio, and how to drive an abuse case
  test-first. This skill says what to test for; those own how to test.
- **`dependency-injection`**: secrets and credentials are supplied at the
  composition root, never hardcoded in the components that use them.
- **Threat modelling**: referenced from Insecure Design (A06) and the mindset.
  Model risk proportionately. A future `threat-modeling` sibling could own STRIDE,
  attack trees, and data flow diagrams in depth; this skill does not run the
  workshop.
- **Tooling**: the `sentrux` MCP and the `/security-review` command detect issues
  after the fact; this skill prevents them while coding. They are complementary.

## Adapt to your context

This skill is a baseline, not dogma. Match the rigour to the risk: a public
payment service warrants ASVS L3 and threat modelling; an internal read-only tool
does not. Your framework, your identity provider, your secret manager, your exact
validation library, and any compliance regime you answer to are yours to layer on
top. Declare them in your own `CLAUDE.md` or a higher-priority skill, which
overrides this baseline. This skill does not impose them.

## Reference

For the secure-by-design principles in full with their Saltzer and Schroeder
origin, the OWASP Top 10:2025 catalogue with cause, prevention, and a TypeScript
note per entry, the Proactive Controls 2024 mapped to the practices, the ASVS
5.0.0 verification levels and how to use them, concrete TypeScript practices
across every cluster, and a worked walkthrough of a single endpoint applying the
controls end to end, read `references/secure-coding.md`.
