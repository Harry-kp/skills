---
name: harry-kp-qa-like-a-user
description: "Drive a whole application the way a real user would — open it, tap/click/type through every screen, menu, button, form, keyboard shortcut and workflow, including the first-time-user path — then audit every bug, every UX/UI problem (confusing colours or layout, workflows that are too complex, elements that break design principles or aren't needed), and every missing feature, and fix them. Works for any project the agent can run: web apps (via a browser driver like Playwright), TUIs (via tmux), CLIs, desktop apps, mobile apps (emulators), and APIs behind a UI. Use this skill whenever the user asks to \"test the app as a user\", \"test every workflow\", \"drive the UI end to end\", \"QA this\", \"find all bugs\", \"audit what's missing\", \"try everything a user would tap\", \"do a first-time-user walkthrough\", \"smoke test the whole thing\", \"review the UX\", \"is this UI confusing\", or says they'll supply credentials so you can log in and test. Trigger even if they don't say \"test\" — e.g. \"go through the app and tell me what's broken\" or \"pretend you're a new user and try to sign up\". Do NOT use for unit-test writing alone, or for reviewing code without running the product."
---

# User-Perspective QA

You are the user now. Not the developer, not a code reviewer. You open the product, you look at what's on screen, you tap the things a person would tap, and you notice what confuses, breaks, or is missing. Then you fix it.

The failure mode this skill exists to prevent: reading the source, guessing what "should" work, writing a report that says "looks fine". A real user never sees the source. If you didn't actually see the screen and press the button, you didn't test it.

## The loop

```
1. Recon      → what is this thing, how do I run it, how do I drive it
2. Setup      → run it, pick a driver, get creds, snapshot a clean state
3. Explore    → walk every screen as a FIRST-TIME user, then as a returning user
4. Workflows  → run every end-to-end job a user would do, start to finish
5. Break it   → edge cases, bad input, interruptions, resize, offline, back button
6. Audit      → bug, UX/UI, and missing-feature lists, each with repro and severity
7. Fix        → fix in severity order, re-drive the exact repro to confirm
8. Report     → final report using assets/report-template.md
```

Keep a running `qa/findings.md` from step 3 onward — write findings *as you see them*, not from memory at the end. Memory-based reports lose half the bugs.

## Step 1 — Recon (5 minutes, no more)

Read just enough to run it, not enough to bias you:
- `README`, `package.json` / `pyproject.toml` / `Cargo.toml` / `Makefile`, `.env.example`, `docker-compose.yml`
- Route/screen list if obvious (router file, `pages/`, `screens/`, `commands/`) — this is your **coverage checklist**, not your test plan
- Any existing e2e tests — they tell you what the devs *think* works

Classify the product and pick a driver from `references/drivers.md`:

| Product type | Driver |
|---|---|
| Web app / SPA / SSR | Playwright (headless Chromium), screenshots each step |
| TUI (Textual, Bubble Tea, ratatui, ncurses, ink) | `tmux` session + `send-keys` + `capture-pane` |
| CLI | Direct invocation, `expect`/`pexpect` for interactive prompts |
| Desktop (Electron, Tauri) | Playwright (Electron) or the app's dev server in a browser |
| Mobile (RN, Flutter, native) | Emulator + `adb`/`xcrun simctl` + screenshots; fall back to web build if present |
| API-only | Treat the docs/OpenAPI as the "UI"; drive with curl/httpie as a new integrator |

Read only the matching section of `references/drivers.md`.

## Step 2 — Setup

