import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const script = fileURLToPath(new URL("../hooks/remind.sh", import.meta.url));
const tools = { bash: "Bash", powershell: "PowerShell", write: "Write", edit: "Edit" };

// Returns what remind.sh prints. A reminder must never stop Pi, so a run that
// fails counts as a run that printed nothing.
function remind(args, input = "") {
  const { status, stdout } = spawnSync("sh", [script, ...args], { input, encoding: "utf8" });
  return status === 0 ? stdout.trim() : "";
}

const startNote = remind(["start"]);

export default function (pi) {
  if (!startNote) return;

  pi.on("before_agent_start", (event) => {
    event.systemPromptOptions.sections["rip-van-winkle"] = startNote;
  });

  pi.on("tool_call", (event, ctx) => {
    const tool = tools[event.toolName];
    if (!tool) return;
    const output = remind([], JSON.stringify({
      session_id: ctx.sessionManager.getSessionId(),
      tool_name: tool,
      tool_input: { command: event.input.command, file_path: event.input.path },
    }));
    if (!output) return;
    const note = JSON.parse(output).hookSpecificOutput.additionalContext;
    // Without triggerTurn: false Pi queues the note as a steering message,
    // and every queued note costs one more model request.
    pi.sendMessage({ customType: "rip-van-winkle", content: note, display: false }, { triggerTurn: false });
  });
}
