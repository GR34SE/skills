# Incomplete integration

**Question:** Does required implementation reach the real consumer path?

**Applies when:** The task requires behavior through a command, endpoint, export,
registration or hook. In an audit, use accepted public contracts.

## Inspect and decide

1. Trace entry point, loading, registration, dispatch and consumer.
2. Follow behaviorally distinct alternate paths, including existing safety rules.
3. Check framework discovery, decorators and package exports rather than relying
   on a missing direct-call search result.
4. Report an evidenced disconnected implementation or omitted policy on a real
   path. Preserve external public consumers, proven autodiscovery and deliberate
   rollout flags. If execution is needed to settle reachability, mark uncertainty.
   Do not invent a feature request; entirely absent features are outside this catalog.

## Route elsewhere

- Unrequested implementation: `scope-creep`.
- Text read by humans/agents describing removed or changed names: `stale-references`.
  Code-consumed entry points, export maps and configuration keys stay here.

## Teaching examples

Contexts supply omitted facts. Excerpts are not executed tests.

### incomplete-integration-B1 · REPORT

Context: The requested CLI export must use the new CSV handler.

```typescript
const exportCsv = () => makeCsv();
const commands = { export: placeholder };
```

Decision: Dispatch still invokes the stub. The implementation exists but the
requested user path does not reach it.

### incomplete-integration-B2 · REPORT

Context: The endpoint must apply the new schema before storing input.

```python
def validate_input(data):
    return schema.parse(data)

def endpoint(data):
    return store(data)
```

Decision: The endpoint bypasses the required rule; a unit test of validation alone
would not establish integration.

### incomplete-integration-B3 · REPORT

Context: Package consumers are promised `decodeInvoice` at the root import.
The function exists in an internal file, but the only public entry point is:

```typescript
export { decodeUser } from "./user";
```

Decision: The promised import cannot reach the new implementation. Inspect
generated entry points and export maps before concluding this in real code.

### incomplete-integration-G1 · PRESERVE

Context: External applications use the library's root export.

```typescript
export { decodeInvoice } from "./invoice";
```

Decision: No local calls are required for a public library feature to be connected.

### incomplete-integration-G2 · PRESERVE

Context: Startup imports every module in `commands/`; this module lives there.
The established decorator registers its function.

```python
@commands.register("export")
def export_command():
    return make_csv()
```

Decision: Import plus registration provides reachability without a direct call.
The decorator alone would not prove the module loads.

### incomplete-integration-G3 · PRESERVE

Context: An approved rollout intentionally enables the new checkout for a subset
of users. The flag has an owner and an active rollout plan.

```typescript
return flags.checkoutV2 ? checkoutV2(order) : checkoutV1(order);
```

Decision: Conditional exposure implements the requested rollout.
