#!/usr/bin/env sh
# Installs skills from github.com/Harry-kp/skills into every coding agent found on this machine.
# Usage: curl -fsSL https://raw.githubusercontent.com/Harry-kp/skills/main/install.sh | sh [-s -- skill-name ...]
set -eu

REPO="${SKILLS_REPO:-Harry-kp/skills}"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

curl -fsSL "https://codeload.github.com/$REPO/tar.gz/main" | tar -xz -C "$tmp" --strip-components=1
src="$tmp/skills"

# ponytail: fixed list of global skill dirs; extend when a new agent ships.
# ~/.agents/skills is the cross-agent default (Codex, Amp, others read it).
targets="$HOME/.agents/skills"
for d in .claude .codex .cursor .gemini .copilot .config/opencode .windsurf; do
  [ -d "$HOME/$d" ] && targets="$targets $HOME/$d/skills"
done

names="$*"
[ -n "$names" ] || names="$(ls "$src")"

for t in $targets; do
  mkdir -p "$t"
  for n in $names; do
    [ -f "$src/$n/SKILL.md" ] || { echo "skip: no skill '$n'" >&2; continue; }
    rm -rf "${t:?}/$n" && cp -R "$src/$n" "$t/$n"
    echo "installed $n -> $t"
  done
done
