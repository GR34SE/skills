# Missed reuse

**Question:** Is a required mechanism already provided by an accessible component
with the right contract?

**Applies when:** New code copies or reimplements contracted behavior such as
clients, retry, caches, logging, randomness or error mapping.

## Inspect and decide

1. Find the existing repository, installed dependency, framework or platform API.
2. Quote usage or declarations and verify public exports in the installed version.
   Search may skip ignored dependencies; read known installed paths directly.
3. Compare requirements, side effects, runtime availability and permissions.
4. Report the duplicate mechanism and its maintenance/behavioral cost. Preserve
   separate mechanisms where contracts differ. Missing API evidence is uncertainty,
   not a finding. Never impose a framework the project does not use.

## Route elsewhere

- No equivalent, but a simpler implementation exists: `unnecessary-complexity`.
- Missing general semantics requiring a new dependency: `reinvented-infrastructure`.
- Expression-level native constructs: `unidiomatic-code`.
- Format/channel/naming divergence without duplicated mechanics: `convention-drift`.
- Copies that resemble added coupling still belong here, not `structural-erosion`.

## Teaching examples

Contexts supply omitted facts. Excerpts are not executed tests.

### missed-reuse-B1 · REPORT

Context: Simulations must replay with a configured seed. The existing injected
`rng.next()` implements that contract and is used by all other simulation paths.

```typescript
const draw = Math.random();
```

Decision: This bypasses the existing source and breaks reproducibility.

### missed-reuse-B2 · REPORT

Context: `apiClient.get` already provides the required retry, diagnostics and
error mapping. This new path implements the same read but omits the latter two.

```typescript
for (let n = 0; n < 3; n++) {
  try { return await directRead(id); }
  catch (error) { if (n === 2) throw error; }
}
```

Decision: Reuse the evidenced client instead of maintaining a divergent policy.

### missed-reuse-B3 · REPORT

Context: `cache.getOrLoad` already supplies the required TTL and capacity bound.
The new module maintains a separate cache without capacity accounting.

```typescript
const entries = new Map<string, { value: User; expires: number }>();
```

Decision: The duplicate responsibility omits an established guarantee. Read its
insertion/removal paths before making this finding in real code.

### missed-reuse-G1 · PRESERVE

Context: The shared client retries every request. The payment API has no
idempotency keys, and a retried charge can bill twice.

```typescript
await fetch(chargeUrl, { method: "POST", body });
```

Decision: Direct transport preserves this operation's no-retry requirement.

### missed-reuse-G2 · PRESERVE

Context: The existing client matches the lookup's retry, logging and error contract.

```typescript
return apiClient.get(`/accounts/${id}`);
```

Decision: The implementation already reuses the appropriate mechanism.

### missed-reuse-G3 · PRESERVE

Context: Recovery tokens require secure randomness. The shared simulation RNG
is deterministic; the supported runtime provides a secure primitive.

```typescript
import { randomBytes } from "node:crypto";
const token = randomBytes(32).toString("hex");
```

Decision: A matching category (“randomness”) does not make the simulation helper
contract-compatible with security tokens.
