import { Box, Center } from "@mantine/core";
import type { FC } from "react";

const Earpiece: FC = () => {
  return (
    <Center
      w='3.25rem'
      h='0.55rem'
      bg='dark.9'
      bdrs='xl'
      style={{
        boxShadow: 'inset 0 1px 2px rgba(0, 0, 0, 0.55)',
        gap: 3,
        flexShrink: 0,
      }}
    >
      {Array.from({ length: 5 }).map((_, i) => (
        <Box
          key={i}
          w={2}
          h={6}
          bg='dark.6'
          bdrs={1}
          opacity={0.7}
        />
      ))}
    </Center>
  );
};

export default Earpiece;
