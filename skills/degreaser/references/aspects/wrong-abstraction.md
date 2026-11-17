# Wrong abstraction

**Question:** Does shared machinery couple consumers with conflicting rules?

**Applies when:** A shared function, component or class serves multiple cases.

## Inspect and decide

1. Read actual consumers and list the policies they require.
2. Trace cross-case assumptions, mutation, exclusions and exception flags.
3. Show how changing one policy affects the other and propose a simpler separation.
4. Report conflicting meaning with a coupling cost, not flag count or textual
   similarity. Preserve genuinely shared contracts and independent policies
   selected by a dispatcher, even when they occupy the same file.

## Route elsewhere

- Extra machinery for one case: `unnecessary-complexity`.
- A layer with no behavior: `unnecessary-layers`.
- A variant without a consumer: `speculative-flexibility`.
- Scattered rules in an overloaded unit rather than divergent shared cases:
  `structural-erosion`.

## Teaching examples

Contexts supply omitted facts. Excerpts are not executed tests.

### wrong-abstraction-B1 · REPORT

Context: Payment and invitation workflows have independent lifecycles. Callers
must coordinate exclusions to avoid executing another workflow's policy.

```typescript
function process(input, options) {
  if (!options.invitation) charge(input);
  if (!options.skipMail) sendMail(input);
  if (options.invitation) createInvite(input);
}
```

Decision: One workflow cannot change without understanding the other's flags.
Separate policies rather than adding more mutual exclusions.

### wrong-abstraction-B2 · REPORT

Context: Guest accounts must not store a tax ID, but guest invoices require one.
The combined path passes a single mutable record through both rules.

```python
if guest:
    data.pop("tax_id", None)
if invoice:
    require(data, "tax_id")
```

Decision: Account sanitization destroys valid invoice input. Use distinct records
and policies instead of coupling their contracts.

### wrong-abstraction-B3 · REPORT

Context: Each screen disables another screen's rules in a shared form. Changes
to shared validation have broken screens with independent requirements.

```typescript
renderForm({ skipAddress: true, payment: false, ignoreRequired: true });
```

Decision: Given those consumer conflicts, configuration is exposing a wrong
boundary. The option count alone would not establish it.

### wrong-abstraction-G1 · PRESERVE

Context: Invoice and refund calculations share exactly the same maintained tax
rounding contract.

```typescript
const invoiceTax = roundTax(invoice.tax);
const refundTax = roundTax(refund.tax);
```

Decision: Shared meaning justifies the shared mechanism.

### wrong-abstraction-G2 · PRESERVE

Context: Invitation expiry and invoice due dates have different owners and rules.

```python
def invite_expiry(date):
    return date + invite_period()

def invoice_due(date):
    return date + payment_terms()
```

Decision: Similar shape does not justify a flag-driven combined abstraction.

### wrong-abstraction-G3 · PRESERVE

Context: The public serializer has current consumers for every supported
combination of indentation and final-newline behavior.

```typescript
serialize(document, { indent: 4, trailingNewline: true });
```

Decision: Coherent options are not conflicting domain policies.
