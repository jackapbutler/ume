import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        // Chaos to Calm color palette
        chaos: {
          50: '#1a1a1a',
          100: '#2a2a2a',
          200: '#3a3a3a',
          500: '#666666',
          900: '#0a0a0a',
          dark: '#0a0a0a',
          darker: '#000000',
          red: '#ef4444',
        },
        calm: {
          50: '#f8fafc',
          100: '#f1f5f9',
          200: '#e2e8f0',
          300: '#cbd5e1',
          500: '#64748b',
          700: '#334155',
          900: '#0f172a',
          light: '#f8fafc',
          dark: '#1e293b',
          blue: '#3b82f6',
          green: '#10b981',
          purple: '#8b5cf6',
        },
        wellness: {
          50: '#fefcf3',
          100: '#fef7e6',
          200: '#fcedc4',
          300: '#f9de97',
          400: '#f5c968',
          500: '#f1b544',
          600: '#e29d2f',
          700: '#be7f28',
          800: '#996527',
          900: '#7c5323',
        },
        ai: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          200: '#bae6fd',
          300: '#7dd3fc',
          400: '#38bdf8',
          500: '#0ea5e9',
          600: '#0284c7',
          700: '#0369a1',
          800: '#075985',
          900: '#0c4a6e',
        },
        // Purple color palette matching Flutter app
        purple: {
          400: 'rgb(107, 83, 140)', // surfaceTint
          600: 'rgb(61, 33, 99)',   // primary
          700: 'rgb(51, 28, 84)',   // darker purple
          900: 'rgb(31, 17, 52)',   // very dark purple
        },
      },
      fontFamily: {
        futuristic: ['Inter', 'system-ui', 'sans-serif'],
        calm: ['Inter', 'system-ui', 'sans-serif'],
      },
      fontSize: {
        'hero': ['3.5rem', { lineHeight: '1.1', letterSpacing: '-0.02em' }],
        'hero-mobile': ['2.5rem', { lineHeight: '1.1', letterSpacing: '-0.02em' }],
        'section-title': ['2.5rem', { lineHeight: '1.2', letterSpacing: '-0.01em' }],
        'section-title-mobile': ['2rem', { lineHeight: '1.2', letterSpacing: '-0.01em' }],
      },
      spacing: {
        'section': '6rem',
        'section-mobile': '4rem',
      },
      keyframes: {
        animatedBeam: {
          "100%": { offsetDistance: "100%" },
        },
        fadeInUp: {
          '0%': { opacity: '0', transform: 'translateY(30px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        gradientShift: {
          '0%, 100%': { backgroundPosition: '0% 50%' },
          '50%': { backgroundPosition: '100% 50%' },
        },
        float: {
          '0%, 100%': { transform: 'translateY(0px)' },
          '50%': { transform: 'translateY(-10px)' },
        },
      },
      animation: {
        animatedBeam: "animatedBeam 7s linear infinite",
        fadeInUp: 'fadeInUp 0.8s ease-out',
        gradientShift: 'gradientShift 6s ease-in-out infinite',
        float: 'float 3s ease-in-out infinite',
      },

      backgroundImage: {
        "gradient-radial": "radial-gradient(var(--tw-gradient-stops))",
        "gradient-conic":
          "conic-gradient(from 180deg at 50% 50%, var(--tw-gradient-stops))",
      },

    },
  },
  plugins: [],
};
export default config;
