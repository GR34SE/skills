# Unnecessary layers

**Question:** What necessary behavior or boundary does this layer provide?

**Applies when:** Wrappers, services, factories, adapters, interfaces, re-exports
or delegating classes are introduced or extended.

## Inspect and decide

1. Trace the caller through the layer to the implementation.
2. Check external consumers, public APIs, current DI seams, transactions, model
   mappings and domain boundaries.
3. Describe where ownership and dependencies would move if the layer disappeared.
4. Report navigation/contract overhead only when removal preserves those boundaries.
   A short function can own an important contract. Inlining that exposes another
   domain's internals merely moves complexity.

## Route elsewhere

- Excess machinery inside an implementation: `unnecessary-complexity`.
- Unused variants or extension points: `speculative-flexibility`.
- Shared layers coupling conflicting consumers: `wrong-abstraction`.

## Teaching examples

Contexts supply omitted facts. Excerpts are not executed tests.

### unnecessary-layers-B1 · REPORT

Context: This internal manager is not a public boundary or DI seam. Every caller
already knows the service and gets no additional policy.

```typescript
class AccountManager {
  constructor(private service: AccountService) {}
  get(id: string) { return this.service.get(id); }
}
```

Decision: Direct service calls remove a type and navigation step without losing
behavior or ownership.

### unnecessary-layers-B2 · REPORT

Context: One parser exists, with no selection, initialization or public factory
contract. No caller substitutes it.

```python
class ParserFactory:
    def create(self):
        return LineParser()
```

Decision: Construct the parser directly; the factory makes no decision.

### unnecessary-layers-B3 · REPORT

Context: Both new interfaces describe the same internal adapter under one owner.
No port/gateway convention or separate consumer contract applies.

```typescript
interface ReaderPort { read(id: string): Promise<Record> }
interface ReaderGateway { read(id: string): Promise<Record> }
```

Decision: Two names duplicate a synchronization obligation without a boundary.

### unnecessary-layers-G1 · PRESERVE

Context: Vendor naming must not leak into a stable domain model.

```typescript
async function findAccount(id: string): Promise<Account> {
  const raw = await vendor.lookup(id);
  return { id: raw.account_id, name: raw.display_name };
}
```

Decision: The adapter maps data and isolates the external contract.

### unnecessary-layers-G2 · PRESERVE

Context: Every charge must share a transaction with its audit entry.

```typescript
return database.transaction(async tx => {
  const result = await charge(tx, order);
  await audit(tx, result);
  return result;
});
```

Decision: The wrapper owns required ordering and atomicity.

### unnecessary-layers-G3 · PRESERVE

Context: External clients rely on this stable exported Go function.

```go
func Decode(data []byte) (Document, error) {
    return decodeV2(data)
}
```

Decision: Delegation preserves a public boundary even when implementation is short.
