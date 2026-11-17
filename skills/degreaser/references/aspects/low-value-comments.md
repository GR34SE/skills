# Low-value comments

**Question:** Which specific maintenance or usage trap does this comment prevent
that the code and connected callers cannot reveal?

**Applies when:** Explanatory comments/docstrings are added or edited; existing
ones also apply in an audit. **Unit:** every explanatory comment or docstring.

## Inspect and decide

1. Start with zero explanatory comments. Read each assessed comment alongside
   implementation, types, names and connected callers, including short summaries
   on public functions, constants and fields.
2. For preservation, identify a tempting wrong change/use, its concrete consequence
   and the hidden fact the comment supplies. Verify that fact against source or
   an established external contract; the comment's own claim is not proof.
3. If no trap remains, report removal and show what is recoverable or irrelevant.
   Redundant narration itself is the defect; it need not cause a runtime bug.
4. If a real warning is buried in narration, retain only that warning. Correct an
   inaccurate warning rather than preserving it because it sounds important.

Public visibility, JSDoc, brevity, security vocabulary, complexity and usefulness
as a summary are not exemptions. Visible conversions and errors remain visible.
Prefer clearer names/types or simpler code where appropriate, but do not invent
an abstraction solely to eliminate a comment.

Keep legally required notices and machine-consumed directives as operational
content; verify their requirement/consumer before proposing removal. If a prose
documentation rule conflicts, recommend reconciling the rule, not silently
breaking its check. Deliberately bad teaching examples are fixtures, not cleanup
targets. Unavailable external evidence means uncertainty, not proof a warning is
false. Inspect repeated occurrences individually and retain each location.

## Route elsewhere

- Suppression effects (`@ts-ignore`, `type: ignore`, lint directives):
  `contract-bypass`. Adjacent explanatory prose still faces this trap test.
- Text made false by a change: `stale-references`.

## Teaching examples

Contexts supply omitted facts. Excerpts are not executed tests.

### low-value-comments-B1 · REPORT

Context: Implementation and callers are available; no hidden external rule changes
what these operations mean.

```typescript
// Remove the expired entry, then check whether it exists.
if (entry.expires < now) entries.delete(id);
return entries.has(id);
```

Decision: Delete the narration. It supplies no fact unavailable from the code.

### low-value-comments-B2 · REPORT

Context: This is a public export, but no tool consumes the docstring and no external
condition changes its behavior.

```typescript
/** Return cents; throw for a negative count. */
export function totalCents(unitCents: number, count: number) {
  if (count < 0) throw new RangeError("count");
  return unitCents * count;
}
```

Decision: Units and the error are already explicit. Public visibility does not
create a hidden trap.

### low-value-comments-B3 · REPORT

Context: An external importer rejects non-UTC date formats. The row type exposes
only a string, not that restriction.

```typescript
// Copy the ID and format the date. The importer rejects locale dates;
// keep the UTC ISO timestamp.
return { id: row.id, date: row.date.toISOString() };
```

Decision: Remove narration, retain the importer warning. Do not delete the
external constraint along with the redundant opening.

### low-value-comments-G1 · PRESERVE

Context: The vendor contract establishes silent truncation after fifty IDs; its
request schema accepts arbitrary array lengths.

```typescript
// The vendor drops IDs after the first 50; larger batches lose work.
const batchSize = 50;
```

Decision: The warning prevents a plausible optimization from silently losing work.

### low-value-comments-G2 · PRESERVE

Context: The library contract says closing the transport discards acknowledged
messages still buffered internally. Names alone do not expose that lifetime rule.

```go
// Close discards acknowledged buffered messages; drain first to avoid loss.
queue.Drain()
transport.Close()
```

Decision: The warning supplies an external fact needed to avoid a dangerous reorder.

### low-value-comments-G3 · PRESERVE

Context: A native binding retains this buffer by reference until flush, but its
signature and wrapper do not disclose ownership.

```typescript
// The binding retains the buffer until flush; reuse corrupts queued frames.
native.send(buffer);
```

Decision: The warning prevents unsafe reuse for a reason absent from code/types.
