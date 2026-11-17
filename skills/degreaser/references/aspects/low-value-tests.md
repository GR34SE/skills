# Low-value tests

**Question:** Can each test detect a plausible regression not already covered
by a stronger retained test under the same conditions?

**Applies when:** Tests, test helpers, fixtures or mocks are added/edited; existing
ones also apply in an audit. **Unit:** every assessed test case.

## Inspect and decide

1. Name the regression, real code executed, and independent expectation source.
2. For negative tests, trace the input to the intended guard; an earlier unrelated
   failure does not test that guard.
3. Before removal, read the complete test, implementation, relevant callers and
   overlapping tests. Identify the stronger retained case and compare boundary,
   configuration and CI routing, not just names or setup.
4. Report tests that test their own fake, copy the mistake they claim to detect,
   or demonstrably add no coverage. Preserve useful unit/smoke tests and boundary
   fakes that do not implement the tested rule.

Source inspection, snapshots and byte comparisons can check an intentional
artifact contract. They do not establish runtime behavior or prompt effectiveness.
Without execution, describe source analysis, never a proven mutation result.

## Route elsewhere

- Runtime/CI/check-command verification outside the test runner:
  `verification-theater`.

## Teaching examples

Contexts supply omitted facts. Excerpts are not executed tests.

### low-value-tests-B1 · REPORT

Context: The test claims to protect production rebate calculation, but uses only
a local replacement.

```typescript
const rebate = () => 7;
assert.equal(rebate(), 7);
```

Decision: Production can change arbitrarily without affecting this assertion.

### low-value-tests-B2 · REPORT

Context: Billing requires rounding tax to cents. This expectation copies the
production calculation, including its missing rounding.

```typescript
const expected = subtotal * configuredRate;
assert.equal(calculateTax(subtotal), expected);
```

Decision: A shared formula mistake is invisible. Use a worked billing-contract
result rather than deriving the oracle from the implementation being checked.

### low-value-tests-B3 · REPORT

Context: A retained test already asserts the exact output of this same call under
the same environment and CI job.

```python
def test_export_smoke():
    assert export(SAMPLE) is not None
```

Decision: This weaker assertion protects no additional state or boundary.

### low-value-tests-G1 · PRESERVE

Context: The public contract converts decimal currency strings to integer cents.

```typescript
assert.equal(parseCents("0.25"), 25);
assert.equal(parseCents("14.07"), 1407);
```

Decision: Independently worked values can catch a scaling or parsing regression.

### low-value-tests-G2 · PRESERVE

Context: This process runs the current packed package in an empty project.
Module tests do not cover missing packaged resources or the executable mapping.

```typescript
const result = runInstalled("--help");
assert.equal(result.status, 0);
assert.match(result.stdout, /Usage:/);
```

Decision: A small smoke test protects a distinct installation/launch boundary.

### low-value-tests-G3 · PRESERVE

Context: The real service must store before emitting. Boundary fakes record
calls without deciding their order.

```python
service.submit(order)
assert calls == [("store", order.id), ("emit", order.id)]
```

Decision: The assertion tests service ordering, not a fake's implementation of it.
