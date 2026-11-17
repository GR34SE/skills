import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { cpSync, mkdtempSync, mkdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import test from "node:test";

const root = new URL("../", import.meta.url);
const source = new URL("skills/talk-to-me-nicely/", root);
const rules = readFileSync(new URL("SKILL.md", source), "utf8");
const readJson = (file) => JSON.parse(readFileSync(file, "utf8"));

function fixture(t) {
  const directory = mkdtempSync(join(tmpdir(), "skills adapters $ "));
  t.after(() => rmSync(directory, { recursive: true, force: true }));
  const plugin = join(directory, "plugin");
  const project = join(directory, "project");
  cpSync(source, plugin, { recursive: true });
  mkdirSync(project);
  return { plugin, project };
}

function run(command, { plugin, project }, input) {
  const result = spawnSync("sh", ["-c", command], {
    cwd: project,
    env: {
      ...process.env,
      CLAUDE_PLUGIN_ROOT: plugin,
      CURSOR_PLUGIN_ROOT: plugin,
      PLUGIN_ROOT: plugin,
    },
    input: JSON.stringify(input),
    encoding: "utf8",
    timeout: 5000,
  });
  assert.ifError(result.error);
  assert.equal(result.status, 0, result.stderr);
  assert.equal(result.stderr, "");
  return result.stdout;
}

// Codex SessionStart sources and matcher semantics:
// https://developers.openai.com/codex/hooks/#matcher-patterns
for (const source of ["startup", "resume", "clear", "compact", "fork"]) {
  test(`shared SessionStart hook emits the complete rules for ${source}`, (t) => {
    const paths = fixture(t);
    const config = readJson(join(paths.plugin, "hooks/hooks.json"));
    const commands = config.hooks.SessionStart
      .filter(({ matcher }) => !matcher || matcher === "*" || new RegExp(matcher).test(source))
      .flatMap(({ hooks }) => hooks);
    assert.equal(commands.length, 1);
    const [handler] = commands;
    assert.equal(handler.type, "command");
    assert.equal(run(handler.command, paths, {
      hook_event_name: "SessionStart",
      source,
      cwd: paths.project,
    }), rules);
  });
}

test("Cursor's versioned hook configuration emits rules outside the plugin directory", (t) => {
  const paths = fixture(t);
  const manifest = readJson(join(paths.plugin, ".cursor-plugin/plugin.json"));
  const { version, hooks } = manifest.hooks;
  assert.equal(version, 1);
  assert.equal(hooks.sessionStart.length, 1);
  const output = JSON.parse(run(hooks.sessionStart[0].command, paths, {
    session_id: "adapter-test",
    is_background_agent: false,
  }));
  assert.equal(output.additional_context, rules);

  const updatedRules = `${rules}\nA tab:\tA quote: "A path: \\\\test"\n`;
  writeFileSync(join(paths.plugin, "SKILL.md"), updatedRules);
  const updated = JSON.parse(run(hooks.sessionStart[0].command, paths, {
    session_id: "adapter-test-2",
    is_background_agent: false,
  }));
  assert.equal(updated.additional_context, updatedRules);
});

test("Pi's registered extension supplies rules each turn without replacing other sections", async () => {
  const manifest = readJson(new URL("package.json", root));
  assert.equal(manifest.pi.extensions.length, 1);
  const { default: register } = await import(new URL(manifest.pi.extensions[0], root));
  const handlers = new Map();
  register({ on: (event, handler) => handlers.set(event, handler) });
  assert.equal(typeof handlers.get("before_agent_start"), "function");
  for (const prompt of ["A quick question", "Another quick question"]) {
    const event = {
      prompt,
      systemPromptOptions: { sections: { existing: "Keep this section" } },
    };
    await handlers.get("before_agent_start")(event);
    assert.deepEqual(event.systemPromptOptions.sections, {
      existing: "Keep this section",
      "talk-to-me-nicely": rules,
    });
  }
});
