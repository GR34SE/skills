import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";

const isEffect = (name) => name === "effect" || name.startsWith("@effect/");

const manifestUsesEffect = (dir) => {
  try {
    const manifest = JSON.parse(readFileSync(join(dir, "package.json"), "utf8"));
    const { dependencies, devDependencies, peerDependencies } = manifest;
    return Object.keys({ ...dependencies, ...devDependencies, ...peerDependencies }).some(isEffect);
  } catch {
    return false; // missing or malformed manifest: not an Effect project as far as we can tell
  }
};

export const usesEffect = (dir) =>
  manifestUsesEffect(dir) || (dirname(dir) !== dir && usesEffect(dirname(dir)));

export const rules = () => readFileSync(join(import.meta.dirname, "../SKILL.md"), "utf8");

if (import.meta.main && usesEffect(process.cwd())) {
  process.stdout.write(rules());
}
