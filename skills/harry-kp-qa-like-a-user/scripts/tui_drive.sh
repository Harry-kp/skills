#!/usr/bin/env bash
# tui_drive.sh — drive a TUI through tmux with automatic numbered captures.
#
#   tui_drive.sh start  "<command>" [cols] [rows]     start session running command
#   tui_drive.sh keys   <label> <tmux-keys...>        send keys, wait, capture as NNN-<label>.txt
#   tui_drive.sh type   <label> "<literal text>"      send literal text (no key-name parsing), capture
#   tui_drive.sh cap    <label>                       capture only
#   tui_drive.sh resize <label> <cols> <rows>         resize then capture
#   tui_drive.sh diff                                 diff last two captures
#   tui_drive.sh stop                                 kill session, capture terminal state after exit
#
# Env: QA_SESSION (default qa-tui), QA_DIR (default qa/screens), QA_WAIT seconds (default 0.6)

set -euo pipefail
S="${QA_SESSION:-qa-tui}"
DIR="${QA_DIR:-qa/screens}"
WAIT="${QA_WAIT:-0.6}"
mkdir -p "$DIR"

# `|| true`: grep finds nothing in an empty dir, and pipefail would silently kill the first capture
next_n() { { ls "$DIR" 2>/dev/null | grep -E '^[0-9]{3}-' || true; } | sort | tail -1 | cut -c1-3 | awk '{printf "%03d", $1+1}'; }
cap() {
  local n; n=$(next_n); [ -z "$n" ] && n=001
  local f="$DIR/$n-$1.txt"
  tmux capture-pane -t "$S" -p > "$f"
  tmux capture-pane -t "$S" -p -e > "${f%.txt}.ansi"
  echo "[cap] $f"; cat "$f"
}

case "${1:-}" in
  start)
    tmux kill-session -t "$S" 2>/dev/null || true
    tmux new-session -d -s "$S" -x "${3:-120}" -y "${4:-40}"
    tmux send-keys -t "$S" "$2" Enter
    sleep "$(awk "BEGIN{print $WAIT*3}")"
    cap launch ;;
  keys)
    label="$2"; shift 2
    tmux send-keys -t "$S" "$@"; sleep "$WAIT"; cap "$label" ;;
  type)
    tmux send-keys -t "$S" -l "$3"; sleep "$WAIT"; cap "$2" ;;
  cap)   cap "$2" ;;
  resize)
    tmux resize-window -t "$S" -x "$3" -y "$4"; sleep "$WAIT"; cap "$2" ;;
  diff)
    # no mapfile: macOS ships bash 3.2
    a=$(ls "$DIR"/[0-9][0-9][0-9]-*.txt | sort | tail -2 | head -1)
    b=$(ls "$DIR"/[0-9][0-9][0-9]-*.txt | sort | tail -1)
    diff "$a" "$b" || true ;;
  stop)
    tmux send-keys -t "$S" q; sleep "$WAIT"
    cap after-quit-terminal-state
    tmux kill-session -t "$S" 2>/dev/null || true ;;
  *) sed -n '2,13p' "$0"; exit 1 ;;
esac
