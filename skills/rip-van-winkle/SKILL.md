---
name: rip-van-winkle
description: No legacy APIs or syntax in new code. Makes the agent look up the current LTS, stable versions, built-in APIs and language features before it writes, instead of trusting training data. Use when starting a project, adding a feature or dependency, writing a config, Dockerfile or CI workflow, or picking a version. Any stack, even when nobody mentions versions.
---

# Rip Van Winkle

Rip Van Winkle slept for twenty years, woke up, and kept talking about a king who no longer ruled. You are in the same position with every language, runtime, framework and package you know.

Your knowledge stops at your training cutoff, and you are being used months or years after it. Most of the code you learned from is older still, so the approach that feels normal to you is usually the one from two or three major versions ago. This is why agents start new projects on runtimes close to end of life, install packages for things the platform has done by itself for years, and write syntax that the language has since replaced.

Code written that way is legacy on the day it is written. The rule of this skill: new code targets what is current today, and you find out what is current by looking it up, not by remembering it.

## What legacy means here

- A runtime, language or framework version older than the current LTS or stable release, when nothing pins it.
- A package that does what the standard library, the runtime or a framework already in the project now does.
- An API, package, config format or command that is deprecated or has an official successor.
- Older syntax where the target version has a direct replacement.
- A polyfill, shim or build step that exists only for versions the project does not support.

Raising a version number does not fix any of this. The current release of a package you do not need is still legacy.

Some examples, to show the shape of the problem. Node watches files, loads `.env` files, runs TypeScript, and ships `fetch` and a test runner, so a new Node project needs no package for any of these. Python parses TOML in the standard library and writes `list[str] | None` without importing `typing`. Go has `slices`, `maps`, `min` and `max`. Rust has `std::sync::LazyLock`. React takes `ref` as a normal prop. CSS has nesting, `:has()` and container queries.

These were checked on 2026-11-18. They show the pattern and they are not the list to check against. Newer changes exist that this file does not name and that you have never seen. Only the lookup below finds them.

## When this applies

- You start a project or generate one with a scaffolding tool.
- You add a feature, a module or a file.
- You add, replace or choose a dependency.
- You write or edit a manifest, a compiler or linter config, a Dockerfile or a CI workflow.
- You set up tooling: tests, watch mode, env loading, build, formatting.
- You pick a version of anything.

Load this skill before you plan the stack. If you already chose packages or wrote a manifest, those choices came from memory. Treat them as a draft: take each one through steps 1 to 3 and change every one that fails.

Scale the effort to the change. A new project or a new major dependency gets every step. A small change in an existing file gets one check: the API or syntax you are about to write, against the version the project targets.

This skill is no reason to upgrade an existing project or to rewrite code you were not asked to touch.

## 1. Find the target versions

**In an existing project**, the project decides. Read what it pins: the manifest (`engines`, `requires-python`, the `go` line, `edition`, `rust-version`), version files (`.nvmrc`, `.python-version`, `.tool-versions`, `rust-toolchain.toml`), the Dockerfile, the CI matrix, the compiler target and the lockfile. Those versions are your target. Go to step 2.

**In a new project**, look the versions up. Use the first source that answers:

| You need | Look here |
|---|---|
| Current LTS or stable release of a runtime, language, framework or database, with end-of-life dates | `curl -s https://endoflife.date/api/<product>.json`. The first entry is the newest release line. Read `latest`, `lts` and `eol`. Product names: `https://endoflife.date/api/all.json` |
| npm package | `npm view <pkg> version engines deprecated` |
| Python package | `curl -s https://pypi.org/pypi/<pkg>/json`, fields `info.version` and `info.requires_python` |
| Rust crate | `cargo info <crate>`, or `curl -s -A version-check https://crates.io/api/v1/crates/<crate>` |
| Go module | `go list -m -versions <module>`, or `curl -s https://proxy.golang.org/<module>/@latest` |
| Ruby gem | `curl -s https://rubygems.org/api/v1/versions/<gem>/latest.json` |
| PHP package | `composer show -a <vendor>/<pkg>` |
| .NET package | `curl -s https://api.nuget.org/v3-flatcontainer/<id-in-lowercase>/index.json` |
| Java or Kotlin artifact | `curl -s https://repo1.maven.org/maven2/<group/as/path>/<artifact>/maven-metadata.xml` |
| Docker image tags | `curl -s "https://hub.docker.com/v2/repositories/library/<image>/tags?page_size=25&name=<prefix>"` |
| A project released on GitHub | `gh release view --repo <owner>/<repo>`, or `curl -s https://api.github.com/repos/<owner>/<repo>/releases/latest` |
| What is installed on this machine | `node --version`, `python3 --version`, `go version`, `rustc --version` and so on |

Rules for choosing:

- Take the LTS where the ecosystem has one, and the latest stable release where it does not. Skip alphas, betas, release candidates and nightlies unless the user asks for one. Some registries list them first, so read the version string.
- Check that the main dependencies support the version you picked: `engines`, `requires-python`, peer dependencies. If one does not, take the newest version that all of them support, and say which package held you back.
- The target is the version you looked up, not the version that happens to be installed. If the installed toolchain is older, tell the user which version is installed and give the command that installs the target. Do not install or switch a runtime without being asked.
- Pin the target where the project reads it: the minimum version in the manifest (`engines`, `requires-python` and the like), the version file, the Dockerfile tag, the CI workflow. A new project declares the target itself as its minimum. Do not pick an older floor for compatibility that nobody asked for, and do not use a floating tag such as `latest`.
- If you have no network access, use the installed toolchain as the target and say that you could not check whether it is current.

## 2. Find out what the platform does now

