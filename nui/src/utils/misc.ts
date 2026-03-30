export const isEnvBrowser = (): boolean => !(window as any).invokeNative;

export const lerp = (a: number, b: number, t: number): number =>  a + (b - a) * t;

export const getRandomInt = (min: number, max: number): number => Math.floor(Math.random() * (max - min + 1)) + min;

export const capitalize = (str: string): string => str.charAt(0).toUpperCase() + str.slice(1);

export const delay = (ms: number): Promise<void> => new Promise(res => setTimeout(res, ms));

export const nothing = (): void => {};