1. **Run it.** Use the documented dev command. If it doesn't start cleanly from a fresh clone, **that's finding #1** (severity: blocker for new devs, note it and move on).
2. **Get credentials.** The user said they'd help — ask *once*, in one message, for everything you foresee needing: test accounts (at least two roles if roles exist), payment sandbox, OAuth test app, seed data, email inbox for verification links. Don't dribble requests over ten turns.
3. **Snapshot clean state** so you can replay the first-time-user path repeatedly: fresh DB / cleared localStorage / new tmux session / fresh emulator. Write down the reset command.
4. **Keep `qa/` out of git**: append `qa/` to `.git/info/exclude` (local-only, doesn't touch `.gitignore`). It will hold screenshots, video, and `qa/auth.json` with live session cookies — never commit those. Only `qa/REPORT.md` is shared, and only if the user wants it in the repo.
5. **Set up evidence capture**: a `qa/screens/` folder, screenshot or `capture-pane` after *every* action, named `NNN-what-i-did.png|txt`. Evidence is what turns "I think the button is broken" into a fixable bug.

## Step 3 — Explore as a first-time user

Reset to clean state. Now pretend you have never seen this product and nobody told you what it does. Go through `references/first-time-user-checklist.md` top to bottom. The key questions at every screen:

- **Do I know where I am?** (title, breadcrumb, active tab)
- **Do I know what I can do here?** (are the actions visible and labeled?)
- **Do I know what just happened?** (feedback after every action: toast, state change, cursor move)
- **Can I get back?** (back/escape/cancel always work and never lose my data silently)
- **Is anything here that I can't understand without reading the docs?**

Then walk the **inventory**: every route, screen, menu item, tab, button, link, icon, keyboard shortcut, context menu, settings toggle, and empty state. Tick each off against the coverage checklist from recon. For each control: tap it, screenshot, note what happened, note what you *expected* to happen. Untapped controls = untested controls.

Then repeat as a **returning user** with data: does the app remember me, my settings, my last position? Are lists paginated/searchable when there are 200 items instead of 3?

## Step 4 — Run every workflow end to end

A workflow is a job the user came to do, not a screen. Enumerate them from the product's purpose, not from the code: "sign up → verify email → create first project → invite a teammate → teammate accepts → both edit → export". Drive each one fully, as one continuous session, checking the result actually landed (the export file opens, the email arrived, the DB row exists, the other user sees the change).

Always include these workflows if they exist at all:
- Onboarding (signup, verification, first-run wizard, empty state → first item)
- Auth (login, logout, wrong password, forgot/reset password, session expiry, remember me)
- Core CRUD for every primary object (create, view, edit, delete, undo/restore if any)
- Search, filter, sort, pagination
- Settings / profile / preferences (change something, reload, confirm it stuck)
- Permissions (do things as the lower-privilege role; try URL-hopping to admin routes)
- Payment / upgrade / downgrade / cancel (sandbox)
- Import / export / share / print
- Notifications, email, and anything async — wait for it and confirm it arrives
- Help, docs links, support contact, keyboard-shortcut cheatsheet, `--help` / `?` key
- Multi-user / real-time if applicable (two sessions at once)

## Step 5 — Break it

Per screen and per form, run `references/break-it-checklist.md`. Highlights: empty submit, whitespace-only, 10 000 characters, emoji and RTL text, `<script>` and SQL-ish strings, negative numbers, past dates, double-click submit, browser back mid-flow, refresh mid-flow, resize to 320px / 40x10 terminal, slow network, offline, expired session mid-action, concurrent edits, deep link to a deleted item.

## Step 6 — Audit: bugs, UX/UI, and missing features

First run `references/ux-ui-checklist.md` over every screen and workflow you drove. Then sort findings into three separate lists. Don't merge them; they're fixed differently.

**Bug** = the product does something other than what a reasonable user expects, or something the product itself promised (label, docs, tooltip). Includes visual bugs, dead controls, wrong data, crashes, confusing copy, inaccessible controls, and broken keyboard nav.

**UX/UI issue** = it works, but a user struggles: the theme or colours confuse (nothing reads as clickable, low contrast, status colours clash with the brand), the layout has no clear hierarchy, the same thing looks or is named differently across screens, a workflow takes more steps or decisions than it should, or an element serves no workflow and just adds noise. Each one names the principle it breaks (heuristic, contrast ratio, step count) — taste alone is not a finding.

**Missing feature** = a reasonable user would look for it here and it isn't there. Judge by: (a) every comparable product has it, (b) the UI implies it exists (a search box with no filters, a list with no sort, a delete with no undo, settings with no save confirmation), (c) the workflow dead-ends without it.

Each finding gets an ID (`BUG-007`, `UX-004`, `MISS-003`), severity, exact repro steps (numbered, from clean state), expected vs actual, and an evidence path. Severity scale:

| Sev | Meaning |
|---|---|
| P0 | Data loss, security, crash, can't complete a core workflow |
| P1 | Core workflow works only with a workaround, or wrong result shown |
| P2 | Non-core broken, confusing, visually wrong, missing feedback |
| P3 | Polish, copy, minor inconsistency |

Also record **what worked well** — briefly. It keeps the report credible and tells the team what not to touch.

## Step 7 — Fix

Only if the user asked for fixes ("find and fix", "QA and fix"). If they asked to find, audit, or "tell me what's broken", skip to Step 8, deliver the report, and ask which findings to fix.

Fix in order P0 → P1 → P2 → P3; at equal severity, bugs → UX/UI → missing features, unless a missing feature is blocking a P0/P1 workflow. For each fix:
1. Find the root cause in code (now you may read source).
2. Fix the cause, not the symptom. If the same class of bug appears elsewhere, grep for siblings and fix them too.
3. **Re-drive the exact repro** from the finding, from clean state, and capture the after-screenshot. A fix without a re-driven repro is a guess.
4. Add or update an automated test at the level the project already uses (e2e if they have Playwright, otherwise integration/unit). Don't introduce a new test framework unless there is none.
5. Mark the finding `FIXED (commit abc123)` in `qa/findings.md`.

UX/UI: fix within the product's existing design system — adjust tokens, spacing, hierarchy, copy, and step count; merge or remove redundant steps and elements. Fix the token or shared component, not one screen, so the fix lands everywhere. Small changes (contrast, labels, button weight, a removed redundant field or confirmation) just ship. Anything that changes the brand/theme, removes a feature or screen someone might rely on, or restructures a whole workflow: show a before/after (screenshot or sketch) with the step count and ask first.

Missing features: implement the small ones (sort, empty state, confirmation dialog, loading spinner, keyboard shortcut). For large ones, write a one-paragraph spec in the report and ask the user before building — don't silently ship a major feature.

If the user gave you access to a branch/PR flow, commit in small, findings-referenced commits: `fix(auth): BUG-004 reset link expires immediately`.

## Step 8 — Report

Use `assets/report-template.md`. Fill every section. The report is for someone who did not watch you work, so every claim points to evidence. Deliver `qa/REPORT.md` plus the `qa/screens/` folder (or a zip / published page if that's the delivery channel).

## Rules of engagement

- **Never test on production** with real users' data unless the user explicitly says so. Confirm the environment before the first destructive action.
- **Don't fake it.** If a driver can't reach a screen (native file picker, OS dialog, 2FA push), say so in the report as "not covered" rather than assuming it works.
- **Time-box exploration** — a typical app is 2–4 hours of driving. If it's bigger, report coverage percentage and ask which areas to prioritize.
- **Keep asking "would a real person understand this?"** Technical correctness is not the bar. Obvious is the bar.
- **Log as you go.** `qa/findings.md` after every finding; screenshots after every action.

## Files in this skill

- `references/drivers.md` — how to drive each product type (Playwright, tmux, pexpect, adb/simctl, API) with copy-paste snippets. Read the section for your product type.
- `references/first-time-user-checklist.md` — the screen-by-screen new-user audit.
- `references/break-it-checklist.md` — edge-case inputs and interruptions per form/screen.
- `references/ux-ui-checklist.md` — visual design and flow checks, with the principles to cite.
- `assets/report-template.md` — the final report skeleton.
- `assets/findings-template.md` — the running findings log format.
- `scripts/tui_drive.sh` — helper for tmux-driven TUI sessions (start, send keys, capture, diff).
