from fastapi import APIRouter, Depends
from src import fire_utils, LOGGER
from src.app_utils import api_key_required
from src.models import DisplayMatch, MatchResponse, MatchUpdate, MatchmakingStatus
from src.algo import matchmaking

router = APIRouter(prefix="/matches")


@router.post("/create", dependencies=[Depends(api_key_required)])
def generate_matches(user_id: str):
    return matchmaking(user_id)


@router.get(
    "/get", response_model=MatchResponse, dependencies=[Depends(api_key_required)]
)
def get_matches(user_id: str):
    # get the user's current matches
    stored_matches = fire_utils.get_matches(user_id)
    match_profiles = [
        fire_utils.get_profile(match.user_id) for match in stored_matches.matches
    ]

    display_matches = []
    if not stored_matches.matches:
        LOGGER.info(f"No matches found for {user_id=}")
    else:
        for match, profile in zip(stored_matches.matches, match_profiles):
            if profile:
                stored_matches = fire_utils.get_matches(match.user_id)
                filtered_matches = [
                    m for m in stored_matches.matches if m.user_id == user_id
                ]
                if not filtered_matches:
                    LOGGER.warning(
                        f"Corresponding {match=} not found for user {match.user_id}"
                    )
                    continue
                their_match = filtered_matches[0]
                display_match = DisplayMatch(
                    name=profile.name,
                    matched_user_id=match.user_id,
                    image_url=profile.profile_image,
                    date_matched=match.date_matched,
                    rationale=match.rationale,
                    highlighted_themes=match.highlighted_themes,
                    you_showed_interest=match.you_showed_interest,
                    your_interested=match.your_interested,
                    they_showed_interest=their_match.you_showed_interest,
                    they_interested=their_match.your_interested,
                    phone_number=profile.phone_number.full_number,
                    age=profile.age,
                    gender=profile.gender,
                    location_name=profile.location.name if profile.location else None,
                )
                display_matches.append(display_match)
            else:
                LOGGER.error(f"Profile not found for {match=}")
    sorted_matches = sorted(display_matches, key=lambda x: x.date_matched, reverse=True)
    LOGGER.info(f"Fetched {len(sorted_matches)} matches for {user_id=}")
    return MatchResponse(
        matches=sorted_matches, last_updated=stored_matches.last_updated
    )


@router.get(
    "/status",
    response_model=MatchmakingStatus,
    dependencies=[Depends(api_key_required)],
)
def return_matchmaking_status():
    return fire_utils.get_matchmaking_status()


@router.post("/update", dependencies=[Depends(api_key_required)])
def update_match(match_update: MatchUpdate):
    # get the user's current matches
    stored_matches = fire_utils.get_matches(match_update.user_id)
    # update the match
    for match in stored_matches.matches:
        if match.user_id == match_update.matched_user_id:
            match.your_interested = match_update.show_interest
            match.you_showed_interest = True
            break
    fire_utils.save_matches(match_update.user_id, stored_matches.matches)
    return {"message": f"Successfully updated match for {match_update.user_id}"}
