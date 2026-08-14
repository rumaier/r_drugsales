import { useEffect, useState, type FC } from "react";
import { useConfigStore } from "../../stores/config";
import { Paper, Transition } from "@mantine/core";
import Dialing from "./Dialing";
import Confirm from "./Confirm";
import { useNuiEvent } from "../../hooks/useNuiEvent";

export interface Order {
  item: { name: string; label: string };
  count: number;
  price: number;
}

const OrderInterface: FC = () => {

  const iconPath = useConfigStore((state) => state.IconPath);
  const [visible, setVisible] = useState<boolean>(false);
  const [order, setOrder] = useState<Order | null>(null);
  const [dialing, setDialing] = useState<boolean>(true);

  useNuiEvent<Order>('openOrderInterface', (order) => {
    setVisible(true);
    setOrder(order);
  });

  useEffect(() => {
    if (!visible) return;
    setTimeout(() => {
      setDialing(false);
    }, 4000);
  }, [visible]);
  
  return (
    <Transition mounted={visible} transition='pop' duration={200}>
      {(styles) => (
        <div style={{ position: 'absolute', bottom: '20%', left: '50%', transform: 'translate(-50%, 50%)' }}>
          <div style={styles}>
            <Paper
              w={dialing ? '22rem' : '27.5rem'}
              h='8rem'
              bg='dark.8'
              withBorder
              style={{
                overflow: 'hidden',
                transition: 'width 150ms ease',
              }}
            >
              <Dialing visible={dialing} />
              <Confirm visible={!dialing && order !== null} setVisible={setVisible} order={order} iconPath={iconPath} />
            </Paper>
          </div>
        </div>
      )}
    </Transition>
  );
};

export default OrderInterface;