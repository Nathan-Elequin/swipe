# 002 — Throwing Knife Keep (withdrawn)
Status: WITHDRAWN — false fail
Family: keep
Cards: throwing_knife, wizard
Phase: fight

Wizard going 2 HP → 1 HP was the correct hit. Keep in this game returns the card at the **end of combat** (`keep_after`, log line Kept after Done). The harness snapshot was still inside the fight, saw the card as spent, and called that a fail. Nathan caught it. Not a bug.
