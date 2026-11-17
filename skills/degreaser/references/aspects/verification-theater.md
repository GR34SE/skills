# Verification theater

**Question:** Does the observation establish the property the check claims?

**Applies when:** Runtime code, CI, scripts or tools add validators, health checks,
checksums, verification or diagnostic commands.

## Inspect and decide

1. Identify the promise, observed object, expectation source and acceptance rule.
2. Show a concrete invalid state accepted or valid state rejected.
3. Distinguish observations from declared capabilities and inferred configuration.
4. Report the gap, not merely shared code. Shared schemas can establish transfer
   or generation consistency without establishing the schema's semantic truth.
   Independence must match the promised property.

## Route elsewhere

- Checks, helpers and fixtures executed only by a test runner: `low-value-tests`.

## Teaching examples

Contexts supply omitted facts. Excerpts are not executed tests.

### verification-theater-B1 · REPORT

Context: This command claims to detect defects in the manifest generator.

```typescript
const actual = buildManifest(input);
const expected = buildManifest(input);
return equal(actual, expected);
```

Decision: A deterministic generator bug survives both calls. The claimed
independent verification never occurs.

### verification-theater-B2 · REPORT

Context: The check promises to verify bytes actually stored on disk.

```python
write_bytes(path, payload)
verified = sha256(payload).digest() == sha256(payload[:]).digest()
```

Decision: A truncated write is invisible because neither side reads the file.

### verification-theater-B3 · REPORT

Context: A diagnostic promises that this deployment can authenticate to storage.

```typescript
return { authenticated: Boolean(config.storageEndpoint) };
```

Decision: An endpoint string proves configuration presence, not a working login.

### verification-theater-G1 · PRESERVE

Context: An authenticated release manifest supplies the expected digest.
The promise is download integrity, not correctness of the released program.

```typescript
assert.equal(hash(await readDownloaded(path)), manifest.digest);
```

Decision: The observed downloaded bytes are checked against an independent value.

### verification-theater-G2 · PRESERVE

Context: The consumer independently owns the versioned schema. This validator
claims contract conformance, not business correctness.

```python
payload = produce(input_data)
validate(payload, consumer_schema_v3)
```

Decision: A malformed producer result can fail the consumer's contract.

### verification-theater-G3 · PRESERVE

Context: This command lists capabilities without claiming an environment check.

```typescript
return { supportsLogin: true, authenticationCheck: "not-run" };
```

Decision: Declared support is explicitly separated from observed results.
