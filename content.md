*Pitch*

UMe, a personality-driven app reimagining dating, so you can stop swiping and start connecting.

You stay in control because you decide who to connect with, while UMe’s AI works quietly in the background to make sure the matches you see truly align with your personality and values. Beyond matching, UMe helps you reflect on yourself and guide you through your dating experiences so every connection feels deeper and more meaningful.

It is dating made effortless and personal, designed to find relationships that actually last.

*User problem(s)*

1. Popular apps are [getting sued](https://www.theguardian.com/lifeandstyle/2024/feb/17/are-dating-apps-fuelling-addiction-lawsuit-against-tinder-hinge-and-match-claims-so), fuelling addictive behaviours and harming mental health.
2. Users struggle to get meaningful matches as apps rely on superficial traits & metrics.
3. Promising matches fizzle due to lack of genuine connection and poor conversation support.
4. Users feel overwhelmed and exhausted by endless swiping and shallow interactions.

[*Pre-MVP Feasibility*](https://www.notion.so/Pre-MVP-Feasibility-2bbc61a8c8124cc59db946483fe74273?pvs=21)

*Deployment stack*

- App → Database, Storage, Authentication, Distribution and Analytics via Firebase
- API → FastAPI via GCP & LLM via OpenAI
- Website → Domain via GoDaddy, Form via Web3Forms & Hosting via Vercel
- Admin → Marketing via Google Ads

*Metrics*

1. Initially growth in # users is most important, aim for at least 10% growth every month
    
    → compounds to 3x per year overall
    
    → better if organically viral via networks
    
2. Profit per user … eventually

*Competitors*

- Classic apps - tinder / bumble / plenty of fish / hinge / etc
- Human matchmaking service (can be > $1,000 for hand-picked dates / advice)
    
    https://www.intro.ie/
    
    https://twoscompany.ie/
    
    https://matchmakerireland.com/
    
- Unique apps
    - [tbc](https://www.tbcapp.co/) have automation + AI + less user burden but not so much location
    - [happn](https://happn.com/) have real-time location but not so much automation
    - [thursday](https://www.getthursday.com/) - singles events in the real world (focused on creating urgency)

*Roadmap*

- Matchmaking
    
    Tired of endless swiping and shallow matches? With UMe, you simply chat. Start by talking naturally with your friendly AI companion who learns what you really like, what matters to you, and what you want in a partner. Then UMe introduces you directly to people you are genuinely compatible with. No endless scrolling and no guessing games.
    
    - Have image based algorithm
    - Allow UMe to write details found during conversation to match’s `additional_context`
    - Integrate domain specific knowledge into the prompt based on statistics around compatibility research
    - Add fast vector search as a scalable first filter before LLM-based ranking
        - Parse and make embeddings for the who they are and who they like component
        - Start with openai embedding model and using firestore vector search
    - Can you train the LLM in a supervised way on a synthetic dataset via LLMs 
    i.e. RLAIF style instruction data
    - Add FCM notifications (storing user <> device token map) for new matches #
    - Add notification for Likes You back when the other has pressed it
    - Add a way to buy more matches, also show them the rationale beforehand.
- Business
    - Register as business
    - Get official email
    - Setup payments
    - Transfer company and all into that official email domain not my own
- Profile
    - Support selfie verification
    - Decay the personality category scores overtime e.g. discover never over
    - Onboarding flow - email sign up, then straight in, auto-profile filling via chat
    - Investigate easier onboarding via tinder / bumble / hinge upload
- Chat
    - Give chat access to each match’s full persona ... helps users know each other
    - Switch to using system prompts
    - Adapt UMe conversation style to the user by extracting any identified preferences 
    e.g. more / less verbose depends on the user
    - Understand what can be learned from existing human matchmaking services to integrate more domain specific knowledge into the chat
    - Improve past matches awareness to track which ones we spoke about or not
    - Letting people send conversation messages via voice for more context
    - Add localisation for other countries
    - *Review* Your matches or randomers to ask directly what they like / don’t like
    - *Planner*, automated date planning / scheduling / payment, just put in your availability and UMe organises the dates
    - *Roleplaying* with sentiment live as the conversation progresses and allow retry or magic ai suggestion for better response
- Persona
    - Make profile category scores as structured parsed OpenAI response
    - Integrate domain specific knowledge into the prompt based on statistics around compatibility research
    - Allow them to add their own pop of personality via a “fun fact” field
- Expand beyond dating
    - Include Friends / Dating / Business modes to cater to different needs
    - Make it a companion to find people that would help you in all areas of life, is it even dating specific ?
    - Can this be the global companion to find people that would help you in all areas of life, is it even dating specific ?
    - People are everywhere online but finding people is still so hard, UMe finds the U for Me.
    - Expand the notion of discovery, roleplay, date planning, etc to be agnostic such as pitching idea instead of roleplay
    - Rebrand this notion page
    - Make themes custom to type
- Foundational model for dating

*Business model*

We want to align the user’s incentives with our business, avoiding mechanisms focused on attention such as advertisements or subscription models. It’s also preferable that user’s only provide a payment based on their outcomes e.g. matches, dates or relationships.

That’s why we have chosen an upfront fees of £30 with milestone-based refunds. 

- if they get no matches they get 100% refund back
- if they don’t get at least 1 match per day, they get 50% refund back
- [tbd] if they don’t have any successful dates they get X% back
- [tbd] if they don’t find a partner they get Y% back

We also want to provide a dating-tier where users can access certain in-relationship features but are no longer considered as looking for matches in the app, this is a fee of £15 per month.

We could also consider money outside of users such as partnerships or sponsorships with other businesses e.g. if we schedule dates, we can create a market for restaurant hosting.

*Background research*

- evaluation / matchmaking potential
    
    https://arxiv.org/pdf/2308.10837.pdf
    
    https://arxiv.org/html/2401.07103v1
    
    https://arxiv.org/pdf/2308.07201.pdf
    
    https://arxiv.org/pdf/2310.08491.pdf
    
    https://arxiv.org/pdf/2401.01312.pdf
    
- impersonation
    
    [https://arxiv.org/pdf/2406.20094.pdf](https://arxiv.org/pdf/2406.20094)
    
    https://arxiv.org/pdf/2305.14930.pdf
    
    https://arxiv.org/pdf/2208.10264.pdf
    
    https://arxiv.org/pdf/2212.10465.pdf
    
    https://dl.acm.org/doi/pdf/10.1145/3526113.3545616
    
- linguistic, expert intelligence
    
    https://arxiv.org/pdf/2308.14536.pdf
    
- finetuning + synthetic data
    
    https://eugeneyan.com/writing/synthetic/
    
    https://arxiv.org/pdf/2305.11206.pdf
    
    https://arxiv.org/html/2404.07503v1
    
    + any papers on PEFT, instruction tuning, finetuning and in-context learning
    
- compatibility, social studies
    
    https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7071359/
    
- text compression / persona
    
    https://arxiv.org/html/2405.17974v1 
    
    https://openreview.net/pdf?id=jhCzPwcVbG