import { Button, Divider, Flex, Group, Paper, Text, Transition, useMantineTheme } from "@mantine/core";
import { useDisclosure } from "@mantine/hooks";
import { IconAntennaBars5, IconBattery3, IconBriefcaseFilled, IconCannabisFilled, IconCaretDownFilled, IconCaretUpFilled } from "@tabler/icons-react";
import { useEffect, useState, type FC } from "react";
import { useAudioStore } from "../stores/audio";
import { locale } from "../stores/locales";
import { fetchNui } from "../utils/fetchNui";
import { useKeybind } from "../hooks/useKeybind";
import { configStore } from "../stores/config";

interface Props {
  dismount: () => void;
};

const DealerMenu: FC<Props> = ({ dismount }) => {
  const theme = useMantineTheme();
  const cfg = configStore.getState();

  const bulkDisabled = !cfg.Options?.BulkSales;

  const playSound = useAudioStore.getState().play;

  const [visible, { open, close }] = useDisclosure(false);
  useEffect(() => open(), []);

  const [time, setTime] = useState<{ hour: number; minute: number }>({ hour: 0, minute: 0 });

  useEffect(() => {
    fetchNui<{ hour: number; minute: number }>('getGameTime').then((resp) => setTime(resp));
  }, []);

  useEffect(() => {
    const interval = setInterval(() => {
      setTime((current) => {
        let { hour, minute } = current;
        minute += 1;
        if (minute >= 60) {
          minute = 0;
          hour += 1;
          if (hour >= 24) {
            hour = 0;
          }
        }
        return { hour, minute };
      });
    }, 2000);
    return () => clearInterval(interval);
  }, []);

  const [option, setOption] = useState<number>(0);
  const [cancelPressed, setCancelPressed] = useState<boolean>(false);
  const [confirmPressed, setConfirmPressed] = useState<boolean>(false);

  const keypressUp = () => {
    playSound('keypress', 0.1);
    setOption((current) => {
      if (bulkDisabled) return 0;
      return Math.max(current - 1, 0);
    });
  };

  useKeybind('ArrowUp', keypressUp);

  const keypressDown = () => {
    playSound('keypress', 0.1);
    setOption((current) => {
      if (bulkDisabled) return 0;
      return Math.min(current + 1, 1);
    });
  };

  useKeybind('ArrowDown', keypressDown);

  const keypressCancel = () => {
    playSound('keypress', 0.1);
    fetchNui('setGameFocus');
    close();
    fetchNui('cleanupPhone');
  };

  useKeybind('Escape', keypressCancel);

  const keypressConfirm = () => {
    playSound('keypress', 0.1);
    if (option === 0) fetchNui('triggerStreetSell');
    else if (option === 1) fetchNui('triggerBulkOrder');
  };

  useKeybind('Enter', keypressConfirm);

  return (
    <Transition mounted={visible} transition='slide-up' duration={200} timingFunction='ease' onExited={dismount}>
      {(transitionStyles) => (
        <Paper
          pos='absolute'
          bottom={0}
          right='5rem'
          w='14rem'
          h='19.5rem'
          p='md'
          radius='md'
          shadow='md'
          style={{
            ...transitionStyles,
            userSelect: 'none',
            borderBottomLeftRadius: 0,
            borderBottomRightRadius: 0,
          }}
        >
          <Flex justify='center' align='center' w='100%'>
            <svg width='50' height='6' viewBox='0 0 50 6' fill="none" xmlns="http://www.w3.org/2000/svg">
              <rect x="2" y="2" width='46' height='2' rx="20" fill={theme.colors.dark[5]} />
            </svg>
          </Flex>
          <Flex
            justify='flex-start'
            align='center'
            direction='column'
            w='100%'
            h='12rem'
            mt='md'
            bdrs='xxs'
            bg={theme.colors.dark[3]}
            style={{
              boxShadow: 'inset 0 0.1rem 1rem 0 #00000040',
            }}
          >
            <Flex justify='space-between' align='center' w='inherit' h='1.15rem' px='xs' bg='dark.4'>
              <Text size='xs' c='dark.0' fw={600}>
                {time.hour.toString().padStart(2, '0')}:{time.minute.toString().padStart(2, '0')}
              </Text>
              <Group gap={0}>
                <IconAntennaBars5 size='1.2rem' color={theme.colors.dark[0]} style={{ marginBottom: '0.1rem' }} />
                <IconBattery3 size='1.4rem' color={theme.colors.dark[0]} />
              </Group>
            </Flex>
            <Flex justify='flex-start' align='center' w='inherit' h='2.75rem' p='sm' bg={option === 0 ? theme.colors[theme.primaryColor][6] : undefined}>
              <Group gap='sm'>
                <IconCannabisFilled size='1.5rem' color={option === 0 ? theme.colors.dark[0] : theme.colors.dark[8]} />
                <Text size='md' c={option === 0 ? theme.colors.dark[0] : theme.colors.dark[8]} fw={600}>{locale('sell_here')}</Text>
              </Group>
            </Flex>
            {!bulkDisabled && (
              <Flex justify='flex-start' align='center' w='inherit' h='2.75rem' p='sm' bg={option === 1 ? theme.colors[theme.primaryColor][6] : undefined}>
                <Group gap='sm'>
                  <IconBriefcaseFilled size='1.5rem' color={option === 1 ? theme.colors.dark[0] : theme.colors.dark[8]} />
                  <Text size='md' c={option === 1 ? theme.colors.dark[0] : theme.colors.dark[8]} fw={600}>{locale('bulk_order')}</Text>
                </Group>
              </Flex>
            )}
            <Flex justify='space-between' align='center' w='inherit' h='1.15rem' px='xs' bg='dark.4' mt='auto'>
              <Text size='xs' fw={600} flex={1} c={cancelPressed ? 'dark.8' : 'dark.0'}>
                {locale('cancel')}
              </Text>
              <Divider orientation='vertical' w='fit-content' color='dark.5' />
              <Text size='xs' fw={600} flex={1} ta='right' c={confirmPressed ? 'dark.8' : 'dark.0'}>
                {locale('confirm')}
              </Text>
            </Flex>
          </Flex>
          <Flex justify='center' align='flex-start' w='100%' h='1rem' mt='sm'>
            <Button
              variant='subtle'
              h='2rem'
              p={0}
              flex={1}
              bd={`1px solid ${theme.colors.dark[6]}`}
              style={{
                borderRight: 'none',
                borderTopRightRadius: 0,
                borderBottomRightRadius: 0,
              }}
              onClick={keypressCancel}
              onMouseDown={() => setCancelPressed(true)}
              onMouseUp={() => setCancelPressed(false)}
              onMouseLeave={() => setCancelPressed(false)}
            >
              <svg width='27' height='7' viewBox='0 0 27 7' fill="none" xmlns="http://www.w3.org/2000/svg">
                <rect x="2" y="2" width='23' height='2' rx="20" fill={theme.colors.dark[2]} />
              </svg>
            </Button>
            <Button.Group orientation='vertical'>
              <Button
                w='3.5rem'
                h='2rem'
                p={0}
                c='dark.2'
                variant='subtle'
                bd={`1px solid ${theme.colors.dark[6]}`}
                bdrs={0}
                style={{
                  borderBottom: 'none',
                }}
                onClick={keypressUp}
              >
                <IconCaretUpFilled size='1.5rem' />
              </Button>
              <Button
                w='3.5rem'
                h='2rem'
                p={0}
                c='dark.2'
                variant='subtle'
                bd={`1px solid ${theme.colors.dark[6]}`}
                style={{
                  borderTop: 'none',
                  borderTopRightRadius: 0,
                  borderTopLeftRadius: 0,
                }}
                onClick={keypressDown}
              >
                <IconCaretDownFilled size='1.5rem' />
              </Button>
            </Button.Group>
            <Button
              variant='subtle'
              h='2rem'
              p={0}
              flex={1}
              bd={`1px solid ${theme.colors.dark[6]}`}
              style={{
                borderLeft: 'none',
                borderTopLeftRadius: 0,
                borderBottomLeftRadius: 0,
              }}
              onClick={keypressConfirm}
              onMouseDown={() => setConfirmPressed(true)}
              onMouseUp={() => setConfirmPressed(false)}
              onMouseLeave={() => setConfirmPressed(false)}
            >
              <svg width='27' height='7' viewBox='0 0 27 7' fill="none" xmlns="http://www.w3.org/2000/svg">
                <rect x="2" y="2" width='23' height='2' rx="20" fill={theme.colors.dark[2]} />
              </svg>
            </Button>
          </Flex>
        </Paper>
      )}
    </Transition>
  );
};

export default DealerMenu;