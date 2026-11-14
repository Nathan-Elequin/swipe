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

CREATE TABLE IF NOT EXISTS telemetry_events (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	received_at TEXT NOT NULL,
	anon_id TEXT NOT NULL,
	session_id TEXT NOT NULL,
	source TEXT,
	build TEXT,
	is_test INTEGER NOT NULL DEFAULT 0,
	name TEXT NOT NULL,
	t_client INTEGER,
	payload TEXT
);

CREATE INDEX IF NOT EXISTS telemetry_name ON telemetry_events (name, is_test, received_at);
CREATE INDEX IF NOT EXISTS telemetry_anon ON telemetry_events (anon_id, received_at);
