import { createTheme } from "@mantine/core";

const theme = createTheme({
  primaryColor: 'violet',
  primaryShade: 6,
  autoContrast: true,
  luminanceThreshold: 0.45,

  fontFamily: 'Rubik, sans-serif',
  fontSizes: {
    xxs: '0.625rem',
    xs: '0.75rem',
    sm: '0.875rem',
    md: '1rem',
    lg: '1.125rem',
    xl: '1.25rem',
    xxl: '1.5rem',
  },

  lineHeights: {
    xxs: '1.35',
    xs: '1.4',
    sm: '1.45',
    md: '1.55',
    lg: '1.6',
    xl: '1.65',
    xxl: '1.7',
  },

  defaultRadius: 'sm',
  radius: {
    xxs: '0.0625rem',
    xs: '0.125rem',
    sm: '0.25rem',
    md: '0.5rem',
    lg: '1rem',
    xl: '2rem',
    xxl: '4rem',
  },

  spacing: {
    xxs: '0.125rem',
    xs: '0.25rem',
    sm: '0.5rem',
    md: '1rem',
    lg: '1.25rem',
    xl: '2rem',
    xxl: '3rem',
  },

  shadows: {
    xxs: '0 1px 2px rgba(0, 0, 0, 0.08)',
    xs: '0 2px 4px rgba(0, 0, 0, 0.12)',
    sm: '0 3px 6px rgba(0, 0, 0, 0.15), 0 2px 4px rgba(0, 0, 0, 0.08)',
    md: '0 6px 12px rgba(0, 0, 0, 0.2), 0 3px 6px rgba(0, 0, 0, 0.12)',
    lg: '0 15px 25px rgba(0, 0, 0, 0.22), 0 8px 10px rgba(0, 0, 0, 0.1)',
    xl: '0 30px 40px rgba(0, 0, 0, 0.25), 0 15px 20px rgba(0, 0, 0, 0.12)',
    xxl: '0 50px 80px rgba(0, 0, 0, 0.3), 0 25px 40px rgba(0, 0, 0, 0.15)',
  },
})

export default theme;