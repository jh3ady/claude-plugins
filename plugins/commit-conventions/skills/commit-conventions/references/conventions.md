# Commit conventions reference

The detailed reference behind the skill: Conventional Commits types, the
gitmoji-to-type pairing, and worked examples. Standards:
[Gitmoji](https://gitmoji.dev/) and
[Conventional Commits](https://www.conventionalcommits.org/).

## The key rule: gitmoji and type are chosen separately

The gitmoji expresses the intent (visual). The Conventional Commits type
expresses the semantic category. Do not infer the type from the emoji's
vibe. For example initializing a repository uses the party emoji (begin a
project) but its type is `chore`, not `feat`, because setting up a project
is not a user-facing feature.

## Conventional Commits types

| Type       | Meaning                                           |
|------------|---------------------------------------------------|
| `feat`     | A user-facing capability (triggers a minor bump). |
| `fix`      | A bug fix (triggers a patch bump).                |
| `docs`     | Documentation only.                               |
| `style`    | Formatting, no behavior change.                   |
| `refactor` | Code change that is neither a fix nor a feature.  |
| `perf`     | Performance improvement.                          |
| `test`     | Adding or fixing tests.                           |
| `build`    | Build system or dependencies.                     |
| `ci`       | Continuous integration configuration.             |
| `chore`    | Setup, tooling, maintenance, housekeeping.        |
| `revert`   | Reverts a previous commit.                        |

## Gitmoji pairing (common cases)

| Intent                  | Gitmoji | Typical type         |
|-------------------------|---------|----------------------|
| Begin a project         | 🎉      | `chore`              |
| New feature             | ✨       | `feat`               |
| Bug fix                 | 🐛      | `fix`                |
| Documentation           | 📝      | `docs`               |
| Internationalization    | 🌐      | `docs`               |
| Refactor code           | ♻️      | `refactor`           |
| Tests                   | ✅       | `test`               |
| Tooling / configuration | 🔧      | `chore`              |
| Performance             | ⚡️      | `perf`               |
| Remove code or files    | 🔥      | `refactor` / `chore` |
| Dependencies            | ➕ / ➖   | `build`              |

## Examples

```
🎉 chore: initialize the project
✨ feat(auth): add refresh token rotation
🐛 fix(api): handle null responses in the webhook handler
📝 docs(readme): add the environment variables section
♻️ refactor(parser): simplify the request handler
✅ test(payments): cover the declined-card edge case
```

## Internal working artifacts

The history outlives the working documents that produced it. A plan gets
archived, a milestone is renamed, a task board is migrated, and every
message that pointed at them stops meaning anything. Write the objective,
not the pointer.

| Instead of | Write |
|------------|-------|
| `✨ feat: implement task 9 of phase 1` | `✨ feat(executors): add embedded cross-platform shell` |
| `📝 docs: apply the M0 plan` | `📝 docs(community): add the contribution guide` |
| `♻️ refactor(api): step 3 of the migration` | `♻️ refactor(api): move pagination to cursor tokens` |
| `👷 ci: set up CI per the design document` | `👷 ci: run formatting, linting, and tests on every change` |

The rule covers commit subjects and bodies, pull request and merge request
titles and descriptions, issue titles, and changelog entries.

Two exceptions. A reference between internal documents is fine, because
both sides travel together. And a footer pointing at an issue or a pull
request (`Refs: #123`, `Closes #123`) is fine, because a reader of the
repository can open it.
