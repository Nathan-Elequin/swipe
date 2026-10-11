import json

c = json.load(open(r"C:\Users\Natha\Documents\boss-rush\data\catalog.json", encoding="utf-8"))
for it in c.get("items", []):
    ops = it.get("ops") or {}
    ab = str(it.get("ability", "")).replace("\n", " ")
    print("%s\t%s\t%s\t%s" % (it.get("id"), it.get("card_color", ""), ops, ab[:90]))
