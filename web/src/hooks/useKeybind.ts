import { useCallback, useEffect } from "react";

export const useKeybind = (key: string, cb: (e: KeyboardEvent) => void): void => {
  const memo = useCallback((e: KeyboardEvent) => {
    if (e.key === key) {
      e.preventDefault();
      cb(e);
    };
  }, [key, cb]);

  useEffect(() => {
    window.addEventListener('keydown', memo);
    
    return () => {
      window.removeEventListener('keydown', memo);
    };
  }, [memo]);
};