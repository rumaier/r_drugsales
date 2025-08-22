import { MantineProvider, type MantineTheme } from "@mantine/core";
import { useEffect, useState, type FC } from "react";
import theme from "./theme";
import { runInitialFetches } from "./utils/initalFetch";
import DevWrapper from "./components/DevWrapper";
import { configStore } from "./stores/config";

const App: FC = () => {
  const cfg = configStore((state) => state);

  const [nuiColor, setNuiColor] = useState<string>('blue');
  const [theming, setTheming] = useState<MantineTheme>(theme as MantineTheme);

  useEffect(() => setNuiColor(cfg.Options?.NuiColor || 'blue'), [cfg]);

  useEffect(() => setTheming((current) => ({ ...current, primaryColor: nuiColor })), [nuiColor]);

  useEffect(() => runInitialFetches(), []);

  return (
    <MantineProvider theme={theming} forceColorScheme='dark'>
      <DevWrapper>

      </DevWrapper>
    </MantineProvider>
  );
};

export default App;