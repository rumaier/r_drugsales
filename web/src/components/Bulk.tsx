import { useEffect, useState, type FC } from "react";
import { useConfigStore } from "../stores/config";
import { useNuiEvent } from "../hooks/useNuiEvent";
import { fetchNui } from "../utils/fetchNui";
import { Button, Group, Image, Paper, Text, Transition } from "@mantine/core";
import { IconPhoneCall } from "@tabler/icons-react";
import { locale } from "../stores/locales";

interface Offer {
  drug: string;
  label: string;
  count: number;
  price: number;
};

const Bulk: FC = () => {

  const cfg = useConfigStore.getState()
  const iconPath = cfg.IconPath;

  const [visible, setVisible] = useState<boolean>(false);
  const [dialing, setDialing] = useState<boolean>(true);
  const [offer, setOffer] = useState<Offer | null>(null);
  const [dots, setDots] = useState<string>('');

  useEffect(() => {
    if (visible) {
      setTimeout(() => {
        fetchNui<Offer>('getOffer').then((offer) => {
          setDialing(false);
          setOffer(offer);
        });
      }, 4000);
    } else {
      setDialing(true);
      setOffer(null);
      setDots('');
    };
  }, [visible]);

  useEffect(() => {
    let interval = null;
    if (dialing) {
      interval = setInterval(() => {
        setDots((prev) => prev.length >= 3 ? '' : prev + '.');
      }, 500);
    } else {
      if (interval) clearInterval(interval);
    };
    return () => {
      if (interval) clearInterval(interval);
    };
  }, [dialing]);

  useNuiEvent('openBulkUi', () => {
    setVisible(true);
  });

  return (
    <>
      <Transition mounted={visible && !offer} transition='pop' duration={200} timingFunction='ease'>
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
              <IconPhoneCall size='3.5rem' color='var(--mantine-color-dark-0)' />
              <Text fz='xxl' fw={600} c='dark.0'>
                {locale('dialing') + dots}
              </Text>
            </Group>
          </Paper>
        )}
      </Transition>
      <Transition mounted={visible && (offer !== null)} transition='pop' duration={200} timingFunction='ease'>
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
              <Image src={iconPath.replace('%s', offer?.drug || 'water')} w='4rem' h='4rem' />
              <Text flex={1} fz='md' fw={500} c='dark.0' w='17rem' style={{ userSelect: 'none' }}>
                {locale('bulk_request', offer?.count || 0, offer?.label || 'locale_err', offer?.price || 0)}
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

export default Bulk;