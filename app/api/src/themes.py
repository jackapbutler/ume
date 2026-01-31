def make_str_from_themes(themes: dict[str, str]) -> str:
    return "\n".join([f"- {k}: {v}" for k, v in themes.items()])


DATING_THEMES = {
    "Communication & Connection": "How you interact with others in both casual and meaningful conversations. Examples: Keeping conversations flowing, Reading and responding to signals, Knowing when to transition to deeper topics, Flirting with confidence and creating attraction.",
    "Emotions & Conflict": "How you understand and respond to emotions, both in yourself and others, especially during difficult conversations. Examples: Sensing emotions in others, Mirroring tone, De-escalating conflicts, Resolving misunderstandings smoothly, Handling awkward moments gracefully.",
    "Values & Beliefs": "The principles and beliefs that shape your decisions and how you approach relationships. Examples: Political and spiritual views, Ethical principles, Causes you're passionate about, How your values align with a partner.",
    "Lifestyle & Routine": "How your daily habits and routines reflect your energy, balance, and overall approach to life. Examples: Work-life balance, Activity level, Introvert vs. extrovert, Living habits, How you make time for a relationship.",
    "Relationships & Expectations": "The type of relationship dynamics you seek and your expectations in terms of commitment, intimacy, and connection. Examples: Casual vs. serious relationships, Marriage intentions, Expectations for independence vs. togetherness, Physical intimacy preferences.",
    "Growth & Ambitions": "Your long-term goals and how you aim to evolve personally and professionally. Examples: Career goals, Personal development, Financial planning, Aspirations and how they fit with a relationship.",
    "Family & Social": "Your approach to family life, friendships, and your social circle. Examples: Family dynamics, Importance of friends, Social life preferences, Views on having children, Balancing family with relationship priorities.",
    "Interests & Passions": "The things that bring you joy and how you share these passions with others. Examples: Hobbies, Creative outlets, Travel, Cultural interests, Adventures and experiences you want to share.",
    "Compatibility & Boundaries": "What you're looking for in a partner and what personal boundaries are essential for a healthy relationship. Examples: Deal-breakers, Must-haves, Humour styles, Lifestyle compatibility, Respect for personal space and boundaries.",
    "Confidence & Assertiveness": "Your ability to be self-assured and clear in your communications and interactions. Examples: Making confident invitations, Setting the right tone, Handling indecisiveness, Displaying self-assurance without being overbearing.",
    "Date Dynamics": "How you move a relationship from online interaction to real-life connection and keep the momentum. Examples: Making clear date plans, Escalating attraction, Ending conversations with anticipation, Transitioning from casual chats to deeper connection."
}
