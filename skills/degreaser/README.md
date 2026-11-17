# Degreaser

A skill for finding and removing code slop: unnecessary mechanisms, hidden
failures, disconnected changes, tests that do not check what they claim, and
comments that repeat the code. It reviews code against the task and its consumers,
not against a guess about whether AI wrote it. It edits only when asked.

## How it recognizes slop

The skill teaches 18 categories of defects through inspection rules and paired
examples of code to report and code to preserve. The distinction depends on
context: a fallback can conceal a required operation's failure or legitimately
degrade an optional feature. Its mere presence does not settle the question.

For each candidate, the agent must establish the required behavior, trace what
the code actually contributes, explain the mismatch or unnecessary cost, and
propose a correction that preserves requirements. It then checks whether a
consumer, contract or constraint disproves that correction. Missing evidence
stays an uncertainty, not a reason to remove code.

## Install and use

```sh
npx skills add GR34SE/skills --skill degreaser
```

Example requests:

```text
Use degreaser to deslop the changes we just made.
Use degreaser to review my uncommitted changes. Do not edit.
Use degreaser to review this branch against origin/main, including local changes.
Use degreaser to audit src/payments and fix upheld findings.
```

The agent takes the task and review scope from your request and the session.
You do not need to repeat context it already has. It asks only when a consequential
detail is unclear, such as the base for a branch comparison. An empty diff never
triggers a repository audit.

The references contain 108 contextual REPORT/PRESERVE examples. Inspection covers
structure, hidden errors and ineffective checks, integration, reuse and local
conventions, and comments. Native read-only subagents are optional. Without them,
the agent checks its own findings in a second pass and reports that this was not
an independent review.

This is an instruction library, not a model runner or automated slop detector.
Examples teach decisions; they are not measured evidence of review effectiveness.
It uses the agent's existing tools to read code and inspect changes. There are no
bundled scripts, hooks, background services or dependencies on the old CLI.

## Provenance

Adapted from the [Degreaser aspect catalog](https://github.com/GR34SE/degreaser-axi/tree/4d61efc/src/modules/aspect)
and its evidence/refutation workflow. This skill owns its own guidance and is
not generated from or synchronized with that CLI.

### MIT notice for adapted material

MIT License

Copyright (c) 2026 Degreaser contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
