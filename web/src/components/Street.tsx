import { Carousel } from "@mantine/carousel";
import { Button, Divider, Flex, Group, Image, Indicator, NumberInput, Paper, Text, TooltipFloating, Transition } from "@mantine/core";
import { useEffect, useState, type FC } from "react";
import { useKeybind } from "../hooks/useKeybind";
import { useNuiEvent } from "../hooks/useNuiEvent";
import { useConfigStore } from "../stores/config";
import { fetchNui } from "../utils/fetchNui";
import { locale } from "../stores/locales";
import { IconCurrencyDollar } from "@tabler/icons-react";

interface Item {
  name: string;
  label: string;
  count: number;
};

const Street: FC = () => {

  const cfg = useConfigStore.getState()
  const drugs = cfg.Drugs;
  const iconPath = cfg.IconPath;

  const [visible, setVisible] = useState<boolean>(false);
  const [items, setItems] = useState<Item[]>([]);
  const [selected, setSelected] = useState<Item | null>(null);
  const [count, setCount] = useState<number>(1);
  const [price, setPrice] = useState<number>(0);
  const [total, setTotal] = useState<number>(0);

  useNuiEvent('openOfferUi', () => {
    setVisible(true);
  });

  useNuiEvent('closeOfferUi', () => {
    if (!visible) return;
    setVisible(false);
  });

  useEffect(() => {
    if (!visible) return;
    fetchNui<Item[]>('getDrugs').then((res) => {
      setItems(res);
    });
  }, [visible]);

  useEffect(() => {
    const cost = selected ? Math.floor(drugs[selected.name].street.maxPricePer / 2) : 0;
    setPrice(cost);
  }, [selected]);

  useEffect(() => {
    if (!selected) return;
    setTotal(price * count);
  }, [count, price]);

  const offer = () => {
    if (!selected) return;
    const offer = {
      drug: selected.name,
      count,
      total
    };
    fetchNui('streetUiResp', offer);
    setVisible(false);
    setSelected(null);
    setCount(0);
  };

  const cancel = () => {
    fetchNui('streetUiResp', 'cancel');
    setVisible(false);
    setSelected(null);
    setCount(0);
  };

  useKeybind('Escape', cancel);

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
            {items.map((drug) => (
              <Carousel.Slide
                key={drug.name}
                bd={selected?.name === drug.name ? '0.1rem solid var(--mantine-primary-color-6)' : `0.1rem solid var(--mantine-color-dark-7)`}
                bdrs='md'
                onClick={() => {
                  if (drug.name === selected?.name) {
                    setSelected(null);
                  } else {
                    setSelected(drug);
                  }
                }}
                style={{ cursor: 'pointer', backgroundColor: selected?.name === drug.name ? 'var(--mantine-color-dark-8)' : 'transparent' }}
                onMouseEnter={(e) => e.currentTarget.style.backgroundColor = 'var(--mantine-color-dark-8)'}
                onMouseLeave={(e) => e.currentTarget.style.backgroundColor = selected?.name === drug.name ? 'var(--mantine-color-dark-8)' : 'transparent'}
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
                      src={iconPath.replace('%s', drug.name)}
                      style={{ userSelect: 'none' }}
                    />
                  </Indicator>
                  <Text lineClamp={1} style={{ userSelect: 'none' }}>
                    {drug.label}
                  </Text>
                </Flex>
              </Carousel.Slide>
            ))}
          </Carousel>
          <Divider my='sm' />
          <Group align='center' justify='center' mt='lg' gap='md'>
            <TooltipFloating label={locale('select_drug')} disabled={selected !== null}>
              <div>
                <NumberInput
                  label={locale('amount')}
                  size='sm'
                  mt='-1rem'
                  min={1}
                  w='12rem'
                  max={selected ? Math.min(selected.count, cfg.Options?.DrugItems[selected?.name].street.maxAmount) : 1}
                  disabled={!selected}
                  allowNegative={false}
                  allowLeadingZeros={false}
                  allowDecimal={false}
                  value={count}
                  onChange={(val) => setCount(Number(val) || 0)}
                />
              </div>
            </TooltipFloating>
            <TooltipFloating label={locale('select_drug')} disabled={selected !== null}>
              <div>
                <NumberInput
                  label={locale('price')}
                  size='sm'
                  mt='-1rem'
                  min={1}
                  w='12rem'
                  disabled={!selected}
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
                onClick={cancel}
                autoContrast
              >
                <Text fz='sm' fw={600}>{locale('cancel')}</Text>
              </Button>
              <Button
                variant='light'
                size='sm'
                w='5.5rem'
                disabled={!selected || count <= 0 || price <= 0}
                onClick={offer}
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

export default Street;