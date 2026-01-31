'use client';

import { motion, useInView } from 'framer-motion';
import { useRef, useState } from 'react';
import AIValuePropJourney from './Components/ui/ValueProp';
import GoogleAnalytics from './Components/GAnalytics';
import { MicroInteraction, ScrollReveal, FloatingParticles } from './Components/ui/MicroInteractions';

interface FormProps {
  email: string;
  setEmail: (email: string) => void;
  platform: string;
  setPlatform: (platform: string) => void;
  onSubmit: (e: React.FormEvent) => void;
  submitted: boolean;
}

export default function Home() {
  const [email, setEmail] = useState('');
  const [platform, setPlatform] = useState('');
  const [submitted, setSubmitted] = useState(false);

  const handleQuickSignup = async (e: React.FormEvent) => {
    e.preventDefault();

    const formData = new FormData();
    formData.append("access_key", process.env.NEXT_PUBLIC_WEB3FORMS_KEY || "");
    formData.append("subject", "UMe Waitlist Registration");
    formData.append("email", email);
    formData.append("platform", platform);
    const formUrl = "https://api.web3forms.com/submit";

    const response = await fetch(formUrl, {
      method: "POST",
      body: formData
    });

    const data = await response.json();
    if (data.success) {
      setSubmitted(true);
    }
  };

  return (
    <main className='relative min-h-screen bg-gradient-to-br from-black via-gray-900 to-gray-800 overflow-hidden'>
      <GoogleAnalytics />

      {/* Floating Particles Background */}
      <FloatingParticles />

      {/* Hero Section - Problem & Value Prop */}
      <HeroSection
        email={email}
        setEmail={setEmail}
        platform={platform}
        setPlatform={setPlatform}
        onSubmit={handleQuickSignup}
        submitted={submitted}
      />

      {/* AI Demo Section - Show the Difference */}
      <DemoSection
        email={email}
        setEmail={setEmail}
        platform={platform}
        setPlatform={setPlatform}
        onSubmit={handleQuickSignup}
        submitted={submitted}
      />

    </main>
  );
}

const SignupForm = ({ email, setEmail, platform, setPlatform, onSubmit }: Omit<FormProps, 'submitted'>) => (
  <MicroInteraction type="hover">
    <div className="bg-gradient-to-br from-purple-900/40 to-purple-700/40 backdrop-blur rounded-2xl p-6 border border-white/20">
      <h3 className="text-white font-bold mb-3">Ready to experience UMe?</h3>
      <form onSubmit={onSubmit} className="space-y-3">
        <MicroInteraction type="focus">
          <input
            type="email"
            placeholder="Your email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            className="w-full bg-white/10 border border-white/30 rounded-lg px-4 py-2 text-white placeholder-white/60 focus:border-purple-400 focus:outline-none text-sm transition-colors"
            required
          />
        </MicroInteraction>
        <MicroInteraction type="focus">
          <select
            value={platform}
            onChange={(e) => setPlatform(e.target.value)}
            className="w-full bg-white/10 border border-white/30 rounded-lg px-4 py-2 text-white focus:border-purple-400 focus:outline-none text-sm transition-colors"
            required
          >
            <option value="" disabled className="text-black">Platform</option>
            <option value="Android" className="text-black">Android</option>
            <option value="iOS" className="text-black">iOS</option>
          </select>
        </MicroInteraction>
        <MicroInteraction type="tap">
          <button
            type="submit"
            className="w-full bg-gradient-to-r from-purple-600 to-purple-400 text-white px-4 py-2 rounded-lg font-medium hover:scale-105 transition-transform text-sm"
          >
            Get Early Access
          </button>
        </MicroInteraction>
      </form>
    </div>
    <br />
  </MicroInteraction>
);


const HeroSection = ({ email, setEmail, platform, setPlatform, onSubmit, submitted }: FormProps) => {
  if (submitted) {
    return (
      <section className="min-h-screen flex items-center justify-center px-4">
        <div className="text-center max-w-4xl mx-auto">
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            className="bg-white/10 backdrop-blur rounded-2xl p-8 border border-white/20"
          >
            <h1 className="text-4xl md:text-6xl font-bold text-white mb-4">
              Welcome to <span className="text-purple-400">UMe!</span>
            </h1>
            <p className="text-xl text-gray-300">
              Thanks for joining the waitlist! We&rsquo;ll be in touch soon.
            </p>
          </motion.div>
        </div>
      </section>
    );
  }

  return (
    <section className="min-h-screen flex items-center justify-center px-4 pt-6">
      <div className="text-center max-w-4xl mx-auto">
        <motion.h1
          className="text-4xl md:text-7xl font-bold text-white mb-8"
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
        >
          Stop swiping.{' '}
          <span className="block h-2"></span>
          <span className="bg-gradient-to-r from-purple-300 to-purple-500 bg-clip-text text-transparent drop-shadow-lg">
            Start connecting
          </span>
        </motion.h1>        <motion.p
          className="text-xl md:text-2xl text-gray-300 mb-12 leading-relaxed"
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.2 }}
        >
          Other apps show you endless profiles. UMe&apos;s AI{' '}
          <span className="text-purple-300 font-medium">finds matches for you.</span>
        </motion.p>
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.4 }}
          className="max-w-md mx-auto"
        >
          <SignupForm
            email={email}
            setEmail={setEmail}
            platform={platform}
            setPlatform={setPlatform}
            onSubmit={onSubmit}
          />

          <button
            onClick={() => {
              const demoSection = document.getElementById('demo-section');
              demoSection?.scrollIntoView({ behavior: 'smooth' });
            }}
            className="text-white/80 hover:text-white transition-colors underline"
          >
            or see how it works first ↓
          </button>
        </motion.div>
      </div>
    </section>
  );
};

const DemoSection = ({ email, setEmail, platform, setPlatform, onSubmit, submitted }: FormProps) => {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, amount: 0.2 });
  return (
    <section id="demo-section" ref={ref} className="min-h-screen py-20 px-4 relative z-10">
      <div className="max-w-6xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 50 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.8 }}
          className="text-center mb-16"
        >
          <h2 className="text-4xl md:text-5xl font-bold text-white mb-6">
            This is the difference
          </h2>
          <p className="text-lg md:text-xl text-gray-300 max-w-2xl mx-auto mb-8">
            UMe guides you through your entire dating journey, from first conversation to a lasting partnership
          </p>
        </motion.div>

        {/* AI Chat Demo */}
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={isInView ? { opacity: 1, scale: 1 } : {}}
          transition={{ duration: 0.8, delay: 0.3 }}
          className="mb-16"
        >
          <AIValuePropJourney />
        </motion.div>

        {/* Mid-page CTA */}
        {!submitted && (
          <ScrollReveal direction="up" delay={0.5}>
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={isInView ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.8, delay: 0.5 }}
              className="max-w-md mx-auto text-center"
            >
              <SignupForm
                email={email}
                setEmail={setEmail}
                platform={platform}
                setPlatform={setPlatform}
                onSubmit={onSubmit}
              />
            </motion.div>
          </ScrollReveal>
        )}
      </div>
    </section>
  );
};

