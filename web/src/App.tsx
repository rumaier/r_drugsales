import { MantineProvider, mergeMantineTheme, type MantineTheme } from "@mantine/core";
import { useEffect, useState, type FC } from "react";
import { useConfigStore } from "./stores/config";
import { theme } from "./theme";
import { runInitialFetches } from "./utils/initFetch";
import DealerMenu from "./components/DealerMenu/DealerMenu";
import OfferInterface from "./components/OfferInterface/OfferInterface";
import OrderInterface from "./components/OrderInterface/OrderInterface";

const App: FC = () => {

  const nuiColor = useConfigStore((state) => state.NuiColor);
  const [mantineTheme, setMantineTheme] = useState<MantineTheme>(theme);

  useEffect(() => {
    if (!nuiColor) return;
    const newTheme = mergeMantineTheme(theme, {
      primaryColor: nuiColor,
    });
    setMantineTheme(newTheme);
  }, [nuiColor]);

  useEffect(() => {
    runInitialFetches();
  }, []);

  return (
    <MantineProvider theme={mantineTheme} forceColorScheme='dark'>
        <DealerMenu />
        <OfferInterface />
        <OrderInterface />
    </MantineProvider>
  );
};

export default App;