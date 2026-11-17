# Structural erosion

**Question:** Does the change couple responsibilities, dependencies or state
that should remain separate?

**Applies when:** An existing function, class or module gains responsibilities,
branches or state; in an audit, inspect current coupling.

## Inspect and decide

1. Read changed hunks and the whole affected unit.
2. Name the responsibilities now coupled and their concrete cost, such as a
   storage test needing mail-transport mocks.
3. Propose a restored ownership boundary, not the same complexity spread into files.
4. Report coupling introduced/worsened by the change, not unrelated old debt.
   Preserve coherent lifecycle orchestration and domain dispatch. Length and
   complexity metrics are clues, never sufficient evidence.

## Route elsewhere

- Excess mechanism within one responsibility: `unnecessary-complexity`.
- Copying an existing mechanism: `missed-reuse`.
- Divergent cases joined by one shared policy: `wrong-abstraction`.
- Format/naming drift without coupling: `convention-drift`.

## Teaching examples

Contexts supply omitted facts. Excerpts are not executed tests.

### structural-erosion-B1 · REPORT

Context: A new partner policy adds distant interdependent exceptions to billing
and response rendering inside an already mixed procedure.

```typescript
if (user.partner) waiveFee = true;
// Existing transport and formatting occupy the intervening code.
if (user.partner) response.mode = "partner";
if (waiveFee && response.mode !== "partner") retryBilling();
```

Decision: One policy now depends on distant mutable states. Restore policy
ownership rather than adding another scattered exception.

### structural-erosion-B2 · REPORT

Context: The repository previously only persisted invoices. This method makes
its tests require both renderer and email-transport mocks.

```typescript
async save(invoice: Invoice) {
  await this.database.insert(invoice);
  await mailer.send(invoice.email, renderPdf(invoice));
}
```

Decision: Persistence now owns notification and presentation dependencies.

### structural-erosion-B3 · REPORT

Context: Partial retries must never persist, even for forced legacy operations.
New transport and billing rules both mutate the persistence decision.

```typescript
let saveResult = true;
if (retry && partial) saveResult = false;
if (legacy && forced) saveResult = true;
if (saveResult) await persist(result);
```

Decision: Billing overrides transport when all four conditions hold. Resolve
the policies before the persistence boundary.

### structural-erosion-G1 · PRESERVE

Context: A new valid state extends a single coherent dispatch with separate handlers.

```typescript
switch (job.state) {
  case "ready": return start(job);
  case "paused": return resume(job);
  case "done": return report(job);
}
```

Decision: An additional domain case does not itself create scattered responsibility.

### structural-erosion-G2 · PRESERVE

Context: This large file is generated protocol data, not hand-maintained control flow.

```python
ERROR_LABELS = {1001: "missing", 1002: "unsupported"}
```

Decision: File length alone does not establish structural erosion.

### structural-erosion-G3 · PRESERVE

Context: Empty input is a new valid case handled before the ordinary report path.

```typescript
if (rows.length === 0) return emptyReport();
return buildReport(rows);
```

Decision: The local guard makes subsequent assumptions simpler without spreading
an exception across responsibilities.
