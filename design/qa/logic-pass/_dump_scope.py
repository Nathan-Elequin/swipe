import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _scope import items, monsters

its = items()
mons = monsters()
print("ITEMS", len(its))
for it in its:
    print(
        "%s\tkind=%s blk=%s atk=%s heal=%s keep=%s unp=%s\n  %s"
        % (
            it["id"],
            it["kind"],
            it["blk"],
            it["atk"],
            it["heal"],
            it["keep"],
            it["unplayable"],
            it["ability"][:120],
        )
    )
print("MONSTERS", len(mons))
for m in mons:
    if m["ability"]:
        print("%s\n  %s" % (m["id"], m["ability"][:120]))
