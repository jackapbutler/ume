import { motion, useInView } from 'framer-motion';
import { useRef, useState, useEffect, useMemo, useCallback } from 'react';
import Image from 'next/image';

export default function AIValuePropJourney() {
    const ref = useRef(null);
    const isInView = useInView(ref, { once: true, amount: 0.2 });
    const [currentPhase, setCurrentPhase] = useState(0);
    const [isAutoPlaying, setIsAutoPlaying] = useState(true);

    const phases = useMemo(() => [
        {
            id: 1, title: 'Learning You', description: 'AI understands your personality through conversation', visual: 'profile-building', chat: [
                { type: 'user', text: 'I love reading fantasy and non-fiction books' },
                { type: 'ai', text: "What draws you to those books? Would you want your partner to share that interest?" }
            ]
        },
        {
            id: 2, title: 'Finding Matches', description: 'Smart compatibility based on personality alignment', visual: 'matching', chat: [
                { type: 'ai', text: 'I found someone who shares your love of The Empyrean series and values authenticity.' }
            ]
        },
        {
            id: 3, title: 'Organising Dates', description: 'AI helps plan and coordinate meaningful meetups', visual: 'date-planning', chat: [
                { type: 'ai', text: 'Based on your shared interest in fantasy, I suggest you try out this new escape room nearby. Shall I help coordinate?' }
            ]
        },
        {
            id: 4, title: 'Relationship Support', description: 'Ongoing guidance for lasting connections', visual: 'relationship-support', chat: [
                { type: 'ai', text: 'Great date, happy it went well! Here are some thoughtful follow-up conversation starters based on what you both enjoyed.' }
            ]
        }
    ], []);

    // auto-cycle through phases
    useEffect(() => {
        if (!isInView || !isAutoPlaying) return;
        const cycle = setInterval(() => setCurrentPhase((p) => (p + 1) % phases.length), 8_000,);
        return () => clearInterval(cycle);
    }, [isInView, isAutoPlaying, phases.length]);

    const handlePhaseClick = useCallback((index: number) => {
        setCurrentPhase(index);
        setIsAutoPlaying(false);
    }, []);

    // keyboard navigation
    useEffect(() => {
        const handleKeyDown = (event: KeyboardEvent) => {
            if (!isInView) return;

            switch (event.key) {
                case 'ArrowLeft':
                case 'ArrowUp':
                    event.preventDefault();
                    if (currentPhase > 0) {
                        handlePhaseClick(currentPhase - 1);
                    }
                    break;
                case 'ArrowRight':
                case 'ArrowDown':
                    event.preventDefault();
                    if (currentPhase < phases.length - 1) {
                        handlePhaseClick(currentPhase + 1);
                    }
                    break;
                case ' ':
                    event.preventDefault();
                    setIsAutoPlaying(!isAutoPlaying);
                    break;
            }
        };

        window.addEventListener('keydown', handleKeyDown);
        return () => window.removeEventListener('keydown', handleKeyDown);
    }, [currentPhase, phases.length, isInView, isAutoPlaying, handlePhaseClick]);

    const { title, description, chat, visual } = phases[currentPhase];

    // render timeline nodes
    const renderTimeline = () => (
        <div className="flex flex-col items-start space-y-6 ml-4">
            {phases.map((phase, idx) => (
                <button
                    key={phase.id}
                    onClick={() => handlePhaseClick(idx)}
                    className="flex items-center group cursor-pointer hover:scale-105 transition-transform min-h-[48px]"
                    aria-label={`Go to phase ${idx + 1}: ${phase.title}`}
                    aria-pressed={idx === currentPhase}
                >
                    {/* connector line */}
                    <div className="flex flex-col items-center">
                        <motion.div
                            initial={{ scale: 0 }}
                            animate={{ scale: phase.id - 1 === currentPhase ? 1.4 : 1 }}
                            transition={{ duration: 0.5 }}
                            className={`w-4 h-4 rounded-full transition-colors ${idx === currentPhase ? 'bg-purple-400' : 'bg-gray-600 group-hover:bg-gray-500'}`}
                            role="presentation"
                        />
                        {idx < phases.length - 1 && <div className="w-px h-12 bg-gray-700" role="presentation"></div>}
                    </div>
                    {/* label */}
                    <div className={`ml-4 transition-colors ${idx === currentPhase ? 'text-purple-300 font-semibold' : 'text-gray-400 group-hover:text-gray-300'}`}>
                        {phase.title}
                    </div>
                </button>
            ))}
        </div>
    );

    // render visual with proper components for each phase
    const renderVisual = () => {
        switch (visual) {
            case 'profile-building':
                return (
                    <div className="space-y-3">
                        <div className="flex items-center justify-center">
                            <div className="w-16 h-16 rounded-full overflow-hidden border-2 border-purple-400/60">
                                <Image
                                    src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face"
                                    alt="User profile"
                                    width={64}
                                    height={64}
                                    className="w-full h-full object-cover"
                                    priority
                                    placeholder="blur"
                                    blurDataURL="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAhEAACAQMDBQAAAAAAAAAAAAABAgMABAUGIWGRkqGx0f/EABUBAQEAAAAAAAAAAAAAAAAAAAMF/8QAGhEAAgIDAAAAAAAAAAAAAAAAAAECEgMRkf/aAAwDAQACEQMRAD8AltJagyeH0AthI5xdrLcNM91BF5pX2HaH9bcfaSXWGaRmknyJckliyjqTzSlT54b6bk+h0R+au+ju3eLTmG8v7c01s7n3vPsOZ8zLa4oc9eD5b/"
                                />
                            </div>
                        </div>
                        <div className="space-y-2">
                            <motion.div
                                initial={{ width: 0 }}
                                animate={{ width: '100%' }}
                                transition={{ duration: 1, delay: 0.5 }}
                                className="h-2 bg-gradient-to-r from-purple-400 to-pink-500 rounded-full"
                            />
                            <motion.div
                                initial={{ width: 0 }}
                                animate={{ width: '80%' }}
                                transition={{ duration: 1, delay: 1 }}
                                className="h-2 bg-gradient-to-r from-purple-400 to-pink-500 rounded-full"
                            />
                            <motion.div
                                initial={{ width: 0 }}
                                animate={{ width: '60%' }}
                                transition={{ duration: 1, delay: 1.5 }}
                                className="h-2 bg-gradient-to-r from-purple-400 to-pink-500 rounded-full"
                            />
                        </div>
                        <p className="text-xs text-gray-400 text-center">Building your profile...</p>
                    </div>
                );
            case 'matching':
                return (
                    <div className="text-center space-y-4">
                        <div className="relative flex justify-center items-center min-h-[140px]">
                            {/* Your profile - central hub with enhanced animations */}
                            <motion.div
                                animate={{
                                    scale: [1, 1.08, 1],
                                    y: [0, -2, 0]
                                }}
                                transition={{ duration: 3, repeat: Infinity, ease: "easeInOut" }}
                                className="w-16 h-16 rounded-full overflow-hidden relative z-20"
                            >
                                <Image
                                    src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face"
                                    alt="You"
                                    width={64}
                                    height={64}
                                    className="w-full h-full object-cover"
                                />

                                {/* Multi-layered glowing border effect */}
                                <motion.div
                                    animate={{
                                        scale: [1, 1.2, 1],
                                        opacity: [0.6, 1, 0.6]
                                    }}
                                    transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
                                    className="absolute inset-0 border-2 border-blue-400/80 rounded-full"
                                />
                                <motion.div
                                    animate={{
                                        scale: [1, 1.4, 1],
                                        opacity: [0.3, 0.7, 0.3]
                                    }}
                                    transition={{ duration: 2.5, repeat: Infinity, ease: "easeInOut", delay: 0.3 }}
                                    className="absolute inset-0 border border-purple-400/60 rounded-full"
                                />

                                {/* Enhanced scanning effect */}
                                <motion.div
                                    animate={{ rotate: 360 }}
                                    transition={{ duration: 4, repeat: Infinity, ease: "linear" }}
                                    className="absolute inset-0 border-2 border-transparent border-t-blue-400 border-r-purple-400 rounded-full"
                                />
                            </motion.div>

                            {/* Animated connection network */}
                            <svg className="absolute inset-0 w-full h-full pointer-events-none" viewBox="0 0 200 140">
                                {/* Connection lines with animation - adjusted to reach all three matches */}
                                <motion.path
                                    initial={{ pathLength: 0, opacity: 0 }}
                                    animate={{ pathLength: 1, opacity: 0.8 }}
                                    transition={{ duration: 1.5, delay: 0.5 }}
                                    d="M100,70 Q130,50 198,20"
                                    stroke="url(#gradient1)"
                                    strokeWidth="2"
                                    fill="none"
                                    strokeDasharray="2,2"
                                />
                                <motion.path
                                    initial={{ pathLength: 0, opacity: 0 }}
                                    animate={{ pathLength: 1, opacity: 0.8 }}
                                    transition={{ duration: 1.5, delay: 0.8 }}
                                    d="M100,50 Q10,90 197,70"
                                    stroke="url(#gradient2)"
                                    strokeWidth="2"
                                    fill="none"
                                    strokeDasharray="2,2"
                                />
                                <motion.path
                                    initial={{ pathLength: 0, opacity: 0 }}
                                    animate={{ pathLength: 1, opacity: 0.8 }}
                                    transition={{ duration: 1.5, delay: 1.1 }}
                                    d="M100,70 Q130,90 198,120"
                                    stroke="url(#gradient3)"
                                    strokeWidth="2"
                                    fill="none"
                                    strokeDasharray="2,2"
                                />

                                {/* Gradient definitions */}
                                <defs>
                                    <linearGradient id="gradient1" x1="0%" y1="0%" x2="100%" y2="0%">
                                        <stop offset="0%" stopColor="#8B5CF6" stopOpacity="0.8" />
                                        <stop offset="100%" stopColor="#EC4899" stopOpacity="0.8" />
                                    </linearGradient>
                                    <linearGradient id="gradient2" x1="0%" y1="0%" x2="100%" y2="0%">
                                        <stop offset="0%" stopColor="#8B5CF6" stopOpacity="0.8" />
                                        <stop offset="100%" stopColor="#10B981" stopOpacity="0.8" />
                                    </linearGradient>
                                    <linearGradient id="gradient3" x1="0%" y1="0%" x2="100%" y2="0%">
                                        <stop offset="0%" stopColor="#8B5CF6" stopOpacity="0.8" />
                                        <stop offset="100%" stopColor="#F59E0B" stopOpacity="0.8" />
                                    </linearGradient>
                                </defs>
                            </svg>

                            {/* Potential matches with realistic photos */}
                            <div className="absolute right-0 flex flex-col space-y-3">
                                <motion.div
                                    initial={{ x: 30, opacity: 0, scale: 0.8 }}
                                    animate={{ x: 0, opacity: 1, scale: 1 }}
                                    transition={{ duration: 0.8, delay: 0.7 }}
                                    className="relative group"
                                >
                                    <div className="w-12 h-12 rounded-full overflow-hidden border-2 border-pink-400/60 shadow-lg hover:shadow-pink-400/30 transition-all">
                                        <Image
                                            src="https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop&crop=face"
                                            alt="Match 1"
                                            width={48}
                                            height={48}
                                            className="w-full h-full object-cover"
                                        />
                                    </div>
                                    {/* Compatibility score */}
                                    <motion.div
                                        initial={{ scale: 0 }}
                                        animate={{ scale: 1 }}
                                        transition={{ delay: 1.2 }}
                                        className="absolute -top-1 -right-1 bg-pink-500 text-white text-xs px-1.5 py-0.5 rounded-full font-medium"
                                    >
                                        94%
                                    </motion.div>
                                </motion.div>

                                <motion.div
                                    initial={{ x: 30, opacity: 0, scale: 0.8 }}
                                    animate={{ x: 0, opacity: 1, scale: 1 }}
                                    transition={{ duration: 0.8, delay: 1 }}
                                    className="relative group"
                                >
                                    <div className="w-12 h-12 rounded-full overflow-hidden border-2 border-green-400/60 shadow-lg hover:shadow-green-400/30 transition-all">
                                        <Image
                                            src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face"
                                            alt="Match 2"
                                            width={48}
                                            height={48}
                                            className="w-full h-full object-cover"
                                        />
                                    </div>
                                    <motion.div
                                        initial={{ scale: 0 }}
                                        animate={{ scale: 1 }}
                                        transition={{ delay: 1.5 }}
                                        className="absolute -top-1 -right-1 bg-green-500 text-white text-xs px-1.5 py-0.5 rounded-full font-medium"
                                    >
                                        89%
                                    </motion.div>
                                </motion.div>

                                <motion.div
                                    initial={{ x: 30, opacity: 0, scale: 0.8 }}
                                    animate={{ x: 0, opacity: 1, scale: 1 }}
                                    transition={{ duration: 0.8, delay: 1.3 }}
                                    className="relative group"
                                >
                                    <div className="w-12 h-12 rounded-full overflow-hidden border-2 border-amber-400/60 shadow-lg hover:shadow-amber-400/30 transition-all">
                                        <Image
                                            src="https://images.unsplash.com/photo-1507591064344-4c6ce005b128?w=100&h=100&fit=crop&crop=face"
                                            alt="Match 3"
                                            width={48}
                                            height={48}
                                            className="w-full h-full object-cover"
                                        />
                                    </div>
                                    <motion.div
                                        initial={{ scale: 0 }}
                                        animate={{ scale: 1 }}
                                        transition={{ delay: 1.8 }}
                                        className="absolute -top-1 -right-1 bg-amber-500 text-white text-xs px-1.5 py-0.5 rounded-full font-medium"
                                    >
                                        92%
                                    </motion.div>
                                </motion.div>
                            </div>

                            {/* AI analysis indicator */}
                            <motion.div
                                animate={{
                                    opacity: [0.5, 1, 0.5],
                                    scale: [1, 1.1, 1]
                                }}
                                transition={{ duration: 2, repeat: Infinity }}
                                className="absolute top-0 left-0 transform -translate-x-2 bg-purple-600/90 text-white text-xs px-2 py-1 rounded-full backdrop-blur-sm border border-purple-400/30"
                            >
                                AI Analysing
                            </motion.div>
                        </div>
                        <p className="text-xs text-gray-400">Finding compatible matches...</p>
                    </div>
                );
            case 'date-planning':
                return (
                    <div className="space-y-3">
                        <div className="flex items-center justify-center">
                            <div className="w-16 h-16 bg-gradient-to-br from-green-400 to-blue-500 rounded-full flex items-center justify-center">
                                <span className="text-white text-xl">📅</span>
                            </div>
                        </div>
                        <div className="grid grid-cols-2 gap-2">
                            <motion.div
                                initial={{ opacity: 0, y: 10 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ delay: 0.3 }}
                                className="p-2 bg-gray-700/50 rounded-lg text-xs text-gray-300"
                            >
                                Gallery ✓
                            </motion.div>
                            <motion.div
                                initial={{ opacity: 0, y: 10 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ delay: 0.6 }}
                                className="p-2 bg-gray-700/50 rounded-lg text-xs text-gray-300"
                            >
                                Time ✓
                            </motion.div>
                            <motion.div
                                initial={{ opacity: 0, y: 10 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ delay: 0.9 }}
                                className="p-2 bg-gray-700/50 rounded-lg text-xs text-gray-300"
                            >
                                Location ✓
                            </motion.div>
                            <motion.div
                                initial={{ opacity: 0, y: 10 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ delay: 1.2 }}
                                className="p-2 bg-gray-700/50 rounded-lg text-xs text-gray-300"
                            >
                                Reminder ✓
                            </motion.div>
                        </div>
                        <p className="text-xs text-gray-400 text-center">Planning your perfect date...</p>
                    </div>
                );
            case 'relationship-support':
                return (
                    <div className="text-center space-y-4">
                        {/* Happy couple visualization */}
                        <div className="relative flex justify-center items-center">
                            <div className="flex items-center space-x-2">
                                {/* Person 1 */}
                                <motion.div
                                    initial={{ x: -10, opacity: 0 }}
                                    animate={{ x: 0, opacity: 1 }}
                                    transition={{ duration: 0.8, delay: 0.3 }}
                                    className="w-12 h-12 rounded-full overflow-hidden border-2 border-emerald-400/60 shadow-lg"
                                >
                                    <Image
                                        src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face"
                                        alt="Happy person 1"
                                        width={48}
                                        height={48}
                                        className="w-full h-full object-cover"
                                    />
                                </motion.div>

                                {/* Connection indicator */}
                                <motion.div
                                    initial={{ scale: 0 }}
                                    animate={{ scale: 1 }}
                                    transition={{ duration: 0.5, delay: 0.8 }}
                                    className="flex items-center space-x-1"
                                >
                                    <div className="w-3 h-px bg-gradient-to-r from-emerald-400 to-blue-400"></div>
                                    <div className="w-2 h-2 bg-emerald-400 rounded-full animate-pulse"></div>
                                    <div className="w-3 h-px bg-gradient-to-r from-blue-400 to-emerald-400"></div>
                                </motion.div>

                                {/* Person 2 */}
                                <motion.div
                                    initial={{ x: 10, opacity: 0 }}
                                    animate={{ x: 0, opacity: 1 }}
                                    transition={{ duration: 0.8, delay: 0.6 }}
                                    className="w-12 h-12 rounded-full overflow-hidden border-2 border-blue-400/60 shadow-lg"
                                >
                                    <Image
                                        src="https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop&crop=face"
                                        alt="Happy person 2"
                                        width={48}
                                        height={48}
                                        className="w-full h-full object-cover"
                                    />
                                </motion.div>
                            </div>

                            {/* Success indicator */}
                            <motion.div
                                initial={{ y: -10, opacity: 0 }}
                                animate={{ y: 0, opacity: 1 }}
                                transition={{ duration: 0.6, delay: 1.2 }}
                                className="absolute -top-3 bg-emerald-500 text-white text-xs px-2 py-1 rounded-full font-medium"
                            >
                                ✓ Connected
                            </motion.div>
                        </div>

                        {/* AI Support suggestions */}
                        <div className="space-y-2">
                            <motion.div
                                initial={{ opacity: 0, y: 10 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ delay: 1.5 }}
                                className="flex items-center justify-center space-x-2 p-2 bg-gray-700/40 rounded-lg"
                            >
                                <div className="w-3 h-3 bg-blue-400 rounded-full"></div>
                                <span className="text-xs text-gray-300">Conversation tips</span>
                            </motion.div>

                            <motion.div
                                initial={{ opacity: 0, y: 10 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ delay: 1.8 }}
                                className="flex items-center justify-center space-x-2 p-2 bg-gray-700/40 rounded-lg"
                            >
                                <div className="w-3 h-3 bg-purple-400 rounded-full"></div>
                                <span className="text-xs text-gray-300">Conflict resolution</span>
                            </motion.div>

                            <motion.div
                                initial={{ opacity: 0, y: 10 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ delay: 2.1 }}
                                className="flex items-center justify-center space-x-2 p-2 bg-gray-700/40 rounded-lg"
                            >
                                <div className="w-3 h-3 bg-emerald-400 rounded-full"></div>
                                <span className="text-xs text-gray-300">Relationship guidance</span>
                            </motion.div>
                        </div>

                        <p className="text-xs text-gray-400">AI-powered relationship support...</p>
                    </div>
                );
            default:
                return null;
        }
    };

    return (
        <div ref={ref} className="max-w-6xl mx-auto p-6 bg-gray-900/70 rounded-3xl border border-purple-500/20">
            {/* Accessibility Instructions */}
            <div className="sr-only">
                Use arrow keys to navigate between phases, spacebar to toggle auto-play.
                Current phase: {currentPhase + 1} of {phases.length}. {phases[currentPhase].title}.
            </div>

            <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={isInView ? { opacity: 1, y: 0 } : {}}
                transition={{ duration: 0.8 }}
                className="flex flex-col lg:flex-row gap-8"
                role="tabpanel"
                aria-label="AI Dating Journey Demonstration"
            >
                {/* Timeline & Labels */}
                <div className="hidden lg:block">
                    {renderTimeline()}
                </div>

                {/* Main Content */}
                <div className="flex-1 space-y-6">
                    {/* Phase Header */}
                    <div className="flex items-center space-x-3">
                        <div className="w-8 h-8 rounded-full overflow-hidden flex items-center justify-center">
                            <Image
                                src="/assets/ume_gradient.gif"
                                alt="UMe"
                                width={32}
                                height={32}
                                className="w-full h-full object-cover"
                            />
                        </div>
                        <div>
                            <h2 className="text-white text-2xl font-bold">{title}</h2>
                            <p className="text-gray-400 text-sm">{description}</p>
                        </div>
                    </div>

                    {/* Chat + Visual + Data Flow */}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                        {/* Chat */}
                        <div className="space-y-4 bg-gray-800/50 p-4 rounded-2xl">
                            {chat.map((msg, i) => (
                                <motion.div key={i} initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: i * 0.4 }} className={`${msg.type === 'user' ? 'text-right' : 'text-left'}`}>
                                    <span className={`inline-block px-3 py-2 rounded-xl ${msg.type === 'user' ? 'bg-purple-600 text-white' : 'bg-gray-700 text-gray-200 border border-purple-400/30'}`}>{msg.text}</span>
                                </motion.div>
                            ))}
                        </div>

                        {/* Visual & Flow */}
                        <div className="relative flex items-center justify-center">
                            <div className="w-full max-w-xs p-4 bg-gray-800/50 rounded-2xl">
                                {renderVisual()}
                            </div>
                        </div>
                    </div>
                </div>
            </motion.div>

            {/* Mobile Navigation - Vertical Progress Indicator */}
            <div className="mt-8 lg:hidden space-y-4">
                {/* Progress Bar */}
                <div className="flex justify-center">
                    <div className="flex space-x-2">
                        {phases.map((_, i) => (
                            <motion.div
                                key={i}
                                className={`h-2 rounded-full transition-all duration-300 ${i === currentPhase
                                    ? 'w-8 bg-purple-400'
                                    : i < currentPhase
                                        ? 'w-2 bg-purple-600/60'
                                        : 'w-2 bg-gray-600'
                                    }`}
                                initial={{ scale: 0.8 }}
                                animate={{ scale: i === currentPhase ? 1.2 : 1 }}
                                transition={{ duration: 0.3 }}
                            />
                        ))}
                    </div>
                </div>

                {/* Navigation Controls */}
                <div className="flex justify-center items-center space-x-6">
                    <motion.button
                        onClick={() => currentPhase > 0 && handlePhaseClick(currentPhase - 1)}
                        disabled={currentPhase === 0}
                        whileTap={{ scale: 0.9 }}
                        className={`w-12 h-12 rounded-full flex items-center justify-center transition-all ${currentPhase === 0
                            ? 'bg-gray-700/50 text-gray-500 cursor-not-allowed'
                            : 'bg-purple-600/80 text-white hover:bg-purple-500 active:bg-purple-700'
                            }`}
                    >
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                        </svg>
                    </motion.button>

                    {/* Current Phase Indicator */}
                    <div className="text-center min-w-[120px]">
                        <div className="text-white font-semibold text-sm">
                            {phases[currentPhase].title}
                        </div>
                        <div className="text-gray-400 text-xs">
                            {currentPhase + 1} of {phases.length}
                        </div>
                    </div>

                    <motion.button
                        onClick={() => currentPhase < phases.length - 1 && handlePhaseClick(currentPhase + 1)}
                        disabled={currentPhase === phases.length - 1}
                        whileTap={{ scale: 0.9 }}
                        className={`w-12 h-12 rounded-full flex items-center justify-center transition-all ${currentPhase === phases.length - 1
                            ? 'bg-gray-700/50 text-gray-500 cursor-not-allowed'
                            : 'bg-purple-600/80 text-white hover:bg-purple-500 active:bg-purple-700'
                            }`}
                    >
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                        </svg>
                    </motion.button>
                </div>

                {/* Auto-play Control */}
                <div className="flex justify-center">
                    <motion.button
                        onClick={() => setIsAutoPlaying(!isAutoPlaying)}
                        whileTap={{ scale: 0.95 }}
                        className={`px-4 py-2 rounded-full text-sm font-medium transition-all ${isAutoPlaying
                            ? 'bg-purple-600/80 text-white hover:bg-purple-500'
                            : 'bg-gray-700/80 text-gray-300 hover:bg-gray-600'
                            }`}
                    >
                        {isAutoPlaying ? (
                            <>
                                Auto-play ON
                            </>
                        ) : (
                            <>
                                Auto-play OFF
                            </>
                        )}
                    </motion.button>
                </div>
            </div>
        </div>
    );
}
