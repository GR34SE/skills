---
name: effect-ts-is-king
description: Stop reinventing Effect. Makes your agent search the whole Effect 4 toolbox before it hand-rolls any of 18 mechanisms, from retry loops to LLM clients. Use for TypeScript backend implementation, debugging, refactoring, and code review whenever a package manifest lists `effect` or an `@effect/*` package, even when the request does not mention Effect. Not for projects without Effect.
---

# Effect-TS Is King

This project runs on Effect. Effect and its ecosystem already ship most of the mechanics a backend needs: retries, timeouts, concurrency limits, resource cleanup, validation, configuration, dependency injection, streaming, caching, HTTP, SQL, logging, tracing, and LLM clients. Those implementations handle interruption, typed errors, and cleanup, and they compose with each other. A hand-written replacement usually handles none of that, and the team has to maintain it.

So divide the work this way: write the behavior that is specific to this application, and take the mechanics from Effect. Code that reimplements a mechanism Effect already provides is a defect to fix before handoff, in the same way a failing test is. It is not a style preference.

Most Effect code written from habit uses a small corner of the library: generators, services, and tagged errors. The rest goes unused because nobody searched for it. This skill exists to make you search.

## Scope

- Apply this only where a package manifest lists `effect` or an `@effect/*` package. If none does, stop. Do not introduce Effect into a project unless the user asks.
- Apply it to the whole task at hand: handlers, workers, integrations, persistence, configuration, pure transformations, and tests.
- Stay inside the task. Do not rewrite unrelated code, replace the framework, or upgrade packages on your own initiative.
- Where Effect covers only part of the backend, work within the existing boundary. Do not start a second runtime or migrate the rest without being asked.

## Do not trust your memory of the API

This skill is written for Effect 4. Most of what you remember about Effect comes from Effect 3, which is legacy. Effect 4 renamed and merged modules, and it moved capabilities that used to be separate `@effect/*` packages, such as HTTP, SQL, RPC, AI, and the command line, into subpaths of `effect` itself. A call that looks right from memory is often an Effect 3 call that no longer exists.

Before you write or change Effect code:

1. Read `AGENTS.md` in the installed `effect` package, next to its `package.json`. Read all of it and follow the references that apply to your task.
2. For every API you are not certain about, check its signature, error type, requirements, and interruption behavior in the package's source or declarations under `node_modules`. If documentation and the installed source disagree, the source wins.
3. Read how neighboring code solves the same kind of problem, and follow that pattern unless it is the thing you are fixing.

Read the source to learn how to use the library. Import only public exports. If you cannot verify an API, say so in your report rather than guessing. If the project is still on Effect 3, the rules in this skill still apply, but expect different names and packages.

## Search before you write a mechanism

When you notice yourself about to write something from the left column, stop and search the installed Effect packages for the right column first.

| You are about to write | Search Effect for |
|---|---|
| `try`/`catch`, custom error classes, a hand-made result union | The typed error channel, tagged errors, `Cause`, `Exit`, `Result`, recovery combinators |
| A retry loop, backoff, polling, `setInterval` | `Schedule`, retry and repeat |
| `setTimeout`, `Date.now()`, manual deadlines, date arithmetic | Timeouts, `Duration`, `Clock`, `DateTime` |
| `Promise.all`, `Promise.race`, a concurrency limiter, a worker pool | Concurrency options on the collection combinators, fibers, semaphores, `Queue`, `PubSub`, `Deferred` |
| `try`/`finally`, connection lifecycle code, shutdown handlers | `Scope`, acquire and release, finalizers, layer lifetimes |
| A validation library, hand-written parsing, type guards, casts | `Schema` |
| Null checks, a `switch` over a kind field, deep equality, comparators, collection helpers | `Option`, `Match`, `Equal`, `Order`, and the data modules for arrays, records, and strings |
| `process.env` reads, a configuration object, secrets held as plain strings | `Config`, `ConfigProvider`, `Redacted` |
| Module-level singletons, clients passed through parameters, a homemade container | Services and `Layer` |
| A `fetch` wrapper, a router, a hand-typed API client | The HTTP client and server, declarative HTTP APIs, RPC |
| Database driver glue, manual transactions, migration scripts | The SQL packages |
| Async iterators, event emitters, batching, pagination loops | `Stream`, `Sink`, and their backpressure |
| A `Map` used as a cache, request deduplication, a rate limiter, a connection pool | `Cache`, request batching, the rate limiter, `Pool` |
| `fs`, `path`, `child_process`, sockets | The platform file system, path, command, and socket modules |
| `console.log`, manual timing, passing trace identifiers around | Effect logging, log annotations, spans, `Metric`, the OpenTelemetry integration |
| A provider SDK call to an LLM, parsing JSON out of model output | The Effect AI packages: model clients, structured output from a `Schema`, tool calls |
| A cron library, a job runner, hand-made durable steps | `Cron`, `Schedule`, the workflow and cluster packages |
| Fake timers, module mocks | The test clock, test layers, the Effect integration for the project's test runner |

