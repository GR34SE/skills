# skills

Agent skills in the [Agent Skills](https://agentskills.io) format, installed with the [skills CLI](https://skills.sh).

## talk-to-me-nicely

Rules for the messages a coding agent writes to you. The skill changes how the agent reports, not how it works.

With the rules loaded, every message:

- starts with 💭, so a message without it tells you the agent has lost the rules
- gives the answer or the current state in the first sentence
- stays within 80 words, or 150 words for a report on several items, unless you ask for detail
- uses full sentences that name who acts, in everyday words, with no bold, em-dashes, or semicolons
- ends open work with a numbered list of who does what next and when

The skill also defines "in simple terms", "un-condense", and "cut the jargon", so the agent rewrites its answer without asking what you mean.

All 24 rules are in [SKILL.md](skills/talk-to-me-nicely/SKILL.md).

### Install

```sh
npx skills add GR34SE/skills --skill talk-to-me-nicely -g
```

### Keep the rules loaded

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

### Sources

The rules draw on these four projects:

- [GOV.UK style skill](https://gist.github.com/fofr/505e225f9bf5e839d30c12ba6bfa0be2) by fofr
- [i-have-adhd](https://github.com/ayghri/i-have-adhd) by ayghri
- [SimpleEnglish](https://github.com/AminBlg/SimpleEnglish) by AminBlg
- [the-elements-of-style](https://github.com/obra/the-elements-of-style) by obra
