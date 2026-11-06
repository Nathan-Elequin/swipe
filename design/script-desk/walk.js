/* Tutorial walk: one row per line, highlight, and click, plus notes. */
var focusTa = null;

var LIGHT = { gold: "#E8C36A", hp: "#E8A0A0", atk: "#E07A7A", defeat: "#C9A0FF", block: "#6BB3D9" };
var PAPER = {
  "#E8C36A": "#6a3c00",
  "#E8A0A0": "#7a1212",
  "#E07A7A": "#8d1414",
  "#C9A0FF": "#4e1c86",
  "#6BB3D9": "#0a456e",
  "#7A2408": "#7a2408"
};
var PHRASES = [
  ["item if i never swing", LIGHT.gold],
  ["no attack damage", LIGHT.gold],
  ["no atk damage", LIGHT.gold],
  ["attacks twice", LIGHT.gold],
  ["double hit", LIGHT.gold],
  ["ignores block", LIGHT.gold],
  ["times you bled", LIGHT.hp],
  ["monsters left", LIGHT.defeat],
  ["take their atk", LIGHT.hp],
  ["heal their hp", LIGHT.hp],
  ["last enemy atk", LIGHT.atk],
  ["last enemy hp", LIGHT.hp],
  ["higher neighbor", LIGHT.atk],
  ["neighbor atk", LIGHT.atk],
  ["neighbor hp", LIGHT.hp],
  ["enemy atk", LIGHT.atk],
  ["enemy hp", LIGHT.hp],
  ["your hp", LIGHT.hp],
  ["even atk", LIGHT.gold],
  ["any monster", LIGHT.gold],
  ["phoenix egg", LIGHT.gold],
  ["phoenix", LIGHT.gold],
  ["bear trap", LIGHT.gold]
];
var STEMS = [
  "defeated", "defeats", "defeating", "defeat",
  "marked", "marks", "mark",
  "attacks", "attacking", "attacked", "attack",
  "blocked", "blocking", "blocks", "block",
  "defending", "defends", "defend",
  "heals", "healed", "healing", "heal",
  "thorns", "thorn", "keep", "move",
  "bled", "bleeds", "bleeding", "bleed",
  "fleeing", "flees", "fled", "flee",
  "poisoned", "poisons", "poison", "any",
  "petrifies", "petrified", "petrify",
  "gaze", "gazed", "decayed", "decay",
  "hex", "toll", "curse", "beggar",
  "spinning", "spins", "spun", "spin",
  "losing", "loses", "lost", "lose",
  "always", "eject", "unplayable", "rust",
  "evasive", "facing", "immediately",
  "atk", "blk", "hp"
];
var WORD_NUMS = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "twice", "thrice"];
var CONTROL_NAMES = {
  end_fight: "Take",
  spin: "Spin",
  done: "Take",
  wheel: "the wheel",
  move: "a move arrow",
  hover: "the highlighted monster",
  hover_item: "the highlighted item",
  da_boot: "Boot",
  breastplate: "Breastplate",
  sai: "Sai",
  shield: "Shield",
  fangs: "Fangs",
  arrow_head: "Arrowhead",
  boot: "Boot",
  join: "the main path",
  trigger: "the trigger path",
  skip_only: "Skip"
};

function walkEsc(s) {
  return String(s ?? "").replace(/[&<>"']/g, (ch) => ({
    "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;"
  }[ch]));
}

function paperHex(hex) {
  return PAPER[String(hex || "").toUpperCase()] || hex;
}

