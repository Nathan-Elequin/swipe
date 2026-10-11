import { Divider, H1, H2, Stack, Text } from "cursor/canvas";

export default function ContentBoardCanvas() {
  return (
    <Stack gap={16}>
      <H1>Content Board</H1>
      <Text>
        The live editor is the HTML twin. Open it in Zen — Native Canvas will not
        save into the repo.
      </Text>
      <Text>
        Path: design/content-board.html. Save into data/content-board.json, then
        tell chat: check for item updates.
      </Text>
      <Divider />
      <H2>What you edit there</H2>
      <Text>
        Monsters and items. Ability is player-facing. Function flow is the
        pseudocode that gets implemented. Notes catch contradictions.
      </Text>
    </Stack>
  );
}
