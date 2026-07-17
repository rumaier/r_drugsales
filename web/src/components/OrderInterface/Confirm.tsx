import type { Dispatch, FC, SetStateAction } from "react";
import type { Order } from "./OrderInterface";
import { Button, Center, Group, Image, Stack, Text, Transition } from "@mantine/core";
import { locale } from "../../stores/locales";
import { fetchNui } from "../../utils/fetchNui";

interface Props {
  visible: boolean;
  setVisible: Dispatch<SetStateAction<boolean>>;
  order: Order | null;
  iconPath: string;
};

const Confirm: FC<Props> = ({ visible, setVisible, order, iconPath }) => {

  const handleAccept = () => {
    fetchNui('orderInterfaceResponse', 'accept').then(() => {
      setVisible(false);
    });
  };

  const handleDecline = () => {
    fetchNui('orderInterfaceResponse', 'decline').then(() => {
      setVisible(false);
    });
  };

  return (
    <Transition mounted={visible} transition='fade' duration={200}>
      {(styles) => (
        <Center pos='absolute' w='100%' h='100%' style={styles}>
          <Group gap={0}>
            <Image src={iconPath.replace('%s', order!.item.name)} w='5rem' mx='sm' />
            <Stack gap='sm' pr='0.75rem' flex={1}>
              <Text size='md' fw={600}>
                {locale('bulk_order_body', order!.count, order!.item.label, order!.price)}
              </Text>
              <Group gap='xs'>
                <Button
                  size='sm'
                  variant='light'
                  color='red'
                  flex={1}
                  onClick={handleDecline}
                >
                  {locale('decline')}
                </Button>
                <Button
                  size='sm'
                  variant='light'
                  color='green'
                  flex={1}
                  onClick={handleAccept}
                >
                  {locale('accept')}
                </Button>
              </Group>
            </Stack>
          </Group>
        </Center>
      )}
    </Transition>
  );
};

export default Confirm;