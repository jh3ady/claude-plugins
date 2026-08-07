# repository-conventions

A Claude Code plugin that applies the majority conventions of popular
repositories to a project's standard files: README structure and tone,
license, contributing guide, community health files, and AI agent
instruction files (AGENTS.md, CLAUDE.md).

It stays generic on purpose: it captures what most popular repositories
converge on, works for private repositories as well as public ones, and
always defers to the maintainers' own style.

## What it does

When you scaffold a repository, write or review a README, a LICENSE, a
CONTRIBUTING guide, community health files, or an agent instruction
file, the bundled skill applies:

- The short, pointer-style README shape and its canonical section order,
  with license as the closing section.
- A pristine `LICENSE` file (no appended notices, so automatic license
  detection keeps working).
- The two legitimate CONTRIBUTING archetypes: self-contained guide or
  pointer file.
- The `.github/` conventions: YAML issue forms with a routing
  `config.yml`, pull request template, SECURITY.md, FUNDING.yml.
- One canonical AI agent instruction file (AGENTS.md or CLAUDE.md) with
  the other names as symlinks, never divergent copies.

The skill ships a reference file with the survey behind the baseline:
adoption rates, file locations, tone registers, and notable outliers
(such as Oh My Zsh's deliberately humorous README) observed across about
twenty of the most-starred GitHub repositories in August 2026.

## Install

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install repository-conventions@jh3ady-claude-plugins
```

For commit messages and review comments, see the companion
`commit-conventions` and `review-conventions` plugins.

## Adapt to your context

This plugin is the baseline standard, not an opinionated ruleset. The
majority pattern is a default, not a law: well-known projects deviate
deliberately (humorous READMEs, marketing-style READMEs, governance
registries), and the final call always belongs to the maintainers and
their style. Declare your own defaults (license choice, badge set, tone,
attribution policy) in your own `CLAUDE.md` or a higher-priority skill.
The plugin does not impose them.

## License

Released under the [MIT License](LICENSE).
