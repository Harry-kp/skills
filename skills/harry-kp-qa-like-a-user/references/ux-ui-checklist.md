# UX / UI checklist

Run this on every screen and every workflow *after* you've used them as a user — you need the felt experience, not a code read. For each hit, log a `UX-NNN` finding with a screenshot and the principle it breaks. "I don't like it" is not a finding; "the primary action is visually weaker than the secondary one, so users hit Cancel" is.

## A. Visual design (UI)

| Check | Broken looks like |
|---|---|
| **Colour has a job** | Theme/accent colour used for decoration *and* for actions, so nothing reads as clickable. Brand colour clashes with status colours (red brand next to red errors). |
| **Contrast** | Text < 4.5:1 (3:1 for large text/icons), grey-on-grey placeholders used as labels, disabled vs enabled indistinguishable. Check light *and* dark theme. |
| **Hierarchy** | Can't tell the one primary action per screen; three buttons with equal weight; heading sizes that don't step down; everything bold. |
| **Consistency** | Same action styled/named differently across screens ("Save" / "Update" / "Done"); two button styles, spacings, radii, or icon sets doing the same job; a component that ignores the design system the rest of the app uses. |
| **Spacing & alignment** | Uneven gaps, elements off the grid, cramped tap targets (< 44pt / 48dp), related things far apart and unrelated things close (proximity). |
| **Typography** | More than 2 typefaces, too many sizes/weights, line length > ~80 chars, truncated labels. |
| **Icons & imagery** | Icons without labels whose meaning isn't universal; decorative images pushing content below the fold. |
| **States** | Missing hover/focus/pressed/selected/loading/empty/error states, or states that look the same. |
| **Theme** | Dark mode as an afterthought: hard-coded colours, invisible borders, pure-black-on-pure-white glare, charts unreadable in one theme. |

## B. Interaction and flow (UX)

| Check | Broken looks like |
|---|---|
| **Steps to done** | Count taps/keys for each core workflow. More steps than a comparable product, or steps that ask for something the app already knows. |
| **Decisions per screen** | Too many choices at once (Hick's law); settings exposed that 95% of users never need, instead of sensible defaults. |
| **Mental model** | Terms from the codebase/domain instead of the user's words; navigation grouped by how it's built, not by what users are trying to do. |
| **Recognition over recall** | User has to remember an ID, a value from a previous screen, or a hidden shortcut to proceed. |
| **Feedback & status** | User can't tell whether something is loading, saved, or failed. |
| **Error prevention** | App lets you make the mistake, then scolds you — instead of constraining input or defaulting safely. |
| **Dead weight** | Screens, fields, options, banners, or confirmations that don't help any workflow. Duplicate paths to the same place that disagree. |
| **Flow breaks** | Workflow forces a detour (leave → set something elsewhere → come back and re-enter data). |
| **Platform conventions** | Web patterns on mobile (hover-only, tiny links), desktop patterns in a TUI, ignoring back gesture/Esc/standard shortcuts. |

## Principles to cite

Nielsen's 10 heuristics (visibility of status, match with real world, user control, consistency, error prevention, recognition over recall, flexibility, minimalist design, error recovery, help), Gestalt proximity/similarity, Fitts's law (target size/distance), Hick's law (choice count), WCAG 2.2 AA contrast and target size, and the platform's own guidelines (Material 3, Apple HIG) for native apps.
