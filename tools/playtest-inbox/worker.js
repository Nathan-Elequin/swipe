const CORS_HEADERS = {
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "content-type, x-swipe-playtest, user-agent",
};

function cors(request) {
  const origin = request.headers.get("Origin") || "*";
  return {
    ...CORS_HEADERS,
    "Access-Control-Allow-Origin": origin,
    Vary: "Origin",
  };
}

function json(data, status, request) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json", ...cors(request) },
  });
}

function clip(s, n) {
  const t = String(s || "").trim();
  if (t.length <= n) return t;
  return t.slice(0, n - 1) + "…";
}

function issueTitle(payload) {
  const name = String(payload.card_name || "").trim();
  const kind = String(payload.kind || "").trim();
  if (kind === "ranks") return "[playtest] tier list";
  if (name) return clip(`[playtest] ${name}`, 80);
  return "[playtest] general";
}

function issueBody(payload) {
  const lines = [];
  const cardId = String(payload.card_id || "").trim();
  const cardName = String(payload.card_name || "").trim();
  if (cardId || cardName) {
    lines.push(`**card:** ${cardName} (\`${cardId}\`)`);
  }
  const preset = String(payload.preset || "").trim();
  if (preset) lines.push(`**preset:** ${preset}`);
  const when = String(payload.when || "").trim();
  if (when) lines.push(`**when:** ${when}`);
  const build = String(payload.build || "").trim();
  if (build) lines.push(`**build:** ${build}`);
  const note = String(payload.note || "").trim();
  if (note) {
    lines.push("");
    lines.push(note);
  }
  const fightLog = String(payload.log || "").trim();
  if (fightLog) {
    lines.push("");
    lines.push("### Log");
    lines.push("```");
    lines.push(clip(fightLog, 60000));
    lines.push("```");
  }
  if (payload.ranks && typeof payload.ranks === "object") {
    lines.push("");
    lines.push("### Ranking");
    lines.push("```json");
    lines.push(JSON.stringify(payload.ranks, null, 2).slice(0, 60000));
    lines.push("```");
  }
  if (lines.length === 0) lines.push("(empty)");
  return lines.join("\n");
}

export default {
  async fetch(request, env) {
    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: cors(request) });
    }
    if (request.method !== "POST") {
      return json({ error: "method" }, 405, request);
    }
    const token = request.headers.get("x-swipe-playtest") || "";
    if (!env.PLAYTEST_TOKEN || token !== env.PLAYTEST_TOKEN) {
      return json({ error: "unauthorized" }, 401, request);
    }
    if (!env.GITHUB_TOKEN || !env.GITHUB_REPO) {
      return json({ error: "server" }, 500, request);
    }
    let payload = {};
    try {
      payload = await request.json();
    } catch (e) {
      return json({ error: "json" }, 400, request);
    }
    const res = await fetch(`https://api.github.com/repos/${env.GITHUB_REPO}/issues`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${env.GITHUB_TOKEN}`,
        Accept: "application/vnd.github+json",
        "User-Agent": "swipe-playtest-inbox",
        "X-GitHub-Api-Version": "2022-11-28",
      },
      body: JSON.stringify({
        title: issueTitle(payload),
        body: issueBody(payload),
        labels: ["playtest"],
      }),
    });
    const text = await res.text();
    if (!res.ok) {
      return json({ error: "github", status: res.status, detail: clip(text, 500) }, 502, request);
    }
    let issue = {};
    try {
      issue = JSON.parse(text);
    } catch (e) {
      issue = {};
    }
    return json({ ok: true, number: issue.number || 0, html_url: issue.html_url || "" }, 201, request);
  },
};
