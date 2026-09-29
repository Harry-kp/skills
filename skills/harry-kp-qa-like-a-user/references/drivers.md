# Drivers: how to actually press the buttons

Read only the section for your product type. Every driver follows the same rhythm: **act → capture → look → log**. Never chain ten actions blind; look after each one.

Contents
1. Web apps (Playwright)
2. TUIs (tmux)
3. CLIs (direct + pexpect)
4. Desktop (Electron / Tauri)
5. Mobile (Android emulator / iOS simulator)
6. API-only products
7. Capturing evidence and naming

---

## 1. Web apps — Playwright

Install once (Python or Node — match the project's ecosystem):

```bash
python -m venv .venv && . .venv/bin/activate && pip install playwright && python -m playwright install chromium
# (in a throwaway sandbox where pip refuses system installs: pip install --break-system-packages playwright)
# or
npm i -D playwright && npx playwright install chromium
```

Drive interactively in a persistent script rather than one-off commands, so login state survives between steps. Minimal harness (`qa/drive.py`):

```python
import sys, json, pathlib
from playwright.sync_api import sync_playwright

SHOTS = pathlib.Path("qa/screens"); SHOTS.mkdir(parents=True, exist_ok=True)
n = [0]
def shot(page, label):
    n[0] += 1
    p = SHOTS / f"{n[0]:03d}-{label}.png"
    page.screenshot(path=str(p), full_page=True)
    print(f"[shot] {p}  url={page.url}  title={page.title()!r}")
    return p

with sync_playwright() as pw:
    browser = pw.chromium.launch(headless=True)
    ctx = browser.new_context(viewport={"width": 1280, "height": 800},
                              record_video_dir="qa/video")   # video is cheap insurance
    page = ctx.new_page()
    page.on("console", lambda m: print(f"[console.{m.type}] {m.text}") if m.type in ("error","warning") else None)
    page.on("pageerror", lambda e: print(f"[pageerror] {e}"))
    page.on("requestfailed", lambda r: print(f"[netfail] {r.method} {r.url} {r.failure}"))
    page.on("response", lambda r: print(f"[http {r.status}] {r.url}") if r.status >= 400 else None)

    page.goto("http://localhost:3000"); shot(page, "landing")
    # ... act, shot, act, shot ...
    ctx.storage_state(path="qa/auth.json")   # reuse login later: new_context(storage_state="qa/auth.json")
```

Useful moves:
- **Inventory a screen's controls**: `page.get_by_role("button").all()`, `get_by_role("link")`, `get_by_role("textbox")`, plus `page.locator("[onclick], [role=menuitem], [tabindex]")`. Print their accessible names. Anything with no accessible name is a finding (a11y + usually a nameless icon button).
- **Accessibility tree snapshot** — the closest thing to "what a screen reader user sees": `page.accessibility.snapshot()` (older) or `page.locator("body").aria_snapshot()` (newer).
- **Keyboard-only pass**: `page.keyboard.press("Tab")` repeatedly, screenshot each focus stop, confirm focus is visible and order is sane. `Enter`/`Space` should activate.
- **Viewports**: repeat key screens at `375x667` (phone), `768x1024` (tablet), `1920x1080`.
- **Network conditions**: `ctx.set_offline(True)`; throttling via CDP `Network.emulateNetworkConditions`.
- **Session expiry**: clear cookies mid-flow `ctx.clear_cookies()` then act.
- **Two users**: two `browser.new_context()`s logged in as different accounts.
- **Wait properly**: `page.wait_for_load_state("networkidle")` or `expect(locator).to_be_visible()`. Never `sleep()` and hope.
- **Console/network errors are findings** even when the UI looks fine.

If the project already has Playwright/Cypress config, use its base URL and fixtures.

---

## 2. TUIs — tmux

tmux gives you a real terminal you can type into and read back. Use `scripts/tui_drive.sh` or the raw commands:

```bash
S=qa-tui
tmux kill-session -t $S 2>/dev/null
tmux new-session -d -s $S -x 120 -y 40          # size matters: also test 80x24 and 40x12
tmux send-keys -t $S 'cd /path/to/app && ./run' Enter
sleep 1.5
tmux capture-pane -t $S -p > qa/screens/001-launch.txt

# keys
tmux send-keys -t $S 'j' 'j' Enter               # literal keys
tmux send-keys -t $S Escape
tmux send-keys -t $S C-c                         # ctrl-c
tmux send-keys -t $S Tab BTab                    # tab / shift-tab
tmux send-keys -t $S Up Down Left Right PageUp PageDown Home End F1
tmux send-keys -t $S -l 'literal text with spaces'   # -l = no key-name parsing

# resize mid-run (layout bugs live here)
tmux resize-window -t $S -x 80 -y 24 ; sleep 0.5 ; tmux capture-pane -t $S -p > qa/screens/012-resized-80x24.txt

# colors/attrs (to catch invisible text, missing highlight on selection)
tmux capture-pane -t $S -p -e > qa/screens/013-with-escapes.txt
```

TUI-specific things to check:
- `?`, `h`, `F1`, `:help` — is there a help screen and does it list *every* binding actually implemented? Cross-check against the keymap in code afterward.
- Every binding in help actually does something; every action in the UI has a discoverable binding.
- `q`, `Esc`, `Ctrl-C` semantics: consistent? Does `Esc` on a modal close only the modal? Does quitting with unsaved changes prompt?
- Selection highlight visible on both light and dark terminals (check with `-e` capture that a bg/fg attr exists).
- Long strings truncate with ellipsis rather than corrupting the layout.
- Resize during a modal / during a list scroll.
- Mouse support: `tmux send-keys -t $S -M` is unreliable; note mouse as "not covered" unless the app documents keyboard parity.
- Unicode/wide chars (CJK, emoji) in user data — alignment breaks here often.
- Slow ops show a spinner/progress; the UI doesn't freeze without feedback.
- Terminal restored on exit (no leftover alt-screen, cursor visible, echo back on). Check with `tmux capture-pane` after quit and by typing a command.

Diff consecutive captures to spot unexpected changes: `diff qa/screens/010-*.txt qa/screens/011-*.txt`.

---

## 3. CLIs — direct + pexpect

Non-interactive: just run them, but run them the way a user would — from a fresh shell, with no env vars set, from a different cwd, with no args, with `--help`, with `-h`, with a typo'd subcommand, with `--version`.

```bash
app                    # no args: should print usage, not a stack trace
app --help ; app -h ; app help ; app --version
app nonexist           # typo: should suggest nearest command
app do --flag=wrong    # bad value: message names the flag and the valid values
app do 2>&1 | cat      # is stderr/stdout split sane for piping?
echo $?                # non-zero on failure, zero on success
app do --json | jq .   # if a --json/--output exists, is it valid JSON with nothing else on stdout?
NO_COLOR=1 app do      # respects NO_COLOR / non-tty
app do < /dev/null     # doesn't hang waiting for a prompt when non-interactive
```

Interactive prompts (wizards, confirmations): use `pexpect`:

```python
import pexpect
c = pexpect.spawn("app init", encoding="utf-8", timeout=10)
c.logfile_read = open("qa/screens/cli-init.log", "w")
c.expect("Project name")   ; c.sendline("")            # empty answer: sensible default or clear error?
c.expect("Project name")   ; c.sendline("my proj ☃")   # space + unicode
c.expect(r"\(y/N\)")       ; c.sendline("maybe")       # invalid choice handled?
c.expect(pexpect.EOF)
```

Check: Ctrl-C mid-wizard leaves no half-written files; re-running is idempotent; `--yes`/`--non-interactive` flag exists for scripting.

---

## 4. Desktop — Electron / Tauri

- Electron: Playwright's `_electron.launch({args: ["."]})` gives you a `page` like the web driver. Same harness as section 1.
- Tauri / other: if there's a web dev server (`tauri dev` usually serves at localhost:1420), drive that with Playwright and note native-only features (tray, file dialogs, notifications) as "not covered by driver — verified manually? [ ]".
- Window states: minimize/restore, small window, multi-monitor DPI if you can, close-to-tray behavior, "unsaved changes" on quit.

---

## 5. Mobile — emulator / simulator

Only feasible when the environment has an emulator. If not, drive the responsive web build at phone viewport and list native-only surfaces as not covered.

Android:
```bash
adb devices
adb shell monkey -p com.example.app -c android.intent.category.LAUNCHER 1
adb shell uiautomator dump /sdcard/ui.xml && adb pull /sdcard/ui.xml qa/screens/005-ui.xml   # control inventory
adb shell input tap 540 1200 ; adb shell input text 'hello' ; adb shell input keyevent KEYCODE_BACK
adb exec-out screencap -p > qa/screens/006-after-tap.png
adb shell settings put global airplane_mode_on 1   # offline
```
iOS:
```bash
xcrun simctl list devices
xcrun simctl launch booted com.example.app
xcrun simctl io booted screenshot qa/screens/007.png
```
Mobile-specific checks: back gesture/hardware back, rotation, keyboard covering inputs, permission prompts (deny them!), deep links, app backgrounded mid-action, low storage/offline banners, tap targets ≥ 44pt.

---

## 6. API-only products

The "UI" is the docs and the first request. Act like a new integrator with only the public docs:

1. Can I find the base URL, auth method, and one working curl in under 2 minutes?
2. Does the quickstart's first request actually work verbatim?
3. Error shape: consistent JSON, useful message, correct status code, no stack traces.
4. Auth failures: missing key, wrong key, expired key → 401 with a message that says *which*.
5. Validation: missing required field names the field. Wrong type names the type.
6. Pagination, rate-limit headers, idempotency on retries, CORS if browsers call it.
7. Every documented endpoint exists; every existing endpoint is documented (compare OpenAPI vs router).

Log each request/response pair to `qa/screens/api-NNN.txt`.

---

## 7. Evidence and naming

- `qa/screens/NNN-<action>.png|txt` — sequential, action-named. `042-click-save-on-profile.png`.
- Log every action to `qa/actions.log` as `NNN | screen | action | expected | actual | ok/bug-id`.
- Before/after pairs for each fix: `BUG-007-before.png`, `BUG-007-after.png`.
- Keep console/network/pageerror logs alongside; a "clean-looking" screen with a 500 in the network log is still a bug.
