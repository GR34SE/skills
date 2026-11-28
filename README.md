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

### [effect-ts-is-king](skills/effect-ts-is-king/SKILL.md)

Maximize use of the Effect API and its ecosystem instead of writing local abstractions.

```sh
npx skills add GR34SE/skills --skill effect-ts-is-king
```

### [rip-van-winkle](skills/rip-van-winkle/SKILL.md)

No legacy APIs or syntax in new code. Makes the agent look up the current LTS, stable versions, built-in APIs and language features before it writes, instead of trusting training data.

```sh
npx skills add GR34SE/skills --skill rip-van-winkle
```

Hooks remind the agent to load the skill at the start of a session and when it installs a package, scaffolds a project or writes a manifest. Claude Code loads them from a global install (add `-g` to the command above), or from a project install in a folder you trust. Codex and Cursor also need the `rip-van-winkle` plugin from this repo's marketplace, and Codex asks you to approve the hooks in `/hooks`. On a Cursor plan without team marketplaces, copy `skills/rip-van-winkle` to `~/.cursor/plugins/local/`. Pi gets the skill and the hooks from `pi install git:github.com/GR34SE/skills`.
