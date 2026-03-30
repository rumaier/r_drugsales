import { isEnvBrowser } from "./misc";

export async function fetchNui<T>(event: string, data?: any, mock?: T): Promise<T> {
  if (isEnvBrowser() && mock) return mock as T;

  const resource = (window as any)?.GetParentResourceName ? (window as any).GetParentResourceName() : "nui-frame-app";

  const response = await fetch(`https://${resource}/${event}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: JSON.stringify(data)
  });

  const formattedResponse = await response.json();
  return formattedResponse as T;
};