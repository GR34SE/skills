# talk-to-me-nicely

Rules for the messages a coding agent writes to you. The rules are in [SKILL.md](SKILL.md).

An agent loads a skill only when it decides the skill fits the task. These rules have to hold for every message, so each install below also loads them at the start of every session. If the first reply of a new session does not start with 💭, the rules are not loaded.

## Claude Code

```sh
npx skills add GR34SE/skills --skill talk-to-me-nicely -g
```

The skill folder is also a plugin. Its SessionStart hook prints the rules into every session.

## Codex

```sh
codex plugin marketplace add GR34SE/skills
codex plugin add talk-to-me-nicely@gr34se-skills
```

Then run `codex`, open `/hooks`, and trust the SessionStart hook. Codex asks for that again when an update changes the hook.

## Pi

```sh
pi install git:github.com/GR34SE/skills
```

## Cursor

Open Customize, choose From GitHub Repository, enter `GR34SE/skills`, and install the talk-to-me-nicely plugin.

## Other agents

```sh
npx skills add GR34SE/skills --skill talk-to-me-nicely -g
```

This installs the skill only. To keep the rules loaded, append them to the file your agent reads at the start of every session. The command below does it for OpenCode:

```sh
awk 'f>=2; /^---$/{f++}' ~/.agents/skills/talk-to-me-nicely/SKILL.md >> ~/.config/opencode/AGENTS.md
```

| Agent | File |
|---|---|
| OpenCode | `~/.config/opencode/AGENTS.md` |
| Amp | `~/.config/amp/AGENTS.md` |
| Zed | `~/.config/zed/AGENTS.md` |
| Gemini CLI | `~/.gemini/GEMINI.md` |
| GitHub Copilot CLI | `~/.copilot/copilot-instructions.md` |

After you update the skill, delete the old copy from that file and run the command again.
