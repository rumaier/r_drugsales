import { Button, Group, Title } from "@mantine/core";
import type { FC } from "react";
import { locale } from "../../stores/locales";
import { IconX } from "@tabler/icons-react";

interface Props {
  onCancel: () => void
};

const Header: FC<Props> = ({ onCancel }) => {

  return (
    <Group p='md'>
      <Title order={3}>{
        locale('offer_drugs')}
      </Title>
      <Button
        size='xs'
        variant='subtle'
        color='red'
        c='dark.0'
        ml='auto'
        p={0}
        onClick={onCancel}
      >
        <IconX />
      </Button>
    </Group>
  );
};

export default Header;