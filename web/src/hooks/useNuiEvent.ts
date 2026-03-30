import { useEffect, useRef } from "react";

interface Payload<T> {
  action: string;
  data: T;
};

type Signature<T> = (data: T) => void;


export const useNuiEvent = <T>(action: string, handler: Signature<T>): void => {
  const ref = useRef<Signature<T>>(handler);

  useEffect(() => {
    ref.current = handler;
  }, [handler]);

  useEffect(() => {
    const listener = (e: MessageEvent<Payload<T>>) => {
      const { action: event, data } = e.data;
      if (ref.current && event === action) {
        ref.current(data);
      };
    };

    window.addEventListener('message', listener);

    return () => {
      window.removeEventListener('message', listener);
    };
  }, [action]);
};