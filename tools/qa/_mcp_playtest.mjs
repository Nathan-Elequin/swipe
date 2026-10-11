import { spawn } from "node:child_process";
import { writeFileSync, mkdirSync } from "node:fs";
import { join } from "node:path";

const evidence = join("C:/Users/Natha/Documents/boss-rush/design/qa/reports/evidence");
mkdirSync(evidence, { recursive: true });

const proc = spawn("npx", ["-y", "@satelliteoflove/godot-mcp"], {
  shell: true,
  stdio: ["pipe", "pipe", "pipe"],
  env: { ...process.env, GODOT_MCP_VERBOSE: "1", GODOT_HOST: "127.0.0.1", GODOT_PORT: "6550" },
});

let buf = "";
const pending = new Map();
proc.stdout.on("data", (d) => {
  buf += d.toString();
  const lines = buf.split("\n");
  buf = lines.pop() ?? "";
  for (const line of lines) {
    const t = line.trim();
    if (!t) continue;
    let msg;
    try {
      msg = JSON.parse(t);
    } catch {
      continue;
    }
    if (msg.id != null && pending.has(msg.id)) {
      pending.get(msg.id)(msg);
      pending.delete(msg.id);
    }
  }
});
proc.stderr.on("data", (d) => process.stderr.write(d));

let nextId = 1;
function call(method, params) {
  const id = nextId++;
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => {
      pending.delete(id);
      reject(new Error(`timeout ${method} ${id}`));
    }, 45000);
    pending.set(id, (msg) => {
      clearTimeout(timer);
      resolve(msg);
    });
    proc.stdin.write(JSON.stringify({ jsonrpc: "2.0", id, method, params }) + "\n");
  });
}

function notify(method, params) {
  proc.stdin.write(JSON.stringify({ jsonrpc: "2.0", method, params }) + "\n");
}

function tool(name, args) {
  return call("tools/call", { name, arguments: args });
}

function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

function saveImages(msg, stem) {
  const paths = [];
  const content = msg?.result?.content ?? [];
  let n = 0;
  for (const part of content) {
    if (part.type === "image" && part.data) {
      const p = join(evidence, `${stem}-${n}.png`);
      writeFileSync(p, Buffer.from(part.data, "base64"));
      paths.push(p);
      n += 1;
    }
  }
  const sc = msg?.result?.structuredContent;
  if (sc?.image_base64) {
    const p = join(evidence, `${stem}-sc.png`);
    writeFileSync(p, Buffer.from(sc.image_base64, "base64"));
    paths.push(p);
  }
  if (sc?.data) {
    const p = join(evidence, `${stem}-data.png`);
    writeFileSync(p, Buffer.from(sc.data, "base64"));
    paths.push(p);
  }
  return { paths, text: content.filter((c) => c.type === "text").map((c) => c.text).join("\n"), structured: sc };
}

