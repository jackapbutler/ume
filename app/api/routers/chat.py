from fastapi import APIRouter, Depends
from typing import Literal
from src import ai, prompts, fire_utils, themes
from src.app_utils import api_key_required
from src.models import Message, Conversation, Persona, MessageResponse
from src import LOGGER
import random
import json

router = APIRouter(prefix="/chat")
LEARN_SCALE = 0.20
MIN_LEARN = 5

def get_seen_matches(user_id: str, name: str) -> str:
    initial_msg = ""
    added_matches = False
    stored_matches = fire_utils.get_matches(user_id)
    if stored_matches.matches:
        LOGGER.debug(f"Adding past matches to initial message for user {user_id}")
        initial_msg += f"\n\n{prompts.PAST_MATCHES}\n"
        for match in stored_matches.matches:
            if match.you_showed_interest:
                matched_profile = fire_utils.get_profile(match.user_id)
                if matched_profile:
                    interest = (
                        "likes them"
                        if match.you_showed_interest
                        else "does not like them"
                    )
                    initial_msg += f"- {matched_profile.name} ({name} {interest}):\n{match.rationale}\n"
                    added_matches = True
    if not added_matches:
        initial_msg += prompts.NO_PAST_MATCHES
    return initial_msg


def get_weakest_themes(
    theme_names: dict[str, str],
    theme_scores: dict[str, int],
    n: int = 2,
) -> dict[str, str]:
    score_names, score_weights = list(theme_scores.keys()), list(theme_scores.values())
    inverse_scores = [100 - s + 1 for s in score_weights]
    chosen_themes = random.choices(score_names, weights=inverse_scores, k=n)
    return {theme: theme_names[theme] for theme in chosen_themes}


@router.get(
    "/opening", response_model=Message, dependencies=[Depends(api_key_required)]
)
def get_opening_prompt(user_id: str, chat_mode: Literal["discover"]):
    LOGGER.info(f"Initialising chat for user:{user_id}")
    profile = fire_utils.get_profile(user_id)
    persona = fire_utils.get_persona(user_id)

    profile_description = profile.to_string() if profile else ""
    persona_description = persona.description if persona else "No persona found"
    match_str = get_seen_matches(user_id, profile.name)

    if chat_mode == "discover":
        if persona and persona.profile_category_scores:
            weakest_themes = get_weakest_themes(
                themes.DATING_THEMES, persona.profile_category_scores
            )
        else:
            weakest_themes = dict(random.sample(themes.DATING_THEMES.items(), k=2))
        initial_msg = prompts.PERSONA_DISCOVERY.format(
            profile=profile_description,
            persona=persona_description,
            themes=themes.make_str_from_themes(weakest_themes),
            matches=match_str,
        )
    else:
        raise ValueError(f"Invalid chat mode: {chat_mode}")

    # initialising chat
    LOGGER.debug(f"Initial message for user {user_id}: {initial_msg}")
    return Message(message=initial_msg, model=ai.MODEL_NAME)


@router.post(
    "/response", response_model=Message, dependencies=[Depends(api_key_required)]
)
def chat_response(conversation: Conversation):
    # get previous messages (currently sent over api),
    ## NOTE this would need to be scalable + persistent (store messages) in future
    LOGGER.info(f"Responding to {conversation.user_id=}: {conversation.messages[-1]}")
    msg_response = ai.GENERATOR(
        messages=[x.to_dict() for x in conversation.messages],
        response_format=MessageResponse,
    )
    LOGGER.debug(f"Returning response for user:{conversation.user_id} {msg_response=}")
    return Message(
        message=msg_response.message,
        model=ai.MODEL_NAME,
        conversation_ended=msg_response.conversation_ended,
    )


@router.post("/persona", dependencies=[Depends(api_key_required)])
def save_persona(persona: Persona):
    LOGGER.info(f"Saving persona for user:{persona.user_id}")
    fire_utils.save_persona(persona.user_id, persona.description)
    return {"message": f"Successfully saved the persona for {persona.user_id}"}


@router.post("/distil", dependencies=[Depends(api_key_required)])
def distil_persona(conversation: Conversation):
    # Persona distillation
    LOGGER.info(f"Distilling persona for user:{conversation.user_id}")
    profile = fire_utils.get_profile(conversation.user_id)
    persona = fire_utils.get_persona(conversation.user_id)

    profile_details = profile.to_string() if profile else ""
    transcript = "\n".join(
        [f"{msg.role}: {msg.content}" for msg in conversation.messages]
    )
    core_prompt = prompts.PERSONA_DISTILLATION.format(
        profile=profile_details, transcript=transcript, persona=persona
    )

    response = ai.GENERATOR([{"role": "assistant", "content": core_prompt}])
    LOGGER.info(f"Distilled persona for user:{conversation.user_id}")
    LOGGER.debug(f"Distilled persona for user {conversation.user_id}: {response}")

    # Profile completeness
    score_prompt = prompts.PROFILE_COMPLETENESS.format(
        persona=response, themes=themes.make_str_from_themes(themes.DATING_THEMES)
    )
    updated_scores = ai.GENERATOR([{"role": "assistant", "content": score_prompt}])
    current_scores = persona.profile_category_scores if persona and persona.profile_category_scores else {}
    if not current_scores:
        current_scores = {theme: 0 for theme in themes.DATING_THEMES}
    new_scores = {}
    try:
        clean_scores = updated_scores.split("```json")[1].replace("```", "").strip()
        parsed_scores_dict = json.loads(clean_scores)
        for _key, _value in parsed_scores_dict.items():
            _curr_val = current_scores.get(_key)
            if _curr_val is not None and 25 < _value:
                suggested_score = _curr_val + int(LEARN_SCALE * _value)
                new_scores[_key] = min(suggested_score, 100)
    except Exception as e:
        new_scores = current_scores
        LOGGER.error(f"Error parsing scores: {e}")
    fire_utils.save_persona(conversation.user_id, response, new_scores)
    return {"message": f"Successfully distilled the persona for {conversation.user_id}"}


@router.get(
    "/persona", response_model=Persona, dependencies=[Depends(api_key_required)]
)
def get_persona(user_id: str):
    LOGGER.info(f"Getting persona for user:{user_id}")
    persona = fire_utils.get_persona(user_id)
    if not persona:
        persona = Persona(user_id=user_id, description="n/a")
    return persona
