import { Box, Center, Text, Transition } from "@mantine/core";
import { IconPhoneCall } from "@tabler/icons-react";
import { useEffect, useState, type FC } from "react";
import { locale } from "../../stores/locales";

interface Props {
  visible: boolean;
};

const Dialing: FC<Props> = ({ visible }) => {

  const [trailingDots, setTrailingDots] = useState<number>(0);

  useEffect(() => {
    let interval: number | null = null;
    if (visible) {
      interval = setInterval(() => {
        setTrailingDots((prev) => (prev + 1) % 4);
      }, 500);
    } else {
      if (interval) clearInterval(interval);
      interval = null;
    }
    return () => {
      if (interval) clearInterval(interval);
      interval = null;
    };
  }, [visible]);
  
  return (
    <Transition mounted={visible} transition='fade' duration={200}>
      {(styles) => (
        <Center pos='absolute' w='100%' h='100%' style={styles}>
          <IconPhoneCall size='3rem' color='var(--mantine-color-text)' />
          <Text size='xxl' fw={600} ml='sm' mr='lg' ta='center' pos='relative'>
            {locale('dialing')}
            <Box
              component='span'
              pos='absolute'
              left='100%'
              aria-hidden
              style={{ whiteSpace: 'nowrap' }}
            >
              {'.'.repeat(trailingDots)}
            </Box>
          </Text>
        </Center>
      )}
    </Transition>
  );
};

export default Dialing;