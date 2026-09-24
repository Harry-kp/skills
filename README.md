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

## Adding a skill

```
skills/harry-kp-<kebab-case-name>/
  SKILL.md        # frontmatter: name (matches folder, always `harry-kp-` prefixed), description (what + when to use)
  ...             # optional scripts/, references/, assets/
```

## License

MIT
