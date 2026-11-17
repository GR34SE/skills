# skills

Skills for coding agents.

- [talk-to-me-nicely](skills/talk-to-me-nicely): rules for how the agent writes to you. The answer comes first, messages are short and in full plain sentences, and open work ends with who does what next.
- [degreaser](skills/degreaser/SKILL.md): find unnecessary code, hidden failures, misleading tests and redundant comments; explain each finding and preserve required behavior.

## Install

```sh
npx skills add GR34SE/skills --skill <name>
```

Or copy this prompt into your coding agent:

```text
Install a skill from GR34SE/skills. Read https://raw.githubusercontent.com/GR34SE/skills/main/README.md and ask me which skill I want. If skills/<name>/README.md in the same repo has an Install section, follow its prompt. Otherwise run `npx skills add GR34SE/skills --skill <name>`.
```
