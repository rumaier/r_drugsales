import { isEnvBrowser } from "./misc";

export const fetchNui = async <T>(eventName: string, data?: any, mock?: T): Promise<T> => {
  const isBrowser = isEnvBrowser();
  const resource = isBrowser ? 'nui-app' : (window as any)?.GetParentResourceName();
  if (isBrowser) {
    return mock as T;
  }
  const response = await fetch(`https://${resource}/${eventName}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: JSON.stringify(data),
  });
  return await response.json() as T;
};