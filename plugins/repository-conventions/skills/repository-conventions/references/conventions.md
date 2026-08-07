# Repository conventions reference

The survey behind the skill's baseline. Data gathered in August 2026 by inspecting the standard files of about twenty of
the most-starred GitHub repositories, including
[react](https://github.com/facebook/react),
[vue](https://github.com/vuejs/core),
[vscode](https://github.com/microsoft/vscode),
[kubernetes](https://github.com/kubernetes/kubernetes),
[rust](https://github.com/rust-lang/rust),
[node](https://github.com/nodejs/node),
[next.js](https://github.com/vercel/next.js),
[fastapi](https://github.com/fastapi/fastapi),
[tailwindcss](https://github.com/tailwindlabs/tailwindcss),
[svelte](https://github.com/sveltejs/svelte),
[deno](https://github.com/denoland/deno),
[bun](https://github.com/oven-sh/bun),
[pytorch](https://github.com/pytorch/pytorch),
[django](https://github.com/django/django),
[ansible](https://github.com/ansible/ansible),
[laravel](https://github.com/laravel/laravel),
[ohmyzsh](https://github.com/ohmyzsh/ohmyzsh),
[vite](https://github.com/vitejs/vite),
[express](https://github.com/expressjs/express), and
[ghostty](https://github.com/ghostty-org/ghostty). Counts below
refer to the 15-repository core panel unless stated otherwise. Adoption percentages will drift over time; the structural
conventions move slowly.

Contents:

- [README structure](#readme-structure)
- [README tone registers](#readme-tone-registers)
- [Badges](#badges)
- [License](#license)
- [Contributing guide](#contributing-guide)
- [Community health files](#community-health-files)
- [Issue and pull request templates](#issue-and-pull-request-templates)
- [Changelogs](#changelogs)
- [AI agent instruction files](#ai-agent-instruction-files)
- [Notable outliers](#notable-outliers)

## README structure

Ten of fifteen READMEs are under 700 words (tailwindcss: 104 words). The modal structure, in order:

1. Centered logo in HTML (`<p align="center">`), 9 of 15; plain `# Title`
   otherwise. Dark and light logo variants via `<picture>` and
   `prefers-color-scheme` in the recently redesigned ones (rust, svelte, tailwindcss, next.js, pytorch).
2. Badges (see below).
3. One-sentence description. Example: "React is a JavaScript library for building user interfaces."
4. Feature bullets with a bold lead word (`* **Fast**: ...`), 7 of 15.
5. Installation or getting started, 12 of 15; the rest link straight to the docs (vue's entire section: "Please follow
   the documentation at vuejs.org!").
6. A Documentation section that is a link, not content, 13 of 15.
7. Community or support links, 11 of 15.
8. A short Contributing section pointing at CONTRIBUTING.md, often with a good-first-issue link, 13 of 15.
9. License as the last or second-to-last section, 11 of 15, one line.

Long READMEs only appear when the file plays another role: docs homepage (fastapi, reused by its docs generator),
build-from-source guide (pytorch, ohmyzsh), or governance registry (node lists its collaborators and release keys). A
table of contents appears only in the long ones. Screenshots appear only for end-user applications (vscode); libraries
show code. A header navigation bar of links separated by `|` or bullets appears in rust and bun.

## README tone registers

Four registers observed, from most to least common:

1. **Factual-descriptive** (about 10 of 15): declarative third-person sentences, zero marketing. Kubernetes, react, rust
   (which describes the repository, not even the product). The default register.
2. **Sober marketing** (tailwindcss, svelte, bun, next.js, laravel):
   crafted taglines ("A utility-first CSS framework for rapidly building custom user interfaces"), valorizing adverbs,
   but no superlatives and no exclamation marks.
3. **Assumed enthusiasm** (fastapi, unique): direct superlatives, emoji bullets, and a testimonial section quoting
   engineers at large companies. Consistent with the README being the docs homepage.
4. **Deliberate humor** (ohmyzsh, unique): self-deprecating jokes sustained through the whole document ("Oh My Zsh will
   not make you a 10x developer... but you may feel like one"). An identity choice for a community project, held
   consistently.

Constants across all registers: second person for instructions, and no unverifiable hyperbole in the mature projects.
The bigger and more institutional the project, the drier the tone.

## Badges

- shields.io in 12 of 15. rust, node, and pytorch carry zero badges:
  badge-free minimalism is a deliberate style among infrastructure projects.
- Package version badge: 8 of 15, the most common.
- CI or build badge: 7 of 15.
- Community chat badge (Discord, Gitter): 6 of 15.
- License badge: 5 of 15.
- Downloads: 3 of 15. Coverage: 1 of 15 (not a top-tier pattern).
- Typical count is two to five. Placement: inline next to the `# Title`, or a centered block under the logo.

## License

Distribution across the panel: MIT 10 of 15, BSD-3-Clause 2 (pytorch, django), Apache-2.0 1 (kubernetes), dual MIT OR
Apache-2.0 1 (rust, the Rust-ecosystem convention, as two files `LICENSE-MIT` and
`LICENSE-APACHE`), GPL-3.0 1 (ansible, in a GNU-style `COPYING` file).

Naming: bare `LICENSE` 8 of 15, `LICENSE.md` 4, `LICENSE.txt` 1, the dual-file pair 1, `COPYING` 1.

The SPDX trap: node, bun, and pytorch append third-party or bundled dependency notices to the license file, and GitHub's
license detection fails on all three (NOASSERTION). Keep the license file pristine and put notices elsewhere.

## Contributing guide

All fifteen have a discoverable contributing document. Location: root 10 of 15, `.github/` 4, docs site only 1
(fastapi). Uppercase
`CONTRIBUTING.md` in 12; three use lowercase; django uses `.rst`.

Bimodal length:

- Pointer or index files of 5 to 60 lines (react at 5 lines, kubernetes, django, rust, next.js): large ecosystems
  externalize the real guide into a community repository, a docs site, or a `contributing/`
  directory.
- Self-contained guides of 100 to 1,400 lines (median around 170), which systems-level projects dominate because build
  instructions dominate (bun, deno, pytorch at 1,418 lines).

Common sections in-file: pull request process (11), development setup (8), bug-reporting guidance (6), code of conduct
pointer (4), commit conventions (2), style guide (3).

Legal gatekeeping splits by governance: CLA for corporate or foundation stewardship (react/Meta, vscode/Microsoft,
kubernetes/CNCF, pytorch via bot), DCO for Linux-lineage projects (node, ansible, both inlining the full DCO 1.1 text),
nothing for the nine independent or startup-backed projects. One outlier: next.js requires cryptographically signed
(Verified) commits and states that a DCO sign-off is not sufficient. Emerging in 2025-2026: explicit AI-contribution
policy sections (rust
"LLM policy", pytorch "AI-Assisted Development").

## Community health files

Adoption on the panel, counting org-level `.github` repository defaults where noted:

| File               | Adoption | Notes                                    |
|--------------------|----------|------------------------------------------|
| SECURITY.md        | 14 of 15 | 10 in-repo, 4 via the org `.github` repo |
| Issue templates    | 14 of 15 | All with a `config.yml`                  |
| CODE_OF_CONDUCT.md | 12 of 15 | 7 of 11 in-repo files are short stubs    |
| PR template        | 12 of 15 | Always under `.github/`, 0 of 15 at root |
| CODEOWNERS         | 6 of 15  | 5 in `.github/`, 1 at root               |
| Root CHANGELOG.md  | 5 of 15  | See changelogs below                     |
| FUNDING.yml        | 5 of 15  | Donation-funded projects only            |
| CITATION.cff       | 2 of 15  | Academic-audience projects               |
| GOVERNANCE.md      | 1 of 15  | Foundation-governed projects only        |

Codes of conduct are mostly Contributor Covenant (versions 1.4 to 2.1)
or the Rust code of conduct, and the dominant in-repo pattern is a two-to-five-line stub delegating to the canonical
text elsewhere; the file exists mainly so the platform detects it.

Security reporting mechanisms split by generation: the younger projects adopt GitHub private vulnerability reporting;
the older or larger ones use a security email, HackerOne, or an external process page. A supported-versions table
appears in only 3 of 15 despite being in GitHub's template.

FUNDING.yml correlates cleanly with funding model: present for donation-funded projects (vue, svelte, tailwindcss, rust,
django), absent for corporate-backed and VC-backed ones.

Microsoft, Meta, Vercel, rust-lang, and sveltejs all rely on an org-level `.github` repository for defaults, so auditing
a single repository undercounts its community health.

## Issue and pull request templates

- YAML issue forms are the majority: 9 of 14 template-bearing repositories use a `.yml` form as the primary bug
  template.
- `config.yml` is universal among them (14 of 14) and routes support traffic to Discussions, Discord, Stack Overflow, or
  a forum;
  `blank_issues_enabled: false` in 9 of 14.
- Numeric filename prefixes (`1-bug-report.yml`, `2-feature.yml`)
  control chooser order (node, next.js, bun).
- fastapi has no public bug template at all: everything funnels through Discussions, plus a maintainer-only privileged
  template.

## Changelogs

A root `CHANGELOG.md` is a minority pattern (5 of 15). Alternatives observed: GitHub Releases or a blog (vscode,
next.js, bun), release notes in the docs (fastapi, django), a per-package changelog in a monorepo driven by changesets
(svelte), a `RELEASES.md` (rust), or machine-generated changelog data (ansible). Pick one channel and point to it rather
than half-maintaining two.

## AI agent instruction files

On a 20-repository panel (August 2026): 12 of 20 carry at least one instruction file. AGENTS.md 9, CLAUDE.md 6,
`.github/`
copilot-instructions.md 4, `.cursorrules`, `llms.txt`, and GEMINI.md 0.

The structural convention: one canonical document, the other names symlink to it. next.js and ghostty symlink CLAUDE.md
to AGENTS.md; bun and pytorch symlink AGENTS.md to CLAUDE.md; vscode points AGENTS.md at its copilot instructions. No
surveyed project maintains divergent content per tool. AGENTS.md is the cross-tool standard name (an open standard since
2025, stewarded under the Linux Foundation, read by most coding agents).

Sizes cluster in two bands: minimal pointers (roughly 300 bytes to 1.5 KB) and comprehensive guides (8 to 25 KB, roughly
100 to 500 lines).

Recurring content, by frequency:

1. Build and test commands with agent-specific traps ("never use `bun
   test` directly, use `bun bd test`"; "do not run entire test suites").
2. A monorepo or directory map.
3. Do-not lists around generated files (never hand-edit `zz_generated.*`
   files, edit the template not the output).
4. Commit and PR conventions, including explicit bans on AI attribution trailers (next.js, kubernetes).
5. Anti-flaky-test rules (poll instead of sleep, bind port 0).
6. AI governance policies (pytorch opens with a mandatory AI policy; ghostty forbids agents from creating issues and
   PRs).
7. Progressive disclosure: the file acts as a router to skills and deeper documents rather than a monolith (next.js
   references its skills directory, bun defers to dedicated docs).
8. Occasionally, tone instructions for the agent (kubernetes: "Dry, concise, low-key humor. No flattery. Skip
   preambles.").

## Notable outliers

Reminders that the baseline is a default, not a law:

- **ohmyzsh**: humor-first README sustained end to end, a merchandise section, and an anti-contribution section ("Do Not
  Send Us Themes").
- **fastapi**: README doubles as the docs homepage, with testimonials and tiered sponsor galleries; its SECURITY.md
  includes a prompt-injection honeypot for AI-generated reports.
- **node**: README as governance registry (collaborator rosters, GPG release keys); the license file compiles all
  bundled dependency licenses (2,900 lines).
- **kubernetes**: no CODEOWNERS; it runs its own `OWNERS` review system, and its README splits audiences ("To start
  using K8s" versus "To start developing K8s").
- **rust**: dual-license file pair, trademark section in the README, and near-zero badges.
- **vue and fastapi**: sponsors placed near the top of the README, prime real estate, a signature of donation-funded
  projects.

Each of these is a deliberate maintainer choice that works for its project. When a repository has such a voice, match
it.
