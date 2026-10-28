# One-shot: split tutorial.beat.01.body into per-click rows and drop dead copy.
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PATH = ROOT / "data" / "player-copy.json"

DEAD_EXACT = {
	"cabin.hot.back_workshop",
	"playtest.voice_chip",
	"nib.piece.stamped_short",
	"map.title.spin",
	"map.subtitle",
	"map.start.pin",
	"map.start.sub",
	"map.legend.down",
	"map.fog",
	"map.scribble.x",
	"map.scribble.snacks",
	"map.node.locked",
	"map.stamp.full",
	"map.stamp.pencil",
	"map.hint.click",
	"rope.campaign.bank_sub",
	"rope.campaign.push_sub",
	"campaign.drawer.title",
	"campaign.drawer.body",
	"door.title",
	"door.shiny",
	"door.owner",
	"door.hook",
	"door.seat",
	"inspect.empty_place",
	"inspect.shift",
	"cue.seat",
	"cue.starters",
	"pause.start_over",
	"title.sub",
	"title.again",
	"title.win_sub",
	"title.lose_sub",
	"title.adventure_win",
	"warn.crossbow",
	"map.route.shortcut.desc",
}

DEAD_PREFIX = (
	"tutorial.beat.",
)


def new_beat() -> dict:
	return {
		"text": "",
		"dir": "",
		"hint": "",
		"focus": "",
		"wait": "continue",
		"go": "Next",
		"force": "",
		"then_focus": "",
		"branch": "",
		"nib": 0.0,
		"tiny": False,
	}


def is_direction(t: str) -> bool:
	low = t.lower()
	starts = (
		"(click", "(highlight", "(take", "(turn", "(sprite", "(comes",
		"(returns", "(nib", "({nib", "(only now", "(when the", "(the player",
		"(animates", "(vignette", "(in very tiny",
	)
	if any(low.startswith(s) for s in starts):
		return True
	return t.startswith("(") and t.endswith(")") and len(t) < 120 and "highlight" in low


def direction_ends(t: str) -> bool:
	low = t.lower()
	if low.startswith(("(click", "(take", "(turn", "(the player", "(when the user hovers")):
		return True
	return low.startswith(("(only now", "(vignette", "(animates"))


def tiny_aside(t: str) -> str:
	inner = t[1:-1] if t.startswith("(") and t.endswith(")") else t
	cut = inner.find("y'know")
	if cut >= 0:
		return "(" + inner[cut:].strip().rstrip(")") + ")"
	return "(y'know, cause of the round dungeon...)"


