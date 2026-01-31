// Design tokens for UMe landing page
// Organized for easy maintenance and consistency

export const colors = {
    chaos: {
        50: '#1a1a1a',
        100: '#2a2a2a',
        200: '#3a3a3a',
        500: '#666666',
        900: '#0a0a0a',
    },
    calm: {
        50: '#f8fafc',
        100: '#f1f5f9',
        200: '#e2e8f0',
        300: '#cbd5e1',
        500: '#64748b',
        700: '#334155',
        900: '#0f172a',
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
};

export const typography = {
    fontFamilies: {
        futuristic: ['Inter', 'system-ui', 'sans-serif'],
        calm: ['Inter', 'system-ui', 'sans-serif'],
    },
    sizes: {
        hero: {
            desktop: '3.5rem',
            mobile: '2.5rem',
        },
        sectionTitle: {
            desktop: '2.5rem',
            mobile: '2rem',
        },
        body: {
            large: '1.125rem',
            base: '1rem',
            small: '0.875rem',
        },
    },
    weights: {
        light: 300,
        normal: 400,
        medium: 500,
        semibold: 600,
        bold: 700,
    },
};

export const spacing = {
    sections: {
        desktop: '6rem',
        mobile: '4rem',
    },
    content: {
        maxWidth: '1200px',
    },
};

export const transitions = {
    smooth: 'cubic-bezier(0.4, 0, 0.2, 1)',
    bounce: 'cubic-bezier(0.68, -0.55, 0.265, 1.55)',
    durations: {
        fast: '0.3s',
        normal: '0.5s',
        slow: '0.8s',
    },
};

export const breakpoints = {
    sm: '640px',
    md: '768px',
    lg: '1024px',
    xl: '1280px',
    '2xl': '1536px',
};

// Gradients for different moods/sections
export const gradients = {
    chaosToCalm: 'linear-gradient(135deg, #1a1a1a 0%, #2a2a2a 50%, #f8fafc 100%)',
    aiGlow: 'linear-gradient(135deg, #0ea5e9 0%, #0369a1 100%)',
    wellness: 'linear-gradient(135deg, #f1b544 0%, #be7f28 100%)',
    heroBackground: 'linear-gradient(135deg, #0a0a0a 0%, #1a1a1a 30%, #f8fafc 100%)',
};
