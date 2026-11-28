import { readFileSync } from "node:fs";

const rule = readFileSync(new URL("../before-new-code.md", import.meta.url), "utf8");

export default function (pi) {
  pi.on("before_agent_start", (event) => {
    event.systemPromptOptions.sections["rip-van-winkle"] = rule;
  });
}
