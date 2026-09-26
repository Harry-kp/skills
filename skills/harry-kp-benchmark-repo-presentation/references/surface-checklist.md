# Presentation surfaces checklist

Walk these top to bottom for both repos. For each, decide: borrow / already fine / skip-at-this-scale / user's differentiator. The "mature" column describes what a well-run project does; the "trap" column is what to warn about.

| # | Surface | What mature looks like | Trap |
|---|---|---|---|
| 1 | **Repo description + topics** | One sentence, states the category and the differentiator. 5–10 topics matching how people search (language, framework, domain). | Empty. Or description restates the name. |
| 2 | **README: first screen** | Name, one-line pitch, badges that mean something (CI, package version, license), one demo asset, then install. A reader knows in 10 seconds what it is and whether it's for them. | Logo + 12 badges + hiring banner before the reader learns what the thing does. |
| 3 | **README: why / positioning** | 3–5 lines on who it's for and what it replaces or sits beside. Names the alternative honestly. | Adjective soup ("blazing fast, modern, powerful"). |
| 4 | **README: install** | One table or block per channel; prerequisite tools stated *before* the install command; the "hello world" command right after. | Install buried under features. Prereqs missing so the first run fails. |
| 5 | **README: features/highlights** | Compact table; each row links to the doc page for that feature. | Unlinked bullet list or a huge multi-column checkmark grid that goes stale. |
| 6 | **README: docs index** | A small table pointing at each user guide with a one-line "covers" summary. Separate rows for user vs contributor docs. | Docs exist but README doesn't link them, so nobody finds them. |
| 7 | **README: social proof** | Short "featured in" line, star-history chart only if the curve is flattering. | Testimonials nobody asked for; logos of companies "using" it. |
| 8 | **README: tail** | License, trademark/attribution for upstream projects, security policy link, acknowledgements. | Missing trademark line for a project whose name/pitch leans on someone else's mark. |
| 9 | **docs/ folder** | Usage, configuration, troubleshooting, migration/upgrade — each a single file with a heading structure a user can scan. Troubleshooting organized by symptom. | Docs organized by internal architecture instead of by what the user is trying to do. |
| 10 | **Issue templates** | `config.yml` disables blank issues and offers contact links (troubleshooting guide, security policy, discussions, feature ideas). Bug form is a YAML form with required OS/version/diagnostics fields. | Markdown templates users delete; no routing, so questions land as bugs. |
| 11 | **Discussion templates** | Only if Discussions are enabled and active. A Q&A form with a "before posting" checklist. | Building a triage bureaucracy for a project with 3 discussions a month. |
| 12 | **CONTRIBUTING** | Quick start build, "what CI runs" command, commit convention, and — importantly — a line on when to open an issue *before* a PR and what kinds of PRs get closed. | Long, aspirational, and silent on the one thing that saves maintainer time: scope agreement before code. |
| 13 | **PR template** | Short checklist; "docs updated / not needed because …" as a required either-or. | Ten checkboxes nobody reads. |
| 14 | **SECURITY.md** | Where to report privately, what's in scope, response expectations. | Missing, or a link to a generic policy. |
| 15 | **Release notes** | Consistent format, generated where possible, user-facing language (what changed for me), upgrade notes linked. | Raw commit dumps, or hand-written notes that lag the actual tag. |
| 16 | **Demo assets** | One GIF/video showing the core loop, small, referenced by raw URL so it works on package registries too. | Version-specific screenshots that drift; a video that needs re-recording every release. |
| 17 | **Package registry pages** | The README renders correctly on crates.io / npm / PyPI (relative image links break there; use absolute). Description and keywords set in the manifest. | Broken images on the registry, empty keywords. |
| 18 | **Community channels** | For a solo project: GitHub Discussions and nothing else. For a team: forum or chat, clearly linked. | Opening a Discord that's empty in a month. |
| 19 | **Roadmap** | Either a live project board or a short ROADMAP.md that's actually updated. | A ROADMAP.md that lists last year's plans. |
| 20 | **Governance / legal** | License is clear and consistent across the repo. CLA only if there's a commercial entity. | Copying a CLA or dual-license structure from a company when there's no company. |

## Reading the reference honestly

Mature reference projects often carry things that are *artifacts of their business* rather than good practice: hiring links, cloud-tier pricing, sponsor programs, DevRel triage flows, translation pipelines, multiple CI matrices. When you see one, ask "would a user of the smaller project ever encounter this?" If not, it's a skip — and worth naming as a skip so the user doesn't feel they're behind.

## Reading the user's project honestly

Look for the things the user does that the reference doesn't. Common ones for well-run small projects: a diagnostics command, a CI-parity script, a manual release gate doc, honest platform-support statements, a security-model section in the README. These are differentiators and should be named in the "already better" section.
