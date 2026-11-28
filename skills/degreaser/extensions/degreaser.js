import { readFileSync } from "node:fs";

const rule = readFileSync(new URL("../before-pr.md", import.meta.url), "utf8");

export default function (pi) {
  pi.on("before_agent_start", (event) => {
    event.systemPromptOptions.sections["degreaser"] = rule;
  });
}
