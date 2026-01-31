# UMe - Stop Swiping, Start Connecting

**A personality-driven dating app that uses AI to find relationships that actually last.**

UMe reimagines dating by putting genuine compatibility first. Instead of endless swiping based on superficial traits, you simply chat with an empathetic AI companion that learns who you are and what you truly want in a partner. Then UMe introduces you directly to people you're genuinely compatible with—no guessing games, no exhaustion.

## The Problem

Modern dating apps are broken:
- [Getting sued](https://www.theguardian.com/lifeandstyle/2024/feb/17/are-dating-apps-fuelling-addiction-lawsuit-against-tinder-hinge-and-match-claims-so) for fueling addictive behaviors and harming mental health
- Rely on superficial metrics that fail to capture genuine compatibility
- Promising matches fizzle due to lack of real connection
- Users feel overwhelmed by endless swiping and shallow interactions

## The Solution

UMe flips the script with three core innovations:

### 1. Conversational Profile Building
No forms, no questionnaires. Just natural conversations with an AI companion inspired by Samantha from *Her*—warm, curious, and genuinely interested in understanding you. The AI asks thoughtful questions across diverse themes to build a rich personality profile.

### 2. Deep Compatibility Matching
Using LLM-powered analysis, UMe evaluates compatibility across multiple dimensions:
- Personality traits and values
- Life goals and relationship preferences
- Communication styles and interests
- Domain-specific compatibility research

The matching algorithm combines preference filtering (age, location, orientation) with AI-driven personality analysis to surface only high-quality matches (8+ compatibility score).

### 3. Guided Dating Journey
Beyond matching, UMe acts as your dating companion—offering advice, helping you make the first move, and guiding you through every stage of your dating experience.

## Technical Architecture

### Mobile App (Flutter)
- **Framework**: Flutter with Firebase integration
- **State Management**: Provider pattern for chat, profile, and matches
- **Authentication**: Firebase Auth with phone number verification
- **Real-time Data**: Firestore for profiles, matches, and conversations
- **Analytics**: Firebase Analytics + Crashlytics

### Backend API (Python/FastAPI)
- **Framework**: FastAPI deployed on Google Cloud Platform
- **AI Engine**: OpenAI GPT models with structured outputs
- **Key Components**:
  - `algo.py` - Matchmaking algorithm with canonical match IDs to prevent duplicates
  - `prompts.py` - Carefully crafted system prompts for persona discovery, distillation, and match ranking
  - `ai.py` - LLM integration with parallel matching capabilities
  - `fire_utils.py` - Firebase operations and preference filtering

### Matchmaking Pipeline
```
1. Persona Discovery → Conversational AI extracts personality traits
2. Persona Distillation → Structured analysis of "who they are" + "what they want"
3. Preference Filtering → Age, location, orientation, distance constraints
4. AI Ranking → LLM evaluates compatibility with personalized rationales
5. Match Delivery → Top 3 matches per user with explanation
```

### Website (Next.js)
- **Framework**: Next.js 14 with TypeScript
- **Styling**: Tailwind CSS with custom animations
- **Features**: Waitlist signup, interactive value prop demos
- **Hosting**: Vercel with GoDaddy domain

## Key Technical Highlights

**Canonical Match IDs**: Prevents duplicate matches by creating consistent IDs regardless of user order (`sorted([user1, user2])`).

**Structured LLM Outputs**: Uses OpenAI's structured output parsing for reliable JSON responses (compatibility scores, persona categories, conversation state).

**Batch Matchmaking**: Daily cron job processes all users, filtering out recent matches (7-day window) and limiting to 3 new matches per user to prevent overwhelming users.

**Persona Compression**: Distills long conversations into concise markdown reports with bullet points across key dimensions (who they are, what they want, life events, additional notes).

**Profile Completeness Scoring**: Tracks evidence across dating themes (0-100 scale) to guide future conversations toward gaps in understanding.

## Business Model

Aligned incentives—no ads, no subscriptions designed to keep you hooked.

**Upfront fee**: £30 with milestone-based refunds
- 100% refund if no matches
- 50% refund if less than 1 match per day
- Future: Refunds tied to successful dates and relationships

**Dating-tier**: £15/month for in-relationship features (no longer in matching pool)

## Research Foundation

UMe is built on academic research in:
- LLM-based matchmaking and evaluation
- Personality impersonation and linguistic intelligence
- Compatibility science and social psychology
- Synthetic data generation and fine-tuning techniques

See `content.md` for full research bibliography.

## Getting Started

See individual README files for setup instructions:
- [Mobile App & API Setup](app/README.md)
- [Website Setup](website/README.md)
- [Feasibility Study](feasibility/README.md)

## Project Structure

```
├── app/
│   ├── mobile-app/   # Flutter mobile application
│   └── api/          # FastAPI backend + matchmaking logic
├── website/          # Next.js landing page
├── feasibility/      # Pre-MVP research and synthetic data
└── content.md        # Product roadmap and research
```

## License

MIT License - See LICENSE files in respective directories.

---

**UMe**: Dating made effortless and personal. Because you deserve connections that matter.
