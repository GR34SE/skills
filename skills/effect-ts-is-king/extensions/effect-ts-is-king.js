import { rules, usesEffect } from "../hooks/load-if-effect.mjs";

export default function (pi) {
  pi.on("before_agent_start", (event) => {
    if (usesEffect(process.cwd())) event.systemPromptOptions.sections["effect-ts-is-king"] = rules();
  });
}