function stemHex(low) {
  if (low === "always" || low === "keep" || low === "move" || low === "evasive" || low === "facing" || low === "immediately" || low === "any" || low === "rust") return LIGHT.gold;
  if (low.startsWith("defeat")) return LIGHT.defeat;
  if (low.startsWith("mark")) return LIGHT.gold;
  if (low.startsWith("attack") || low === "atk" || low.startsWith("thorn")) return LIGHT.atk;
  if (low.startsWith("block") || low === "blk" || low.startsWith("defend")) return LIGHT.block;
  if (low.startsWith("heal") || low === "hp" || low.startsWith("bleed") || low === "bled") return LIGHT.hp;
  if (low.startsWith("flee") || low.startsWith("poison") || low.startsWith("spin") || low === "spun") return LIGHT.gold;
  if (low === "swap" || low.startsWith("swap") || low === "loaded" || low.startsWith("eject")) return LIGHT.gold;
  if (low === "unplayable") return "#C8C2BA";
  if (low === "decay" || low === "decayed" || low.startsWith("decay")) return LIGHT.gold;
  if (low === "gaze" || low === "gazed" || low.startsWith("gaze") || low.startsWith("petrif")) return LIGHT.gold;
  if (low === "hex" || low === "toll" || low === "curse" || low.startsWith("beggar")) return LIGHT.gold;
  if (low.startsWith("lose") || low === "lost") return LIGHT.hp;
  return "";
}

