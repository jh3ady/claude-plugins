# commit-conventions

A Claude Code plugin that applies the gitmoji + Conventional Commits
standard to commit messages: subject-based scopes, the Git 50/72 length
rule, and lower-case-verb casing.

It stays generic on purpose: compose it with your own project scope
vocabulary and your team or personal rules.

## What it does

When you write or amend a commit, or prepare or split a commit, the bundled
skill applies:

- The commit format `<gitmoji> <type>(<optional scope>): <summary>`.
- The Conventional Commits type list and the gitmoji-to-type pairing.
- Subject-based scoping (derive scopes from your project's own areas).
- The Git 50/72 length rule and lower-case-verb casing (proper nouns and
  acronyms keep their natural case).

## Install

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install commit-conventions@jh3ady-claude-plugins
```

For review comments on pull and merge requests, see the companion
`review-conventions` plugin.

## Adapt to your context

This plugin is the baseline standard, not an opinionated ruleset. Define
your project's scope vocabulary, and layer your own team or personal rules
(attribution policy, author identity, required footers) in your own
`CLAUDE.md` or a higher-priority skill. The plugin does not impose them.

## License

Released under the [MIT License](LICENSE).
