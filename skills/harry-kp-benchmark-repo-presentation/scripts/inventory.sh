#!/usr/bin/env bash
# Inventory the presentation surfaces of two GitHub repos (user's + reference).
# Usage: inventory.sh <owner/repo-user> <owner/repo-reference> [outdir]
set -euo pipefail

USER_REPO="${1:?usage: inventory.sh <owner/repo-user> <owner/repo-reference> [outdir]}"
REF_REPO="${2:?usage: inventory.sh <owner/repo-user> <owner/repo-reference> [outdir]}"
OUT="${3:-${TMPDIR:-/tmp}/repo-inventory}"
mkdir -p "$OUT"

inventory_one() {
  local repo="$1" label="$2"
  local name="${repo/\//__}"  # owner__name, so same-named forks don't collide
  local dir="$OUT/$name"
  local src="$OUT/_src/$name"
  mkdir -p "$dir" "$OUT/_src"

  if [ ! -d "$src/.git" ]; then
    git clone -q --depth 1 "https://github.com/$repo" "$src" 2>/dev/null || {
      echo "clone failed for $repo" >&2; return 1; }
  fi

  local s="$dir/summary.txt"
  {
    echo "== $label: $repo =="
    echo
    echo "-- top-level files --"
    ls -A "$src" | grep -v '^\.git$' | tr '\n' ' '; echo
    echo
    echo "-- community / meta files present --"
    for f in README.md CONTRIBUTING.md CODE_OF_CONDUCT.md SECURITY.md LICENSE CHANGELOG.md ROADMAP.md RELEASING.md AUTHORS CONTRIBUTOR_LICENSE_AGREEMENT.md; do
      [ -e "$src/$f" ] && echo "  [x] $f ($(wc -l < "$src/$f") lines)" || echo "  [ ] $f"
    done
    echo
    echo "-- .github tree --"
    [ -d "$src/.github" ] && (cd "$src/.github" && find . -type f | sort | sed 's|^\./|  |') || echo "  (none)"
    echo
    echo "-- docs tree --"
    [ -d "$src/docs" ] && (cd "$src/docs" && find . -type f | sort | sed 's|^\./|  |' | head -80) || echo "  (no docs/ dir)"
    echo
    echo "-- README badges (shields/actions/sonar) --"
    grep -oE '!\[[^]]*\]\([^)]*\)' "$src/README.md" 2>/dev/null | grep -iE 'shields|badge|actions/workflows|sonar' | sed 's/^/  /' || echo "  (none)"
    echo
    echo "-- README headings --"
    grep -E '^#{1,3} ' "$src/README.md" 2>/dev/null | sed 's/^/  /' || echo "  (no README)"
    echo
    echo "-- README media (images/gifs/video links) --"
    grep -oE '(https?://[^ )"]+\.(gif|png|jpg|jpeg|mp4|webm)|youtu\.?be[^ )"]*|user-attachments/assets/[^ )"]*)' "$src/README.md" 2>/dev/null | sort -u | sed 's/^/  /' || true
    echo
    echo "-- README outbound links (unique hosts) --"
    grep -oE 'https?://[^/ )"]+' "$src/README.md" 2>/dev/null | sort | uniq -c | sort -rn | head -20 | sed 's/^/  /' || true
    echo
    echo "-- GitHub metadata --"
    if command -v gh >/dev/null 2>&1; then
      gh repo view "$repo" --json description,repositoryTopics,homepageUrl,hasDiscussionsEnabled \
        --jq '"  description: \(.description)\n  topics: \([.repositoryTopics[]?.name] | join(", "))\n  homepage: \(.homepageUrl)\n  discussions: \(.hasDiscussionsEnabled)"' 2>/dev/null || echo "  (gh repo view failed)"
      gh release view -R "$repo" --json tagName,publishedAt --jq '"  latest release: \(.tagName) (\(.publishedAt))"' 2>/dev/null || echo "  latest release: (none)"
    else
      echo "  (gh not installed; check description, topics, homepage, Discussions, releases manually)"
    fi
    echo
    echo "-- issue template config --"
    [ -e "$src/.github/ISSUE_TEMPLATE/config.yml" ] && sed 's/^/  /' "$src/.github/ISSUE_TEMPLATE/config.yml" || echo "  (none)"
  } > "$s"

  # copy the readable surfaces for full reading
  for f in README.md CONTRIBUTING.md SECURITY.md ROADMAP.md CHANGELOG.md; do
    [ -e "$src/$f" ] && cp "$src/$f" "$dir/"
  done
  [ -d "$src/.github" ] && cp -r "$src/.github" "$dir/github"
  [ -d "$src/docs" ] && cp -r "$src/docs" "$dir/docs"

  echo "wrote $s"
}

inventory_one "$USER_REPO" "USER PROJECT"
inventory_one "$REF_REPO"  "REFERENCE PROJECT"

echo
echo "Next: read $OUT/*/summary.txt, then both README.md files in full."
echo "Still to read: latest release notes body (gh release view -R <repo>)."
