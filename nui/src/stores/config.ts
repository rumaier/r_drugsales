import { create } from "zustand";
import { addInitialFetch } from "../utils/initalFetch";
import { fetchNui } from "../utils/fetchNui";
import { isEnvBrowser } from "../utils/misc";

const mockConfig = {
  Server: {},
  Options: {},
  Debug: false,
};

export const configStore = create<any>(() => isEnvBrowser() && mockConfig || {});

addInitialFetch('fetchConfig', () => {
  fetchNui('getConfig').then((resp) => {
    configStore.setState(resp);
  }).catch((err) => {
    console.error("Failed to fetch config:", err);
  });
});