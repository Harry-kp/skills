---
name: harry-kp-distill-session-learnings
description: At the end of (or during) a working session, extract only the durable, non-obvious learnings and write them into the right agent-instruction file — CLAUDE.md / AGENTS.md for project-wide facts, an existing or new skill for reusable workflows — while leaving everything else out. Use this whenever the user says things like "update CLAUDE.md with what we learned", "add this to the skill", "remember this for next time", "improve the agent instructions", "make sure future sessions know this", "don't make that mistake again", or at the natural end of a session where the agent was corrected, hit environment quirks, or discovered project conventions. Also use it proactively when a session contained two or more user corrections about the same kind of thing. Not for writing general documentation or READMEs for humans.
---

# Distill session learnings

Instruction files are read at the start of every future session. Every line in them costs attention forever, so the bar for adding one is high: **a future session must be measurably better off for having read it.** Most of what happens in a session does not clear that bar. This skill is mostly a filter.

## Step 1 — Harvest candidates from the session

Scan the conversation for these signals. Each is a *candidate*, not yet a learning:

- **User corrections.** "No, do X instead", "we don't use Y", "that's the wrong file". Especially anything corrected twice.
- **Failed attempts that were fixed.** A tool that errored, a path that didn't exist, a command that needed a flag, a rate limit hit, an approach abandoned for a better one.
- **Discovered facts about the environment or project.** Where things live, what's writable, which commands actually run, which service is reachable and which isn't.
- **Stated conventions and preferences.** Commit style, naming, tone, formatting, "always ask before X", "never do Y".
- **Decisions with reasons.** "We chose A over B because C" — the reason is the durable part.
- **Workflow that worked.** A sequence of steps that produced the result the user wanted and would be repeated.

Ignore: task narration, things that only mattered for this one deliverable, restated content of files that already exist in the repo, and anything the agent already knew without being told.

## Step 2 — Apply the filter

Keep a candidate only if **all** of these are true:

1. **Recurring.** A future session doing similar work would plausibly hit it again. One-off task details fail here.
2. **Non-obvious.** The agent would not derive it from the code, README, or common sense in under a minute. "Run tests before pushing" fails; "tests need `--break-system-packages` in this sandbox" passes.
3. **Costly to rediscover.** It wasted time, produced a wrong result, or annoyed the user. If rediscovering it takes ten seconds, don't record it.
4. **Still true.** Not contingent on today's task, a temporary outage, or a file that's about to change.
5. **Not already recorded.** Read the existing instruction files first. If it's there, don't duplicate; if it's there but wrong or stale, fix that line instead.

If you're unsure, leave it out. A missing line costs one rediscovery; a wrong or noisy line costs every session.

Typical yield from a long session is 2–6 lines, not 20. If you have more than ten, the filter wasn't applied.

## Step 3 — Route each learning to the right home

| Learning is about… | Goes in… | Why |
|---|---|---|
| The project as a whole: layout, commands, conventions, gotchas, "never touch X" | `CLAUDE.md` / `AGENTS.md` at repo root (or the nearest one for a subdirectory). If one just imports the other (e.g. `CLAUDE.md` containing `@AGENTS.md`), edit the file with the content | Always loaded; short, factual, project-scoped |
| How to do one *kind of task* well (a workflow, a checklist, a template) | The skill for that task — edit it if it exists, create one if the task will recur | Loaded only when relevant, can be long |
| Long detail a skill needs only sometimes (tables, schemas, per-tool notes) | `references/*.md` inside that skill, linked from SKILL.md | Progressive disclosure; keeps SKILL.md scannable |
| A quirk of *this* environment/sandbox (paths, network, rate limits) | The skill that uses that tool if one exists; otherwise CLAUDE.md under an "Environment" heading | Only the sessions that hit the tool need it |
| Something the user wants remembered about *them* (tone, formatting, preferences) | Memory / user preferences if available; otherwise CLAUDE.md under "Working with the maintainer" | It's about the person, not the project |
| A one-time fact | Nowhere. Say it in chat and move on. | |

Never put the same fact in two places. If a skill needs a project fact, link to CLAUDE.md or state it once in the skill — don't mirror it.

## Step 4 — Write it well

- **Read the target file in full before editing.** Merge into existing sections; don't append a "Session notes" blob at the bottom. Prune anything the session proved wrong or stale while you're there — instruction files should shrink as often as they grow.
- **One line per learning, imperative mood, with the reason when it isn't obvious.** The reason is what lets a future session decide whether the rule still applies.
  - Bad: `GitHub API notes: sometimes it's rate limited so be careful`
  - Good: `GitHub REST API is rate-limited from this sandbox (unauthenticated). Use \`git clone --depth 1\` and scrape the repo HTML page instead.`
- **State the trigger, not just the fact**, for skill edits: *when* would a future session need this step?
- **Respect budgets.** CLAUDE.md / AGENTS.md should stay under roughly 80–150 lines, shorter is better; SKILL.md under ~500. If an addition would blow the budget, something older should move to a reference file or be cut.
- **Keep the user's voice and existing structure.** Don't restyle a file to add one line.
- **Preserve skill names** when editing an existing skill; never fork it into `-v2`.

## Step 5 — Show the diff, then apply

Before writing, tell the user in a few lines: what you're adding, where, and what you deliberately left out (naming one or two rejected candidates and why helps them calibrate the filter). If the user asked for this, make the edits. If you triggered it proactively, stop and wait for a yes — instruction files are the user's, and unrequested edits to them erode trust. If a file is read-only where it lives, copy it to a writable location, edit, and hand it back (for skills, repackage with the original name).

## Anti-patterns

- Dumping the transcript or a "what we did today" summary into CLAUDE.md.
- Turning a one-off instruction into an "always" rule.
- Restating the README, package manifest, or directory listing.
- Recording the *outcome* of a task ("added config.yml") instead of the *reusable lesson* ("issue-template config.yml is the highest-leverage noise filter for a solo maintainer").
- Adding without pruning. Every edit is a chance to delete a stale line.
- Writing for a human reader. These files are for the next agent session — terse, specific, no encouragement.

## Example

Session: user asked to compare their repo to a reference project; the GitHub API was rate-limited; `web_fetch` refused a URL that hadn't appeared in a search; the user corrected Claude that the skill should be general, not project-specific; Claude produced a six-item borrow list.

Harvested candidates: 7. Survived the filter: 3.

- → skill `harry-kp-benchmark-repo-presentation`, Step 2: "GitHub API is rate-limited unauthenticated from the sandbox; use `git clone --depth 1` + HTML scrape for description/topics."
- → skill `harry-kp-benchmark-repo-presentation`, Step 2: "`web_fetch` only opens URLs seen earlier in the conversation; search first or clone instead."
- → CLAUDE.md, "Working with the maintainer": "When asked for a skill, default to a general, reusable one unless told it's project-specific."

Rejected: the borrow list itself (task outcome), "the user's README is 218 lines" (derivable, will change), "user admires the reference project" (one-off context).
