# Markdown conventions: detail and examples

This reference expands the default profile in `SKILL.md`. It applies only where
the project's own configuration is silent; the project's configuration always
wins.

## Grounding

- CommonMark is the parsing baseline: prefer constructs that render
  unambiguously under CommonMark.
- The markdownlint rule set (rules `MD001` to `MD059`) is the recognised style
  vocabulary. The mapping below names the relevant rules so a project using
  markdownlint sees the same intent.
- Prettier's markdown defaults are the reflow reference for spacing, list
  markers, and emphasis.

## Rule-by-rule, with markdownlint mapping

### Headings

- ATX style, `#` followed by a single space (`MD018`, `MD019`, `MD023`).
- One blank line before and after a heading (`MD022`).
- A single top-level heading per document, and no skipped levels (`MD025`,
  `MD001`).
- No trailing punctuation such as a colon in a heading (`MD026`).

Before:
```
##Title
Text immediately after.
```
After:
```
## Title

Text immediately after.
```

### Lists

- One consistent unordered marker per document, `-` by default (`MD004`).
- Ordered lists numbered `1.`, `2.`, `3.` (`MD029`).
- Nested items indented by two spaces (`MD007`).
- One space after the marker (`MD030`).

Before:
```
* First
+ Second
    - Nested
```
After:
```
- First
- Second
  - Nested
```

### Code

- Fenced code blocks with a language tag, not indented blocks (`MD046`,
  `MD040`).
- A blank line before and after a fenced block (`MD031`).

Before:
```
    const x = 1
```
After:
````
```ts
const x = 1
```
````

### Emphasis and whitespace

- Consistent emphasis markers (`MD049`, `MD050`).
- No trailing spaces, except a deliberate two-space hard break (`MD009`).
- No hard tabs for indentation (`MD010`).
- A single final newline (`MD047`).

### Line wrapping

- Do not hard-wrap prose by default (leave `MD013` line length off unless the
  project enables it). If the project sets a print width or line-length rule,
  follow it exactly.

### Tables

- Pipe tables with a header separator row. Column alignment is optional; keep it
  consistent within a table.

Before:
```
Name|Role
Ada|Engineer
```
After:
```
| Name | Role     |
| ---- | -------- |
| Ada  | Engineer |
```

### Links

- Prefer inline links. Use reference-style links when the same target is
  repeated, to keep the prose readable.

## Relationship to sibling plugins

- Commit message bodies are markdown-adjacent but owned by `commit-conventions`.
- Pull and merge request review comments are owned by `review-conventions`.

This skill does not restate those; it formats the markdown, they own the
wording.
