import { useCallback, useEffect } from "react";

export const useKeybind = (key: string, cb: (e: KeyboardEvent) => void): void => {
  const memoizedCb = useCallback((e: KeyboardEvent) => {
    if (e.key === key) {
      e.preventDefault();
      cb(e);
    }
  }, [key, cb]);

  useEffect(() => {
    window.addEventListener('keydown', memoizedCb);
    return () => window.removeEventListener('keydown', memoizedCb);
  }, [memoizedCb]);
};