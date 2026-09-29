# Findings log — [product]

Append as you go. Never reconstruct from memory. One block per finding. IDs never reused.

Reset command: `…`   Driver: `…`   Started: YYYY-MM-DD HH:MM

---

BUG-001 | P1 | functional | OPEN
where: Settings > Profile
repro: 1) login as member 2) change display name 3) click Save 4) reload
expected: new name shown
actual: old name; PUT /api/profile returned 200 but response body is the old record
evidence: qa/screens/031-save-profile.png, qa/screens/032-after-reload.png
notes:

---

UX-001 | P2 | OPEN
where: Checkout
experience: primary "Pay" is outlined grey, "Cancel" is solid brand colour — users hit Cancel
principle: visual hierarchy / Fitts's law; 1 primary action per screen
evidence: qa/screens/044-checkout.png
notes: fix in Button variant tokens, not just this screen

---

MISS-001 | S | PROPOSED
where: Projects list
expected: sort by name/date; list has 40 items and no sort/filter
evidence: qa/screens/019-projects-list.png
notes:

---

OK | Onboarding wizard — skip works, doesn't re-show, resume from Settings. Nice.
