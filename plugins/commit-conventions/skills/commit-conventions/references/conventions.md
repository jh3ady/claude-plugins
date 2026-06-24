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
