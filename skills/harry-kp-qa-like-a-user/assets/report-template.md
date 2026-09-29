# User-Perspective QA Report — [Product name]

**Date:** YYYY-MM-DD  **Build/commit tested:** abc1234  **Environment:** local dev / staging (never prod unless stated)
**Driver:** Playwright headless Chromium 1280x800 + 375x667 / tmux 120x40 + 80x24 / …
**Accounts used:** user@ (member), admin@ (admin) — sandbox

## 1. Summary

Two or three sentences a manager can read: overall state, the worst thing found, what got fixed.

| | Found | Fixed | Open |
|---|---|---|---|
| P0 | | | |
| P1 | | | |
| P2 | | | |
| P3 | | | |
| Missing features | | | |

## 2. Coverage

What was driven, what wasn't, and why. Be honest — an un-driven screen is untested.

| Area / screen / command | Driven? | Notes |
|---|---|---|
| Landing | ✅ | phone + desktop |
| Signup / verify | ✅ | email via sandbox inbox |
| Billing | ⚠️ partial | no payment sandbox creds provided |
| Native file picker | ❌ | not reachable via driver |

Workflows run end to end: list them.

## 3. Bugs

Ordered by severity. Each one self-contained.

### BUG-001 · P0 · [one-line title]
- **Where:** screen / route / command
- **Repro (from clean state):**
  1. …
  2. …
- **Expected:** …
- **Actual:** …
- **Evidence:** `qa/screens/017-…png`, console log excerpt
- **Root cause:** file:line, one sentence
- **Status:** FIXED in `abc1234` — re-driven, after-shot `qa/screens/BUG-001-after.png` / OPEN — reason

## 4. Missing features

Things a reasonable user expected here and didn't find.

### MISS-001 · [title]
- **Where a user looks for it:** …
- **Why they expect it:** implied by UI / every comparable product / workflow dead-ends
- **Impact:** …
- **Proposal:** one paragraph. Effort: S / M / L
- **Status:** IMPLEMENTED in `abc1234` / PROPOSED — needs decision

## 5. First-time-user friction

Not bugs, but moments a new user would stall. Short bullets with screenshot refs. Include the "time to first success" you observed.

## 6. What works well

Brief. Things the team should not touch.

## 7. Fixes made

Commit list with finding IDs. Tests added. Anything the fix changed that a user would notice.

## 8. Not covered / needs a human

Concrete list with why (no emulator, no creds, native dialogs, real payment, real email deliverability, etc.) and the exact steps a human should run.

## 9. Recommended next steps

Top 3–5, in order.
