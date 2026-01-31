import firebase_admin
from firebase_admin import auth
from src import LOGGER
from firebase_admin import firestore
import datetime
import pytz
import geopy.distance as geodist
from src.models import (
    Profile,
    RecordedMatch,
    Location,
    MatchmakingStatus,
    StoredMatches,
    Persona,
)

fire_app = firebase_admin.initialize_app()
fdb = firestore.client()

def create_feedback(user_id: str, text: str, category: str):
    feedback_ref = fdb.collection("feedback").document(user_id)
    feedback_doc = feedback_ref.get()

    feedback_data = []
    if feedback_doc.exists:
        feedback_data = feedback_doc.to_dict().get("user_feedbacks", [])

    feedback_data.append({"text": text, "timestamp": datetime.datetime.now(pytz.utc).isoformat(), "category": category,})
    feedback_ref.set({"user_feedbacks": feedback_data})
    LOGGER.info(f"Feedback successfully saved for {user_id=}")

def delete_all(user_id: str):
    _ = auth.delete_user(user_id)
    profile_ref = fdb.collection("profile").document(user_id)
    profile_ref.delete()
    matches_ref = fdb.collection("matches").document(user_id)
    matches_ref.delete()
    persona_ref = fdb.collection("persona").document(user_id)
    persona_ref.delete()
    LOGGER.info(f"Deleted all data for {user_id=}")


def get_profile(user_id: str) -> Profile | None:
    profile_ref = fdb.collection("profile").document(user_id)
    profile_doc = profile_ref.get()

    if not profile_doc.exists:
        LOGGER.warning(f"No profile found for {user_id=}")
        return None

    profile_data = profile_doc.to_dict()
    LOGGER.info(f"Found profile for {user_id=}")
    LOGGER.debug(f"Profile for {user_id=}: {profile_data}")
    return Profile(**profile_data)


def get_all_profiles() -> list[Profile]:
    profiles = fdb.collection("profile").stream()
    return [Profile(**profile.to_dict()) for profile in profiles]


def apply_preference_filters(
    user_profile: Profile, all_new_profiles: list[Profile]
) -> list[Profile]:
    filtered_profiles = []
    for profile in all_new_profiles:
        # if child mismatch
        if (user_profile.is_child and not profile.is_child) or (
            profile.is_child and not user_profile.is_child
        ):
            continue
        # if orientation selected and mismatch
        if user_profile.orientation and profile.gender not in user_profile.orientation:
            continue
        if profile.orientation and user_profile.gender not in profile.orientation:
            continue
        # if age range mismatch
        if profile.age_range and not (
            profile.age_range[0] <= user_profile.age <= profile.age_range[1]
        ):
            continue
        if user_profile.age_range and not (
            user_profile.age_range[0] <= profile.age <= user_profile.age_range[1]
        ):
            continue
        # if location mismatch
        if profile.location and profile.distance_range_km:
            if not user_profile.location or profile.distance_range_km < distance_km(
                user_profile.location, profile.location
            ):
                continue
        if user_profile.location and user_profile.distance_range_km:
            if not profile.location or user_profile.distance_range_km < distance_km(
                user_profile.location, profile.location
            ):
                continue
        filtered_profiles.append(profile)
    return filtered_profiles


def distance_km(location: Location, location2: Location) -> float:
    return geodist.distance(
        (location.latitude, location.longitude),
        (location2.latitude, location2.longitude),
    ).km


def get_matches(user_id: str) -> StoredMatches:
    matches_ref = fdb.collection("matches").document(user_id)
    matches_doc = matches_ref.get()

    if not matches_doc.exists:
        LOGGER.debug(f"No matches found for {user_id=}")
        return StoredMatches(matches=[])

    details = matches_doc.to_dict()
    matches = [RecordedMatch(**match) for match in details.get("matches", [])]
    return StoredMatches(matches=matches, last_updated=details.get("last_updated"))


def save_matches(
    user_id: str, new_matches: list[RecordedMatch], update_time: bool = False
):
    matches_ref = fdb.collection("matches").document(user_id)
    update_properties = {"matches": [match.dict() for match in new_matches]}
    if update_time:
        update_properties["last_updated"] = datetime.datetime.now(pytz.utc).isoformat()

    matches_ref.set(update_properties)
    LOGGER.info(
        f"Matches successfully saved/updated for {user_id=} with {update_time=}"
    )


def batch_save_matches(user_matches: dict[str, list[RecordedMatch]]):
    batch = fdb.batch()
    for user_id, matches in user_matches.items():
        matches_ref = fdb.collection("matches").document(user_id)
        batch.set(
            matches_ref,
            {
                "matches": [match.dict() for match in matches],
                "last_updated": datetime.datetime.now(pytz.utc).isoformat(),
            },
        )
    batch.commit()
    LOGGER.info(f"Batch saved {len(user_matches)} user matches")


def get_matchmaking_status() -> MatchmakingStatus:
    status_ref = fdb.collection("status").document("matchmaking")
    status_doc = status_ref.get()

    if not status_doc.exists:
        LOGGER.warning("No matchmaking status found")
        return MatchmakingStatus()

    return MatchmakingStatus(**status_doc.to_dict())


def save_matchmaking_status(status: MatchmakingStatus):
    status_ref = fdb.collection("status").document("matchmaking")
    status_ref.set(status.dict(), merge=True)
    LOGGER.info("Matchmaking status successfully saved/updated")


def get_persona(user_id: str) -> Persona | None:
    persona_ref = fdb.collection("persona").document(user_id)
    persona_doc = persona_ref.get()

    if not persona_doc.exists:
        LOGGER.warning(f"No persona found for {user_id=}")
        return None

    return Persona(**persona_doc.to_dict(), user_id=user_id)


def save_persona(
    user_id: str,
    persona_description: str,
    new_scores: dict[str, int] | None = None
):
    persona_ref = fdb.collection("persona").document(user_id)
    update_props = {"description": persona_description}
    if new_scores:
        update_props["profile_category_scores"] = new_scores
    persona_ref.set(update_props, merge=True)
    LOGGER.info(f"Persona successfully saved/updated for {user_id=}")


def save_profile(user_id: str, profile: Profile):
    profiles_ref = fdb.collection("profile").document(user_id)
    profiles_ref.set(profile.dict(), merge=True)
    LOGGER.info(f"Profile successfully saved/updated for {user_id=}")
