import { create } from "zustand";
import { addInitialFetch } from "../utils/initalFetch";
import { fetchNui } from "../utils/fetchNui";
import { isEnvBrowser } from "../utils/misc";

interface LocaleTable {
  [key: string]: string;
};

type LookupFunction = (key: string, ...args: (string | number)[]) => string;

interface LocaleStore {
  locales: LocaleTable;
  lookup: LookupFunction;
}

const mockLocales: LocaleTable = {

};

export const localeStore = create<LocaleStore>((_, get) => ({
  locales: isEnvBrowser() ? mockLocales : {},
  lookup: (key: string, ...args: (string | number)[]) => {
    let str = get().locales[key] || key;
    if (args.length) str = str.replace(/%s/g, () => args.shift() as string);
    return str;
  }
}));

addInitialFetch('fetchLocales', () => {
  fetchNui<LocaleTable>('getLocales').then((resp) => {
    localeStore.setState({ locales: resp });
  }).catch((err) => {
    console.error("Failed to fetch locales:", err);
  });
});

export const locale = localeStore.getState().lookup;