# Scope creep

**Question:** Which added feature, permission or refactoring is not required
by the user's task?

**Applies when:** A concrete task supplies feature scope. A repository audit or
generic “review my changes” without an original feature task is not applicable.

## Inspect and decide

1. Read the actual task and acceptance criteria; never infer them from the diff.
2. Enumerate added capabilities, permissions and refactorings individually.
3. Trace necessary implementation dependencies before judging something unrelated.
4. Report an addition by citing both the task boundary and the unjustified change.
   Preserve requested migrations, necessary shared-code edits and regression tests.
   Diff size alone does not establish excess scope.

## Route elsewhere

- Required code disconnected from its path: `incomplete-integration`.
- Internal variants without consumers: `speculative-flexibility`.
- Rules silently removed from rewritten text: `stale-references`.

## Teaching examples

Contexts supply omitted facts. Excerpts are not executed tests.

### scope-creep-B1 · REPORT

Context: The task is to sort the user list. Guest export permissions are unrelated.

```typescript
const rows = sortUsers(users);
policy.guestsCanExport = true;
```

Decision: The new permission is a separate product decision, not a sorting dependency.

### scope-creep-B2 · REPORT

Context: The task fixes date formatting in an existing CSV endpoint.

```python
@route("/export.xml")
def export_xml():
    return build_xml()
```

Decision: A new format and endpoint exceed the supplied task.

### scope-creep-B3 · REPORT

Context: Fixing one validator does not require changing project-wide formatting.
The change reformats thousands of unrelated lines.

```javascript
export default { printWidth: 160 };
```

Decision: Unrelated configuration and churn add review cost without serving the fix.

### scope-creep-G1 · PRESERVE

Context: The task adds NDJSON import; the endpoint's existing shared parser owns
content-type dispatch.

```typescript
case "application/x-ndjson": return parseNdjson(body);
```

Decision: Editing shared code is necessary to implement the requested behavior.

### scope-creep-G2 · PRESERVE

Context: Acceptance criteria explicitly require migrating every existing client.

```python
for client in existing_clients:
    migrate(client)
```

Decision: Breadth follows the task, not unauthorized initiative.

### scope-creep-G3 · PRESERVE

Context: The bug is that parsing `"0.25"` yields 2 rather than 25 cents.
The change fixes the parser and adds this regression assertion.

```typescript
assert.equal(parseCents("0.25"), 25);
```

Decision: A focused regression test protects the requested correction.
