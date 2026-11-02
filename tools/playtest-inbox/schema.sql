CREATE TABLE IF NOT EXISTS lists (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	received_at TEXT NOT NULL,
	kind TEXT NOT NULL,
	card_tier INTEGER NOT NULL,
	buckets TEXT,
	source TEXT,
	build TEXT,
	preset TEXT,
	when_client TEXT,
	is_test INTEGER NOT NULL DEFAULT 0,
	discarded INTEGER NOT NULL DEFAULT 0,
	discarded_at TEXT,
	note TEXT,
	github_issue INTEGER
);

CREATE TABLE IF NOT EXISTS ranks (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	list_id INTEGER NOT NULL,
	card_id TEXT NOT NULL,
	letter TEXT NOT NULL,
	score INTEGER NOT NULL,
	FOREIGN KEY (list_id) REFERENCES lists(id)
);

CREATE INDEX IF NOT EXISTS ranks_card ON ranks (card_id, letter);
CREATE INDEX IF NOT EXISTS lists_cohort ON lists (kind, card_tier, is_test, discarded);
