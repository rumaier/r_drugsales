import { Button, Divider, Flex, Group, Image, Indicator, NumberInput, Paper, Text, TooltipFloating, Transition, useMantineTheme } from "@mantine/core";
import { useDisclosure } from "@mantine/hooks";
import { useEffect, useState, type FC } from "react";
import { fetchNui } from "../utils/fetchNui";
import { Carousel } from "@mantine/carousel";
import { locale } from "../stores/locales";
import { configStore } from "../stores/config";
import { useKeybind } from "../hooks/useKeybind";
import { IconCurrencyDollar } from "@tabler/icons-react";
import { useNuiEvent } from "../hooks/useNuiEvent";

interface DrugItem {
  name: string;
  label: string;
  count: number;
  metadata?: {
    image?: string;
  };
};

const StreetSale: FC = () => {
  const theme = useMantineTheme();
  const cfg = configStore.getState();

  const [visible, { open, close }] = useDisclosure(false);

  useNuiEvent('openStreetSale', () => open());

  useNuiEvent('closeStreetSale', () => {
    if (visible) handleCancel();
  });

  const [drugs, setDrugs] = useState<DrugItem[]>([]);

  const [selectedDrug, setSelectedDrug] = useState<DrugItem | null>(null);
  const [amount, setAmount] = useState<number>(1);
  const [price, setPrice] = useState<number>(0);

  useEffect(() => {
    setPrice(selectedDrug ? Math.floor(cfg.Options?.DrugItems[selectedDrug?.name].street.maxPricePer / 2) : 0);
  }, [selectedDrug]);

  useEffect(() => {
    if (selectedDrug) {
      setPrice(Math.floor(cfg.Options?.DrugItems[selectedDrug?.name].street.maxPricePer / 2) * amount);
    };
  }, [amount]);

  useEffect(() => {
    if (!visible) return;
    fetchNui<DrugItem[]>('getPlayerDrugs').then((drugs) => {
      setAmount(1);
      setDrugs(drugs);
    });
  }, [visible]);

  const handleOffer = () => {
    if (!selectedDrug) return;
    fetchNui('saleUiResponse', { drug: selectedDrug.name, amount: amount, price: price });
    setSelectedDrug(null);
    close();
  };
  
  const handleCancel = () => {
    setSelectedDrug(null);
    fetchNui('saleUiResponse', 'cancelled');
    close();
  };

  useKeybind('Escape', handleCancel);

  return (
    <Transition mounted={visible} transition='pop' duration={200} timingFunction='ease'>
      {(transitionStyles) => (
        <Paper
          pos='absolute'
          w='30rem'
          bottom='7.5rem'
          left='calc(50% - 15rem)'
          shadow='lg'
          p='md'
          style={transitionStyles}
        >
          <Carousel
            withControls={false}
            height='fit-content'
            slideSize={{ md: '20%' }}
            slideGap='sm'
            emblaOptions={{ loop: true, align: 'start', dragFree: true }}
          >
            {drugs.map((drug) => (
              <Carousel.Slide
                key={drug.name}
                bd={selectedDrug?.name === drug.name ? `0.1rem solid ${theme.colors[theme.primaryColor][6]}` : `0.1rem solid ${theme.colors.dark[7]}`}
                bdrs='md'
                onClick={() => {
                  if (drug.name === selectedDrug?.name) {
                    setSelectedDrug(null);
                  } else {
                    setSelectedDrug(drug);
                  }
                }}
                style={{ cursor: 'pointer', backgroundColor: selectedDrug?.name === drug.name ? theme.colors.dark[8] : 'transparent' }}
                onMouseEnter={(e) => e.currentTarget.style.backgroundColor = theme.colors.dark[8]}
                onMouseLeave={(e) => e.currentTarget.style.backgroundColor = selectedDrug?.name === drug.name ? theme.colors.dark[8] : 'transparent'}
              >
                <Flex
                  direction='column'
                  align='center'
                  justify='center'
                  gap='sm'
                  p='sm'
                  bg='transparent'
                  bdrs='md'
                  style={{ opacity: drug.count > 0 ? 1 : 0.5 }}
                >
                  <Indicator
                    size='sm'
                    position='bottom-end'
                    label={drug.count < 999 ? 'x' + drug.count : (drug.count / 1000).toFixed(1) + 'k'}
                    style={{ userSelect: 'none' }}
                  >
                    <Image
                      w='4rem'
                      h='4rem'
                      src={cfg.Server?.InventoryPath.replace('%s', drug.name)}
                      style={{ userSelect: 'none' }}
                    />
                  </Indicator>
                  <Text lineClamp={1} style={{ userSelect: 'none' }}>{drug.label}</Text>
                </Flex>
              </Carousel.Slide>
            ))}
          </Carousel>
          <Divider my='sm' />
          <Group align='center' justify='center' mt='lg' gap='md'>
            <TooltipFloating label={locale('select_drug')} disabled={selectedDrug !== null}>
              <div>
                <NumberInput
                  label={locale('amount')}
                  size='sm'
                  mt='-1rem'
                  min={1}
                  w='12rem'
                  max={selectedDrug ? Math.min(selectedDrug.count, cfg.Options?.DrugItems[selectedDrug?.name].street.maxAmount) : 1}
                  disabled={!selectedDrug}
                  allowNegative={false}
                  allowLeadingZeros={false}
                  allowDecimal={false}
                  value={amount}
                  onChange={(val) => setAmount(Number(val) || 0)}
                />
              </div>
            </TooltipFloating>
            <TooltipFloating label={locale('select_drug')} disabled={selectedDrug !== null}>
              <div>
                <NumberInput
                  label={locale('price')}
                  size='sm'
                  mt='-1rem'
                  min={1}
                  w='12rem'
                  disabled={!selectedDrug}
                  allowNegative={false}
                  allowLeadingZeros={false}
                  allowDecimal={false}
                  value={price}
                  onChange={(val) => setPrice(Number(val) || 0)}
                  leftSection={<IconCurrencyDollar />}
                />
              </div>
            </TooltipFloating>
            <Group>
              <Button
                variant='light'
                size='sm'
                w='5.5rem'
                onClick={handleCancel}
                autoContrast
              >
                <Text fz='sm' fw={600}>{locale('cancel')}</Text>
              </Button>
              <Button
                variant='light'
                size='sm'
                w='5.5rem'
                disabled={!selectedDrug || amount <= 0 || price <= 0}
                onClick={handleOffer}
                autoContrast
              >
                <Text fz='sm' fw={600}>{locale('offer')}</Text>
              </Button>
            </Group>
          </Group>
        </Paper>
      )}
    </Transition>
  );
};

export default StreetSale;