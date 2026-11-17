# Contract bypass

**Question:** Does a cast, suppression or default conceal a real contract mismatch?

**Applies when:** Code adds casts, non-null assertions, type/lint suppressions,
missing-data defaults or unchecked boundary parsing.

## Inspect and decide

1. Name the contract, source of data and a reachable mismatching value.
2. Trace the consumer assumption concealed by the cast, suppression or default.
3. Inspect preceding validation and installed dependency declarations.
4. Report a demonstrated mismatch, not syntax alone. Preserve a narrow cast after
   sufficient validation, agreed optional defaults, or an evidenced declaration
   gap. `any`, `unknown` and suppression directives alone establish no defect.

## Route elsewhere

- Actual failure converted into success: `masked-errors`.
- Excess validation: `unjustified-defense`.
- Narrative beside a directive: `low-value-comments`; judge the directive's
  suppression effect here.

## Teaching examples

Contexts supply omitted facts. Excerpts are not executed tests.

### contract-bypass-B1 · REPORT

Context: `ship` requires a validated delivery address. The request body is untrusted.

```typescript
const shipment = request.body as Shipment;
await ship(shipment);
```

Decision: An absent address reaches a consumer that assumes it exists. The cast
substitutes for validation rather than recording an established guarantee.

### contract-bypass-B2 · REPORT

Context: Zero is a valid free price, not the agreed meaning of a missing price.

```typescript
return charge(payload.price ?? 0);
```

Decision: The default turns absent required data into a financial decision.

### contract-bypass-B3 · REPORT

Context: `loadReceipt` accepts a numeric receipt ID, not an account-name string.

```typescript
// @ts-ignore
return loadReceipt(accountName);
```

Decision: The directive conceals a semantic mismatch; its existence alone would
not establish the problem without these contracts.

### contract-bypass-G1 · PRESERVE

Context: `validateRecord` checks every Invoice field but its declaration returns
void, so the SDK's unknown result is not narrowed by the type checker.

```typescript
const record = sdk.read();
validateRecord(record);
return record as Invoice;
```

Decision: The cast follows a complete runtime guarantee instead of replacing one.

### contract-bypass-G2 · PRESERVE

Context: The API explicitly specifies twenty results when the limit is omitted.
`checkLimit` rejects zero and negative values.

```typescript
const limit = input.limit ?? 20;
checkLimit(limit);
```

Decision: The default implements an agreed optional contract.

### contract-bypass-G3 · PRESERVE

Context: A fictional installed SDK forwards cancellation signals, but its
declarations omit that option. Runtime source and integration coverage establish it.

```typescript
// @ts-expect-error -- installed declarations omit supported cancellation
await client.read({ signal });
```

Decision: This compensates for a declaration gap. The directive also becomes a
type-check failure once that gap closes; no claim about a real SDK is implied.
