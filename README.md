## Skills

```sh
npx skills add GR34SE/skills --skill '*'
```

### [talk-to-me-nicely](skills/talk-to-me-nicely/SKILL.md)

Communication rules for your agent. Replaces defensive, disclaimer-heavy replies with a straight answer and a clear next step.

```sh
npx skills add GR34SE/skills --skill talk-to-me-nicely
```

### [degreaser](skills/degreaser/SKILL.md)

Fight slop code. Checks your code against 18 slop patterns, from swallowed errors to tests that test their own mocks.

```sh
npx skills add GR34SE/skills --skill degreaser
```

A hook stops `gh pr create`, `glab mr create` and `no-mistakes axi run` until the agent has run degreaser on the branch and you have decided every finding it asks about. It works in Claude Code after the command above. Codex and Cursor need the `degreaser` plugin from this repo's marketplace, and Pi needs `pi install git:github.com/GR34SE/skills`.

### [effect-ts-is-king](skills/effect-ts-is-king/SKILL.md)

Maximize use of the Effect API and its ecosystem instead of writing local abstractions.

```sh
npx skills add GR34SE/skills --skill effect-ts-is-king
```
