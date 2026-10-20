export default function LogicQaBoard() {
  return (
    <div style={{ padding: 24, background: "#100e0c", color: "#f3e6d0", minHeight: "100%" }}>
      <h1 style={{ color: "#c4a574" }}>Bucket 0 — Logic QA</h1>
      <p>
        Native Canvas is optional. The live board is the HTML page in Zen:
      </p>
      <p>
        <a href="http://127.0.0.1:8757/design/qa/logic-pass/board.html" style={{ color: "#e8c36a" }}>
          http://127.0.0.1:8757/design/qa/logic-pass/board.html
        </a>
      </p>
      <p>Sprites, drag columns, click-to-edit notes, and ruling choices all live there. Save writes design/qa/logic-pass/rulings.json.</p>
    </div>
  );
}
