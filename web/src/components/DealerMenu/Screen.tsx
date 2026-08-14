import { Box, Button, Divider, Group, Stack, Text } from "@mantine/core";
import { IconAntennaBars5, IconBattery3, IconCancel, IconCannabisFilled, IconPackage } from "@tabler/icons-react";
import type { FC } from "react";
import { locale } from "../../stores/locales";

interface GameTime {
  hour: number;
  minute: number;
}

interface ScreenProps {
  gameTime: GameTime;
  bulkEnabled: boolean;
  streetSelling: boolean;
  onSellHere: () => void;
  onCancelSelling: () => void;
  onBulkOrder: () => void;
}

const formatGameTime = ({ hour, minute }: GameTime) =>
  `${String(hour).padStart(2, '0')}:${String(minute).padStart(2, '0')}`;

const Screen: FC<ScreenProps> = ({ gameTime, bulkEnabled, streetSelling, onSellHere, onCancelSelling, onBulkOrder }) => {
  return (
    <Stack
      w='100%'
      flex={1}
      bg='dark.9'
      p='xs'
      gap='xxs'
      align='stretch'
      bdrs={8}
      style={{
        boxShadow: 'inset 0 0 0 2px rgba(0, 0, 0, 0.45), inset 0 2px 6px rgba(0, 0, 0, 0.35)',
        minHeight: 0,
        overflow: 'hidden',
      }}
    >
      <Group justify='space-between' wrap='nowrap' gap={0} w='100%'>
        <Box flex={1} />
        <Text fz='xxs' c='dimmed' fw={600} lts={0.5}>
          {formatGameTime(gameTime)}
        </Text>
        <Group flex={1} justify='flex-end' gap={2} wrap='nowrap' c='dimmed'>
          <IconAntennaBars5 size={12} stroke={1.5} />
          <IconBattery3 size={12} stroke={1.5} />
        </Group>
      </Group>
      <Divider color='dark.7' />
      <Button
        variant='subtle'
        justify='flex-start'
        leftSection={streetSelling ? <IconCancel /> : <IconCannabisFilled />}
        px='xs'
        c={streetSelling ? 'red.4' : 'dark.0'}
        onClick={streetSelling ? onCancelSelling : onSellHere}
      >
        {locale(streetSelling ? 'cancel_selling' : 'sell_here')}
      </Button>
      {bulkEnabled && (
        <Button
          variant='subtle'
          justify='flex-start'
          leftSection={<IconPackage />}
          px='xs'
          c='dark.0'
          onClick={onBulkOrder}
        >
          {locale('bulk_order')}
        </Button>
      )}
    </Stack>
  );
};

export default Screen;
