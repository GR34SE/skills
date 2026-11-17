# talk-to-me-nicely

Rules for the messages a coding agent writes to you. The rules are in [SKILL.md](SKILL.md).

## Install

```sh
npx skills add GR34SE/skills --skill talk-to-me-nicely -g
```

## Keep the rules loaded

An agent loads a skill only when it decides the skill fits the task. These rules have to hold for every message, so they have to load at the start of every session.

Claude Code needs nothing more after a global install. The skill folder is also a plugin, and its SessionStart hook prints the rules into every new session. If the first reply of a new session does not start with 💭, add this line to `~/.claude/CLAUDE.md`:

```
@~/.claude/skills/talk-to-me-nicely/SKILL.md
```

Codex does not run that hook and cannot import a file, so append the rules to `~/.codex/AGENTS.md`:

```sh
awk 'f>=2; /^---$/{f++}' ~/.agents/skills/talk-to-me-nicely/SKILL.md >> ~/.codex/AGENTS.md
```

After you update the skill, delete the old copy from `AGENTS.md` and run the command again.