const log = [];
try {
  await call("initialize", {
    protocolVersion: "2024-11-05",
    capabilities: {},
    clientInfo: { name: "swipe-qa-demo", version: "0" },
  });
  notify("notifications/initialized");
  await sleep(2500);

  const state1 = await tool("godot_editor_read", { action: "get_state" });
  log.push({ step: "get_state", state1 });

  const playing = state1?.result?.structuredContent?.is_playing;
  if (playing) {
    log.push({ step: "stop", ...(await tool("godot_editor_edit", { action: "stop" })) });
    await sleep(800);
  }

  log.push({ step: "run", ...(await tool("godot_editor_edit", { action: "run" })) });
  await sleep(4000);

  const state2 = await tool("godot_editor_read", { action: "get_state" });
  log.push({ step: "playing", state2 });

  const shot1 = saveImages(await tool("godot_editor_read", { action: "screenshot_game", max_width: 900 }), "2026-10-10-title");
  log.push({ step: "screenshot_title", paths: shot1.paths, text: shot1.text?.slice(0, 400) });

  const key = await tool("godot_input", {
    action: "sequence",
    inputs: [{ key: "Space", duration_ms: 80 }],
  });
  log.push({ step: "key_space", key });

  const execOpen = await tool("godot_exec", {
    action: "run",
    source: `var m = tree.current_scene
m._open_dev_test()
m._dev_add_monster("goblin")
m._dev_add_item("shield")
m._dev_add_item("throwing_knife")
var QaProbe = load("res://tools/qa/qa_probe.gd")
return JSON.stringify(QaProbe.dump(m))`,
  });
  log.push({ step: "exec_devtest", execOpen });

  await sleep(500);
  const shot2 = saveImages(await tool("godot_editor_read", { action: "screenshot_game", max_width: 900 }), "2026-10-10-devtest");
  log.push({ step: "screenshot_devtest", paths: shot2.paths });

  const execPlay = await tool("godot_exec", {
    action: "run",
    source: `var m = tree.current_scene
m._dev_enter()
var QaProbe = load("res://tools/qa/qa_probe.gd")
return JSON.stringify(QaProbe.dump(m))`,
  });
  log.push({ step: "exec_enter", execPlay });

  await sleep(400);
  const execSpin = await tool("godot_exec", {
    action: "run",
    source: `tree.current_scene._on_spin()
return "spin_started"`,
  });
  log.push({ step: "exec_spin", execSpin });

  const stepped = await tool("godot_game_time", {
    action: "step_until",
    until: 'str(tree.current_scene.phase) == "fighting" or str(tree.current_scene.phase) == "defeat"',
    max_ms: 8000,
  });
  log.push({ step: "step_until_fight", stepped });

  const dumpFight = await tool("godot_exec", {
    action: "run",
    source: `var QaProbe = load("res://tools/qa/qa_probe.gd")
return JSON.stringify(QaProbe.dump(tree.current_scene))`,
  });
  log.push({ step: "dump_fight", dumpFight });

  const useShield = await tool("godot_exec", {
    action: "run",
    source: `var m = tree.current_scene
var uid = -1
for it in m.hotbar:
	if str(it.get("card_id","")) == "shield":
		uid = int(it.get("uid", -1))
		break
if uid >= 0:
	m._use_item(uid)
return str(uid)`,
  });
  log.push({ step: "use_shield", useShield });
  await sleep(800);

  const dumpBlk = await tool("godot_exec", {
    action: "run",
    source: `var QaProbe = load("res://tools/qa/qa_probe.gd")
return JSON.stringify(QaProbe.dump(tree.current_scene))`,
  });
  log.push({ step: "dump_after_shield", dumpBlk });

  const useKnife = await tool("godot_exec", {
    action: "run",
    source: `var m = tree.current_scene
var uid = -1
for it in m.hotbar:
	if str(it.get("card_id","")) == "throwing_knife":
		uid = int(it.get("uid", -1))
		break
if uid >= 0:
	m._use_item(uid)
return str(uid)`,
  });
  log.push({ step: "use_knife", useKnife });
  await sleep(600);

  const pickThrow = await tool("godot_exec", {
    action: "run",
    source: `var m = tree.current_scene
m._choose_option({"id": "throw", "atk": 3, "keep": false})
return "chose_throw"`,
  });
  log.push({ step: "knife_choice", pickThrow });
  await sleep(800);

  const dumpAtk = await tool("godot_exec", {
    action: "run",
    source: `var QaProbe = load("res://tools/qa/qa_probe.gd")
return JSON.stringify(QaProbe.dump(tree.current_scene))`,
  });
  log.push({ step: "dump_after_atk", dumpAtk });

  const shot3 = saveImages(await tool("godot_editor_read", { action: "screenshot_game", max_width: 900 }), "2026-10-10-fight");
  log.push({ step: "screenshot_fight", paths: shot3.paths });

  const logs = await tool("godot_editor_read", { action: "get_log_messages", severity: "all", limit: 40 });
  log.push({ step: "editor_log", logs });

  writeFileSync(join(evidence, "2026-10-10-playtest-log.json"), JSON.stringify(log, null, 2));
  console.log("WROTE", join(evidence, "2026-10-10-playtest-log.json"));
  console.log("SHOTS", JSON.stringify({ title: shot1.paths, devtest: shot2.paths, fight: shot3.paths }));
} catch (e) {
  writeFileSync(join(evidence, "2026-10-10-playtest-error.json"), JSON.stringify({ error: String(e), log }, null, 2));
  console.error(e);
} finally {
  try {
    proc.stdin.end();
  } catch {
    /* ignore */
  }
  proc.kill();
}
