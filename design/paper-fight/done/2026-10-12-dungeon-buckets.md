# Paper Fight — dungeon buckets

Built from Nathan’s answers on 2026-10-12.

A clear or a death in Adventure adds one to the counter. The run still ends on a death. The next fresh Adventure shows the reveal before the first seats. In the middle of Adventure, Go deeper opens its own screen, reveals the new bucket, then the next dungeon is seated. Dive In, How to Play, and Developer Test do not add to the counter.

Bucket 0 is 9 items and 9 monsters, with an even tier split, including Wizard and Golem. Each later bucket is 3 items and 3 monsters until the roster runs out. Live and todo cards are in the sort. Retired cards are not. The bucket is the only gate. The old starter flag does not decide the pool.

The next dungeon forces one monster from the new bucket into the four opening seats, and one item from that bucket into the opening gifts, replacing a card if it has to.

Unlocks are stored in `user://bucket_progress.json` and survive quitting. Roster has Reset unlocks.

Buckets 7 through 10 are short on monsters. The editor warning is there so those can be moved.
