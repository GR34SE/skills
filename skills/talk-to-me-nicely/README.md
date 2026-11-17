# talk-to-me-nicely

Rules for the messages a coding agent writes to you. The rules are in [SKILL.md](SKILL.md).

## Install

```sh
npx skills add GR34SE/skills --skill talk-to-me-nicely -g
```

## Keep the rules loaded

An agent loads a skill only when it decides the skill fits the task. These rules have to hold for every message, so also load them from your global instructions.

For Claude Code, add this line to `~/.claude/CLAUDE.md`:

```
@~/.claude/skills/talk-to-me-nicely/SKILL.md
```

Codex cannot import a file, so append the rules to `~/.codex/AGENTS.md`:

```sh
awk 'f>=2; /^---$/{f++}' ~/.agents/skills/talk-to-me-nicely/SKILL.md >> ~/.codex/AGENTS.md
```

After you update the skill, delete the old copy from `AGENTS.md` and run the command again.
