# Break-it checklist

Run against every form, list, and long-running action. Capture before/after. Anything that crashes, corrupts layout, loses data, or produces an unhelpful error is a bug.

## Inputs — try each in every text field

| Input | Looking for |
|---|---|
| empty submit | field-level required message, focus moves to first error |
| whitespace only `"   "` | trimmed or rejected, not accepted as a name |
| leading/trailing spaces `" bob "` | trimmed consistently (login especially) |
| very long: 300 chars, then 10 000 | max length enforced with a counter or clear error; layout doesn't explode |
| emoji `🚀👨‍👩‍👧` and CJK `日本語テスト` | stored, displayed, counted, sorted, searched correctly |
| RTL `مرحبا` mixed with LTR | alignment doesn't break the layout |
| `<script>alert(1)</script>` and `<b>bold</b>` | shown literally, never rendered |
| `' OR 1=1 --` and `"; DROP TABLE` | plain string, no 500 |
| `{{7*7}}` `${7*7}` `%s %d` | shown literally (template injection) |
| `../../etc/passwd` in file/name fields | rejected or sanitized |
| `null`, `undefined`, `NaN`, `0`, `-1`, `1e309`, `0.1+0.2` in numeric fields | proper validation, proper formatting |
| negative and zero for quantities/prices | rejected where meaningless |
| past dates for future-only fields; Feb 30; year 0001 and 9999 | validated; timezone doesn't shift the day |
| duplicate of an existing unique value (email, slug, name) | friendly conflict message, not a DB error |
| paste multi-line text into single-line field | newlines stripped or rejected |
| autofill / browser autocomplete | fields have correct `autocomplete` attrs; nothing autofills into the wrong field |

Files (if uploads exist): 0-byte file, 200 MB file, wrong extension with right MIME, right extension wrong content, filename with spaces/unicode/`..`, 50 files at once, cancel mid-upload.

## Interactions

- Double-click / mash the submit button → exactly one record created
- Press Enter in every field → submits the form (or doesn't) consistently
- Tab out of a field with an error → error shows on blur, not only on submit
- Open two tabs, edit the same item, save both → last-write warning or merge, not silent overwrite
- Start an action, hit browser Back → no half-state, no duplicate on Forward
- Refresh mid-wizard → resume or clean restart, data not half-saved
- Deep-link to a modal/step directly → renders or redirects gracefully
- Rapidly switch tabs/routes while data loads → no stale data from the previous screen, no "cannot update unmounted component"
- Scroll to bottom of every long list → pagination/infinite scroll fires once, not repeatedly
- Sort then filter then paginate then edit an item → position and filters survive the edit
- Cancel a running operation → actually stops; UI returns to a sane state

## Environment

- Viewport 320px wide; 4K wide; browser zoom 50% and 200%
- Terminal 40x12, then 300x80, then resize *during* a modal
- Offline: perform an action, go online, see it reconcile or report clearly
- Slow 3G: skeletons/spinners appear; no double-submits from impatient clicks
- Expired session mid-form: submit → re-auth → form data preserved (or clearly lost with warning)
- Clock skew / different timezone on the client
- Dark mode, high-contrast mode, reduced motion
- Ad blocker / third-party cookies blocked (auth and analytics failures often surface as blank screens)
- Second user deletes the item you're viewing → what do you see on your next action?

## Data volume

Seed 1, 25, 200, and 5 000 items where practical:
- Lists still render and scroll; no N+1 stalls
- Counts, totals, and "select all" are correct beyond the first page
- Search returns in reasonable time
- Export includes all items, not just the visible page

## Permissions

- Log in as each role; walk the same screens; note every control the lower role can *see* but not use (should be hidden or disabled with reason)
- Guess URLs/commands for admin things while unprivileged
- Change role/permissions in another session while acting → next action respects the new permission

## Recovery

- Kill the process mid-write (Ctrl-C the CLI, kill the server during save) → restart → data consistent, no corrupt file, no orphaned records
- Fill disk / DB quota if simulable → user-readable error, not a crash loop
