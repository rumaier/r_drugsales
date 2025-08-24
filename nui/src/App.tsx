import { MantineProvider, type MantineTheme } from "@mantine/core";
import { useEffect, useState, type FC } from "react";
import theme from "./theme";
import { runInitialFetches } from "./utils/initalFetch";
import DevWrapper from "./components/DevWrapper";
import { configStore } from "./stores/config";
import DealerMenu from "./components/DealerMenu";
import { useNuiEvent } from "./hooks/useNuiEvent";
import StreetSale from "./components/StreetSale";

const App: FC = () => {
  const cfg = configStore((state) => state);

  const [nuiColor, setNuiColor] = useState<string>('blue');
  const [theming, setTheming] = useState<MantineTheme>(theme as MantineTheme);

  useEffect(() => setNuiColor(cfg.Options?.NuiColor || 'blue'), [cfg]);

  useEffect(() => setTheming((current) => ({ ...current, primaryColor: nuiColor })), [nuiColor]);

  useEffect(() => runInitialFetches(), []);

  const [mounted, setMounted] = useState<{ [key: string]: boolean }>({
    dealerMenu: false,
    streetSale: false,
  });

  useNuiEvent('mount', (data: string) => {
    setMounted((current) => ({ ...current, [data]: true }));
  });

  const dismount = (component: string) => {
    setMounted((current) => ({ ...current, [component]: false }));
  };

  return (
    <MantineProvider theme={theming} forceColorScheme='dark'>
      <DevWrapper>
        {mounted.dealerMenu && <DealerMenu dismount={() => dismount('dealerMenu')} />}
        {mounted.streetSale && <StreetSale dismount={() => dismount('streetSale')} />}
      </DevWrapper>
    </MantineProvider>
  );
};

export default App;