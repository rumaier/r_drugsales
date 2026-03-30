import { Button, Divider, Flex, Group, Paper, Text, Transition } from "@mantine/core";
import { IconAntennaBars5, IconBattery3, IconBriefcaseFilled, IconCannabisFilled, IconCaretDownFilled, IconCaretUpFilled } from "@tabler/icons-react";
import { useEffect, useState, type FC } from "react";
import { useKeybind } from "../hooks/useKeybind";
import { useConfigStore } from "../stores/config";
import { locale } from "../stores/locales";
import { useSoundStore } from "../stores/sounds";
import { fetchNui } from "../utils/fetchNui";

interface Time {
  hour: number;
  minute: number;
};

const Menu: FC = () => {

  const cfg = useConfigStore.getState()
  const bulk = cfg.BulkSales;

  const [visible, setVisible] = useState<boolean>(false);
  const [time, setTime] = useState<Time>({ hour: 0, minute: 0 });
  const [option, setOption] = useState<number>(0);
  const [cancelled, setCancelled] = useState<boolean>(false);
  const [confirmed, setConfirmed] = useState<boolean>(false);

  const playSound = useSoundStore.getState().play;

  useEffect(() => {
    let interval = null;
    if (visible) {
      interval = setInterval(() => {
        fetchNui<Time>('getTime').then((resp) => {
          setTime(resp);
        });
      }, 2000);
    } else {
      if (interval) clearInterval(interval);
    };
    return () => {
      if (interval) clearInterval(interval);
    };
  }, [visible]);

  const keyUp = () => {
    playSound('keypress', 0.1);
    setOption((prev) => (!bulk ? 0 : Math.max(prev - 1, 0)));
  };
  
  useKeybind('ArrowUp', keyUp);

  const keyDown = () => {
    playSound('keypress', 0.1);
    setOption((prev) => (!bulk ? 0 : Math.min(prev + 1, 1)));
  };

  useKeybind('ArrowDown', keyDown);

  const confirm = () => {
    const fetch = ['triggerStreet', 'triggerBulk'];
    playSound('keypress', 0.1);
    fetchNui(fetch[option]);
    if (option === 0) fetchNui('closeMenu');
    fetchNui('setNuiFocus', false);
    setVisible(false);
  };
  
  useKeybind('Enter', confirm);

  const cancel = () => {
    playSound('keypress', 0.1);
    fetchNui('setNuiFocus', false);
    fetchNui('closeMenu');
    setVisible(false);
  };

  useKeybind('Escape', cancel);

  return (
    <Transition mounted={visible} transition='slide-up' duration={200} timingFunction='ease'>
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
              <rect x="2" y="2" width='46' height='2' rx="20" fill='var(--mantine-color-dark-5)' />
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
            bg='dark.3'
            style={{
              boxShadow: 'inset 0 0.1rem 1rem 0 #00000040',
            }}
          >
            <Flex justify='space-between' align='center' w='inherit' h='1.15rem' px='xs' bg='dark.4'>
              <Text size='xs' c='dark.0' fw={600}>
                {time.hour.toString().padStart(2, '0')}:{time.minute.toString().padStart(2, '0')}
              </Text>
              <Group gap={0}>
                <IconAntennaBars5 size='1.2rem' color='var(--mantine-color-dark-0)' style={{ marginBottom: '0.1rem' }} />
                <IconBattery3 size='1.4rem' color='var(--mantine-color-dark-0)' />
              </Group>
            </Flex>
            <Flex justify='flex-start' align='center' w='inherit' h='2.75rem' p='sm' bg={option === 0 ? 'var(--mantine-primary-color-6)' : undefined}>
              <Group gap='sm'>
                <IconCannabisFilled size='1.5rem' color={option === 0 ? 'var(--mantine-color-dark-0)' : 'var(--mantine-color-dark-8)'} />
                <Text size='md' c={option === 0 ? 'var(--mantine-color-dark-0)' : 'var(--mantine-color-dark-8)'} fw={600}>{locale('sell_here')}</Text>
              </Group>
            </Flex>
            {!bulk && (
              <Flex justify='flex-start' align='center' w='inherit' h='2.75rem' p='sm' bg={option === 1 ? 'var(--mantine-primary-color-6)' : undefined}>
                <Group gap='sm'>
                  <IconBriefcaseFilled size='1.5rem' color={option === 1 ? 'var(--mantine-color-dark-0)' : 'var(--mantine-color-dark-8)'} />
                  <Text size='md' c={option === 1 ? 'var(--mantine-color-dark-0)' : 'var(--mantine-color-dark-8)'} fw={600}>{locale('bulk_order')}</Text>
                </Group>
              </Flex>
            )}
            <Flex justify='space-between' align='center' w='inherit' h='1.15rem' px='xs' bg='dark.4' mt='auto'>
              <Text size='xs' fw={600} flex={1} c={cancelled ? 'dark.8' : 'dark.0'}>
                {locale('cancel')}
              </Text>
              <Divider orientation='vertical' w='fit-content' color='dark.5' />
              <Text size='xs' fw={600} flex={1} ta='right' c={confirmed ? 'dark.8' : 'dark.0'}>
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
              bd={`1px solid var(--mantine-color-dark-6)`}
              style={{
                borderRight: 'none',
                borderTopRightRadius: 0,
                borderBottomRightRadius: 0,
              }}
              onClick={cancel}
              onMouseDown={() => setCancelled(true)}
              onMouseUp={() => setCancelled(false)}
              onMouseLeave={() => setCancelled(false)}
            >
              <svg width='27' height='7' viewBox='0 0 27 7' fill="none" xmlns="http://www.w3.org/2000/svg">
                <rect x="2" y="2" width='23' height='2' rx="20" fill='var(--mantine-color-dark-2)' />
              </svg>
            </Button>
            <Button.Group orientation='vertical'>
              <Button
                w='3.5rem'
                h='2rem'
                p={0}
                c='dark.2'
                variant='subtle'
                bd={`1px solid var(--mantine-color-dark-6)`}
                bdrs={0}
                style={{
                  borderBottom: 'none',
                }}
                onClick={keyUp}
              >
                <IconCaretUpFilled size='1.5rem' />
              </Button>
              <Button
                w='3.5rem'
                h='2rem'
                p={0}
                c='dark.2'
                variant='subtle'
                bd={`1px solid var(--mantine-color-dark-6)`}
                style={{
                  borderTop: 'none',
                  borderTopRightRadius: 0,
                  borderTopLeftRadius: 0,
                }}
                onClick={keyDown}
              >
                <IconCaretDownFilled size='1.5rem' />
              </Button>
            </Button.Group>
            <Button
              variant='subtle'
              h='2rem'
              p={0}
              flex={1}
              bd={`1px solid var(--mantine-color-dark-6)`}
              style={{
                borderLeft: 'none',
                borderTopLeftRadius: 0,
                borderBottomLeftRadius: 0,
              }}
              onClick={confirm}
              onMouseDown={() => setConfirmed(true)}
              onMouseUp={() => setConfirmed(false)}
              onMouseLeave={() => setConfirmed(false)}
            >
              <svg width='27' height='7' viewBox='0 0 27 7' fill="none" xmlns="http://www.w3.org/2000/svg">
                <rect x="2" y="2" width='23' height='2' rx="20" fill='var(--mantine-color-dark-2)' />
              </svg>
            </Button>
          </Flex>
        </Paper>
      )}
    </Transition>
  );
};

export default Menu;