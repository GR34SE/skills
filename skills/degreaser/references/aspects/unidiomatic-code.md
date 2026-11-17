# Unidiomatic code

**Question:** Can a native construct remove manual expression-level logic while
preserving semantics?

**Applies when:** Loops, accumulators, collection or string operations have a
direct language/standard-library equivalent.

## Inspect and decide

1. Compare ordering, equality, sparse data, errors, mutation, async sequencing
   and early termination.
2. Verify availability at the project's minimum supported runtime.
3. Check the language's idioms and local conventions; Go loops are not JavaScript
   anti-patterns.
4. Report a concrete clarity or resource cost, not preferred syntax. Preserve
   deliberate ordering, short-circuiting and measured allocation constraints.

## Route elsewhere

- Algorithm/control-flow design beyond an expression: `unnecessary-complexity`.
- An existing contracted repository/dependency component: `missed-reuse`.
- Custom general infrastructure: `reinvented-infrastructure`.

## Teaching examples

Contexts supply omitted facts. Excerpts are not executed tests.

### unidiomatic-code-B1 · REPORT

Context: A dense array undergoes a pure ordered transformation. No early exit or
special allocation budget applies, and this module uses `map` for transformations.

```typescript
const labels: string[] = [];
items.forEach(item => { labels.push(item.label); });
```

Decision: `items.map(item => item.label)` removes a separate mutable accumulator
without altering the stated semantics.

### unidiomatic-code-B2 · REPORT

Context: A large string list needs exact deduplication preserving first occurrence.

```typescript
const unique: string[] = [];
for (const value of values) {
  if (unique.indexOf(value) < 0) unique.push(value);
}
```

Decision: A Set preserves string equality and insertion order without a linear
search for every item.

### unidiomatic-code-B3 · REPORT

Context: All parts are strings; ordinary comma joining is the entire contract.

```python
result = ""
for index, part in enumerate(parts):
    if index:
        result += ","
    result += part
```

Decision: `",".join(parts)` removes separator bookkeeping.

### unidiomatic-code-G1 · PRESERVE

Context: Each write depends on the previous write to the same resource.

```typescript
for (const update of updates) await apply(update);
```

Decision: Parallel collection operations would violate required ordering.

### unidiomatic-code-G2 · PRESERVE

Context: Remote checks are expensive and must stop at the first match, sequentially.

```typescript
for (const item of items) {
  if (await matches(item)) return item;
}
```

Decision: Async `find` does not await its predicate, and `Promise.all` loses
early termination and sequencing.

### unidiomatic-code-G3 · PRESERVE

Context: Profiling identified per-frame allocations as a problem. A reusable
typed-array output buffer is required by the hot-path budget.

```typescript
for (let i = 0; i < values.length; i++) out[i] = transform(values[i]);
```

Decision: An allocating transformation would violate the measured constraint.