def apply_dir(cur: dict, t: str) -> None:
	low = t.lower()
	if any(w in low for w in ("closer", "close to", "leaning", "80%")):
		cur["nib"] = 0.85 if "80%" in low else 0.55
	if any(w in low for w in ("returns", "original position", "returns to his")):
		cur["nib"] = 0.0
	if "center screen" in low:
		cur["nib"] = 0.4
	if "got it" in low:
		cur["go"] = "Got It"
		cur["wait"] = "continue"
	elif "click 'next'" in low or "click to continue" in low or "click 'got" in low:
		cur["wait"] = "continue"
		if not cur.get("go"):
			cur["go"] = "Next"
	if "click 'spin'" in low or "click spin" in low:
		cur["wait"] = "spin"
		cur["focus"] = "spin"
		cur["hint"] = "(click Spin)"
		if "golem" in low:
			cur["force"] = "golem"
		elif "goblin" in low:
			cur["force"] = "goblin"
	if "only now" in low:
		cur["wait"] = "auto_spin"
		cur["focus"] = "spin"
		cur["force"] = "golem"
	if "sai" in low and any(w in low for w in ("click", "highlight", "use")):
		cur["focus"] = "item:sai"
		if "click" in low or "use it" in low:
			cur["wait"] = "item:sai"
			cur["hint"] = "(click the Sai)"
	if "helmet" in low and ("click" in low or "highlight" in low):
		cur["focus"] = "item:helmet"
		if "click the helmet" in low:
			cur["wait"] = "item:helmet"
			cur["hint"] = "(click Helmet)"
	if ("da boot" in low or "the boot" in low) and "take 3" in low:
		cur["wait"] = "choice"
		cur["focus"] = "item:da_boot"
		cur["hint"] = "(click The Boot, or Take 3)"
	elif "da boot" in low or "the boot" in low:
		cur["focus"] = "item:da_boot"
	if "safe" in low and ("click" in low or "highlight" in low):
		cur["focus"] = "done"
		if "click 'safe'" in low or "click safe" in low:
			cur["wait"] = "done"
			cur["hint"] = "(click Safe)"
	if "empty slice" in low or "corridor" in low:
		cur["focus"] = "empty"
	elif "dungeon wheel" in low or "monster card" in low:
		cur["focus"] = "wheel"
	if ("hotbar" in low or "your loot" in low) and not str(cur.get("focus", "")).startswith("item:"):
		cur["focus"] = "hotbar"
	if "healthbar" in low or "6 health" in low:
		cur["focus"] = "hearts"
	if "attack icon" in low:
		cur["focus"] = "atk"
	if "hp icon" in low:
		cur["focus"] = "hp"
	if "block icon" in low:
		cur["focus"] = "block"
	if "detail view" in low:
		cur["focus"] = "inspect"
	if "dungeon deck" in low:
		cur["focus"] = "deck"
	if "take the shuriken" in low:
		cur["wait"] = "draft:shuriken"
		cur["focus"] = "draft"
		cur["hint"] = "(take the Shuriken)"
	elif "shuriken" in low and "click" in low:
		cur["wait"] = "item:shuriken"
		cur["focus"] = "item:shuriken"
		cur["hint"] = "(click the Shuriken)"
	if "turn to the bandit" in low:
		cur["wait"] = "face"
		cur["force"] = "bandit"
		cur["focus"] = "wheel"
		cur["hint"] = "(turn to the Bandit)"
	if "move arrow" in low:
		cur["wait"] = "move"
		cur["force"] = "gelatinous_cube"
		cur["focus"] = "move_arrow"
		cur["hint"] = "(click the arrow)"
	if "when the user hovers" in low or ("hover" in low and "monster" in low):
		cur["wait"] = "hover_shift"
		cur["focus"] = "wheel"
		cur["then_focus"] = "inspect"
		cur["hint"] = "(hover the monster)"


def flush(out: list, cur: dict) -> None:
	text = str(cur.get("text", "")).strip()
	wait = str(cur.get("wait", "continue"))
	if text == "" and wait == "continue":
		return
	if not cur.get("go"):
		cur["go"] = "Next"
	out.append(dict(cur))


def parse(raw: str) -> list:
	out: list[dict] = []
	cur = new_beat()
	branch = ""
	nib = 0.0
	for line in raw.split("\n"):
		t = line.strip()
		if not t:
			continue
		if t.startswith("---"):
			flush(out, cur)
			cur = new_beat()
			low = t.lower()
			if "landed on the wizard" in low:
				branch = "wizard"
			elif "landed on the golem" in low:
				branch = "golem"
			elif "landed on the goblin" in low:
				branch = "goblin"
			elif "golem is still" in low:
				branch = "golem_waiting"
			elif "goblin is still" in low:
				branch = "goblin_waiting"
			elif "the boot" in low and "chose" in low:
				branch = "boot"
			elif "take 3" in low:
				branch = "take"
			elif "join" in low:
				branch = "join"
			cur["branch"] = branch
			cur["nib"] = nib
			continue
		if t.startswith("(") and is_direction(t):
			cur["dir"] = (str(cur.get("dir", "")).strip() + "\n" + t).strip()
			if "y'know" in t.lower() or "tiny text" in t.lower():
				flush(out, cur)
				cur = new_beat()
				cur["text"] = tiny_aside(t)
				cur["tiny"] = True
				cur["dir"] = t
				cur["nib"] = nib
				cur["branch"] = branch
				apply_dir(cur, t)
				continue
			apply_dir(cur, t)
			nib = float(cur.get("nib", nib) or 0)
			if direction_ends(t):
				cur["nib"] = nib
				cur["branch"] = branch
				flush(out, cur)
				cur = new_beat()
				cur["nib"] = nib
				cur["branch"] = branch
			continue
		if str(cur.get("text", "")) and str(cur.get("wait", "continue")) != "continue":
			cur["nib"] = nib
			cur["branch"] = branch
			flush(out, cur)
			cur = new_beat()
			cur["nib"] = nib
			cur["branch"] = branch
		if cur.get("text"):
			cur["text"] = str(cur["text"]) + "\n" + t
		else:
			cur["text"] = t
		cur["nib"] = nib
		cur["branch"] = branch
	cur["nib"] = nib
	cur["branch"] = branch
	flush(out, cur)
	return out


