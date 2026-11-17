#!/usr/bin/env node
// Prints SKILL.md when the project depends on Effect. Prints nothing otherwise.
import { readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

const MAX_DEPTH = 3; // root, plus two levels of workspace folders such as packages/api
const SKIP = new Set(["node_modules", "dist", "build"]);
const isEffect = (name) => name === "effect" || name.startsWith("@effect/");

const manifestUsesEffect = (file) => {
  try {
    const pkg = JSON.parse(readFileSync(file, "utf8"));
    return [pkg.dependencies, pkg.devDependencies, pkg.peerDependencies].some(
      (deps) => deps && Object.keys(deps).some(isEffect),
    );
  } catch {
    return false; // missing or malformed manifest: not an Effect project as far as we can tell
  }
};

export const usesEffect = (dir, depth = 1) => {
  if (manifestUsesEffect(join(dir, "package.json"))) return true;
  if (depth >= MAX_DEPTH) return false;
  let entries;
  try {
    entries = readdirSync(dir, { withFileTypes: true });
  } catch {
    return false;
  }
  return entries.some(
    (e) =>
      e.isDirectory() &&
      !e.name.startsWith(".") &&
      !SKIP.has(e.name) &&
      usesEffect(join(dir, e.name), depth + 1),
  );
};

export const rules = () => readFileSync(new URL("../SKILL.md", import.meta.url), "utf8");

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  if (usesEffect(process.env.CLAUDE_PROJECT_DIR || process.cwd())) process.stdout.write(rules());
}
