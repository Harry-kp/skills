# skills

General-purpose agent skills I use across my repos. Each skill is a folder under [`skills/`](skills) with a `SKILL.md` ([Agent Skills](https://agentskills.io) format), so it works with any agent that supports skills.

## Install

**Any agent (Claude Code, Codex, Cursor, Gemini CLI, Copilot, OpenCode, Windsurf, and more):**

```sh
npx skills add Harry-kp/skills
```

Pick skills interactively, or add `--skill <name>` for one, `-g` for global, `-a <agent>` to target one agent.

**No Node? One-liner:**

```sh
curl -fsSL https://raw.githubusercontent.com/Harry-kp/skills/main/install.sh | sh
```

Installs every skill globally into `~/.agents/skills` and into each agent it finds (`~/.claude`, `~/.codex`, `~/.cursor`, `~/.gemini`, `~/.copilot`, `~/.config/opencode`, `~/.windsurf`). Only want some?

```sh
curl -fsSL https://raw.githubusercontent.com/Harry-kp/skills/main/install.sh | sh -s -- skill-a skill-b
```

**Claude Code plugin:**

```
/plugin marketplace add Harry-kp/skills
/plugin install harry-kp@harry-kp-skills
```

Re-run any of these to update.

## Skills

| Skill | What it does |
|-------|--------------|
| [`harry-kp-agent-ready-repo`](skills/harry-kp-agent-ready-repo/SKILL.md) | Audit and simplify any repo (flatten, dedupe to one source of truth, delete dead code) with an approval gate, then write a verified CLAUDE.md / AGENTS.md so agents can work in it autonomously |
| [`harry-kp-benchmark-repo-presentation`](skills/harry-kp-benchmark-repo-presentation/SKILL.md) | Compare your repo's README, docs, install story and community files against a project you admire; returns a short borrow list filtered by upkeep cost for a small team, plus what to skip |
| [`harry-kp-distill-session-learnings`](skills/harry-kp-distill-session-learnings/SKILL.md) | At the end of a session, keep only the durable, non-obvious lessons and write them into the right place (CLAUDE.md / AGENTS.md, a skill, or memory), pruning stale lines while there |
| [`harry-kp-qa-like-a-user`](skills/harry-kp-qa-like-a-user/SKILL.md) | Drive your app the way a real user would (web, TUI, CLI, desktop, mobile, API): every screen, workflow and edge case, then a functional, logic, UX/UI and missing-feature report with evidence (confusing theme, over-complex workflows, needless UI), and fixes on request |

## Adding a skill

```
skills/harry-kp-<kebab-case-name>/
  SKILL.md        # frontmatter: name (matches folder, always `harry-kp-` prefixed), description (what + when to use)
  ...             # optional scripts/, references/, assets/
```

## License

MIT
