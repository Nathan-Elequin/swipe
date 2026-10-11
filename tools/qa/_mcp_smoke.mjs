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
function rpc(method, params) {
  const id = nextId++;
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => {
      pending.delete(id);
      reject(new Error(`timeout ${method}`));
    }, 40000);
    pending.set(id, (msg) => {
      clearTimeout(timer);
      resolve(msg);
    });
    proc.stdin.write(JSON.stringify({ jsonrpc: "2.0", id, method, params }) + "\n");
  });
}
function tool(name, args) {
  return rpc("tools/call", { name, arguments: args });
}
function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}
function saveImages(msg, stem) {
  const paths = [];
  for (const part of msg?.result?.content ?? []) {
    if (part.type === "image" && part.data) {
      const p = join(evidence, `${stem}.png`);
      writeFileSync(p, Buffer.from(part.data, "base64"));
      paths.push(p);
    }
  }
  const sc = msg?.result?.structuredContent;
  const b64 = sc?.image_base64 || sc?.data;
  if (b64 && typeof b64 === "string" && b64.length > 80) {
    const p = join(evidence, `${stem}-sc.png`);
    writeFileSync(p, Buffer.from(b64, "base64"));
    paths.push(p);
  }
  const text = (msg?.result?.content ?? []).filter((c) => c.type === "text").map((c) => c.text).join("\n");
  return { paths, text, structured: sc, isError: Boolean(msg?.result?.isError) };
}

const out = {};
try {
  await rpc("initialize", {
    protocolVersion: "2024-11-05",
    capabilities: {},
    clientInfo: { name: "swipe-qa-proof", version: "0" },
  });
  proc.stdin.write(JSON.stringify({ jsonrpc: "2.0", method: "notifications/initialized" }) + "\n");
  await sleep(2500);
  out.state = await tool("godot_editor_read", { action: "get_state" });
  const playing = out.state?.result?.structuredContent?.is_playing;
  if (playing) {
    await tool("godot_editor_edit", { action: "stop" });
    await sleep(700);
  }
  out.run = await tool("godot_editor_edit", { action: "run" });
  await sleep(4500);
  out.playing = await tool("godot_editor_read", { action: "get_state" });
  const shot = saveImages(await tool("godot_editor_read", { action: "screenshot_game", max_width: 900 }), "2026-10-10-mcp-proof");
  out.screenshot = { paths: shot.paths, text: (shot.text || "").slice(0, 300), isError: shot.isError };
  out.key = await tool("godot_input", {
    action: "sequence",
    inputs: [{ key: "Space", duration_ms: 100 }],
  });
  await sleep(400);
  out.exec = await tool("godot_exec", {
    action: "run",
    source: `var QaProbe = load("res://tools/qa/qa_probe.gd")
return JSON.stringify(QaProbe.dump(tree.current_scene))`,
  });
  out.log = await tool("godot_editor_read", { action: "get_log_messages", severity: "error", limit: 20 });
  writeFileSync(join(evidence, "2026-10-10-mcp-proof.json"), JSON.stringify(out, null, 2));
  console.log("PROOF_OK");
  console.log(JSON.stringify({
    scene: out.playing?.result?.structuredContent,
    shots: shot.paths,
    exec: out.exec?.result?.content?.[0]?.text?.slice(0, 400),
    log: out.log?.result?.content?.[0]?.text?.slice(0, 400),
  }, null, 2));
} catch (e) {
  console.error("PROOF_FAIL", e);
  writeFileSync(join(evidence, "2026-10-10-mcp-proof-error.txt"), String(e));
} finally {
  try { proc.stdin.end(); } catch { /* ignore */ }
  proc.kill();
}
