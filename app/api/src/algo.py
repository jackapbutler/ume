from src import ai, LOGGER, fire_utils
from src.models import (
    RecordedMatch,
    Profile,
    MatchResult,
)
import datetime
import pytz

N_SUBSET = 20
MIN_SCORE = 8
MAX_MATCHES_PER_USER = 3


def create_canonical_match_id(user1: str, user2: str) -> str:
    """Create a consistent match ID regardless of user order."""
    return "_".join(sorted([user1, user2]))


def find_new_prospects(
    profile: Profile, all_user_profiles: list[Profile], existing_match_ids: set[str]
) -> dict[str, MatchResult]:
    """Find new prospects, filtering out any existing matches using canonical IDs."""
    valid_new_prospects = fire_utils.apply_preference_filters(
        profile, all_user_profiles
    )
    if not valid_new_prospects:
        LOGGER.warning(
            f"No valid prospects for {profile.user_id=}. Returning empty results."
        )
        return {}
    LOGGER.debug(
        f"Found {len(valid_new_prospects)} profiles after preference filtering for {profile.user_id=}"
    )

    # Filter out prospects that would create duplicate matches
    filtered_prospects = []
    for prospect in valid_new_prospects[:N_SUBSET]:
        match_id = create_canonical_match_id(profile.user_id, prospect.user_id)
        if match_id not in existing_match_ids:
            filtered_prospects.append(prospect)

    if not filtered_prospects:
        LOGGER.warning(
            f"No valid prospects after duplicate filtering for {profile.user_id=}. Returning empty results."
        )
        return {}

    LOGGER.debug(
        f"Found {len(filtered_prospects)} profiles after reducing search space and duplicate filtering for {profile.user_id=}"
    )

    match_results = ai.parallel_matching(profile, filtered_prospects)
    top_ranked_matches = {
        k: v
        for k, v in sorted(
            match_results.items(),
            key=lambda item: item[1].compatibility_rating,
            reverse=True,
        )
        if v.compatibility_rating >= MIN_SCORE
    }

    if not top_ranked_matches:
        LOGGER.warning(f"No matches found for {profile.user_id=}.")
        return {}

    LOGGER.debug(
        f"Found {len(top_ranked_matches)} top ranked matches for {profile.user_id=}"
    )
    return top_ranked_matches


def get_existing_match_ids(
    stored_matches_dict: dict[str, list[RecordedMatch]],
) -> set[str]:
    """Extract all existing match IDs in their canonical form."""
    existing_ids = set()
    for user_id, matches in stored_matches_dict.items():
        for match in matches:
            match_id = create_canonical_match_id(user_id, match.user_id)
            existing_ids.add(match_id)
    return existing_ids


def matchmaking(user_id: str | None = None):
    # Initialize matchmaking status
    current_status = fire_utils.get_matchmaking_status()
    if user_id:
        LOGGER.info(f"Generating matches for {user_id=}")
        matchee_profiles = [fire_utils.get_profile(user_id)]
    else:
        current_status.start()  # only start for daily cron job
        fire_utils.save_matchmaking_status(current_status)
        LOGGER.info("Generating matches for all users")
        matchee_profiles = fire_utils.get_all_profiles()

    all_user_profiles = fire_utils.get_all_profiles()

    # Get all existing matches and create canonical IDs
    user_current_valid_matches: dict[str, list[RecordedMatch]] = {}
    for profile in matchee_profiles:
        stored_matches = fire_utils.get_matches(profile.user_id)
        user_current_valid_matches[profile.user_id] = [
            r
            for r in stored_matches.matches
            if (datetime.datetime.now(pytz.utc) - r.date_matched).days < 7
        ]

    existing_match_ids = get_existing_match_ids(user_current_valid_matches)
    LOGGER.debug(f"Found {len(existing_match_ids)} existing match IDs")

    # Store prospective matches using canonical IDs
    all_match_prospects: dict[str, tuple[str, str, MatchResult]] = {}

    for profile in matchee_profiles:
        LOGGER.info(f"Generating matches for {profile.user_id=}")

        # Get potential profiles excluding already matched users
        all_potential_profiles = [
            p for p in all_user_profiles if p.user_id != profile.user_id
        ]

        LOGGER.debug(
            f"Found {len(all_potential_profiles)} potential match profiles for {profile.user_id=}"
        )

        # Find new prospects
        top_ranked_matches = find_new_prospects(
            profile, all_potential_profiles, existing_match_ids
        )

        # Store matches using canonical IDs
        for matched_user_id, match_result in top_ranked_matches.items():
            match_id = create_canonical_match_id(profile.user_id, matched_user_id)
            if match_id not in all_match_prospects:
                all_match_prospects[match_id] = (
                    profile.user_id,
                    matched_user_id,
                    match_result,
                )

    # Process and save matches
    sorted_prospects = sorted(
        all_match_prospects.values(),
        key=lambda x: x[2].compatibility_rating,
        reverse=True,
    )

    if not sorted_prospects:
        LOGGER.info("No matches found, exiting")
        return {"message": "No matches found"}

    _max, _min = (
        sorted_prospects[0][2].compatibility_rating,
        sorted_prospects[-1][2].compatibility_rating,
    )
    LOGGER.info(
        f"Found {len(sorted_prospects)} total prospective matches, score range max={_max}, min={_min}"
    )

    # Track matches per user and save new matches
    num_new_matches = 0
    count_matches_per_user: dict[str, int] = {}

    for user1, user2, match_result in sorted_prospects:
        user1_count = count_matches_per_user.get(user1, 0)
        user2_count = count_matches_per_user.get(user2, 0)

        if user1_count >= MAX_MATCHES_PER_USER or user2_count >= MAX_MATCHES_PER_USER:
            LOGGER.debug(
                f"Skipping match {user1=} - {user2=}, score={match_result.compatibility_rating}"
            )
            continue

        # Create and save matches for both users
        user1_match, user2_match = RecordedMatch.from_match_result(
            user1, user2, match_result
        )

        user_current_valid_matches.setdefault(user1, []).append(user1_match)
        user_current_valid_matches.setdefault(user2, []).append(user2_match)

        num_new_matches += 1
        LOGGER.debug(
            f"Saved match {user1=} - {user2=}, score={match_result.compatibility_rating}"
        )

        # Update match counts
        count_matches_per_user[user1] = user1_count + 1
        count_matches_per_user[user2] = user2_count + 1

    # Save results
    LOGGER.info(f"Saving {num_new_matches} new matches")
    fire_utils.batch_save_matches(user_current_valid_matches)

    if not user_id:
        current_status.stop()
        fire_utils.save_matchmaking_status(current_status)

    return {"message": f"Successfully created {num_new_matches} new matches"}
