import { Box, Button, Center, CheckIcon, Group, Image, NumberInput, RollingNumber, Select, Stack, type SelectProps } from "@mantine/core";
import type { UseFormReturnType } from "@mantine/form";
import { useEffect, type Dispatch, type FC, type SetStateAction } from "react";
import { locale } from "../../stores/locales";
import type { Item } from "./OfferInterface";
import { IconCurrencyDollar, IconEqual, IconHash, IconX } from "@tabler/icons-react";
import { fetchNui } from "../../utils/fetchNui";

interface Props {
  form: UseFormReturnType<{
    item: string;
    count: number;
    price: number;
  }>
  setVisible: Dispatch<SetStateAction<boolean>>
  iconPath: string
  items: Item[]
  drugsCfg: {
    [key: string]: {
      street: { maxOffer: number; maxPrice: number };
      bulk: { minRequest: number; maxRequest: number; minPrice: number; maxPrice: number };
    }
  }
};

const Form: FC<Props> = ({ form, setVisible, iconPath, items, drugsCfg }) => {

  const handleSubmit = (values: typeof form.values) => {
    const streetCfg = drugsCfg[values.item]?.street;
    const selectedItem = items.find((item) => item.name === values.item);
    if (!streetCfg || !selectedItem) return;

    const allowedCount = Math.min(streetCfg.maxOffer, selectedItem.count);

    const offer = {
      ...values,
      count: Math.min(Math.max(Number(values.count) || 1, 1), allowedCount),
      price: Math.min(Math.max(Number(values.price) || 1, 1), streetCfg.maxPrice),
    };

    form.setValues(offer);
    fetchNui('offerInterfaceResponse', offer).then(() => {
      setVisible(false);
    });
  };

  const renderSelectOption: SelectProps['renderOption'] = ({ option, checked }) => (
    <Group flex={1} gap='xs'>
      <Image src={iconPath.replace('%s', option.value)} w='1rem' />
      {option.label}
      {checked && <CheckIcon color='currentColor' opacity={0.6} size={12} style={{ marginInlineStart: 'auto' }} />}
    </Group>
  );

  const selectData = items.map((item) => ({
    value: item.name,
    label: item.label,
  }));

  const selectedItem = items.find((item) => item.name === form.values.item);
  const streetCfg = drugsCfg[form.values.item]?.street;
  const maxCount = selectedItem && streetCfg
    ? Math.min(streetCfg.maxOffer, selectedItem.count)
    : undefined;
  const maxPrice = streetCfg?.maxPrice;

  useEffect(() => {
    if (form.values.item.length > 0) {
      form.setValues({
        count: maxCount !== undefined && form.values.count > maxCount ? maxCount : form.values.count,
        price: maxPrice !== undefined && form.values.price > maxPrice ? maxPrice : form.values.price,
      })
    };
  }, [form.values.item]);
  
  return (
    <Box px='md' w='20rem'>
      <form onSubmit={form.onSubmit(handleSubmit)}>
        <Select
          key={form.key('item')}
          placeholder={'-'}
          allowDeselect={false}
          data={selectData}
          {...form.getInputProps('item')}
          renderOption={renderSelectOption}
        />
        <Center my='sm'>
          <IconX size={12} />
        </Center>
        <NumberInput
          allowNegative={false}
          allowLeadingZeros={false}
          allowDecimal={false}
          clampBehavior='strict'
          disabled={form.values.item === ''}
          min={1}
          max={maxCount}
          key={form.key('count')}
          {...form.getInputProps('count')}
          leftSection={<IconHash size='1.25rem' />}
        />
        <Center my='sm'>
          <IconX size={12} />
        </Center>
        <NumberInput
          allowNegative={false}
          allowLeadingZeros={false}
          allowDecimal={false}
          clampBehavior='strict'
          disabled={form.values.item === ''}
          min={1} 
          max={maxPrice}
          key={form.key('price')}
          {...form.getInputProps('price')}
          leftSection={<IconCurrencyDollar size='1.25rem' />}
        />
        <Stack my='sm' justify='center' align='center'>
          <IconEqual size={12} />
          <RollingNumber
            value={form.values.count * form.values.price}
            prefix='$'
            thousandSeparator
            decimalScale={2}
            fixedDecimalScale
            fz='xxl'
          />
        </Stack>
        <Button type='submit' size='sm' my='md' fullWidth disabled={form.values.item === ''}>
          {locale('offer')}
        </Button>
      </form>
    </Box>
  );
};

export default Form;