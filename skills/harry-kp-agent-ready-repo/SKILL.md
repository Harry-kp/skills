---
name: harry-kp-agent-ready-repo
description: Audit and simplify a software repository in any language or stack — flatten accidental directory depth, consolidate duplicated logic into a single source of truth (SSOT), delete dead code, and write a short, verified agent instructions file (CLAUDE.md / AGENTS.md) so coding agents can work in the repo autonomously. Use this whenever the user asks to simplify, flatten, clean up, de-duplicate, restructure, or "make agent-ready" a codebase, asks for a CLAUDE.md or AGENTS.md, complains that a repo is over-engineered or hard to navigate, or wants a refactoring proposal before changes are made — even if they don't say "refactor" or "SSOT".
---

# Repo Refactor: Agent-Ready Simplification

Turn an over-engineered repository into one that is easy for a human to scan and easy for an AI agent to work in end-to-end. The work happens in four phases with a hard stop for human approval between the proposal and any file changes.

## What "good" looks like

A repository is agent-ready when a coding agent, given only an issue number, can: find the relevant module in under a minute of searching, write a failing test, fix the bug using existing helpers instead of inventing new ones, run one command to validate, and open a PR. Every decision in this skill should be judged against that outcome, not against an abstract ideal of "clean architecture."

Principles that serve that outcome:

