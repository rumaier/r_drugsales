import { create } from "zustand";
import { fetchNui } from "../utils/fetchNui";
import { addInitialFetch } from "../utils/initFetch";

interface LocaleTable {
  [key: string]: string
};

interface LocaleStore {
  locales: LocaleTable;
  lookup: (key: string, ...args: (string | number)[]) => string;
};

export const useLocaleStore = create<LocaleStore>((_, get) => ({
  locales: {},

  lookup: (key: string, ...args: (string | number)[]) => {
    let str = get().locales[key] || key;
    if (args.length) {
      str = str.replace(/%s/g, () => String(args.shift()));
    };
    return str;
  }
}));

export const locale = useLocaleStore.getState().lookup;

addInitialFetch('fetchLocales', () => {
  fetchNui<LocaleTable>('fetchLocales').then((resp) => {
    useLocaleStore.setState({ locales: resp });
  }).catch((err) => {
    console.error('Failed to fetch locales', err);
  });
});