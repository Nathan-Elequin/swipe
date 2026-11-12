# Paper Fight — Commander fled mark and bag return

Answered 2026-11-12. Built in this chat.

**What Nathan chose:**
- Bag return keeps the monster as they left, including poison, current HP, current Attack, and the one flee. A passive like Commander’s neighbor +2 is not frozen. It comes back only while Commander is on the wheel.
- The indicator is a skull superscript beside the heart. No extra word. It means this defeat already happened, and the next one removes him.

**What the code does:**
- The skull draws on the wheel heart and on the fight callout heart, because both use the same heart painter.
- Bag of Holding peels neighbor buffs off the stored copy, then locks HP. Attack stays locked except for monsters whose Attack is their own ongoing rule (Bandit, Vampire, Dire Wolf, Slime, Spider Queen, Hydra, Kobold Trapper, Berserker). When the bag opens, Commander’s +2 is applied again only if he is on the wheel.
