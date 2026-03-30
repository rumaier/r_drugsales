export const isEnvBrowser = (): boolean => {
  return !(window as any).invokeNative;
};

export const wait = (ms: number): Promise<void> => {
  return new Promise((resolve) => setTimeout(resolve, ms));
};

export const rem = (value: number): number => {
  const root = parseFloat(getComputedStyle(document.documentElement).fontSize);
  return value * root;
};