# Speculative flexibility

**Question:** Does each option or extension point serve a current requirement?

**Applies when:** Options, parameters, flags, variants, strategies, plugins or
configuration fields are introduced or extended, or the change removes the
last consumer of existing code.

## Inspect and decide

1. Enumerate every introduced variant, not just one conspicuous option.
2. Trace each through task, configuration, public contract and actual consumer.
   Forwarding or populating a value is not consuming its behavior.
3. Identify the narrower form that meets current requirements and the maintenance
   cost of unnecessary variants or accepted spellings.
4. Report unsupported speculation, not legitimate public consumers, deterministic
   test seams or an active migration. No local production caller is not proof
   of no consumer. Missing requirements remain uncertainty.

## Route elsewhere

- More complicated handling of current behavior: `unnecessary-complexity`.
- Behaviorless layer without variants: `unnecessary-layers`.
- Used variants with conflicting policies: `wrong-abstraction`.
- Unrequested product capability: `scope-creep`.

## Teaching examples

Contexts supply omitted facts. Excerpts are not executed tests.

### speculative-flexibility-B1 · REPORT

Context: An internal CSV exporter has one caller using defaults, no public API,
and no requirement for alternate strategies or plugins. Each option adds a path.

```typescript
type Options = {
  delimiter?: string;
  plugins?: Plugin[];
  strategy?: "buffered" | "streaming";
};
```

Decision: Each variant adds contracts and combinations without a current consumer.

### speculative-flexibility-B2 · REPORT

Context: Only HTTP is required and used. Neither plugin nor resolver has a caller.

```python
def sender(kind="http", plugin=None, resolver=None):
    if plugin:
        return plugin(resolver)
    return HttpSender()
```

Decision: Unused extension points add paths, while ignored `kind` advertises
unsupported behavior such as `kind="smtp"`.

### speculative-flexibility-B3 · REPORT

Context: Every private caller validates; the flag is neither public nor part
of an active migration.

```typescript
function save(item: Item, validateFirst = true) {
  if (validateFirst) validate(item);
  return persist(item);
}
```

Decision: The disabled-validation path exists only for hypothetical future use.

### speculative-flexibility-G1 · PRESERVE

Context: Two current products require distinct delivery channels.

```typescript
deliver(receipt, { channel: "email" });
deliver(event, { channel: "webhook" });
```

Decision: Both variants serve observed requirements.

### speculative-flexibility-G2 · PRESERVE

Context: The published SDK contract promises custom transports. External offline
deployments use the option, though this repository has no such production caller.

```typescript
export interface ClientOptions { transport?: Transport }
```

Decision: Public consumers justify the extension point.

### speculative-flexibility-G3 · PRESERVE

Context: An approved migration supports two actively produced formats until
the old producers retire.

```python
if payload.version == 1:
    return decode_v1(payload)
return decode_v2(payload)
```

Decision: Compatibility serves current consumers rather than speculative ones.