Knowing the version number is not enough, because you do not know what that version can do.

List the jobs the change needs. For a new service that is, for example: running the code, reloading it during development, loading configuration, making HTTP requests, generating ids, storing data, running tests. For each job, find out how the target version does it. Do this before you think of a package, and do it for every job, including the ones where you are sure you need a package.

Ask the toolchain first, because it is exact and needs no network: the `--help` output of the runtime, the compiler and the package manager, and their lists of subcommands. New capabilities show up there as flags and commands you do not recognize. Then check the official documentation of the target version for each job.

Then, for each major version between the one you would have picked from memory and the target, open the release notes, the "what's new" page or the migration guide. For a framework or library, read the current getting-started page too. Look for four things:

1. **Now built in.** Something that used to need a package, a plugin or a flag.
2. **Deprecated or removed.** APIs, options, commands and whole packages, with their replacements.
3. **New syntax and APIs** that replace a pattern you would write from habit.
4. **Changed defaults.** The module system, the config file format, the project layout, the scaffolding command, the recommended tool for a job.

If Context7 or another documentation tool is available in this session, use it for this reading. It returns the documentation of a specific version and is faster than searching the web. Otherwise fetch the official pages. Trust, in this order: the documentation shipped inside the installed package, the official documentation and release notes, everything else, your memory.

A built-in feature has rules you have not learned, such as required file extensions, flags or config values. When one fails on the first try, read its documentation page and fix your usage. Do not fall back to the package you know. The cause is almost always a rule you missed, not a missing feature.

## 3. Add a dependency only for what is left

For each job that still looks like it needs a package, ask these in order and stop at the first yes:

1. Does the language, its standard library or the runtime do this at the target version?
2. Does a framework or library already in the project do this?
3. Is it a few lines of plain code?

Only after three noes, add a package. These jobs are the ones most often already covered, so check them every time:

| You are about to add a package for | Check first |
|---|---|
| Restarting or reloading on file changes | The runtime's watch mode |
| Loading `.env` files or reading configuration | Runtime flags and the standard library |
| HTTP requests, WebSockets, streams | The built-in client |
| Running tests, assertions, mocks, coverage | The built-in test runner |
| Running or compiling TypeScript, type hints, a transpile step | Native support in the runtime or language |
| Parsing command-line arguments, coloring terminal output | The standard library |
| UUIDs, hashing, random values, encoding | The standard library |
| Globbing, recursive copy and delete, temporary files, paths | The standard library |
| Deep cloning, grouping, sorting copies, set operations, dates and times | Built-in language APIs |
| Parsing JSON, TOML, CSV, YAML or XML | The standard library |
| SQLite, a key-value store, a cache | The standard library and the runtime |
| A polyfill or a shim of any kind | The target version, which probably has the feature |
| Lazy initialization, synchronization helpers, error wrapping, collection helpers | The standard library |
| Layout, state or animation in JavaScript, a CSS preprocessor | Native CSS |
| A helper around a framework's refs, context, forms, data loading or routing | The framework's current API |

When you do add a package, look it up before you install it:

- Install the current stable version from the registry, not the one you remember.
- Check that it is alive: a release within the last year or so, no deprecation notice in the registry or the README, no archived repository.
- Check that the ecosystem has not moved to a successor. The package you remember as the standard choice may be the legacy one now.
- Match companion packages to what they belong to. Type definitions, plugins and adapters take the same major version as their package, and type definitions for the runtime take the major version of the target runtime.
- When two packages conflict, look for the fix that keeps both current, such as a newer release or a built-in replacement for one of them. Downgrade only when there is none, and say so.
- If it comes with a scaffolding or init command, run that command at its current version. Do not write the boilerplate from memory.

## 4. Write for the target

- Use the newest syntax the target supports. Check the families that changed most: null and optional handling, pattern matching, resource cleanup, destructuring, async iteration, type syntax, string formatting, the module system.
- Stay inside the target. The compile target, the minimum language version and the supported browsers set the ceiling: `target` and `lib`, `requires-python`, `edition`, the `go` line, `browserslist`. Syntax above that ceiling is as wrong as syntax years below it.
- Use the current config format and file names for every tool, and the options that the current version documents.
- Add no polyfill, compatibility branch or fallback for a version below the target.
- When you are unsure whether an API exists at the target, check the installed package or the documentation. Do not guess, and do not fall back to the old way because it is the one you are sure of.

## Existing projects

- The pinned versions are the target. Use the newest APIs and syntax they allow. That is usually far more than what you write from habit.
- Do not add a new dependency for something the pinned platform already does.
- Do not replace a dependency or a pattern that the project already uses, and follow it in the code around it. If the platform now covers it, say so in one sentence and leave the decision to the user.
- If a pinned version is past its end of life, or is the reason you could not do something well, say so and offer the upgrade as a separate task. Do not bump it yourself.

## Before you hand off

1. Run the code on the target version: build, tests, linter. If you could not, because the installed toolchain is older, say so.
2. In a new project, run the package manager's check for outdated packages: `npm outdated`, `uv tree --outdated --depth 1`, `pip list --outdated --not-required`, `go list -u -m all`, `bundle outdated --only-explicit`, `composer outdated --direct`, `dotnet list package --outdated`. A dependency you declared that the check reports as outdated has a version that came from memory. Fix it or say why it stays. Leave the dependencies of your dependencies alone.
3. Read the output of the install, the build and the tests. A deprecation warning that your code or your choice of package caused is a defect. Fix it.
4. Read your diff once more for the items in "What legacy means here".
5. Report in a few lines: the versions you chose and where you looked them up, the packages you did not add because the platform covers the job, and anything you could not verify.
