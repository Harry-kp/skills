# Logic & functional correctness checklist

A screen can render perfectly and still be wrong. For every workflow, don't stop at "it completed" — check **the result is correct**. Work out the expected value yourself (by hand, a calculator, a quick script, the raw API response, the DB row) *before* reading what the app shows, then compare. A mismatch is a `BUG-NNN` tagged `logic`.

## Numbers and calculations

- Totals, subtotals, averages, percentages: recompute from the line items shown. Off by a rounding step, a missing item, or a double-counted item?
- Money: rounding (per line vs on total), currency symbol and decimals, tax/fee order, negative balances, refunds/credits applied once.
- Units: kWh vs Wh, bytes vs KiB, ms vs s, per-day vs per-month; labels match the maths.
- Derived values ("days left", "projected bill", "usage vs last month"): recompute from the inputs. Check the edge cases — zero usage, first day of the period, negative or missing data.
- Charts: bars/lines match the table beneath them; axis scale and legend correct; the latest point isn't silently dropped.
- Counters and badges: "12 unread" matches the list; updates after an action.

## Dates and time

- Timezone: the day shown matches the user's day (UTC midnight shifts are the classic bug). Test near midnight and on month/year boundaries.
- Ranges: "last 30 days" includes the right endpoints; month lengths, leap years, DST changes.
- Relative times ("2 hours ago") agree with the absolute timestamp.
- Sorting by date is chronological, not alphabetical.

## State and rules

- Each object's status transitions only the allowed ways (can't ship an unpaid order, can't edit a closed item). Try the forbidden transitions.
- Business rules the product states (limits, thresholds, eligibility, discounts, permissions) actually apply — at the boundary value, one below, and one above.
- Toggles and settings change the behaviour they claim to, not just their own UI.
- Filters and search return exactly the matching items: none missing, none extra; combined filters AND/OR as labelled.
- Pagination: no item repeated or skipped across pages, total count right.

## Data integrity

- Round-trip: what you enter is exactly what is saved and shown back (reload, another device/session, export). No truncation, re-encoding, or trimmed precision.
- Same fact shown in two places (dashboard vs detail, list vs export, UI vs API/DB) agrees.
- Create → edit → delete leaves no orphans; counts and totals update everywhere.
- Retrying or double-submitting doesn't duplicate side effects (charges, emails, records).
- Cache and staleness: after a change, every screen shows the new value without a manual refresh (or clearly shows it's stale).

## Integrations and async

- The third-party/API response the app uses is interpreted correctly — compare the raw response with what's displayed (fields swapped, wrong field, fallback silently masking an error).
- Error from upstream shows as an error, not as zero, empty, or a default value that looks real.
- Background jobs, notifications, and emails fire once, at the right time, with the right values.

## How to log it

```
BUG-012 | P1 | logic | OPEN
where: Dashboard > Days left
expected: balance ₹540 / avg ₹61.2 per day (last 7 days) = 8.8 → "8 days"
actual: "14 days" — uses 30-day average including a 9-day outage with zero usage
evidence: qa/screens/021-dashboard.png, qa/screens/api-007.txt (raw usage)
```

Always show the expected calculation — it's what makes a logic bug fixable and settles "is this actually wrong?".
