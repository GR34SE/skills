# Unjustified defense

**Question:** Can the rejected state actually occur on this path?

**Applies when:** Validation, type/null guards, error handlers or retry are added
around data or operations.

## Inspect and decide

1. Trace all relevant entries and upstream guarantees, not just static types.
2. Check mutation, asynchronous gaps, external rereads and new consumers between
   supposedly duplicate checks.
3. Report a redundant guard only when its rejected state cannot occur on that
   path. Name the unnecessary branch, traversal or handler it creates.
4. Preserve network, disk, trust, public runtime API and concurrency boundaries.
   A type annotation does not establish runtime validity.

## Route elsewhere

- What actual error handling returns: `masked-errors`.
- Missing validation concealed by a cast/default: `contract-bypass`.
- Excess main logic rather than checks: `unnecessary-complexity`.

## Teaching examples

Contexts supply omitted facts. Excerpts are not executed tests.

### unjustified-defense-B1 · REPORT

Context: The only internal caller has just parsed this object with the same
schema, and no mutation or asynchronous gap intervenes.

```typescript
function total(order: Order) {
  OrderSchema.parse(order);
  return order.lines.reduce((sum, line) => sum + line.amount, 0);
}
```

Decision: The repeated traversal establishes no new guarantee on this closed path.

### unjustified-defense-B2 · REPORT

Context: Inspection of the private producer shows it always returns a list.
There are no external inputs or alternate callers between producer and consumer.

```python
rows = parse_rows(validated_input)
if not isinstance(rows, list):
    raise TypeError("rows")
return summarize(rows)
```

Decision: The guard defends against an impossible producer result, not a boundary.

### unjustified-defense-B3 · REPORT

Context: The local variable is unchanged between these adjacent statements.

```typescript
if (account === null) return null;
if (account !== null) return account.name;
```

Decision: The second predicate repeats an established branch condition.

### unjustified-defense-G1 · PRESERVE

Context: The request comes from the network; a declared payload type does not
validate its actual bytes.

```typescript
const raw = await request.text();
await verifySignature(raw, request.headers);
return handle(EventSchema.parse(JSON.parse(raw)));
```

Decision: Authentication and shape validation protect real input boundaries.

### unjustified-defense-G2 · PRESERVE

Context: JavaScript clients also call this public TypeScript export.

```typescript
export function setCapacity(value: number) {
  if (!Number.isInteger(value) || value < 1) throw new RangeError("capacity");
  capacity = value;
}
```

Decision: Static typing does not protect external runtime callers.

### unjustified-defense-G3 · PRESERVE

Context: The first check rejects a stale client version. The conditional write
raises on races after that read.

```python
if current.version != expected_version:
    raise Conflict()
save_if_version_matches(current, expected_version)
```

Decision: The early check and atomic write cover different possible stale states.
