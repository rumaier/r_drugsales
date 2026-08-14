import { hasLength, useForm } from "@mantine/form";
import { useState, type FC } from "react";
import { useNuiEvent } from "../../hooks/useNuiEvent";
import { useConfigStore } from "../../stores/config";
import { locale } from "../../stores/locales";
import { Divider, Paper, Transition } from "@mantine/core";
import Header from "./Header";
import Form from "./Form";
import { fetchNui } from "../../utils/fetchNui";

export interface Item {
  name: string;
  label: string;
  count: number;
};

interface Payload {
  items: Item[];
};

const OfferInterface: FC = () => {

  const cfg = useConfigStore((state) => state);
  const [visible, setVisible] = useState<boolean>(false);
  const [items, setItems] = useState<Item[]>([]);

  const form = useForm({
    mode: 'controlled',
    initialValues: {
      item: '',
      count: 1,
      price: 1,
    },
    validate: {
      item: hasLength({ min: 1 }, locale('item_required')),
    },
  })

  useNuiEvent('openOfferInterface', (payload: Payload) => {
    form.reset();
    setItems(payload.items);
    setVisible(true);
  });

  const handleCancel = () => {
    fetchNui('offerInterfaceResponse', false).then(() => {
      setVisible(false);
    });
  };

  useNuiEvent('closeOfferInterface', () => {
    handleCancel();
  });

  return (
    <Transition mounted={visible} transition='pop' duration={200}>
      {(styles) => (
        <div style={{ position: 'absolute', bottom: '50%', left: '50%', transform: 'translate(-50%, 50%)' }}>
          <Paper bg='dark.8' withBorder style={styles}>
            <Header onCancel={handleCancel} />
            <Divider mb='lg' />
            <Form form={form} setVisible={setVisible} iconPath={cfg.IconPath} items={items} drugsCfg={cfg.DrugItems} />
          </Paper>
        </div>
      )}
    </Transition>
  );
};

export default OfferInterface;