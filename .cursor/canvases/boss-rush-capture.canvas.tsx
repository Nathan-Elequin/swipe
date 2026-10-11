export default function BossRushCapture() {
  return (
    <div
      style={{
        fontFamily: 'Georgia, "Times New Roman", serif',
        background: "#1a1714",
        color: "#f0e6d8",
        padding: 24,
        minHeight: "100%",
      }}
    >
      <h1 style={{ color: "#c4a574", fontSize: 22, margin: "0 0 8px" }}>
        Boss Rush — captured catalog
      </h1>
      <p style={{ color: "#9a8b78", marginTop: 0 }}>
        Native Canvas is a snapshot. Use the HTML twin in Zen to see every card and play the POC.
      </p>
      <p>
        Indexed in data/catalog.json from the 2022-05-03 spreadsheet. POC monsters: Wizard,
        Golem. POC items: Shield, Throwing Knife, Sai.
      </p>
      <h2 style={{ color: "#c4a574", fontSize: 18 }}>Chat rulings</h2>
      <p>BLK leftover floors at 0 (sheet silent).</p>
      <p>One encounter then the slice leaves — Function Flow step 4, not a multi-round slog.</p>
      <p>POC skips tier odds and dungeon draft / bribe.</p>
      <h2 style={{ color: "#c4a574", fontSize: 18 }}>Sheet disagreements (no winner picked)</h2>
      <p>Dragon: ignore block vs double first BLK/ATK.</p>
      <p>Healing Potion: heal up to 3 vs set HP to 4.</p>
      <p>Commander: +2 neighbor ATK vs Function Flow +1.</p>
      <p>Wraith text says Captain; roster says Commander.</p>
      <p>Knucklers / Spiked Flail: ability vs Defined column.</p>
      <p>Function Flow lists Sword; no Sword row. Bracers listed under ATK examples.</p>
      <h2 style={{ color: "#c4a574", fontSize: 18 }}>POC play</h2>
      <p>
        Open .cursor/canvases/boss-rush-capture.html in Zen, tab Play POC. Or Godot F5 on this
        folder.
      </p>
    </div>
  );
}

