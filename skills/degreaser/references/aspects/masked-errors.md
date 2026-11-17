# Masked errors

**Question:** Does an actual failure become apparent success or expected absence?

**Applies when:** Code catches, ignores or translates errors, failed statuses or
unsuccessful results.

## Inspect and decide

1. Trace the original error through the handler and public result.
2. Inspect the consumer's branch and contract. Check cancellation, timeouts,
   corrupt state and unavailable evidence separately from expected absence.
3. Report the observable contradiction. Logging does not repair a false result.
4. Preserve explicitly permitted degradation, correct domain error translation,
   sanitized diagnostics with visible failure, and retries that propagate failure.
   Do not demand disclosure of sensitive underlying messages.

## Route elsewhere

- Whether a guard/handler is needed: `unjustified-defense`.
- A cast or missing-data default without an actual error: `contract-bypass`.

## Teaching examples

Contexts supply omitted facts. Excerpts are not executed tests.

### masked-errors-B1 · REPORT

Context: Success promises durable storage; persistence errors are not optional.

```typescript
try { await persist(invoice); }
catch { return { saved: true }; }
```

Decision: The consumer receives a storage guarantee after storage failed.

### masked-errors-B2 · REPORT

Context: A report may claim zero pending transfers only after reading the bank.

```python
try:
    transfers = bank.pending()
except BankUnavailable:
    transfers = []
return len(transfers)
```

Decision: Unknown data becomes a confirmed zero, misleading report consumers.

### masked-errors-B3 · REPORT

Context: `lookup` returns null only for missing users and rejects on service
failure. The caller deletes local accounts when it receives `notFound()`.

```typescript
const user = await lookup(id).catch(() => null);
if (user === null) return notFound();
```

Decision: A temporary outage becomes evidence that an account does not exist.

### masked-errors-G1 · PRESERVE

Context: Related articles are optional; the response contract exposes degradation.

```typescript
try { return { articles: await related(), degraded: false }; }
catch { return { articles: [], degraded: true }; }
```

Decision: The response truthfully distinguishes degraded service from full success.

### masked-errors-G2 · PRESERVE

Context: A seat conflict is an expected domain outcome, not a successful booking.

```python
try:
    book(seat)
except SeatTaken:
    return {"status": "conflict"}
```

Decision: Translation preserves failure to book rather than concealing it.

### masked-errors-G3 · PRESERVE

Context: A required read permits one retry. The second rejection reaches the caller.

```typescript
try { return await readReport(); }
catch { return await readReport(); }
```

Decision: Retrying is not masking. Assess retry policy separately if necessary.
