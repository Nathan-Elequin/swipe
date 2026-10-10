extends Object
## After the door opens: they came for that shiny. Cycle five lines per item.

const COPY := preload("res://scripts/player_copy.gd")

const DEFAULT := [
	"Hey! That {item} is mine — spit it out!",
	"Cute steal. Shame you're going to lose holding it.",
	"You swiped the {item}. I noticed. That's a problem for you.",
	"Keep it warm. I'm taking it off you.",
	"The {item} called. You just stole it. I'm coming.",
]

const LINES := {
	"throwing_knife": [
		"Hey! That's my throwing knife — spit it out!",
		"Cute steal. I'm taking the knife back. Point first.",
		"You swiped my knife. I'll swipe you.",
		"One knife. Two of us. Put it down, thief.",
		"Don't throw it yet. I want it back in one piece.",
	],
	"shield": [
		"That's MY Shield! Hide behind it — I'll wait.",
		"Sticky fingers on my Shield. Rude.",
		"Give it back. I'll still knock you over.",
		"Nice steal. Bad idea.",
		"Keep the Shield warm. I'm coming for it.",
	],
	"sai": [
		"Those Sai are mine! Pokey little thief.",
		"You grabbed my Sai. Now we dance.",
		"Put the prongs down. I said please. Kind of.",
		"Fancy steal. I'm still taking them home.",
		"My Sai. Your problem.",
	],
	"medallion": [
		"Shiny Medallion — that's mine, sparkles!",
		"You stole my luck charm. Bad luck for you.",
		"Hand it over, sticky-fingers.",
		"Jewelry thief! I saw that!",
		"The Medallion called me. You just grabbed it.",
	],
	"helmet": [
		"My Helmet! Cover your head — I'll aim anyway.",
		"You swiped my lid. Bold.",
		"That Helmet's mine. Your thoughts can stay.",
		"Cute. Wrong head.",
		"Take the Helmet. I'll take the rest of you.",
	],
	"da_boot": [
		"That's MY Boot! I'm kicking you with it!",
		"You stole a boot. I stole a seat. Guess who wins.",
		"My size. Your foot's optional.",
		"A boot heist? I'm laughing, then I'm winning.",
		"Keep it laced. I want it back clean.",
	],
	"grimoire": [
		"My Grimoire! That's not light reading for you!",
		"Book thief! Homework's over — fight starts.",
		"Magic book. Sticky fingers. I can do that math.",
		"Don't dog-ear it. I'll end you either way.",
		"The Grimoire called. You just stole it.",
	],
	"bloody_gauntlets": [
		"Those Gauntlets are mine — already my color!",
		"You put them on. I put on a smile. Only one lasts.",
		"Sticky red fingers. Cute.",
		"Give them back before they match the floor.",
		"My gloves. Our blood optional.",
	],
	"breastplate": [
		"My Breastplate! Fancy tin on a thief!",
		"I'll dent it. Then I'll keep it.",
		"That plate's mine. Your ribs can commute.",
		"Armor theft. Bold. I brought teeth.",
		"Polish it. I'm taking it shiny.",
	],
	"bracers": [
		"My Bracers! Wrist jewelry looks better on me.",
		"Snap them off later. After I win.",
		"You grabbed the Bracers. I grabbed a seat.",
		"Cute armor. Bad owner now.",
		"Keep them on. Makes the trophy shot nicer.",
	],
	"smoke_bomb": [
		"My Smoke Bomb? Hiding already? I can wait.",
		"Puff — then me — then you, briefly.",
		"You stole my exit trick. Cute.",
		"Smoke's mine. The dark is mine too.",
		"Take it. I'll find you anyway. That's the fun.",
	],
	"knucklers": [
		"My Knucklers! You want to punch ME with MY brass?",
		"Sticky fingers, brass knuckles. Adorable.",
		"Those are mine. Your plan is notes.",
		"Packed for a brawl with my stuff. Rude.",
		"Keep them warm. I'm reclaiming a pair.",
	],
	"fangs": [
		"Those Fangs are copies — I'll show you the originals!",
		"Teeth thief! Brave. Stupid. Brave.",
		"My extras. Your mouth. No.",
		"Bite toys. Guess what they're for.",
		"Keep them handy. I'm collecting a matching pair.",
	],
	"poison_flask": [
		"My Poison Flask! Classy steal. You first.",
		"Green vintage. Notes of sticky-fingers.",
		"Don't spill. I want all of it back.",
		"You packed my poison. I packed hunger.",
		"Cute vial. Keep the symptoms. Return the bottle.",
	],
	"spiked_flail": [
		"My Flail! Spikes AND theft? You're speaking my language.",
		"That Flail's going back on my mantel.",
		"Finally someone with taste. Still a thief.",
		"You picked the mean one. Briefly respected.",
		"Don't get attached. I will.",
	],
	"healing_potion": [
		"My Healing Potion? Planning to live with MY juice?",
		"Second chance stolen. I'm taking it back.",
		"Red flask. Red ending. Consistent.",
		"Don't drink it yet. I want it full.",
		"Sweet steal. I'll take it off the corpse.",
	],
	"crossbow": [
		"My Crossbow! Point it at someone else — then give it back.",
		"Bolts thief. I'll keep the bow. You can keep the holes.",
		"You aimed MY Crossbow in MY room. Rude.",
		"Don't scratch the stock. I'm reclaiming it.",
		"Finally a thief with range. I have more.",
	],
	"sledgehammer": [
		"My Sledgehammer! Overkill theft. I like overkill.",
		"Big hammer. Small thief. This'll be short.",
		"You brought MY hammer to MY nest. Rude. Fun.",
		"The wall can keep the hole. I want the hammer.",
		"I'll take it back. You can keep the headache.",
	],
	"pocketwatch": [
		"My Pocketwatch! Time's up, thief — not a metaphor.",
		"Tick tock. That's me walking. That's you not.",
		"Nice steal. Time of death: soon.",
		"You grabbed a clock. I grabbed a seat.",
		"Stop winding it. I'll stop you.",
	],
}

static var _i: Dictionary = {}


static func grab(id: String, item: String) -> String:
	var arr: Array = COPY.taunts(id)
	if arr.is_empty():
		arr = LINES.get(id, DEFAULT)
	if arr.is_empty():
		arr = DEFAULT
	var n: int = arr.size()
	var k: int = int(_i.get(id, 0)) % n
	_i[id] = k + 1
	var t: String = str(arr[k])
	if item == "":
		return t.replace("the {item}", "that").replace("{item}", "that")
	return t.replace("{item}", item)
