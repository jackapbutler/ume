import os
from src import LOGGER
from openai import OpenAI
from src import fire_utils, prompts, themes
from src.models import Profile, MatchResult

MODEL_NAME = os.getenv("MODEL_NAME")


def get_gpt_response(messages: list[dict], response_format=None) -> str:
    assert MODEL_NAME, "OpenAI model name not found"
    assert "OPENAI_API_KEY" in os.environ, "OpenAI API key not found"

    CLIENT = OpenAI()
    if response_format:
        completion = CLIENT.beta.chat.completions.parse(
            model=MODEL_NAME, messages=messages, response_format=response_format
        )
        response = completion.choices[0].message.parsed
    else:
        completion = CLIENT.chat.completions.create(model=MODEL_NAME, messages=messages)
        response = completion.choices[0].message.content
    return response


GENERATOR = get_gpt_response


def rank_match(user_profile: Profile, other_profile: Profile) -> MatchResult:
    persona1 = fire_utils.get_persona(user_profile.user_id)
    persona2 = fire_utils.get_persona(other_profile.user_id)

    no_data = "Not enough information to consider match"
    result = MatchResult(
        compatibility_rating=0.0, rationale1=no_data, rationale2=no_data
    )
    if persona1 and persona2:
        prompt = prompts.MATCH_RANKING.format(
            profile1=user_profile.to_string(),
            profile2=other_profile.to_string(),
            persona1=persona1,
            persona2=persona2,
            themes=themes.make_str_from_themes(themes.DATING_THEMES)
        )
        try:
            result = GENERATOR(
                [{"role": "system", "content": prompt}], response_format=MatchResult
            )
        except Exception as e:
            LOGGER.error(f"Error while ranking match with {prompt=}\n {e}")
    else:
        LOGGER.warning(
            f"Not enough information to consider match between {user_profile=} and {other_profile=}"
        )
    return result


def parallel_matching(
    user_profile: Profile, potential_matches: list[Profile]
) -> dict[str, MatchResult]:
    match_results = {}
    try:
        for p in potential_matches:
            try:
                match = rank_match(user_profile, p)
                LOGGER.debug(
                    f"Match between {user_profile.user_id=} and {p.user_id=}: {match=}"
                )
                match_results[p.user_id] = match
            except Exception as e:
                LOGGER.error(
                    f"Match ranking {(p.user_id, user_profile.user_id)} generated exception: {e}"
                )
    except Exception as e:
        LOGGER.error(f"Error while matching: {e}")
    return match_results
