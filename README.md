# skills

Skills for coding agents.

- [talk-to-me-nicely](skills/talk-to-me-nicely): rules for how the agent writes to you. The answer comes first, messages are short and in full plain sentences, and open work ends with who does what next.

## Install

```sh
npx skills add GR34SE/skills --skill <name>
```

Or copy this prompt into your coding agent:

```text
Install a skill from GR34SE/skills. Read https://raw.githubusercontent.com/GR34SE/skills/main/README.md and ask me which skill I want. Then read skills/<name>/README.md in the same repo and follow the prompt in its Install section.
```

## Checks

Run `npm test` with Node.js 22 or later. The offline tests execute the shared hooks and Pi extension and check Cursor's native rule configuration without calling a model. Cursor's configuration test checks that the plugin selects only the canonical `SKILL.md`, marks it always-applied, and disables automatic skill and hook discovery. It rejects a return to asynchronous session-start delivery but does not exercise Cursor's request builder.
