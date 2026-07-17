import { useEffect, useState, type FC } from "react";
import { useConfigStore } from "../../stores/config";
import { useSoundStore } from "../../stores/sounds";
import { useNuiEvent } from "../../hooks/useNuiEvent";
import { fetchNui } from "../../utils/fetchNui";
import { useKeybind } from "../../hooks/useKeybind";
import { Paper, Stack, Transition } from "@mantine/core";
import Earpiece from "./Earpiece";
import Screen from "./Screen";
import Keypad from "./Keypad";

interface GameTime {
  hour: number;
  minute: number;
}

const DealerMenu: FC = () => {

  const playSound = useSoundStore.getState().play;
  const bulkEnabled = useConfigStore.getState().BulkSalesEnabled;
  const [visible, setVisible] = useState<boolean>(false);
  const [gameTime, setGameTime] = useState<GameTime>({ hour: 0, minute: 0 });

  const getGameTime = () => fetchNui<GameTime>('getGameTime').then((time) => {
    setGameTime(time);
  });

  useNuiEvent('openMenu', () => {
    setVisible(true);
    getGameTime();
  });

  useKeybind('Escape', () => {
    if (!visible) return;
    fetchNui('onMenuClose');
    setVisible(false);
  });

  const advanceGameTime = (prev: GameTime) => {
    let { hour, minute } = prev;
    minute += 1;
    if (minute >= 60) {
      hour += 1;
      minute = 0;
    };
    if (hour >= 24) {
      hour = 0;
    };
    return { hour, minute };
  };

  useEffect(() => {
    let interval: number | null = null;
    if (visible) {
      interval = setInterval(() => setGameTime((prev) => advanceGameTime(prev)), 2000);
    } else {
      if (interval) clearInterval(interval);
      interval = null;
    };
    return () => {
      if (interval) clearInterval(interval);
      interval = null;
    };
  }, [visible]);

  const handleSellHere = () => {
    playSound('keypress', 0.025);
    fetchNui('initStreetSale').then((success) => {
      if (!success) return;
      fetchNui('onMenuClose');
      setVisible(false);
    })
  };

  const handleBulkOrder = () => {
    playSound('keypress', 0.025);
    fetchNui('initBulkOrder').then((success) => {
      if (!success) return;
      setVisible(false);
    })
  };

  return (
    <Transition mounted={visible} transition='slide-up' duration={200}>
      {(styles) => (
        <Paper
          pos='absolute'
          right={0}
          bottom={0}
          w='14rem'
          h='19.5rem'
          mx='sm'
          px='md'
          pt='md'
          bg='dark.8'
          style={{
            ...styles,
            borderBottomLeftRadius: 0,
            borderBottomRightRadius: 0,
            userSelect: 'none',
            overflow: 'hidden',
            boxShadow: [
              'inset 3px 0 5px rgba(255, 255, 255, 0.07)',
              'inset -4px 0 7px rgba(0, 0, 0, 0.55)',
              'inset 0 2px 3px rgba(255, 255, 255, 0.05)',
              'inset 0 -3px 5px rgba(0, 0, 0, 0.35)',
              '4px 0 14px rgba(0, 0, 0, 0.4)',
            ].join(', '),
          }}
        >
          <Stack gap='md' h='100%' align='center'>
            <Earpiece />
            <Screen
              gameTime={gameTime}
              bulkEnabled={bulkEnabled}
              onSellHere={handleSellHere}
              onBulkOrder={handleBulkOrder}
            />
            <Keypad />
          </Stack>
        </Paper>
      )}
    </Transition>
  );
};

export default DealerMenu;
