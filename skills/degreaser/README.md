# Degreaser

A standalone skill for evidence-based deslop. It reviews 18 aspects, checks the
strongest reason to preserve each candidate, and reports justified findings or
applies fixes when requested. It does not detect AI authorship.

## Install and use

```sh
npx skills add GR34SE/skills --skill degreaser
```

Example requests:

```text
Use degreaser to review my uncommitted changes. Do not edit.
Use degreaser to review this branch against origin/main, including local changes.
Use degreaser to audit src/payments and fix upheld findings.
```

Supply the original task when asking whether changes exceed its scope. Name the
base for a branch review. A repository audit must be explicit; an empty diff
never triggers one.

The skill includes 18 references with 108 contextual REPORT/PRESERVE examples.
It groups inspection into five families while tracking every aspect separately.
Native read-only subagents are optional. Without them, the skill discloses its
sequential self-check.

The optional [scope helper](scripts/scope.sh) needs Bash and Git on macOS/Linux.
It captures final worktree contents using a temporary index, including nonignored
new files, without changing the user's index or refs. It writes Git objects and
local temporary evidence; configured Git clean filters may execute. Use it only
in trusted repositories. See [SKILL.md](SKILL.md) for usage, limitations and the
manual fallback.

This is an instruction library, not a model runner or automated slop detector.
Examples teach decisions; they are not measured evidence of review effectiveness.
There is no dependency on the old CLI, no hooks and no background service.

## Provenance

Adapted from the [Degreaser aspect catalog](https://github.com/GR34SE/degreaser-axi/tree/4d61efc/src/modules/aspect)
and its evidence/refutation workflow. This skill owns its own guidance and is
not generated from or synchronized with that CLI. MIT, see [LICENSE](LICENSE).
