import { isEnvBrowser } from "./misc";

interface InitialFetchesTable {
  [key: string]: () => void;
};

const initialFetches: InitialFetchesTable = {};

export const addInitialFetch = (key: string, func: () => void) => {
  const isBrowser = isEnvBrowser();
  if (isBrowser) return;
  initialFetches[key] = func;
};

export const runInitialFetches = () => {
  const isBrowser = isEnvBrowser();
  if (isBrowser) return;
  for (const key in initialFetches) {
    initialFetches[key]();
  };
};