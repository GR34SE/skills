# Stale references

**Question:** Did the change make repository text false or silently drop an
unrevoked rule or its reason?

**Applies when:** Names, paths, flags, commands, environment variables, exports,
configuration keys, values, enumerated sets or documented behavior change; also
when documentation, help, prompts or instructions are rewritten. In an audit,
compare existing assessed text with its current implementation.

## Inspect and decide

1. List changed/removed names, paths, values, behavior and rules.
2. Search old forms in documentation, comments, help, examples, descriptive
   configuration, skills and instructions. Check links and anchors too.
3. Read matches in context. Establish the same referent, not a homonym, independent
   timeout or fixture deliberately pinning an older form.
4. Check mirrored values/counts, supposedly exhaustive lists and omitted members.
   For rewrites, compare old rules and reasons with the new wording and task.
5. Stale text outside the assessed paths still counts when the assessed
   change made it false. Correct every occurrence one change caused together
   where the edit scope (path filter, worker slice) allows it; raise the rest
   under “Your call”.

Report false text, broken targets and dropped unrevoked rules. Preserve dated
history, migration explanations, still-working aliases and independent copies.
A rephrased rule survives if its meaning and reason remain. Report a generator
rather than its output unless stale committed output itself ships. An audit has
no old side, so it cannot establish dropped historical rules.

A search without matches proves little until it covers every old form of the
name and every root where such text lives. External websites are not repository
evidence.

## Route elsewhere

- Code/tool-consumed exports, registrations, paths and keys: `incomplete-integration`.
- Accurate narration rather than false text: `low-value-comments`.
- Unrequested additions rather than dropped rules: `scope-creep`.

## Teaching examples

Contexts supply omitted facts. Excerpts are not executed tests.

### stale-references-B1 · REPORT

Context: Startup now accepts only `DATABASE_URL`. The setup guide tells users
to copy the unchanged `.env.example` below.

```sh
APP_DATABASE=postgres://localhost/app
```

Decision: Setup supplies a name no longer read. Anchor in the assessed rename
and cite this stale example even if its file was not changed.

### stale-references-B2 · REPORT

Context: The change raises the same request timeout to sixty seconds, but help
still describes its old value.

```typescript
export const REQUEST_TIMEOUT_SECONDS = 60;
const help = "Requests time out after 30 seconds.";
```

Decision: These refer to one setting. Update or derive the human-facing statement.

### stale-references-B3 · REPORT

Context: The task only asks to shorten instructions. No replacement preserves
the branch rule or its reason.

```markdown
Before: Use a PR, because direct commits bypass review. Run tests.
After: Run tests.
```

Decision: Restore the unrevoked rule and reason; shorter wording did not authorize
their removal.

### stale-references-G1 · PRESERVE

Context: The current version removed `--old-format`. These are dated release notes.

```markdown
- 3.0: Removed --old-format; migrate to --format legacy.
- 2.1: Added --old-format.
```

Decision: Historical statements and migration advice remain truthful.

### stale-references-G2 · PRESERVE

Context: An HTTP timeout changed from thirty to sixty seconds. The queue's
visibility timeout has a separate contract.

```typescript
const QUEUE_VISIBILITY_SECONDS = 30;
```

Decision: A matching old literal is not a mirrored setting.

### stale-references-G3 · PRESERVE

Context: A shortening task merges two instructions without changing their meaning.

```markdown
Before: Use pull requests. Direct commits skip review.
After: Use pull requests because direct commits skip review.
```

Decision: Both obligation and rationale survive; a deleted line is not itself
a lost rule.
