import { Center, Group, Stack, Text } from "@mantine/core";
import type { FC } from "react";

const KEYPAD_LABELS = [
  ['1', '2', '3'],
  ['4', '5', '6'],
] as const;

const Keypad: FC = () => {
  return (
    <Stack gap={6} w='100%' style={{ flexShrink: 0, marginBottom: '-1.35rem' }}>
      {KEYPAD_LABELS.map((row, rowIndex) => (
        <Group key={rowIndex} grow gap={6} wrap='nowrap' w='100%'>
          {row.map((label) => (
            <Center
              key={label}
              h='2.15rem'
              bg='dark.6'
              bdrs={6}
              style={{
                boxShadow: '0 2px 0 rgba(0, 0, 0, 0.35), inset 0 1px 0 rgba(255, 255, 255, 0.08)',
              }}
            >
              <Text fz='xs' c='dark.2' fw={600} lts={1}>
                {label}
              </Text>
            </Center>
          ))}
        </Group>
      ))}
    </Stack>
  );
};

export default Keypad;
