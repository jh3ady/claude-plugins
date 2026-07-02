# secure-coding

A Claude Code plugin that carries the developer-facing discipline of writing
secure application code: the secure-by-design mindset, the proactive controls
you apply while coding, and the catalogue of the most critical risks to
recognise and prevent. It builds security in from the start rather than testing
for it at the end.

It stays knowledge rather than tooling: compose it with your own framework,
identity provider, secret manager, and conventions. It complements, but does not
replace, a scanner (such as the `sentrux` MCP) or a diff auditor (such as the
`/security-review` command). Those detect; this prevents.

## What it does

When you write, review, or refactor code that handles untrusted input,
authentication, authorization, sessions, secrets, cryptography, database
queries, file uploads, or outbound requests, when you shape error paths, when
you add or update dependencies, or when you recognise and prevent an OWASP Top
10 risk, the bundled skill applies:

- The secure-by-design mindset: least privilege, fail-safe defaults (fail
  closed), defence in depth, complete mediation, economy of mechanism, secure
  defaults, never trust input, minimise the attack surface, and do not roll your
  own crypto, distilled from Saltzer and Schroeder (1975).
- The OWASP Proactive Controls 2024 (C1 to C10) as the what-to-do-while-coding
  checklist, from access control to stopping server side request forgery.
- The OWASP Top 10:2025 (A01 to A10) as the risk catalogue to recognise, each
  linked to the control that prevents it, including the two new 2025 categories
  (Software Supply Chain Failures and Mishandling of Exceptional Conditions).
- ASVS 5.0.0 as the verification standard: pick a level by risk (L1, L2, L3) and
  use it as a per-feature checklist.
- Concrete practices across access control, authentication and identity, input
  handling and injection, cryptography and secrets, configuration, dependencies
  and the supply chain, exceptional conditions, logging, and SSRF, with
  TypeScript examples and a worked end-to-end walkthrough.

The plugin is architecture-agnostic: it does not require hexagonal, DDD, or any
particular layering, though it composes with them.

## Relationship to other plugins

- `hexagonal-architecture`: the ports and adapters are the trust boundaries
  where input validation, authentication, and authorization belong. That plugin
  owns the boundary structure; this one places the controls on it.
- `clean-code`: owns disciplined error handling in general; this plugin owns its
  security dimension (mishandling of exceptional conditions, not leaking detail).
- `testing-strategy` and `test-driven-development`: where security and abuse-case
  tests sit in the portfolio and how to drive them; this plugin says what to test
  for.
- `dependency-injection`: secrets are supplied at the composition root, never
  hardcoded in the components that use them.
- A future `threat-modeling` plugin could own design-time STRIDE, attack trees,
  and data flow diagrams in depth, referenced here from Insecure Design (A06).

## Install

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install secure-coding@jh3ady-claude-plugins
```

## Adapt to your context

This plugin is a baseline, not a dogma. Match the rigour to the risk: a public
payment service warrants ASVS L3 and threat modelling; an internal read-only
tool does not. Layer your framework, identity provider, secret manager, exact
validation library, and any compliance regime you answer to in your own
`CLAUDE.md` or a higher-priority skill, which overrides this baseline. The plugin
does not impose them.

## License

Released under the [MIT License](LICENSE).
