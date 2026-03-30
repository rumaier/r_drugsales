interface FormatOptions {
  currency?: string;
  locale?: string;
  compact?: boolean;
};

export const formatCurrency = (amount: number, options?: FormatOptions): string => {
  const { currency = "USD", locale = "en-US", compact = false } = options || {};

  try {
    return new Intl.NumberFormat(locale, {
      style: 'currency',
      currency: currency,
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
      notation: compact ? 'compact' : 'standard'
    }).format(amount);
  } catch (err) {
    console.log('[^6DEBUG^0] - Error formatting currency:', err);
    return amount.toString();
  };
};

export const formatNumber = (num: number, options?: FormatOptions): string => {
  const { locale = "en-US", compact = false } = options || {};

  try {
    return new Intl.NumberFormat(locale, {
      style: 'decimal',
      minimumFractionDigits: 0,
      maximumFractionDigits: 2,
      notation: compact ? 'compact' : 'standard'
    }).format(num);
  } catch (err) {
    console.log('[^6DEBUG^0] - Error formatting number:', err);
    return num.toString();
  };
};

export const formatTime = (seconds: number): string => {
  if (seconds > 3599) {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;
    return `${hours}:${minutes.toString().padStart(2, "0")}:${secs.toString().padStart(2, "0")}`;
  } else {
    const minutes = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${minutes}:${secs.toString().padStart(2, "0")}`;
  };
};