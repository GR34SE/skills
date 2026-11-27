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

In Claude Code, a hook blocks shell commands that contain `gh pr create`, `gh pr new`, `gh-axi pr create` or `no-mistakes axi run` until the agent adds the comment `# degreaser-done` to confirm that it ran degreaser on the branch.

### [effect-ts-is-king](skills/effect-ts-is-king/SKILL.md)

Maximize use of the Effect API and its ecosystem instead of writing local abstractions.

```sh
npx skills add GR34SE/skills --skill effect-ts-is-king
```
