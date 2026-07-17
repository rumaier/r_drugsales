export const isEnvBrowser = (): boolean => {
  return !(window as any).invokeNative;
};

export const rem = (value: number): number => {
  const root = parseFloat(getComputedStyle(document.documentElement).fontSize);
  return value * root;
};