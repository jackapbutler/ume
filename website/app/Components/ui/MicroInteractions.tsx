'use client';

import { motion } from 'framer-motion';

interface MicroInteractionProps {
    children: React.ReactNode;
    type?: 'hover' | 'tap' | 'focus' | 'scroll';
    className?: string;
}

// Simple seeded random number generator for consistent SSR/client rendering
const seededRandom = (seed: number) => {
    let x = Math.sin(seed) * 10000;
    return x - Math.floor(x);
};

export const FloatingParticles = () => {
    return (
        <div className="fixed inset-0 pointer-events-none z-0">
            {[...Array(12)].map((_, i) => (
                <motion.div
                    key={i}
                    className="absolute w-2 h-2 rounded-full"
                    style={{
                        backgroundColor: 'rgba(61, 33, 99, 0.6)', // primary color with 60% opacity
                        left: `${seededRandom(i * 7) * 100}%`,
                        top: `${seededRandom(i * 11) * 100}%`,
                    }}
                    animate={{
                        x: [0, seededRandom(i * 13) * 100 - 50],
                        y: [0, seededRandom(i * 17) * 100 - 50],
                        opacity: [0, 0.8, 0],
                        scale: [0, 1.2, 0],
                    }}
                    transition={{
                        duration: seededRandom(i * 19) * 8 + 6,
                        repeat: Infinity,
                        delay: seededRandom(i * 23) * 4,
                        ease: "easeInOut"
                    }}
                />
            ))}
            {[...Array(8)].map((_, i) => (
                <motion.div
                    key={`purple-${i}`}
                    className="absolute w-1.5 h-1.5 rounded-full"
                    style={{
                        backgroundColor: 'rgba(107, 83, 140, 0.5)', // surfaceTint color with 50% opacity
                        left: `${seededRandom(i * 29 + 100) * 100}%`,
                        top: `${seededRandom(i * 31 + 100) * 100}%`,
                    }}
                    animate={{
                        x: [0, seededRandom(i * 37 + 100) * 80 - 40],
                        y: [0, seededRandom(i * 41 + 100) * 80 - 40],
                        opacity: [0, 0.7, 0],
                        scale: [0, 1.8, 0],
                    }}
                    transition={{
                        duration: seededRandom(i * 43 + 100) * 10 + 8,
                        repeat: Infinity,
                        delay: seededRandom(i * 47 + 100) * 6,
                        ease: "easeInOut"
                    }}
                />
            ))}
        </div>
    );
};

export const MicroInteraction = ({
    children,
    type = 'hover',
    className = ''
}: MicroInteractionProps) => {
    const getAnimation = () => {
        switch (type) {
            case 'hover':
                return {
                    whileHover: {
                        scale: 1.02,
                        y: -2,
                        transition: { duration: 0.2, ease: "easeOut" }
                    }
                };
            case 'tap':
                return {
                    whileTap: {
                        scale: 0.98,
                        transition: { duration: 0.1 }
                    }
                };
            case 'focus':
                return {
                    whileFocus: {
                        scale: 1.02,
                        boxShadow: "0 0 0 3px rgba(59, 130, 246, 0.3)",
                        transition: { duration: 0.2 }
                    }
                };
            default:
                return {};
        }
    };

    return (
        <motion.div
            {...getAnimation()}
            className={className}
        >
            {children}
        </motion.div>
    );
};

export const ScrollReveal = ({
    children,
    delay = 0,
    direction = 'up'
}: {
    children: React.ReactNode;
    delay?: number;
    direction?: 'up' | 'down' | 'left' | 'right';
}) => {
    const getInitial = () => {
        switch (direction) {
            case 'up':
                return { opacity: 0, y: 30 };
            case 'down':
                return { opacity: 0, y: -30 };
            case 'left':
                return { opacity: 0, x: 30 };
            case 'right':
                return { opacity: 0, x: -30 };
            default:
                return { opacity: 0, y: 30 };
        }
    };

    return (
        <motion.div
            initial={getInitial()}
            whileInView={{ opacity: 1, x: 0, y: 0 }}
            viewport={{ once: true, amount: 0.3 }}
            transition={{ duration: 0.6, delay, ease: "easeOut" }}
        >
            {children}
        </motion.div>
    );
};
