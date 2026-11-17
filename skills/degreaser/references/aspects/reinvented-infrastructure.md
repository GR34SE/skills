# Reinvented infrastructure

**Question:** Does custom general-purpose infrastructure miss required semantics
when no equivalent is already available?

**Applies when:** The change adds a cache, standard parser, scheduler, timezone
arithmetic, retry/backoff mechanism, cryptographic primitive or similar infrastructure.

## Inspect and decide

1. Inspect the repository, manifests and existing dependencies for an equivalent.
2. Identify a concrete required semantic case that the custom mechanism misses.
   Tie it to the task, not an imagined fully featured cache or parser.
3. Check dependency restrictions and the actual bounded problem.
4. Report missing semantics with a counterexample. Suggest considering a mature
   solution, not an unverified package/API. Library selection needs separate
   verification; popularity alone proves nothing. Preserve small code that fully
   meets its contract and custom domain policy built on approved primitives.

## Route elsewhere

- An accessible equivalent already exists: `missed-reuse`.
- One expression has a language/standard-library replacement: `unidiomatic-code`.

## Teaching examples

Contexts supply omitted facts. Excerpts are not executed tests.

### reinvented-infrastructure-B1 · REPORT

Context: A new cache must retain at most 1,024 value bytes. No equivalent exists;
dependencies are permitted. This is its only insertion path.

```typescript
set(key: string, value: Uint8Array) {
  this.entries.set(key, { value, expires: Date.now() + 60_000 });
}
```

Decision: Two different 600-byte values retain 1,200 bytes. TTL metadata does not
enforce the required capacity limit.

### reinvented-infrastructure-B2 · REPORT

Context: The import must accept CSV exports containing quoted commas and newlines.
The repository and its dependencies contain no CSV parser.

```typescript
const rows = input.split("\n").map(line => line.split(","));
```

Decision: `"Doe, Sam"` becomes two fields. Recommend a parser implementing the
required CSV semantics, without claiming an unverified library does so.

### reinvented-infrastructure-B3 · REPORT

Context: Users supply five-field cron schedules with weekday constraints and
steps. No parser exists in the project.

```python
minute, hour = [int(x) for x in expression.split()[:2]]
return next_daily_time(hour, minute)
```

Decision: `0 9 * * 1-5` incorrectly includes weekends and `*/15` cannot parse.
Those required cases justify replacing the partial scheduling mechanism.

### reinvented-infrastructure-G1 · PRESERVE

Context: Only the fifty most recently inserted results must be retained, with
no TTL or byte limit. The project forbids runtime dependencies.

```typescript
cache.delete(key);
cache.set(key, value);
if (cache.size > 50) cache.delete(cache.keys().next().value!);
```

Decision: Insertion order covers the entire bounded contract. Do not invent a
TTL requirement to justify a dependency.

### reinvented-infrastructure-G2 · PRESERVE

Context: The validated internal format is exactly a key and value separated by
one colon; it is deliberately not CSV.

```python
key, value = line.split(":", 1)
```

Decision: A standard-format parser would solve a problem this format does not have.

### reinvented-infrastructure-G3 · PRESERVE

Context: A product-specific canonicalization rule is not offered by generic
libraries. An approved signer handles the cryptographic primitive.

```typescript
return signer.sign(encodeDomainRecord(record));
```

Decision: Custom domain semantics do not reinvent cryptography.
