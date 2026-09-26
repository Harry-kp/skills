---
name: harry-kp-benchmark-repo-presentation
description: Compare the presentation, marketing, documentation, and community layer of the user's own open-source project against a mature reference project, and produce a short, prioritized list of things worth borrowing — filtered hard by maintenance cost for a small or solo team. Use this whenever the user says things like "compare my repo to X", "what can I learn from project Y", "how does Z present itself vs mine", "benchmark my README/docs against", "what am I missing that they have", or names a project they admire and wants their own to feel as polished. Trigger even when the user only vaguely says "see what we can do" — this skill is about presentation and packaging, NOT feature or behaviour comparison. Do not use for comparing product features or code architecture.
---

# Benchmark repo presentation

The user has a project they own and a mature project they admire. They want to learn from how the reference *presents itself* — README, docs, install story, community intake, release hygiene, discoverability — without copying its identity and without taking on work that won't move the needle for their users.

The output is a short, ranked borrow list. Every item must survive an impact-vs-maintenance filter. The default answer for most things a big project does is "don't borrow it," and the skill should say so explicitly, because the user needs to hear what to *skip* as much as what to add.

## Step 1 — Establish what you're comparing

Confirm three things before cloning anything:

1. **Which repo is the user's** (and that it is theirs — the recommendations are about their brand, so tone matters).
2. **Which repo is the reference.** If the user names it loosely ("the netbird github"), resolve it to an exact `owner/name`.
3. **Team size / maintenance appetite.** If the user hasn't said, assume small or solo and say you're assuming it. This assumption drives the whole filter.

If you have memory or earlier context about the user's project, use it first — you'll often already know what it is, what it does, and what they've already tried.

## Step 2 — Inventory both repos

Run the bundled script (path is relative to this skill's directory); it clones both repos shallowly and dumps the surfaces that matter:

```bash
bash scripts/inventory.sh <user-owner/repo> <reference-owner/repo> [outdir]
```

It writes `<outdir>/<owner>__<name>/` (default outdir: a temp dir, so the user's working tree stays clean) for each with README, community files, `.github/` contents, docs tree, badge list, and a one-page `summary.txt`. Read both summaries, then read both READMEs in full — the README is the surface where most of the leverage lives.

If `gh` is installed, the summary also includes the GitHub description, topics, homepage, Discussions on/off, and latest release notes. If it isn't, check those yourself (repo page or API), and read the release notes body either way. Don't skip this — description and topics are the cheapest discoverability win and are often empty.

## Step 3 — Compare surface by surface

Walk `references/surface-checklist.md` — it lists every presentation surface and, for each one, what "mature" looks like and the common traps. For each surface, note one of:

- **Reference does it, user doesn't** → candidate to borrow (goes through the filter in Step 4).
- **User already does it as well or better** → say so. People undervalue what they already have; naming it is useful and prevents churn.
- **Reference does it, but it only makes sense at their scale** → explicit skip, with the reason.
- **User does something the reference doesn't** → worth pointing out; it's a differentiator, not a gap.

Be honest when the user's surface is already stronger. A young, well-run solo project often has a *tighter* README than a VC-backed one that has accreted hiring banners and product tiers. Don't invent gaps to fill a list.

## Step 4 — Apply the maintenance filter

This is the step the user cares most about. For each candidate, ask:

- **Who benefits?** A user trying to install/use/debug, a contributor, or a maintainer? Rank user-facing highest. Contributor-facing only matters if contributors actually show up.
- **One-time or recurring?** A YAML issue template is one-time. A docs website, translations, a changelog written by hand, a Slack/Discord, a video, a hand-curated comparison table — all recurring. Recurring cost needs a much higher bar.
- **Does it rot?** Anything that must be updated on every release (screenshots of a specific version, feature counts, hand-maintained roadmaps, badge walls) will go stale and then look worse than nothing.
- **Does it need a second person?** CLA flows, DevRel triage, "validated issue" gates, code-review bots — these assume a team. Skip for a solo maintainer.
- **Does it save the maintainer time?** Some borrows are net-negative on paper but net-positive in practice because they *reduce* inbound noise: a good issue-template `config.yml` that routes questions to docs, a "read before opening a PR" section, a required diagnostics field in the bug form. These are the best kind of borrow for a solo dev.

Drop anything that fails. Keep the list short — five to eight items is typical; more than ten means the filter wasn't applied.

## Step 5 — Write the answer

Use this structure, in chat (not a file, unless the user asks):

```
## What you already do as well or better
(2–5 bullets; honest, specific, no flattery)

## Worth borrowing
For each item (ranked, highest impact first):
  **Name** — what the reference does, in one line.
  Why it matters for *your* users. One-time vs recurring cost. Concrete first step.

## Deliberately skip
(the tempting things and one-line reasons — scale, needs a team, rots, no user impact)

## If you do only one thing
(the single highest-leverage item)
```

Keep it conversational and concrete. Point at exact files (`.github/ISSUE_TEMPLATE/config.yml`, a specific README section). Where a borrow is a small edit, show the edit or the exact lines rather than describing it. Never suggest renaming, restyling, or repositioning the user's brand to resemble the reference — the goal is to make *their* thing clearer, not to make it look like the other thing.

## Things that are almost always worth borrowing (cheap, user-facing, one-time)

- Repo description and topics filled in.
- Feature/highlights table where each cell links to the doc that explains it.
- Issue-template `config.yml` with contact links to troubleshooting docs, security policy, and discussions — routes noise away from the issue tracker.
- Bug form as a YAML issue form with required environment/diagnostics fields (especially if the project has a `report`/`doctor` command).
- A "before you open a large PR, open an issue" line plus a short "PRs I will close" list in CONTRIBUTING.
- Trademark/attribution line for upstream projects the name leans on (e.g. WireGuard®).
- A "main may be unstable, use releases" note if `main` is actually unstable.

## Things that are almost never worth borrowing for a small team

- A separate docs website when a `docs/` folder is working.
- Chat communities (Slack/Discord) — they demand presence.
- CLA, DCO bots, review bots, triage gates, DevRel workflows.
- Hand-written changelogs when release automation already exists.
- Translations, hiring banners, sponsor logos, pricing links.
- Screenshot/video assets that pin to a version and must be regenerated.
- Multi-column feature matrices with dozens of cells — they rot and read as marketing.