function formatToken(tok) {
  var prefix = "";
  var suffix = "";
  var core = tok;
  var sep = /[\s()[\]{},.:;!?+−↔/—–'"“”]/;
  while (core.length && sep.test(core[0])) { prefix += core[0]; core = core.slice(1); }
  while (core.length && sep.test(core[core.length - 1])) { suffix = core[core.length - 1] + suffix; core = core.slice(0, -1); }
  if (!core) return tok;
  var low = core.toLowerCase();
  if (low === "atk" || low === "blk" || low === "hp") return prefix + low.toUpperCase() + suffix;
  if (low === "always") return prefix + "Always" + suffix;
  if (low === "unplayable") return prefix + "Unplayable" + suffix;
  if (WORD_NUMS.indexOf(low) >= 0 || /\d/.test(core)) return tok;
  if (stemHex(low)) return prefix + core[0].toUpperCase() + core.slice(1).toLowerCase() + suffix;
  return tok;
}

function formatPiece(piece) {
  return String(piece).split(/(\s+)/).map((part) => /^\s+$/.test(part) ? part : formatToken(part)).join("");
}

function hitRegex() {
  var phrases = PHRASES.map((p) => p[0].replace(/[.*+?^${}()|[\]\\]/g, "\\$&")).join("|");
  return new RegExp("(" + phrases + "|\\b(?:" + STEMS.join("|") + ")\\b|[+\\-−]?\\d+)", "gi");
}

function hitsOf(plain) {
  var rx = hitRegex();
  var raw = [];
  var m;
  while ((m = rx.exec(plain))) {
    var piece = m[1];
    var a = m.index;
    var b = a + piece.length;
    var low = piece.trim().toLowerCase();
    if (WORD_NUMS.indexOf(low) >= 0) continue;
    if (low === "any") {
      var after = plain.slice(b).trim().toLowerCase();
      if (!after.startsWith("monster") && !after.startsWith("enemy")) continue;
    }
    raw.push({ a: a, b: b });
  }
  raw.sort((x, y) => x.a - y.a);
  var merged = [];
  raw.forEach((h) => {
    var prev = merged[merged.length - 1];
    if (prev && plain.slice(prev.b, h.a).trim() === "") prev.b = h.b;
    else merged.push({ a: h.a, b: h.b });
  });
  return merged;
}

function hexFor(plain, a, b) {
  var piece = plain.slice(a, b);
  var low = piece.trim().toLowerCase();
  for (var i = 0; i < PHRASES.length; i++) {
    if (low === PHRASES[i][0]) return PHRASES[i][1];
  }
  var found = "";
  piece.split(/\s+/).forEach((tok) => {
    var core = tok.toLowerCase().replace(/^[^a-z0-9]+|[^a-z0-9]+$/gi, "");
    var h = stemHex(core);
    if (h) found = h;
  });
  if (found) return found;
  if (/\d/.test(piece)) return "#7a2408";
  return LIGHT.gold;
}

function stripTags(s) {
  return String(s).replace(/\[\/?(?:b|i|color)(?:=#[0-9A-Fa-f]{3,8})?\]/gi, "");
}

function wrapSel(chunk, kind, hex) {
  var bare = stripTags(chunk);
  if (kind === "clear") return bare;
  if (kind === "b") return "[b]" + bare + "[/b]";
  return "[color=" + hex + "][b]" + bare + "[/b][/color]";
}

function bakeExcept(plain, selA, selB, kind, hex) {
  var hits = hitsOf(plain);
  var cuts = { 0: true, [plain.length]: true, [selA]: true, [selB]: true };
  hits.forEach((h) => { cuts[h.a] = true; cuts[h.b] = true; });
  var pts = Object.keys(cuts).map(Number).filter((n) => n >= 0 && n <= plain.length).sort((a, b) => a - b);
  var out = "";
  var selBuf = "";
  function flushSel() {
    if (!selBuf) return;
    out += wrapSel(selBuf, kind, hex);
    selBuf = "";
  }
  for (var k = 0; k < pts.length - 1; k++) {
    var p = pts[k];
    var q = pts[k + 1];
    if (p === q) continue;
    var chunk = plain.slice(p, q);
    var inSel = selB > selA && p >= selA && q <= selB;
    var hit = null;
    for (var h = 0; h < hits.length; h++) {
      if (p >= hits[h].a && q <= hits[h].b) { hit = hits[h]; break; }
    }
    if (inSel) { selBuf += chunk; continue; }
    flushSel();
    if (hit) {
      var col = paperHex(hexFor(plain, hit.a, hit.b));
      out += "[color=" + col + "][b]" + formatPiece(chunk) + "[/b][/color]";
    } else out += chunk;
  }
  flushSel();
  return out;
}

function bbToHtml(src) {
  var s = String(src || "");
  var re = /\[(\/?)(b|i|color)(?:=(#[0-9A-Fa-f]{3,8}))?\]/gi;
  var html = "";
  var last = 0;
  var m;
  while ((m = re.exec(s))) {
    html += walkEsc(s.slice(last, m.index));
    last = m.index + m[0].length;
    var closing = m[1] === "/";
    var tag = m[2].toLowerCase();
    if (!closing && tag === "b") html += "<b>";
    else if (closing && tag === "b") html += "</b>";
    else if (!closing && tag === "i") html += "<i>";
    else if (closing && tag === "i") html += "</i>";
    else if (!closing && tag === "color") html += '<span style="color:' + (m[3] || "#6a3c00") + '">';
    else if (closing && tag === "color") html += "</span>";
  }
  html += walkEsc(s.slice(last));
  return html || "<span style='color:#6b4a10'>Empty line</span>";
}

function previewHtml(raw) {
  var src = String(raw || "");
  var bb = src.indexOf("[color") >= 0 ? src : bakeExcept(src, 0, 0, "clear", "");
  return bbToHtml(bb);
}

function applyFmt(kind, hex) {
  var ta = focusTa;
  var status = document.getElementById("status");
  if (!ta) {
    if (status) { status.className = "dirty"; status.textContent = "Click a line first"; }
    return;
  }
  var a = ta.selectionStart;
  var b = ta.selectionEnd;
  if (a === b) {
    if (status) { status.className = "dirty"; status.textContent = "Select the words in the line first"; }
    return;
  }
  var src = ta.value;
  var prev = src;
  if (src.indexOf("[color") < 0 && kind !== "clear") src = bakeExcept(src, a, b, kind, hex);
  else src = src.slice(0, a) + wrapSel(src.slice(a, b), kind, hex) + src.slice(b);
  ta._undoPrev = prev;
  ta.value = src;
  ta.dispatchEvent(new Event("input", { bubbles: true }));
  ta.focus();
}

function controlLabel(id) {
  var raw = String(id || "");
  if (!raw) return "";
  if (CONTROL_NAMES[raw]) return CONTROL_NAMES[raw];
  if (raw.indexOf("item:") === 0) return controlLabel(raw.slice(5));
  if (raw.indexOf("draft:") === 0) return controlLabel(raw.slice(6)) + " in the draft";
  return raw.replace(/_/g, " ");
}

function branchTitle(br) {
  if (br === "join") return "Back on the main path";
  if (br === "trigger") return "Only on the trigger path";
  if (br === "skip_only") return "Only if they skipped";
  return "Only if they chose " + controlLabel(br);
}

function tutSortKey(row) {
  var rest = String(row.key || "").replace(/^tutorial\.line\./, "");
  var parts = rest.split(".");
  var beat = parts[0] || "";
  var line = parts[1] || "0";
  var rank = "3";
  var body = beat;
  if (beat.indexOf("B") === 0) { rank = "1"; body = beat.slice(1); }
  else if (beat.indexOf("T") === 0) { rank = "2"; body = beat.slice(1); }
  else if (beat.indexOf("S") === 0) { rank = "4"; body = beat.slice(1); }
  var digits = "";
  var suffix = "";
  for (var i = 0; i < body.length; i++) {
    var ch = body[i];
    if (suffix === "" && ch >= "0" && ch <= "9") digits += ch;
    else suffix += ch;
  }
  while (digits.length < 3) digits = "0" + digits;
  while (line.length < 3) line = "0" + line;
  return rank + "-" + digits + suffix + "-" + line;
}

function momentsOf(row) {
  var out = [{ id: "say", kicker: "Line", title: "What Nib says", kind: "say" }];
  if (row.hint) out.push({ id: "hint", kicker: "Hint", title: row.hint, kind: "spot" });
  if (row.focus) out.push({ id: "highlight", kicker: "Highlight", title: controlLabel(row.focus), kind: "spot" });
  if (row.then_focus) out.push({ id: "then", kicker: "Then highlight", title: controlLabel(row.then_focus), kind: "spot" });
  var w = row.wait || "continue";
  if (w === "choice") {
    var allow = Array.isArray(row.allow) ? row.allow : [];
    if (!allow.length) out.push({ id: "click", kicker: "Choice", title: "Pick one", kind: "click" });
    allow.forEach((id) => out.push({ id: "click:" + id, kicker: "Can click", title: controlLabel(id), kind: "click" }));
  } else if (w === "auto_spin") {
    out.push({ id: "auto", kicker: "On its own", title: "The wheel spins", kind: "auto" });
  } else if (w === "continue" || w === "") {
    out.push({ id: "click", kicker: "Click", title: row.go || "Next", kind: "click" });
  } else if (w === "hover") {
    out.push({ id: "click", kicker: "Hover", title: controlLabel(row.focus || "hover"), kind: "click" });
  } else if (w === "hover_item") {
    out.push({ id: "click", kicker: "Hover", title: controlLabel(row.focus || "hover_item"), kind: "click" });
  } else if (w === "move") {
    out.push({ id: "click", kicker: "Click", title: "a move arrow", kind: "click" });
  } else if (w === "spin") {
    out.push({ id: "click", kicker: "Click", title: "Spin", kind: "click" });
  } else if (w === "done") {
    out.push({ id: "click", kicker: "Click", title: "Take", kind: "click" });
  } else if (w.indexOf("item:") === 0 || w.indexOf("draft:") === 0) {
    out.push({ id: "click", kicker: "Click", title: controlLabel(w), kind: "click" });
  } else {
    out.push({ id: "click", kicker: "Do this", title: controlLabel(w), kind: "click" });
  }
  if (row.branch) out.push({ id: "branch", kicker: "Path", title: branchTitle(row.branch), kind: "branch" });
  return out;
}

var RIG_LINES = {
  draft_shield: "Draft card: Shield",
  deck_fangs_t2: "Deck rig: Fangs, Tier 2",
  wheel_collapse: "Empty seats close",
  moves_on: "Move arrows on",
  ensure_shield: "Shield is in the hotbar",
  reveal: "Board revealed",
  deck_golem_1: "First deck draw stays the golem",
  after_golem1: "Deck waits",
  grant_arrow_head: "Arrow Head is in the hotbar",
  free_play: "Free play",
  board_d2: "Dungeon 2"
};

var FOCUS_ON = {
  wheel: "the wheel",
  spin: "Spin",
  atk: "Attack",
  hearts: "hearts",
  hp: "hearts",
  hotbar: "the hotbar",
  deck: "the deck",
  draft: "the draft",
  block: "Block",
  done: "Take",
  move: "a move arrow"
};

function onLabel(focus, row) {
  var id = String(focus || "");
  if (!id) return "";
  if (id === "draft") {
    var w = String((row && row.wait) || "");
    if (w.indexOf("draft:") === 0) return controlLabel(w.slice(6)) + " (Draft)";
    if (row && row.rig === "draft_shield") return "Shield (Draft)";
    return "the draft";
  }
  if (id.indexOf("item:") === 0) return controlLabel(id.slice(5)) + " (hotbar)";
  if (id.indexOf("draft:") === 0) return controlLabel(id.slice(6)) + " (Draft)";
  if (FOCUS_ON[id]) return FOCUS_ON[id];
  return controlLabel(id);
}

function stageBlock(row) {
  var lines = [];
  lines.push("[Nib Dialogue]");
  if (row.focus) lines.push("[Highlight] on: " + onLabel(row.focus, row));
  if (row.then_focus) lines.push("[Highlight] on: " + onLabel(row.then_focus, row));
  var w = String(row.wait || "continue");
  if (w === "choice") {
    var allow = Array.isArray(row.allow) ? row.allow : [];
    var names = allow.map(controlLabel);
    lines.push("[Choice] " + (names.length ? names.join(" / ") : "pick one"));
  } else if (w === "auto_spin") lines.push("[Spin] on its own");
  else if (w === "hover" || w === "hover_item") lines.push("[Hover] " + onLabel(row.focus || w, row));
  else if (w === "spin") lines.push("[Click] Spin");
  else if (w === "done") lines.push("[Click] Take");
  else if (w === "move") lines.push("[Click] a move arrow");
  else if (w.indexOf("item:") === 0) lines.push("[Click] " + controlLabel(w.slice(5)) + " (hotbar)");
  else if (w.indexOf("draft:") === 0) lines.push("[Click] " + controlLabel(w.slice(6)) + " (Draft)");
  else if (w !== "continue" && w !== "") lines.push("[Wait] " + w);
  if (row.branch) lines.push("*" + branchTitle(row.branch) + "*");
  return lines.join("\n");
}

function describeBeat(rows) {
  var out = [];
  var seen = {};
  rows.forEach((row) => {
    if (!row.rig || seen[row.rig]) return;
    seen[row.rig] = true;
    out.push(RIG_LINES[row.rig] ? ("*" + RIG_LINES[row.rig].replace(/\.$/, "") + "*") : ("*Setup: " + row.rig + "*"));
  });
  var prev = "";
  rows.forEach((row) => {
    var block = stageBlock(row);
    if (!block || block === prev) return;
    if (out.length) out.push("");
    out.push(block);
    prev = block;
  });
  out.push("");
  out.push("*Player Facing:*");
  return out.join("\n").trim();
}

function stageHtml(src) {
  return String(src || "").split("\n").map((line) => {
    var t = line.trim();
    if (!t) return "";
    if (t.charAt(0) === "*" && t.charAt(t.length - 1) === "*" && t.length > 2) {
      return "<em>" + walkEsc(t.slice(1, -1)) + "</em>";
    }
    var m = t.match(/^(\[[^\]]+\])\s*(.*)$/);
    if (m) return '<b class="stage-tag">' + walkEsc(m[1]) + "</b> " + walkEsc(m[2]);
    return walkEsc(t);
  }).join("<br>");
}

function appendVisuals(beat, beatRows) {
  var card = document.createElement("div");
  card.className = "step visuals";
  var hasVisual = pack.visuals && Object.prototype.hasOwnProperty.call(pack.visuals, beat);
  var saved = hasVisual ? String(pack.visuals[beat]) : "";
  var k = document.createElement("div");
  k.className = "moment-k";
  k.textContent = "Visuals";
  var title = document.createElement("div");
  title.className = "moment-d";
  title.textContent = "What is on screen during " + beat;
  var view = document.createElement("div");
  view.className = "stage-view";
  var ta = document.createElement("textarea");
  ta.className = "tall";
  ta.dataset.visualBeat = beat;
  ta.dataset.starter = describeBeat(beatRows);
  ta.value = hasVisual ? saved : ta.dataset.starter;
  var paint = () => { view.innerHTML = stageHtml(ta.value); };
  ta.addEventListener("input", () => { markDirty(); paint(); });
  paint();
  var hint = document.createElement("p");
  hint.className = "vis-hint";
  hint.textContent = "Brackets are what is on screen. Asterisks are the board, not words Nib says. Fill in Player Facing. Save, and Cursor reads it.";
  card.appendChild(k);
  card.appendChild(title);
  card.appendChild(view);
  card.appendChild(ta);
  card.appendChild(hint);
  return card;
}

function renderWalk() {
  if (window.clearDeskUndo) clearDeskUndo();
  document.body.classList.add("walk");
  var desk = document.getElementById("desk");
  var chips = document.getElementById("chips");
  desk.innerHTML = "";
  chips.innerHTML = "";
  var rows = (pack.rows || []).filter((r) => String(r.key || "").indexOf("tutorial.line.") === 0);
  rows.sort((a, b) => tutSortKey(a) < tutSortKey(b) ? -1 : 1);
  var seen = {};
  rows.forEach((r) => {
    var b = r.beat || "";
    if (!b || seen[b]) return;
    seen[b] = true;
    var a = document.createElement("a");
    a.href = "#beat-" + b;
    a.textContent = b;
    chips.appendChild(a);
  });
  var bar = document.createElement("div");
  bar.className = "fmt";
  bar.innerHTML = 'Select words in a line, then '
    + '<button type="button" data-fmt="b">Bold</button>'
    + '<button type="button" data-fmt="color" data-hex="#6a3c00"><i class="swatch" style="background:#6a3c00"></i>Keyword</button>'
    + '<button type="button" data-fmt="color" data-hex="#7a1212"><i class="swatch" style="background:#7a1212"></i>Hearts</button>'
    + '<button type="button" data-fmt="color" data-hex="#8d1414"><i class="swatch" style="background:#8d1414"></i>Attack</button>'
    + '<button type="button" data-fmt="color" data-hex="#0a456e"><i class="swatch" style="background:#0a456e"></i>Block</button>'
    + '<button type="button" data-fmt="color" data-hex="#4e1c86"><i class="swatch" style="background:#4e1c86"></i>Defeat</button>'
    + '<button type="button" data-fmt="clear">Clear</button>';
  desk.appendChild(bar);
  bar.querySelectorAll("button").forEach((btn) => {
    btn.addEventListener("mousedown", (e) => e.preventDefault());
    btn.addEventListener("click", () => applyFmt(btn.dataset.fmt, btn.dataset.hex || ""));
  });
  var groups = [];
  var current = null;
  rows.forEach((row) => {
    var beat = row.beat || "";
    if (!current || current.beat !== beat) {
      current = { beat: beat, rows: [] };
      groups.push(current);
    }
    current.rows.push(row);
  });
  groups.forEach((group) => {
    var beat = group.beat;
    var h = document.createElement("h2");
    h.id = "beat-" + beat;
    h.className = "beat-head";
    h.style.background = "#8a6a20";
    h.appendChild(document.createTextNode(beat || "Tutorial"));
    var gap = document.createElement("span");
    gap.style.flex = "1";
    h.appendChild(gap);
    var addBtn = document.createElement("button");
    addBtn.type = "button";
    addBtn.className = "beat-btn";
    addBtn.textContent = "Add beat after";
    addBtn.addEventListener("click", () => addBeatAfter(beat));
    var delBtn = document.createElement("button");
    delBtn.type = "button";
    delBtn.className = "beat-btn danger";
    delBtn.textContent = "Delete beat";
    delBtn.addEventListener("click", () => deleteBeat(beat));
    h.appendChild(addBtn);
    h.appendChild(delBtn);
    desk.appendChild(h);
    var beatGrid = document.createElement("div");
    beatGrid.className = "beat";
    var lines = document.createElement("div");
    lines.className = "beat-lines";
    beatGrid.appendChild(lines);
    beatGrid.appendChild(appendVisuals(beat, group.rows));
    desk.appendChild(beatGrid);
    group.rows.forEach((row) => {
    var step = document.createElement("div");
    step.className = "step";
    var head = document.createElement("h3");
    head.innerHTML = walkEsc(row.where || row.key)
      + (row.branch ? ' <span class="path">' + walkEsc(branchTitle(row.branch)) + "</span>" : "")
      + '<div class="key">' + walkEsc(row.key) + "</div>";
    step.appendChild(head);
    momentsOf(row).forEach((m) => {
      var box = document.createElement("div");
      box.className = "moment";
      var left = document.createElement("div");
      left.innerHTML = '<div class="moment-k">' + walkEsc(m.kicker) + '</div><div class="moment-d">' + walkEsc(m.title) + "</div>";
      if (m.kind === "say") {
        var prev = document.createElement("div");
        prev.className = "preview";
        var ta = document.createElement("textarea");
        ta.dataset.key = row.key;
        ta.value = row.shown != null ? row.shown : (row.text || "");
        if (!ta.value) ta.placeholder = "What Nib says";
        var sync = () => { prev.innerHTML = previewHtml(ta.value); };
        ta.addEventListener("input", () => { markDirty(); sync(); });
        ta.addEventListener("focus", () => { focusTa = ta; });
        left.appendChild(prev);
        left.appendChild(ta);
        sync();
      }
      var note = document.createElement("div");
      note.className = "note-col";
      var lab = document.createElement("label");
      lab.className = "lab";
      lab.textContent = "Notes for Cursor";
      var nta = document.createElement("textarea");
      nta.dataset.noteFor = row.key;
      nta.dataset.note = m.id;
      var notes = row.desk_notes || {};
      nta.value = notes[m.id] || "";
      nta.placeholder = "What should change here";
      nta.addEventListener("input", markDirty);
      note.appendChild(lab);
      note.appendChild(nta);
      box.appendChild(left);
      box.appendChild(note);
      step.appendChild(box);
    });
    lines.appendChild(step);
    });
  });
}

var undoStack = [];
var redoStack = [];
var undoLock = false;

function clearDeskUndo() {
  undoStack = [];
  redoStack = [];
  var btn = document.getElementById("btnUndo");
  if (btn) btn.disabled = true;
}

function rememberUndo(el, prev, next) {
  if (undoLock || prev === next) return;
  undoStack.push({ el: el, prev: prev, next: next });
  if (undoStack.length > 200) undoStack.shift();
  redoStack = [];
  var btn = document.getElementById("btnUndo");
  if (btn) btn.disabled = false;
}

function restoreStep(step, toPrev) {
  if (!step.el || !step.el.isConnected) return false;
  undoLock = true;
  step.el.value = toPrev ? step.prev : step.next;
  step.el.dispatchEvent(new Event("input", { bubbles: true }));
  var preview = step.el.parentElement && step.el.parentElement.querySelector(".preview");
  if (preview && step.el.dataset.key) preview.innerHTML = previewHtml(step.el.value);
  undoLock = false;
  try { step.el.focus(); } catch (err) {}
  return true;
}

function undoDesk() {
  var step = undoStack.pop();
  if (!step) return;
  if (!restoreStep(step, true)) return;
  redoStack.push(step);
  var btn = document.getElementById("btnUndo");
  if (btn) btn.disabled = undoStack.length === 0;
}

function deskUndoKey(e) {
  if (!(e.ctrlKey || e.metaKey)) return false;
  var k = String(e.key || "").toLowerCase();
  if (k === "z" && !e.shiftKey) {
    e.preventDefault();
    undoDesk();
    return true;
  }
  if (k === "y" || (k === "z" && e.shiftKey)) {
    e.preventDefault();
    var step = redoStack.pop();
    if (step && restoreStep(step, false)) undoStack.push(step);
    var btn = document.getElementById("btnUndo");
    if (btn) btn.disabled = undoStack.length === 0;
    return true;
  }
  return false;
}

if (!window._deskUndoBound) {
  window._deskUndoBound = true;
  document.addEventListener("beforeinput", (e) => {
    var el = e.target;
    if (!el || el.tagName !== "TEXTAREA") return;
    if (e.inputType === "historyUndo" || e.inputType === "historyRedo") {
      e.preventDefault();
      return;
    }
    el._undoPrev = el.value;
  });
  document.addEventListener("input", (e) => {
    var el = e.target;
    if (!el || el.tagName !== "TEXTAREA" || undoLock) return;
    if (el._undoPrev == null) return;
    rememberUndo(el, el._undoPrev, el.value);
    el._undoPrev = el.value;
  });
}
function parseBeatId(id) {
  var m = String(id || "").match(/^([BTS])(\d+)(.*)$/i);
  if (!m) return null;
  return { pre: m[1].toUpperCase(), num: m[2], suf: m[3].toLowerCase() };
}

function beatLess(a, b) {
  return tutSortKey({ key: "tutorial.line." + a + ".1" }) < tutSortKey({ key: "tutorial.line." + b + ".1" });
}

function beatTaken(id) {
  return (pack.rows || []).some((r) => String(r.beat || "") === id || String(r.key || "") === "tutorial.line." + id + ".1");
}

function beatIdAfter(prev, next) {
  var p = parseBeatId(prev);
  if (!p) return "B99";
  var n = next ? parseBeatId(next) : null;
  if (!n || n.pre !== p.pre) {
    var num = String(parseInt(p.num, 10) + 1);
    while (num.length < p.num.length) num = "0" + num;
    var fresh = p.pre + num;
    if (!beatTaken(fresh) && beatLess(prev, fresh) && (!next || beatLess(fresh, next))) return fresh;
  }
  var alphabet = "abcdefghijklmnopqrstuvwxyz";
  function search(base, depth) {
    if (depth > 8) return "";
    for (var i = 0; i < alphabet.length; i++) {
      var suf = base + alphabet.charAt(i);
      var id = p.pre + p.num + suf;
      if (beatTaken(id)) continue;
      if (!beatLess(prev, id)) continue;
      if (next && !beatLess(id, next)) continue;
      return id;
    }
    return search(base + "a", depth + 1);
  }
  return search(p.suf, 0) || search("-", 0) || (p.pre + p.num + "-a");
}

function newNibLine(beat) {
  return {
    src: "copy",
    cat: "Tutorial",
    key: "tutorial.line." + beat + ".1",
    beat: beat,
    line: 1,
    text: "",
    shown: "",
    where: "Tutorial · " + beat + " · line 1",
    wait: "continue",
    focus: "",
    hint: "",
    go: "Next",
    branch: "",
    force: "",
    then_focus: "",
    nib: 0,
    tiny: false,
    rig: "",
    allow: [],
    trigger: "",
    desk_notes: {}
  };
}

function tutorialRowsSorted() {
  return (pack.rows || []).filter((r) => String(r.key || "").indexOf("tutorial.line.") === 0)
    .sort((a, b) => tutSortKey(a) < tutSortKey(b) ? -1 : 1);
}

function addBeatAfter(beat) {
  var ordered = tutorialRowsSorted();
  var next = "";
  var seen = false;
  for (var i = 0; i < ordered.length; i++) {
    var b = String(ordered[i].beat || "");
    if (b === beat) { seen = true; continue; }
    if (seen) { next = b; break; }
  }
  if (window.keepEdits) keepEdits();
  var id = beatIdAfter(beat, next);
  pack.visuals = pack.visuals || {};
  pack.holdVisuals = pack.holdVisuals || {};
  var copied = Object.prototype.hasOwnProperty.call(pack.visuals, beat) ? pack.visuals[beat] : "";
  pack.visuals[id] = copied;
  pack.holdVisuals[id] = true;
  var insertAt = pack.rows.length;
  for (var j = pack.rows.length - 1; j >= 0; j--) {
    if (String(pack.rows[j].beat || "") === beat && String(pack.rows[j].key || "").indexOf("tutorial.line.") === 0) {
      insertAt = j + 1;
      break;
    }
  }
  pack.rows.splice(insertAt, 0, newNibLine(id));
  markDirty();
  render({ fresh: true });
  var head = document.getElementById("beat-" + id);
  if (head) head.scrollIntoView({ behavior: "smooth", block: "start" });
}

function deleteBeat(beat) {
  var ok = window.confirm("Delete " + beat + " and every line in it? Save to keep the deletion.");
  if (!ok) return;
  if (window.keepEdits) keepEdits();
  pack.rows = pack.rows.filter((r) => !(String(r.beat || "") === beat && String(r.key || "").indexOf("tutorial.line.") === 0));
  if (pack.visuals && Object.prototype.hasOwnProperty.call(pack.visuals, beat)) delete pack.visuals[beat];
  if (pack.holdVisuals) delete pack.holdVisuals[beat];
  markDirty();
  render({ fresh: true });
}

window.clearDeskUndo = clearDeskUndo;
window.undoDesk = undoDesk;
window.deskUndoKey = deskUndoKey;
