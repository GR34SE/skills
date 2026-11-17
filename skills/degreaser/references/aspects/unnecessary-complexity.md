# Unnecessary complexity

**Question:** Can fewer mechanisms meet every actual requirement?

**Applies when:** Implementation logic changes: algorithms, control flow, state or
transformations. Documentation, formatting and configuration values alone do not
qualify. In an audit, inspect existing implementation.

## Inspect and decide

1. Name the extra state, phases, collections, passes, callbacks or concurrency.
2. Describe a concrete simpler implementation, not “simplify this.”
3. Compare results, ordering, errors, side effects, concurrency, resource limits
   and public contracts. Read the affected callers.
4. Report only when the alternative preserves those requirements and removes
   a named maintenance cost. Preserve domain complexity, measured constraints
   and required conventions. Moving complexity elsewhere is not simplification.

## Route elsewhere

- Behaviorless boundary: `unnecessary-layers`.
- Unused option: `speculative-flexibility`.
- Divergent consumers sharing policy: `wrong-abstraction`.
- Expression-level native replacement: `unidiomatic-code`.
- Added responsibilities/coupling: `structural-erosion`.
- Redundant guards: `unjustified-defense`.
- An accessible existing equivalent: `missed-reuse`.

## Teaching examples

Contexts supply omitted facts. Excerpts are not executed tests.

### unnecessary-complexity-B1 · REPORT

Context: This one-shot operation cannot resume or retry, and nobody observes its phase.

```typescript
let step = 0;
while (step < 3) {
  if (step === 0) await load();
  if (step === 1) await validate();
  if (step === 2) await publish();
  step++;
}
```

Decision: Three consecutive awaited calls preserve order and rejection while
removing a counter and loop that encode no requirement.

### unnecessary-complexity-B2 · REPORT

Context: A basket has at most twelve lines; its count is read only on display.
Every other mutation of `lines` must update `count` as well.

```python
def add(self, line):
    self.lines.append(line)
    self.count += 1
```

Decision: Derive `len(self.lines)` when displayed. Maintaining the duplicate
count creates a synchronization obligation without a resource justification.

### unnecessary-complexity-B3 · REPORT

Context: IDs are unique. The caller wants only whether any task is overdue.

```typescript
const byId = new Map(tasks.map(task => [task.id, task]));
const ids = [...byId.keys()].sort();
return ids.some(id => byId.get(id)!.due < now);
```

Decision: Inspect tasks directly. Indexing and sorting serve neither the boolean
result nor an ordering requirement and add allocations and lookups.

### unnecessary-complexity-G1 · PRESERVE

Context: A job resumes after crashes, records completed stages, and each stage
is idempotent under the job ID.

```typescript
if (job.phase === "fetch") {
  await fetchChunk(job.id);
  await checkpoint(job.id, "import");
}
```

Decision: The persisted phase avoids replay of checkpointed work. A plain
sequence would lose resume semantics; idempotency covers pre-checkpoint crashes.

### unnecessary-complexity-G2 · PRESERVE

Context: An append-only ledger contains millions of entries. Measured latency
exceeds the documented target if every balance request sums all entries.

```python
def append(self, entry):
    self.entries.append(entry)
    self.balance += entry.amount
```

Decision: Maintained state serves a measured requirement with one mutation path.
Do not replace it with an unbounded read-time sum.

### unnecessary-complexity-G3 · PRESERVE

Context: Gregorian leap-year behavior is required, including century exceptions.

```typescript
return year % 400 === 0 || (year % 4 === 0 && year % 100 !== 0);
```

Decision: Each condition represents a rule. Keeping only divisibility by four
would incorrectly accept 1900; fewer conditions would not preserve behavior.
