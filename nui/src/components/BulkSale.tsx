import { useDisclosure } from "@mantine/hooks";
import { useEffect, useState, type FC } from "react";
import { fetchNui } from "../utils/fetchNui";
import { Button, Group, Image, Paper, Text, Transition, useMantineTheme } from "@mantine/core";
import { IconPhoneCall } from "@tabler/icons-react";
import { locale } from "../stores/locales";
import { configStore } from "../stores/config";
import { useNuiEvent } from "../hooks/useNuiEvent";

interface Offer {
  drug: string;
  label: string;
  amount: number;
  price: number;
};

const BulkSale: FC = () => {
  const theme = useMantineTheme();
  const cfg = configStore.getState();

  const [visible, { open, close }] = useDisclosure(false);

  useNuiEvent('openBulkSale', () => open());

  const [dialing, setDialing] = useState<boolean>(true);

  const [trailingDots, setTrailingDots] = useState<string>('');
  useEffect(() => {
    if (!dialing) return;
    const interval = setInterval(() => {
      if (!dialing) clearInterval(interval);
      setTrailingDots((current) => {
        if (current.length >= 3) return '';
        return current + '.';
      });
    }, 500);
    return () => clearInterval(interval);
  }, []);

  const [offer, setOffer] = useState<Offer | null>(null);

  useEffect(() => {
    setTimeout(() => {
      fetchNui<Offer>('getCurrentOffer').then((resp) => {
        setOffer(resp);
        setDialing(false);
      });
    }, 4000);
  }, []);

  return (
    <>
      <Transition mounted={visible && dialing} transition='pop' duration={200} timingFunction='ease'>
        {(transitionStyles) => (
          <Paper
            pos='absolute'
            w='20rem'
            bottom='7.5rem'
            h='6rem'
            left='calc(50% - 10rem)'
            shadow='lg'
            p='md'
            style={transitionStyles}
          >
            <Group justify='flex-start' align='center' h='100%' style={{ userSelect: 'none' }}>
              <IconPhoneCall size='3.5rem' color={theme.colors.dark[0]} />
              <Text fz='xxl' fw={600} c='dark.0'>
                {locale('dialing') + trailingDots}
              </Text>
            </Group>
          </Paper>
        )}
      </Transition>
      <Transition mounted={visible && !dialing} transition='pop' duration={200} timingFunction='ease'>
        {(transitionStyles) => (
          <Paper
            pos='absolute'
            w='fit-content'
            bottom='7.5rem'
            left='calc(50% - 11rem)'
            shadow='lg'
            p='md'
            style={transitionStyles}
          >
            <Group>
              <Image src={cfg.Server?.InventoryPath.replace('%s', offer?.drug || 'water')} w='4rem' h='4rem' />
              <Text flex={1} fz='md' fw={500} c='dark.0' w='17rem' style={{ userSelect: 'none' }}>
                {locale('bulk_request', offer?.amount || 0, offer?.label || 'locale_err', offer?.price || 0)}
              </Text>
            </Group>
            <Group justify='center' align='center' gap='sm' mt='sm' w='100%'>
              <Button
                variant='light'
                flex={1}
                onClick={() => fetchNui('bulkUiResponse', 'cancel').then(() => close())}
              >
                {locale('cancel')}
              </Button>
              <Button
                variant='light'
                flex={1}
                onClick={() => fetchNui('bulkUiResponse', 'accept').then(() => close())}
              >
                {locale('accept')}
              </Button>
            </Group>
          </Paper>
        )}
      </Transition>
    </>
  );
};

export default BulkSale;