extends RefCounted
class_name PlaytestVictoryCode
## Deterministic playtest victory codes (slice 4).
## Format: ABYSS-XXXX-XXXX (Crockford base32, no ambiguous I/L/O/U).
## Pure helpers — safe for selftests and the Discord verifier.

const SALT := "spinheritance-playtest-victory-v1"
const PREFIX := "ABYSS"
## Crockford base32 alphabet (RFC-ish; excludes I L O U).
const CROCKFORD := "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
const CODE_CHARS := 8 ## two groups of 4


static func generate(anon_id: String, milestone: String = "big") -> String:
	var id := str(anon_id).strip_edges()
	if id == "":
		id = "anon"
	var mid := str(milestone).strip_edges().to_lower()
	if mid == "":
		mid = "big"
	var material := "%s|%s|%s" % [id, mid, SALT]
	var digest: PackedByteArray = _sha256(material)
	var chars := _encode_crockford(digest, CODE_CHARS)
	return "%s-%s-%s" % [PREFIX, chars.substr(0, 4), chars.substr(4, 4)]


static func normalize(code: String) -> String:
	var raw := str(code).strip_edges().to_upper().replace(" ", "")
	## Accept missing dashes / lowercase / confusing lookalikes.
	raw = raw.replace("I", "1").replace("L", "1").replace("O", "0").replace("U", "V")
	raw = raw.replace("-", "")
	if raw.begins_with(PREFIX):
		raw = raw.substr(PREFIX.length())
	if raw.length() != CODE_CHARS:
		return ""
	for i in raw.length():
		if CROCKFORD.find(raw[i]) < 0:
			return ""
	return "%s-%s-%s" % [PREFIX, raw.substr(0, 4), raw.substr(4, 4)]


static func is_valid_format(code: String) -> bool:
	return normalize(code) != ""


static func verify(anon_id: String, code: String, milestone: String = "big") -> bool:
	var expected := generate(anon_id, milestone)
	var got := normalize(code)
	return got != "" and got == expected


static func _sha256(text: String) -> PackedByteArray:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(text.to_utf8_buffer())
	return ctx.finish()


static func _encode_crockford(bytes: PackedByteArray, count: int) -> String:
	## Pack bytes into a bit buffer, emit `count` 5-bit Crockford digits.
	var out := ""
	var bit_buf: int = 0
	var bit_len: int = 0
	var bi: int = 0
	while out.length() < count:
		if bit_len < 5:
			var b: int = int(bytes[bi % bytes.size()]) & 0xFF
			bi += 1
			bit_buf = (bit_buf << 8) | b
			bit_len += 8
		var shift: int = bit_len - 5
		var idx: int = (bit_buf >> shift) & 0x1F
		bit_buf &= (1 << shift) - 1 if shift > 0 else 0
		bit_len = shift
		out += CROCKFORD[idx]
	return out
