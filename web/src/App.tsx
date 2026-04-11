import { MantineProvider, mergeMantineTheme, type MantineTheme } from "@mantine/core";
import { ModalsProvider } from '@mantine/modals';
import { useEffect, useState, type FC } from "react";
import { useConfigStore } from "./stores/config";
import { theme } from "./theme";
import { runInitialFetches } from "./utils/initFetch";

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
      <ModalsProvider>
        {/* App goes here */}
      </ModalsProvider>
    </MantineProvider>
  );
};

export default App;