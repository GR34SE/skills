# skills

Skills for coding agents.

| Skill | What it does | Install |
| --- | --- | --- |
| [talk-to-me-nicely](skills/talk-to-me-nicely/SKILL.md) | Communication rules for your agent. Replaces defensive, disclaimer-heavy replies with a straight answer and a clear next step. | `npx skills add GR34SE/skills --skill talk-to-me-nicely` |
| [degreaser](skills/degreaser/SKILL.md) | Fight slop code. Checks your code against 18 slop patterns, from swallowed errors to tests that test their own mocks. | `npx skills add GR34SE/skills --skill degreaser` |

Install all of them:

```sh
npx skills add GR34SE/skills --skill '*'
```