The names in the right column are search terms, not guaranteed imports. Find where each one lives in the installed package and confirm its API there. The table is a starting point and does not list everything, so search by the problem you have as well as by these names.

Start with what is already installed. Most capabilities ship inside `effect`. Platform adapters, database drivers, and LLM providers are separate official `@effect/*` packages. If you need one that is not installed, prefer adding it over writing the mechanism yourself, and tell the user you added it.

## Choose the smallest complete solution

Take the first option that solves the problem:

1. An existing piece of this application that already does it correctly.
2. A public Effect or ecosystem API.
3. Plain TypeScript, for trivial pure computation or something Effect does not usefully cover.
4. A mature dependency, when it removes more maintenance than it adds.
5. Your own mechanism, only for a gap you can name.

For option 5, write down which APIs you checked and what specific capability was missing. If you cannot name the gap, there is no gap, so use the API.

Effect-first does not mean Effect everywhere. Leave direct arithmetic and obvious expressions as they are. Do not wrap a pure value in an effect, and do not replace a readable expression with a longer chain of combinators. Do not hide Effect behind your own facade. A service named for a domain concept that holds real application policy is useful, and a wrapper that only renames library functions is not. Do not add abstractions, options, or configuration for callers that do not exist yet.

## Keep the semantics intact

These properties are easy to lose when you write or move Effect code. Check each one that your change touches.

- **Errors.** Expected failures stay in the typed error channel. Do not turn failures into successes, convert them all into defects, or widen them to `unknown`. Keep defects and interruption distinct from expected failures.
- **Interruption.** A promise-based SDK enters Effect at one boundary, with its cancellation connected to interruption. Do not leave unmanaged promises, timers, or detached tasks running.
- **Resources.** A scope owns every resource and every background fiber. Anything acquired is released on success, on failure, and on interruption.
- **Runtime.** Build the production layers once, at the application's entry point. Do not construct runtimes or run effects to promises inside feature code.
- **Contracts.** Decode untrusted input with a schema at the boundary. Keep the nullability, field names, and types of the external API or database as they are. When a type is too loose, fix the contract rather than adding casts, non-null assertions, or repeated defensive checks.
- **Configuration.** One place owns each setting, its default, and its validation.
- **Guarantees.** Simplifying code must not remove backpressure, idempotency, transaction boundaries, or required validation.
- **Domain.** Keep business decisions separate from transport, persistence, and execution, so the rules stay easy to read and test.

## Before you hand off

1. Read your whole diff against the left column of the table. Replace every mechanism Effect already provides, and remove wrappers, options, and abstractions that nothing currently needs.
2. Test the behavior that matters: business decisions, error handling, interruption, resource release, retry policy, concurrency limits, and input contracts. Use the test clock and replaceable layers instead of real time and module mocks. Make sure each test double fails and cleans up the way the real service does. Skip tests that only restate types or check that a constructor exists.
3. Run the project's tests, type checking, and linting, and fix what fails.
4. Report what you changed, what you verified and how, and what you could not verify. For each custom mechanism you kept, name the missing capability that made it necessary.
