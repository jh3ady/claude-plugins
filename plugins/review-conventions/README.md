# review-conventions

A Claude Code plugin that applies the
[Conventional Comments](https://conventionalcomments.org/) standard to code
review comments on pull and merge requests: labelled, decorated, actionable
comments.

It stays generic on purpose: compose it with your own team or personal
review rules.

## What it does

When you review or comment on a pull or merge request, the bundled skill
applies the format `<label> [decorations]: <subject>`, with:

- Labels: `praise`, `nitpick`, `suggestion`, `issue`, `question`,
  `thought`, `chore`, `note`.
- Decorations: `(blocking)`, `(non-blocking)`, `(if-minor)`.

## Install

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install review-conventions@jh3ady-claude-plugins
```

For commit messages, see the companion `commit-conventions` plugin.

## Adapt to your context

This plugin is the baseline standard, not an opinionated ruleset. Layer
your team's required labels, approval rules, or tone guidelines in your own
`CLAUDE.md` or a higher-priority skill. The plugin does not impose them.

## License

Released under the [MIT License](LICENSE).
