import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const script = fileURLToPath(new URL("../hooks/pre-pr.sh", import.meta.url));

export default function (pi) {
  pi.on("tool_call", (event) => {
    if (event.toolName !== "bash") return;
    const input = JSON.stringify({ tool_name: "Bash", tool_input: { command: event.input.command } });
    const result = spawnSync("sh", [script], { input, encoding: "utf8" });
    if (result.status === 2) return { block: true, reason: result.stderr.trim() };
  });
}
