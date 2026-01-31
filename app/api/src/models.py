from pydantic import BaseModel, constr
import pytz
from datetime import datetime, timedelta
from faker import Faker
import random

faker = Faker()


class MatchResult(BaseModel):
    compatibility_rating: int  # 1-10
    rationale1: str  # explanation of the rating to person 1
    rationale2: str  # explanation of the rating to person 2
    highlighted_themes: list[str] | None = None


class Chat(BaseModel):
    role: str
    content: str

    def to_dict(self):
        return {"role": self.role, "content": self.content}


class Conversation(BaseModel):
    user_id: str
    messages: list[Chat]


class StoredMatches(BaseModel):
    matches: list["RecordedMatch"]
    last_updated: datetime | None = None


class Message(BaseModel):
    message: str
    model: str | None
    conversation_ended: bool = False


class MessageResponse(BaseModel):
    message: str  # the message response to the user
    conversation_ended: bool  # determines if the conversation should end


class Persona(BaseModel):
    description: str | None
    user_id: str
    profile_category_scores: dict[str, int] | None = None

class MatchmakingStatus(BaseModel):
    last_started: datetime | None = None
    last_finished: datetime | None = None
    status: str = "DONE"  # DONE, IN_PROGRESS

    def start(self):
        self.status = "IN_PROGRESS"
        self.last_started = datetime.now(pytz.utc)

    def stop(self):
        self.status = "DONE"
        self.last_finished = datetime.now(pytz.utc)


class RecordedMatch(BaseModel):
    user_id: str
    rationale: str
    compatibility_rating: int
    highlighted_themes: list[str]
    you_showed_interest: bool = False
    your_interested: bool = False
    had_date: bool = False
    had_relationship: bool = False
    date_matched: datetime = datetime.now(pytz.utc)
    additional_context: str | None = None

    @property
    def last_24_hours(self) -> bool:
        now = datetime.now(pytz.utc)
        last_24hr = now - timedelta(days=1)
        return last_24hr <= self.date_matched <= now

    @classmethod
    def from_match_result(
        cls, user_id1: str, user_id2: str, match_result: MatchResult
    ) -> tuple["RecordedMatch", "RecordedMatch"]:
        shared_kwargs = {
            "compatibility_rating": match_result.compatibility_rating,
            "highlighted_themes": match_result.highlighted_themes,
        }
        return (
            cls(
                user_id=user_id2,
                rationale=match_result.rationale1,
                **shared_kwargs
            ),
            cls(
                user_id=user_id1,
                rationale=match_result.rationale2,
                **shared_kwargs
            ),
        )


class DisplayMatch(BaseModel):
    name: str
    matched_user_id: str
    image_url: str
    date_matched: datetime
    rationale: str
    highlighted_themes: list[str]
    you_showed_interest: bool
    your_interested: bool
    they_showed_interest: bool
    they_interested: bool
    phone_number: str | None = None
    age: int | None = None
    gender: str | None = None
    location_name: str | None = None


class MatchResponse(BaseModel):
    matches: list[DisplayMatch]
    last_updated: datetime | None


class MatchUpdate(BaseModel):
    user_id: str
    matched_user_id: str
    show_interest: bool


class Location(BaseModel):
    latitude: float
    longitude: float
    consent: bool
    name: str | None = None

    @classmethod
    def generate_random(cls) -> "Location":
        return Location(
            latitude=random.uniform(-90, 90),
            longitude=random.uniform(-180, 180),
            consent=random.choice([True, False]),
            name="Fake Land",
        )


class PhoneNumber(BaseModel):
    countryISOCode: str
    countryCode: str
    number: str

    @classmethod
    def generate_random(cls) -> "PhoneNumber":
        return PhoneNumber(countryISOCode="AD", countryCode="+376", number="222222")

    @property
    def full_number(self) -> str:
        return f"{self.countryCode} {self.number}"


def age_from_dob(dob: str) -> int | None:
    if dob is None:
        return None  # No date of birth provided
    try:
        birth_date = datetime.strptime(dob, "%d/%m/%Y")
        today = datetime.today()
        age = (
            today.year
            - birth_date.year
            - ((today.month, today.day) < (birth_date.month, birth_date.day))
        )
        return age
    except ValueError:
        raise ValueError("Date of birth must be in 'DD/MM/YYYY' format")


class Profile(BaseModel):
    user_id: str
    name: constr(max_length=100) | None = None  # type: ignore
    dob: str | None = None  # YYYY-MM-DD
    age_range: tuple[int, int] | None = None
    phone_number: PhoneNumber | None = None
    gender: str | None = None
    orientation: list[str] | None = None
    profile_image: str | None = None
    location: Location | None = None
    distance_range_km: int | None = None
    never_refreshed_matches: bool = True

    @property
    def is_child(self) -> bool:
        return self.age < 18

    @property
    def age(self) -> int | None:
        return age_from_dob(self.dob)

    @classmethod
    def generate_random(cls, gender: str | None = None) -> "Profile":
        # get random profile image
        base_image_url = "https://randomuser.me/api/portraits"
        male_images = [f"{base_image_url}/men/{x}.jpg" for x in range(100)]
        female_images = [f"{base_image_url}/women/{x}.jpg" for x in range(100)]

        # handle dependent properties
        genders = ("Male", "Female", "Non-Binary")
        if not gender:
            gender = random.choice(genders)
        if gender == "Male":
            name = faker.name_male()
            profile_image = random.choice(male_images)
        elif gender == "Female":
            name = faker.name_female()
            profile_image = random.choice(female_images)
        else:
            name = faker.name()
            profile_image = random.choice(male_images + female_images)
        dob = faker.date_of_birth(minimum_age=18, maximum_age=100).strftime("%d/%m/%Y")
        age = age_from_dob(dob)
        return cls(
            user_id=faker.uuid4().replace("-", ""),
            name=name,
            dob=dob,
            age_range=(18, random.randint(age, 100)),
            phone_number=PhoneNumber.generate_random(),
            gender=gender,
            orientation=random.sample(genders, k=random.randint(1, len(genders))),
            profile_image=profile_image,
            location=Location.generate_random(),
            distance_range_km=random.randint(1, 100)
            if random.choice([True, False])
            else None,
            neverRefreshedMatches=random.choice([True, False]),
        )

    def to_string(self) -> str:
        properties_to_ignore = ["user_id", "phone_number", "profile_image"]
        property_to_pretty = {
            "dob": "Date of Birth",
            "distance_range_km": "Preferred Min. Distance (KM)",
            "orientation": "Interested in",
        }
        custom_functions = {"dob": lambda x: f"{x} ({age_from_dob(x)})"}

        context_items = []
        for k, v in dict(self).items():
            if k not in properties_to_ignore and v:
                pretty_name = property_to_pretty.get(k, k.replace("_", " ").capitalize())
                pretty_val = custom_functions.get(k, lambda x: x)(v)
                context_items.append(f"{pretty_name}: {pretty_val}")

        return "\n".join(context_items)
