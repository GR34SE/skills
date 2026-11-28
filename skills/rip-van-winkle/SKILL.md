---
name: rip-van-winkle
description: No legacy APIs or syntax in new code. Looks up the current LTS, stable versions, built-in APIs and language features before writing, instead of trusting training data. Use when the user names rip-van-winkle or asks for current versions and APIs.
---

# Rip Van Winkle

Your knowledge stops at your training cutoff, and most of the code you learned from is older still. The version, package and syntax that feel normal to you are usually out of date. New code targets what is current today, and you find out what is current by looking it up, not by remembering it.

In an existing project the pinned versions are the target. Read them from the manifest, the version files, the Dockerfile and the CI config, then go to step 2. Do not upgrade the project and do not replace a dependency it already uses.

## 1. Look up the versions

| You need | Look here |
|---|---|
| Current LTS or stable release of a runtime, language, framework or database | `curl -s https://endoflife.date/api/<product>.json`. The first entry is the newest release line. |
| npm package | `npm view <pkg> version engines deprecated` |
| Python package | `curl -s https://pypi.org/pypi/<pkg>/json`, fields `info.version` and `info.requires_python` |
| Rust crate | `cargo info <crate>` |
| Go module | `go list -m -versions <module>` |
| Anything else | The registry of that ecosystem, or `gh release view --repo <owner>/<repo>` |

- Take the LTS where the ecosystem has one, and the latest stable release where it does not. Skip pre-releases.
- The target is the version you looked up, not the version that happens to be installed.
- Pin the target where the project reads it: the manifest, the version file, the Dockerfile tag, the CI workflow.
- Without network access, use the installed toolchain and say that you could not check it.

## 2. Check what the platform does now

List the jobs the change needs, for example running the code, reloading on changes, loading configuration, HTTP requests, tests. For each job, find out how the target version does it before you think of a package. Read the `--help` output of the toolchain and the official documentation of the target version. Use Context7 or another documentation tool if the session has one.

When a built-in feature fails on the first try, read its documentation and fix your usage. Do not fall back to the package you know.

## 3. Add a package only for what is left

Add a package only when the language, the runtime and the frameworks already in the project do not do the job, and a few lines of plain code do not either. Take its version from the registry, and check that it is maintained and has no official successor.

## 4. Write for the target

Use the syntax and APIs of the target version and the config format that the current version of each tool documents. Add no polyfill or fallback for a version below the target.

## Report

Say which versions you chose and where you looked them up, which packages you did not add because the platform covers the job, and what you could not verify.
