import { create } from "zustand";
import { fetchNui } from "../utils/fetchNui";
import { addInitialFetch } from "../utils/initFetch";

export const useConfigStore = create<any>(() => ({}));

addInitialFetch('fetchConfig', () => {
  fetchNui<any>('fetchConfig').then((resp) => {
    useConfigStore.setState(resp);
  }).catch((err) => {
    console.error('Failed to fetch config', err);
  });
});