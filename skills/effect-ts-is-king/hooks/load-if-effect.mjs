import { globSync, readFileSync } from "node:fs";
import { dirname, join } from "node:path";

const isEffect = (name) => name === "effect" || name.startsWith("@effect/");

const manifestUsesEffect = (file) => {
  try {
    const { dependencies, devDependencies, peerDependencies } = JSON.parse(readFileSync(file, "utf8"));
    return Object.keys({ ...dependencies, ...devDependencies, ...peerDependencies }).some(isEffect);
  } catch {
    return false; // missing or malformed manifest: not an Effect project as far as we can tell
  }
};

const ancestors = (dir) => (dirname(dir) === dir ? [dir] : [dir, ...ancestors(dirname(dir))]);

// Looks up to the filesystem root, and two levels down for workspace folders such as packages/api.
export const usesEffect = (dir) =>
  [
    ...ancestors(dir).map((folder) => join(folder, "package.json")),
    ...globSync("{*,*/*}/package.json", { cwd: dir, exclude: ["node_modules/**"] }).map((file) => join(dir, file)),
  ].some(manifestUsesEffect);

export const rules = () => readFileSync(join(import.meta.dirname, "../SKILL.md"), "utf8");

if (import.meta.main && usesEffect(process.env.CLAUDE_PROJECT_DIR ?? process.cwd())) {
  process.stdout.write(rules());
}