BRANCH_TITLE = {
	"": "Opening",
	"wizard": "If the wheel landed on Wizard",
	"golem": "If the wheel landed on Golem",
	"goblin": "If the wheel landed on Goblin",
	"golem_waiting": "If Golem is still waiting",
	"goblin_waiting": "If Goblin is still waiting",
	"boot": "If they used The Boot",
	"take": "If they took the hit",
	"join": "After the fight",
}


def where_of(b: dict) -> str:
	title = BRANCH_TITLE.get(str(b.get("branch", "")), "How to Play")
	wait = str(b.get("wait") or "continue")
	focus = str(b.get("focus") or "(none)")
	return f"{title} · {wait} / {focus} · Nib line"


def is_dead_row(key: str) -> bool:
	if key in DEAD_EXACT:
		return True
	if key.startswith(DEAD_PREFIX):
		return True
	return False


def main() -> None:
	pack = json.loads(PATH.read_text(encoding="utf-8"))
	rows = pack["rows"]
	blob = ""
	for r in rows:
		if r.get("key") == "tutorial.beat.01.body":
			blob = r.get("text") or ""
			break
	beats = parse(blob)
	line_rows = []
	for i, b in enumerate(beats, start=1):
		key = f"tutorial.line.{i:03d}"
		entry = {
			"author_lock": True,
			"cat": "Tutorial",
			"key": key,
			"locked_at": "2026-10-28",
			"text": b.get("text") or "",
			"dir": b.get("dir") or "",
			"where": where_of(b),
			"wait": b.get("wait") or "continue",
			"focus": b.get("focus") or "",
			"hint": b.get("hint") or "",
			"go": b.get("go") or "Next",
			"branch": b.get("branch") or "",
			"force": b.get("force") or "",
			"then_focus": b.get("then_focus") or "",
			"nib": b.get("nib") or 0.0,
			"tiny": bool(b.get("tiny")),
		}
		line_rows.append(entry)
	insert_at = 0
	for i, r in enumerate(rows):
		if str(r.get("key", "")).startswith("tutorial."):
			insert_at = i
			break
	kept = [r for r in rows if not is_dead_row(str(r.get("key", "")))]
	# find first tutorial key in kept
	at = 0
	for i, r in enumerate(kept):
		if str(r.get("key", "")).startswith("tutorial."):
			at = i
			break
	# place lines after speaker/skip/nudge
	after = at
	for i, r in enumerate(kept):
		k = str(r.get("key", ""))
		if k in ("tutorial.speaker", "tutorial.skip", "tutorial.nudge_wait", "tutorial.nudge_item"):
			after = i + 1
	kept = kept[:after] + line_rows + kept[after:]
	pack["rows"] = kept
	pack["updated"] = "2026-10-28"
	PATH.write_text(json.dumps(pack, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")
	print(f"lines={len(line_rows)} kept={len(kept)} was={len(rows)}")


if __name__ == "__main__":
	main()
