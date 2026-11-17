# talk-to-me-nicely

Rules for the messages a coding agent writes to you. The rules are in [SKILL.md](SKILL.md).

## Install

```sh
npx skills add GR34SE/skills --skill talk-to-me-nicely
```

This installs the skill. An agent loads a skill only when it decides the skill fits the task, and these rules have to hold for every message. To also load them at the start of every session, copy this prompt into your coding agent:

```text
Install the talk-to-me-nicely skill from GR34SE/skills so that its rules load at the start of every session.

1. Say which coding agent you are, then do only the matching step:
   - Claude Code: run `npx skills@latest add GR34SE/skills --skill talk-to-me-nicely -g -a claude-code -y`
   - Codex: run `codex plugin marketplace add GR34SE/skills`, then `codex plugin add talk-to-me-nicely@gr34se-skills`. Then ask me to open /hooks and trust the SessionStart hook.
   - Pi: run `pi install git:github.com/GR34SE/skills`
   - Cursor: ask me to open Customize, choose From GitHub Repository, enter GR34SE/skills, and install the talk-to-me-nicely plugin.
   - Any other agent: run `npx skills@latest add GR34SE/skills --skill talk-to-me-nicely -g`. Then append the rules from the installed SKILL.md, without its frontmatter, to the instructions file you read at the start of every session. Show me that file's path and wait for my yes before you write to it.
2. If a command fails, stop and show me the error. Do not change any other setting.
3. Tell me to start a new session. Its first reply should start with 💭.
```

Then start a new session and ask:

```text
In two sentences, which rules do you follow when you write to me?
```

The reply should start with 💭.
