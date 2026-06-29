# screaming-architecture

A Claude Code plugin that helps apply Screaming Architecture pragmatically:
organise the top-level structure of a codebase so it announces the business
domain and its use cases rather than the framework, without fragmenting small
projects into noise.

Screaming Architecture is a heuristic about what a structure communicates, not a
dependency rule and not a layering system. It asks one question of any project:
when you look at the top-level directories, do they scream what the system does
(Health Care System, Reservations, Payments) or merely which framework built it
(Rails, Spring, ASP)? This plugin keeps that framing front and centre and pairs
it with the patterns that govern dependency direction.

It stays generic on purpose: compose it with your own architecture rules and
your team or personal conventions.

## What it does

When you decide how to lay out folders, modules, or packages, review whether a
project's structure reveals its domain, choose between organising by technical
layer and organising by feature, or name modules and bounded contexts, the
bundled skill applies:

- Robert C. Martin's thesis (2011): the top-level structure should scream the
  use cases of the system, because "software architectures are structures that
  support the use cases of the system".
- The building-blueprint analogy: the plans of a library scream "Library"; the
  plans of a software system should scream its use cases the same way.
- Frameworks, the web, and the database as details: "Frameworks are tools to be
  used, not architectures to be conformed to"; the delivery and persistence
  mechanisms belong at the edges, not the front door.
- The testability corollary: a domain-first structure is one whose use cases can
  be unit-tested without the web server, the database, or the framework running.
- Package by feature over package by layer, package by component, and vertical
  slice architecture, with concrete folder-tree examples for back-end and
  front-end stacks.
- Pragmatic guardrails against over-fragmenting small CRUD projects, against
  treating it as a dependency rule, and against renaming folders without
  reorganising.

## Relationship to other plugins

- `hexagonal-architecture`: the complementary half. Screaming Architecture says
  what the structure should communicate; hexagonal (and clean and onion) say
  which way dependencies point. Scream the domain at the top, apply the
  dependency rule within each feature.
- `modular-monolith`: the screaming top level is the module boundary. This
  plugin supplies the naming and grouping discipline; the modular monolith
  supplies the public-API and isolation discipline.
- `domain-driven-design`: a screaming structure is the ubiquitous language made
  visible. Top-level modules map to bounded contexts and subdomains; use-case
  folders map to commands, queries, and aggregates.
- `cqrs`: in a vertical-slice layout each slice is naturally one command or one
  query handler.
- `simplicity-principles`: the rule of three guards against carving a project
  into single-file feature folders before the domain justifies it.

## Install

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install screaming-architecture@jh3ady-claude-plugins
```

## Adapt to your context

This plugin is a baseline, not a dogma. Layer your own granularity (capabilities,
features, or individual use cases), whether each feature carries full layers,
where shared code lives, and your naming conventions in your own `CLAUDE.md` or a
higher-priority skill. The plugin does not impose a folder layout; it gives you
the test to judge one.

## License

Released under the [MIT License](LICENSE).
