import { readFileSync } from "node:fs";

const rules = readFileSync(new URL("../SKILL.md", import.meta.url), "utf8");

export default function (pi) {
  pi.on("before_agent_start", (event) => {
    event.systemPromptOptions.sections["talk-to-me-nicely"] = rules;
  });
}