- **Shallow over deep.** Files are grouped by functional domain (`billing/`, `auth/`), not by architectural layer (`services/impl/adapters/`). Depth that is a stack convention (Maven's `src/main/java/com/org/`, Go module paths, Django apps) is fine; depth that exists only to separate one file from another is not.
- **One implementation per concept.** Duplicate helpers, mirrored types, and parallel client wrappers are the main way agents write drift. Consolidate them.
- **Merge tiny files.** A file under ~30 lines that only makes sense next to another file should usually be part of that file.
- **Fewer abstractions than you think.** Single-use wrappers, interfaces with one implementation, and utility packages with two functions add lookup cost without adding value.

## Phase 1: Audit (read-only)

Do not edit anything in this phase. Use it to build an accurate picture, because a proposal built on a misread of the repo wastes the user's review time.

1. **Establish a baseline first.** Run `git status` (stop and ask if the tree is dirty — refactoring on top of uncommitted work makes regressions impossible to attribute). Then find and run the existing test suite, lint, and build. Record the results verbatim. If tests already fail, note which ones; you'll need to know that the failures predate your changes.
2. **Map the structure.** Generate the directory tree (ignore `node_modules`, `.git`, `target`, `dist`, `__pycache__`, virtualenvs, vendored dependencies, generated code such as protobuf/OpenAPI output — duplication and "dead" code there is expected). In a monorepo or a repo too large to audit in one pass, list the packages and ask which to start with instead of auditing everything shallowly. For each directory ask: does this depth exist because the stack requires it, or because someone added a layer? Flag single-file directories, `index`/`mod`/`__init__` files that only re-export, and directories named after a pattern rather than a domain (`utils`, `helpers`, `common`, `shared`, `core`, `lib`, `misc`).
3. **Find duplicated logic.** Grep for repeated function names, near-identical bodies, multiple HTTP/database clients, parallel type or schema definitions, hand-rolled versions of standard-library functions, and constants defined in more than one place. Read the candidates — names that match are often different functions, and functions that look different are often the same one.
4. **Identify the toolchain.** Locate the package manager, test runner, linter/formatter, type checker, and build tool from config files (`package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `pom.xml`, `build.gradle`, `*.csproj`, `Makefile`, `justfile`, CI config). The CI config is usually the most honest source for the commands that actually matter.
5. **Find dead wood — carefully.** Look for unreferenced exports, orphaned config, tests for code that no longer exists, and docs describing structures that don't exist. Before calling anything dead, check for dynamic references: string-based imports, reflection, plugin registries, entry points declared in config, CLI commands, and anything loaded by name from an environment variable. Also check whether the repo is a library — its public API may have external consumers you can't see.

## Phase 2: Proposal (stop for approval)

Write the proposal using the template below, then **end your turn and wait**. Do not create a branch, move a file, or "just start on the safe ones." The user needs to be able to veto individual items, and a partial refactor the user didn't sign off on is worse than none.

Keep the proposal honest about risk. Each item gets one of: **safe** (mechanical move/merge, fully covered by tests), **moderate** (touches logic or is under-tested), or **risky** (public API, dynamic references, or no tests). If more than a third of items are risky, say so up front and suggest doing the safe tier first.

When there's a judgment call, present the option and your recommendation rather than deciding silently — e.g., "`utils/dates.py` and `helpers/time.py` overlap 80%; I'd merge into `dates.py`, but `time.py` has a timezone quirk that may be intentional."

### Proposal template

````markdown
# Refactoring Proposal: <repo name>

**Baseline:** <test/lint/build results before any change, incl. pre-existing failures>
**Scope:** <N> merges, <N> moves, <N> deletions · <N> safe / <N> moderate / <N> risky

## 1. Directory tree

### Before
```text
<current tree, pruned to what changes>
```

### After
```text
<proposed tree, with one-line comments on changed entries>
```

## 2. SSOT consolidation

| Concept | Currently in | Canonical location | Rationale | Risk |
|---|---|---|---|---|
| Date formatting | `utils/dates.py`, `helpers/time.py` | `dates.py` | Same three functions; `time.py` adds one tz helper, which moves too | safe |

## 3. Action plan

### Merge
1. `<a>` → `<b>` — <one-line reason> — **<risk>**

### Move / flatten
1. `<from>` → `<to>` — <reason> — **<risk>**

### Delete
1. `<path>` — <reason, incl. how you confirmed it is unreferenced> — **<risk>**

## 4. Not changing (and why)
- `<path>` — looks over-nested but is required by <framework/tool>.

## 5. Open questions
- <anything you couldn't determine from the code alone>

---
Reply with approval, or list the item numbers to skip.
````

## Phase 3: Execute (after approval only)

Work in small, verifiable steps so a regression is easy to bisect and easy to revert.

1. **Branch.** `git checkout -b refactor/simplify-structure` (or the user's naming convention).
2. **Move with `git mv`**, never copy-and-delete, so history follows the file.
3. **One logical change per commit.** Move a file, fix its imports, run the tests, commit. Do not batch ten moves and then debug.
4. **Update every reference**, not just imports: build config paths, test discovery globs, CI paths, Dockerfiles, `.gitignore`, documentation links, package `exports`/`__all__`/`mod` declarations, and IDE config if committed.
5. **Consolidate duplicates by choosing the better implementation**, not by writing a third one. Keep the more-tested version, port any behavior the other had that tests depend on, and redirect callers. If the two versions differ in behavior, stop and ask — that difference may be a latent bug or an intentional distinction.
6. **Delete only after grep confirms zero references** across code, config, docs, and scripts.
7. **Verify against the baseline.** Run the full test suite, lint, type check, and build. The result must match or improve on Phase 1's baseline. If a test breaks, fix the cause in the refactor; do not edit the test to pass unless the test was asserting on the old file path or structure.
8. **Report** what was done, what was skipped, and any surprises, with the before/after test counts.

## Phase 4: Documentation and agent instructions file

Update `README.md` and any contributor docs so they describe the repo that now exists. Delete doc sections that describe removed structure rather than leaving them "for context."

Then write the agent instructions file in the repo root: `CLAUDE.md` for Claude Code, `AGENTS.md` for Codex, Cursor, Copilot and most others. If the repo already has one, update it; if it needs both, write `AGENTS.md` and make `CLAUDE.md` a one-line `@AGENTS.md` import so there is a single source of truth. Agents load this file into every session, so length is a direct cost: aim for under 80 lines. Include only what an agent cannot infer by reading the code — commands, conventions, and gotchas. Do not restate the directory tree (the agent can `ls`) or explain what each module does (it can read them).

**Every command in the instructions file must have been run by you and produced the expected result.** A wrong test command silently breaks every future autonomous session.

### Instructions file template

```markdown
# CLAUDE.md

## Commands
- Install: `<cmd>`
- Run locally: `<cmd>`
- Test (all): `<cmd>`
- Test (single file): `<cmd> path/to/test`
- Lint + format: `<cmd>`
- Type check: `<cmd>`          <!-- omit lines that don't apply -->
- Build: `<cmd>`

## Structure
<3–6 lines max: the domain directories and where new code of each kind goes. Not a tree.>

## Conventions
- Before writing a helper, grep for one. Duplicates of formatting, parsing, and client code are the #1 thing to avoid here.
- Files under ~30 lines that belong to one module go in that module, not in a new file.
- <stack-specific: e.g., "Use `Result<T, E>` not panics", "Prefer `dataclass` over dict for structured data">

## Gotchas
- <things that bit you during the refactor: dynamic imports, tests that need a service running, env vars required, slow tests to skip locally, generated files not to edit>

## Working on an issue
1. Reproduce with a failing test in the existing test file for that module.
2. Fix with minimal churn; reuse existing helpers.
3. Run lint, type check, and the full test suite — all must pass.
4. Branch `fix/<short-desc>` or `feat/<short-desc>`; commit with a conventional message.
5. PR description: root cause, what changed, tests added.
```

## When to hold back

Not every repo needs this treatment, and applying it blindly makes things worse. Say so instead of proceeding if:

- The repo follows a framework's mandated layout (Rails, Django, Angular, Next.js `app/`, Maven). Simplify *within* the convention, not against it.
- The "duplication" is deliberate isolation — e.g., bounded contexts in a monorepo that must not share code, or vendored copies pinned for stability.
- There are no tests and the user won't add them. Flattening an untested codebase is a gamble; propose the safe tier only and recommend writing characterization tests first.
- The repo is a published library. Public paths are API; moving them is a breaking change and belongs in a major-version plan, not a cleanup.

## Examples

**Prompt:** "This Python service has gotten messy, can you simplify it and set it up for Claude Code?"
**Expected:** Phase 1 audit with baseline test results → Phase 2 proposal with risk tiers → wait. After approval: `git mv` moves in small commits, `pyproject.toml`/pytest paths updated, tests match baseline, verified `CLAUDE.md`/`AGENTS.md` under 80 lines.

**Prompt:** "Write a CLAUDE.md for this repo."
**Expected:** Skip Phases 2–3. Run the toolchain to verify commands, then produce only the Phase 4 `CLAUDE.md`. Mention (in one line) any obvious simplification opportunities without executing them.

**Prompt:** "Flatten everything into a single `src/` folder."
**Expected:** Audit first. If the current depth is a framework convention or the repo is a library, explain the constraint and propose what *can* be flattened rather than doing it anyway.
