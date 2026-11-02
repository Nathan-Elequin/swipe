const CORS_HEADERS = {
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "content-type, x-swipe-playtest, user-agent",
};

const LETTER_SCORE = { S: 5, A: 4, B: 3, C: 2, D: 1, F: 0 };
const LETTERS = ["S", "A", "B", "C", "D", "F"];

function cors(request) {
  const origin = request.headers.get("Origin") || "*";
  return {
    ...CORS_HEADERS,
    "Access-Control-Allow-Origin": origin === "null" ? "*" : origin,
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

function authorized(request, env) {
  const token = request.headers.get("x-swipe-playtest") || "";
  return Boolean(env.PLAYTEST_TOKEN) && token === env.PLAYTEST_TOKEN;
}

function issueTitle(payload) {
  const name = String(payload.card_name || "").trim();
  const kind = String(payload.kind || "").trim();
  if (kind === "ranks") return "[playtest] tier list";
  if (name) return clip(`[playtest] ${name}`, 80);
  const note = String(payload.note || "").trim().split("\n")[0];
  if (note) return clip(`[playtest] ${note}`, 80);
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

function asRanks(payload) {
  if (payload && typeof payload.ranks === "object" && payload.ranks) {
    return payload.ranks;
  }
  return payload && typeof payload === "object" ? payload : {};
}

function parsePlacements(ranks) {
  const kind = String(ranks.kind || "").trim();
  const cardTier = Number(ranks.card_tier || 0);
  const rows = ranks.rows && typeof ranks.rows === "object" ? ranks.rows : {};
  const out = [];
  const seen = {};
  for (const letter of LETTERS) {
    const ids = rows[letter];
    if (!Array.isArray(ids)) continue;
    for (const raw of ids) {
      const cardId = String(raw || "").trim();
      if (!cardId || seen[cardId]) continue;
      seen[cardId] = true;
      out.push({ card_id: cardId, letter, score: LETTER_SCORE[letter] });
    }
  }
  return { kind, cardTier, buckets: ranks.buckets || [], placements: out };
}

async function insertList(env, payload, extras) {
  if (!env.TIER_DB) {
    throw new Error("no-d1");
  }
  const ranks = asRanks(payload);
  const parsed = parsePlacements(ranks);
  if (parsed.kind !== "item" && parsed.kind !== "monster") {
    return { error: "kind" };
  }
  if (parsed.cardTier < 1 || parsed.cardTier > 3) {
    return { error: "card_tier" };
  }
  const source = String(extras.source || payload.source || "").trim() || "unknown";
  const isTest =
    extras.is_test === true ||
    extras.is_test === 1 ||
    payload.is_test === true ||
    source === "editor";
  const received = new Date().toISOString();
  const info = await env.TIER_DB.prepare(
    `INSERT INTO lists (received_at, kind, card_tier, buckets, source, build, preset, when_client, is_test, discarded, note, github_issue)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0, ?, ?)`
  )
    .bind(
      received,
      parsed.kind,
      parsed.cardTier,
      JSON.stringify(parsed.buckets),
      source,
      String(payload.build || "").slice(0, 120),
      String(payload.preset || "").slice(0, 80),
      String(payload.when || "").slice(0, 40),
      isTest ? 1 : 0,
      String(extras.note || payload.note || "").slice(0, 240),
      extras.github_issue || null
    )
    .run();
  const listId = info.meta.last_row_id;
  if (parsed.placements.length > 0) {
    const stmt = env.TIER_DB.prepare(
      "INSERT INTO ranks (list_id, card_id, letter, score) VALUES (?, ?, ?, ?)"
    );
    const batch = parsed.placements.map((p) =>
      stmt.bind(listId, p.card_id, p.letter, p.score)
    );
    await env.TIER_DB.batch(batch);
  }
  return {
    ok: true,
    list_id: listId,
    placed: parsed.placements.length,
    is_test: isTest,
  };
}

function median(nums) {
  if (!nums.length) return null;
  const s = [...nums].sort((a, b) => a - b);
  const mid = Math.floor(s.length / 2);
  if (s.length % 2) return s[mid];
  return (s[mid - 1] + s[mid]) / 2;
}

async function summary(env) {
  const lists = await env.TIER_DB.prepare(
    `SELECT id, received_at, kind, card_tier, buckets, source, build, preset, when_client, is_test, discarded, note, github_issue
     FROM lists ORDER BY id DESC LIMIT 200`
  ).all();
  const ranks = await env.TIER_DB.prepare(
    `SELECT r.list_id, r.card_id, r.letter, r.score, l.kind, l.card_tier, l.is_test, l.discarded
     FROM ranks r JOIN lists l ON l.id = r.list_id`
  ).all();
  const cards = {};
  for (const row of ranks.results || []) {
    if (row.is_test || row.discarded) continue;
    const key = `${row.kind}|${row.card_tier}|${row.card_id}`;
    if (!cards[key]) {
      cards[key] = {
        card_id: row.card_id,
        kind: row.kind,
        card_tier: row.card_tier,
        n: 0,
        scores: [],
        hist: { S: 0, A: 0, B: 0, C: 0, D: 0, F: 0 },
      };
    }
    const c = cards[key];
    c.n += 1;
    c.scores.push(row.score);
    if (c.hist[row.letter] != null) c.hist[row.letter] += 1;
  }
  const cardRows = Object.values(cards).map((c) => {
    const sum = c.scores.reduce((a, b) => a + b, 0);
    return {
      card_id: c.card_id,
      kind: c.kind,
      card_tier: c.card_tier,
      n: c.n,
      mean: c.n ? Math.round((sum / c.n) * 100) / 100 : null,
      median: median(c.scores),
      hist: c.hist,
    };
  });
  cardRows.sort((a, b) => {
    if (a.kind !== b.kind) return a.kind.localeCompare(b.kind);
    if (a.card_tier !== b.card_tier) return a.card_tier - b.card_tier;
    const am = a.mean == null ? -1 : a.mean;
    const bm = b.mean == null ? -1 : b.mean;
    if (bm !== am) return bm - am;
    return a.card_id.localeCompare(b.card_id);
  });
  return {
    score_map: LETTER_SCORE,
    counted: "live lists only (not test, not discarded)",
    lists: lists.results || [],
    cards: cardRows,
  };
}

async function setDiscard(env, listId, discarded) {
  const id = Number(listId);
  if (!id) return { error: "list_id" };
  await env.TIER_DB.prepare(
    "UPDATE lists SET discarded = ?, discarded_at = ? WHERE id = ?"
  )
    .bind(discarded ? 1 : 0, discarded ? new Date().toISOString() : null, id)
    .run();
  return { ok: true, list_id: id, discarded: Boolean(discarded) };
}

async function openGithubIssue(payload, env) {
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
    return { error: "github", status: res.status, detail: clip(text, 500) };
  }
  let issue = {};
  try {
    issue = JSON.parse(text);
  } catch (e) {
    issue = {};
  }
  return { ok: true, number: issue.number || 0, html_url: issue.html_url || "" };
}

export default {
  async fetch(request, env) {
    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: cors(request) });
    }
    if (!authorized(request, env)) {
      return json({ error: "unauthorized" }, 401, request);
    }
    const url = new URL(request.url);
    const view = url.searchParams.get("view") || "";

    if (request.method === "GET") {
      if (!env.TIER_DB) return json({ error: "no-d1" }, 500, request);
      if (view === "tier" || view === "summary") {
        return json(await summary(env), 200, request);
      }
      return json({ error: "view" }, 400, request);
    }

    if (request.method !== "POST") {
      return json({ error: "method" }, 405, request);
    }

    let payload = {};
    try {
      payload = await request.json();
    } catch (e) {
      return json({ error: "json" }, 400, request);
    }

    const kind = String(payload.kind || "").trim();

    if (kind === "ranks" || kind === "tier_import") {
      try {
        const extras = {
          source: payload.source,
          is_test: kind === "tier_import" ? payload.is_test !== false : payload.is_test,
          note: payload.note,
          github_issue: payload.github_issue || null,
        };
        const result = await insertList(env, payload, extras);
        if (result.error) return json(result, 400, request);
        return json(result, 201, request);
      } catch (e) {
        return json({ error: "d1", detail: clip(String(e && e.message), 200) }, 500, request);
      }
    }

    if (kind === "tier_discard") {
      if (!env.TIER_DB) return json({ error: "no-d1" }, 500, request);
      const result = await setDiscard(env, payload.list_id, payload.discarded !== false);
      if (result.error) return json(result, 400, request);
      return json(result, 200, request);
    }

    if (!env.GITHUB_TOKEN || !env.GITHUB_REPO) {
      return json({ error: "server" }, 500, request);
    }
    const gh = await openGithubIssue(payload, env);
    if (gh.error) {
      return json(gh, 502, request);
    }
    return json(gh, 201, request);
  },
};
