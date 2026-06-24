# claude-plugins

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A curated marketplace of open-source [Claude Code](https://www.anthropic.com/claude-code)
plugins.

## Installation

Add the marketplace, then install a plugin:

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install <plugin>@jh3ady-claude-plugins
```

You can also declare the marketplace in your `settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "jh3ady-claude-plugins": {
      "source": { "source": "github", "repo": "jh3ady/claude-plugins" }
    }
  }
}
```

## Plugins

| Plugin | Description |
| ------ | ----------- |
| [`commit-conventions`](plugins/commit-conventions) | gitmoji + Conventional Commits for commit messages: subject-based scopes, the 50/72 rule, lower-case-verb casing. |
| [`review-conventions`](plugins/review-conventions) | Conventional Comments for pull and merge request reviews: labelled, decorated, actionable comments. |

## Contributing

Issues and suggestions are welcome. Open an issue to report a problem or
propose a plugin.

## License

Released under the [MIT License](LICENSE). Individual plugins may carry
their own license; see each plugin's directory.
