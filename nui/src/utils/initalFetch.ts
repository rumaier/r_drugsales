import { isEnvBrowser } from "./misc";

interface InitalFetchTable {
  [key: string]: () => void;
}

const initalFetches = {} as InitalFetchTable;

export const addInitialFetch = (key: string, cb: () => void) => {
  if (!isEnvBrowser()) initalFetches[key] = cb;
};

export const runInitialFetches = () => {
  for (const key in initalFetches) initalFetches[key]();
};