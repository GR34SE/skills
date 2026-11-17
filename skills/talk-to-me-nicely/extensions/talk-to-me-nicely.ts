// Pi extension. Puts the rules from SKILL.md into the system prompt of every run,
// so they apply from the first reply without a skill call.
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const skillPath = join(dirname(fileURLToPath(import.meta.url)), "..", "SKILL.md");
const rules = readFileSync(skillPath, "utf8").replace(/^---\r?\n[\s\S]*?\r?\n---\r?\n/, "").trim();

export default function (pi: any) {
  pi.on("before_agent_start", async (event: any) => {
    const sections = event?.systemPromptOptions?.sections;
    if (sections && typeof sections === "object") {
      sections["talk-to-me-nicely"] = rules;
      return;
    }
    return { systemPrompt: `${event.systemPrompt}\n\n${rules}` };
  });
}
