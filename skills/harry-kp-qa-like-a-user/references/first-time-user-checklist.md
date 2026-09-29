# First-time-user checklist

Work through this from a clean state. You know nothing about the product. For every line: do it, capture it, note pass / BUG-id / MISS-id. Skip lines that don't apply, but write "n/a — why" so coverage is visible.

## A. Arrival (first 60 seconds)

- [ ] Landing / launch screen tells me what this product does in one sentence
- [ ] The primary action is obvious (one clear CTA / one obvious key to press)
- [ ] Nothing is broken on first paint: no console errors, no layout shift, no missing images/fonts, no garbled terminal
- [ ] Load time feels acceptable; if it's slow there's a loading state, not a blank screen
- [ ] Works at phone width / 80x24 terminal without horizontal scroll or overlap
- [ ] No dead links in header/footer/nav; every nav item leads somewhere real
- [ ] Legal/privacy/help links exist if the product collects data or takes money

## B. Sign up / first run

- [ ] Sign-up is findable from the landing
- [ ] Each field says what it wants (format, requirements) *before* I get it wrong
- [ ] Password rules are stated up front, and the error tells me *which* rule I missed
- [ ] Email/phone verification: link/code arrives, works once, expires sensibly, resend exists
- [ ] Social/SSO login options work in the sandbox and land me in the same place as email signup
- [ ] Existing-account attempt gives a clear "already registered → log in" path, not a vague error
- [ ] After signup I'm logged in (not bounced to a login screen to re-enter what I just typed)
- [ ] First-run wizard/onboarding: can skip it, can come back to it, doesn't repeat every launch
- [ ] TUI/CLI: first launch without config creates sane defaults or a guided init; doesn't crash on missing config file

## C. Empty states

For every list/dashboard/table before there is any data:
- [ ] Empty state explains what will appear here and how to create the first one
- [ ] The "create first X" action is right there, not buried in a menu
- [ ] No "0 of 0", "undefined", "null", "NaN", "[object Object]", "%s" visible anywhere

## D. Creating the first thing

- [ ] Create flow completes with only required fields
- [ ] Required vs optional is marked
- [ ] Success is confirmed (toast / redirect to the new item / list updates) — I never wonder "did it save?"
- [ ] The new item shows correctly everywhere it should appear (list, dashboard count, search)
- [ ] Cancel/Escape mid-create discards cleanly and asks if I had typed something
- [ ] Defaults are sensible (dates default to today, not 1970; currency to my locale)

## E. Orientation on every screen

Walk every screen in the app. For each:
- [ ] I can tell where I am (title / breadcrumb / highlighted nav / TUI status line)
- [ ] I can tell how to leave (back, close, Esc, q — and they work)
- [ ] All controls are labeled or have a tooltip/`aria-label`; no mystery icons
- [ ] Disabled controls explain why (tooltip) or aren't shown
- [ ] Every button/link/menu item does something visible; none are dead
- [ ] Text is readable: contrast, size, no truncation without ellipsis, no overflow
- [ ] Focus is visible when tabbing; tab order follows visual order
- [ ] Hover/focus/active/selected states exist and are distinguishable
- [ ] Copy is human: no "Error 500", "Something went wrong" without a next step, no internal jargon, no lorem ipsum, no TODO
- [ ] Dates, numbers, currency are formatted and localized consistently across screens

## F. Feedback and errors

- [ ] Every action gives feedback within ~1s (spinner, progress, optimistic update, cursor move)
- [ ] Errors say what happened, why, and what to do next — close to where it happened
- [ ] Network failure mid-action: clear message, retry available, no data silently dropped
- [ ] Destructive actions (delete, cancel subscription, overwrite) confirm — and the confirm dialog names *what* is being destroyed
- [ ] Undo exists for delete where practical, or a trash/restore
- [ ] Unsaved-changes guard on navigate-away / close / quit

## G. Finding things again (returning user)

- [ ] Log out → log in: land somewhere sensible; "remember me" works; session survives reload
- [ ] Preferences/settings persist across reload and across devices/sessions if promised
- [ ] Search finds items by the obvious fields; empty search result says "no results for X" with a way to clear
- [ ] Sort and filter exist on any list that could grow past ~20 items; they persist (or reset) predictably
- [ ] Pagination / infinite scroll works and shows position ("21–40 of 312")
- [ ] Deep links / bookmarks / `--resume` reopen the same item
- [ ] Recently used / last opened is surfaced if the product has documents/projects

## H. Help and escape hatches

- [ ] Help is reachable from every screen (`?`, F1, Help menu, `--help`)
- [ ] Help content matches the actual UI (screenshots/bindings not stale)
- [ ] Keyboard shortcut list is complete vs what's implemented
- [ ] Support/contact/feedback path exists and works
- [ ] Account deletion / data export exists if the product stores personal data

## I. Access and inclusion

- [ ] Whole primary workflow completable by keyboard only
- [ ] Screen-reader pass on 2–3 key screens: landmarks, headings, labels present (aria snapshot)
- [ ] Color is never the only signal (status, errors, selection)
- [ ] Respects reduced-motion / NO_COLOR / dark mode if the platform offers them
- [ ] Zoom to 200% doesn't break layout

## J. Security smells a user can notice

- [ ] Password fields masked; no passwords/tokens in URLs, logs, or screen
- [ ] Logged-out user hitting a private URL/route is redirected, not shown data or a crash
- [ ] Lower-privilege role can't see/act on admin things by URL or key combo
- [ ] Session actually ends on logout (back button doesn't show private page)
- [ ] Error pages don't leak stack traces, paths, or versions
