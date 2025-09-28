import { useEffect, useRef, type RefObject } from "react";
import { nothing } from "../utils/misc";

interface NuiMessagePayload<T> {
  action: string;
  data: T;
};

type NuiHandlerSignature<T> = (data: T) => void;

export const useNuiEvent = <T = any>(action: string, handler: (data: T) => void) => {
  const handlerRef: RefObject<NuiHandlerSignature<T>> = useRef(nothing);

  useEffect(() => {
    handlerRef.current = handler;
  }, [handler]);

  useEffect(() => {
    const listener = (e: MessageEvent<NuiMessagePayload<T>>) => {
      const { action: eventAction, data } = e.data;
      if (handlerRef.current && eventAction === action) {
        handlerRef.current(data);
      }
    };

    window.addEventListener("message", listener);
    return () => window.removeEventListener("message", listener);
  }, [action]);
};