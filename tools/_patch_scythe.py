from pathlib import Path

p = Path("scripts/main.gd")
t = p.read_text(encoding="utf-8")
t = t.replace(
	'return int(wheel[index].get("hp", 0)) == hp * 2',
	'return int(wheel[index].get("hp", 0)) == hp',
	1,
)
t = t.replace(
	'int(m.get("hp", 0)) != hp * 2',
	'int(m.get("hp", 0)) != hp',
	1,
)
old = '''			out["equation"] = "(%s = %s × 2)" % [_bb(hp_c, "Enemy HP"), _bb(hp_c, "Your HP")]
			out["body"] = "Defeat any Monster with exactly double your HP"
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = "Can't — no monster has exactly double your HP."'''
new = '''			out["equation"] = "(%s = %s)" % [_bb(hp_c, "Enemy HP"), _bb(hp_c, "Your HP")]
			out["body"] = str(it.get("ability", "Defeat Any Monster with HP equal to yours"))
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = "Can't — no monster has HP equal to yours."'''
if old not in t:
	raise SystemExit("inspect block not found")
t = t.replace(old, new, 1)
p.write_text(t, encoding="utf-8", newline="\n")
print("ok", t.count("hp * 2"))
