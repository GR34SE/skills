# skills

Skills for coding agents.

- [talk-to-me-nicely](skills/talk-to-me-nicely/SKILL.md): Communication rules for your agent. Replaces defensive, disclaimer-heavy replies with a straight answer and a clear next step.
- [degreaser](skills/degreaser/SKILL.md): Fight slop code. Checks your code against 18 slop patterns, from swallowed errors to tests that test their own mocks.

## Install

All skills:

```sh
npx skills add GR34SE/skills --skill '*'
```

One skill:

```sh
npx skills add GR34SE/skills --skill talk-to-me-nicely
npx skills add GR34SE/skills --skill degreaser
```

Or copy this prompt into your coding agent:

```text
For talk-to-me-nicely, its rules must load at the start of every session. Say which coding agent you are, then do only the matching step:
- Claude Code: run `npx skills@latest add GR34SE/skills --skill talk-to-me-nicely -g -a claude-code -y`
- Codex: run `codex plugin marketplace add GR34SE/skills`, then `codex plugin add talk-to-me-nicely@gr34se-skills`. Then ask me to open /hooks and trust the SessionStart hook.
- Pi: run `pi install git:github.com/GR34SE/skills`
- Cursor: ask me to open Customize, choose From GitHub Repository, enter GR34SE/skills, and install the talk-to-me-nicely plugin.
For any other skill, run `npx skills@latest add GR34SE/skills --skill <name>`.

If a command fails, stop and show me the error. Do not change any other setting.
```
