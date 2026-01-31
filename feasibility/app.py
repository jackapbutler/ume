import streamlit as st
import json
import dotenv
from utils import ai_generate

dotenv.load_dotenv()

ORIENTATIONS = ["Heterosexual", "Homosexual", "Bisexual", "Other"]
PASSIONS = [
    "Reading",
    "Travel",
    "Sports",
    "Cooking",
    "Music",
    "Art",
    "Science",
    "Gaming",
    "Other",
]
GENDER = ["Male", "Female", "Other"]
EDUCATIONS = ["", "Secondary School", "University", "Other"]

SYSTEM_PROMPT = "You are an User Discovery Representative for the world's greatest dating site tasked with interviewing new applicants to understand their preferences and interests so you can accurately represent them when you try match with other people on the site. Ask questions to understand more information about them and their preferences to help match them with others. Ask diverse questions one at a time and make sure to cover lots of different aspects of their life, personality and preferences."
PROMPT = """
The current information that I have submitted in a questionnaire is below:
{}
"""
PASSWORD = os.getenv("APP_PASSWORD", "change-me-in-production")


def save_to_json(data, filename="users.json"):
    with open(filename, "r") as file:
        users = json.load(file)
    users.append(data)
    with open(filename, "w+") as file:
        json.dump(users, file, indent=2)


def user_registration():
    st.title("Research - Dating App")

    for prop in ["ai_submit"]:
        if prop not in st.session_state:
            st.session_state[prop] = False

    def auto_disabled() -> bool:
        return True if st.session_state["ai_submit"] else False

    password = st.text_input("Enter your password:", type="password")
    if password and password == PASSWORD:
        with st.form("initial_data"):
            st.subheader("Part 1")
            name = st.text_input("Enter your name:", disabled=auto_disabled())
            sex = st.selectbox("Select your gender:", GENDER, disabled=auto_disabled())
            age = st.number_input(
                "Enter your age:", min_value=18, max_value=99, disabled=auto_disabled()
            )
            orientation = st.radio(
                "Select your sexual orientation:",
                ORIENTATIONS,
                disabled=auto_disabled(),
            )
            education = st.selectbox(
                "Select your education level:", EDUCATIONS, disabled=auto_disabled()
            )
            occupation = st.text_input(
                "Enter your occupation:", disabled=auto_disabled()
            )
            passions = st.multiselect(
                "Select your passions or interests:",
                PASSIONS,
                [],
                disabled=auto_disabled(),
            )
            if "Other" in passions:
                custom_passion = st.text_input(
                    "Enter your custom passion:", disabled=auto_disabled()
                )
                passions.append(custom_passion)
            user_data = {
                "Name": name,
                "Gender": sex,
                "Age": age,
                "Sexual Orientation": orientation,
                "Passions/Interests": passions,
                "Education": education,
                "Occupation": occupation,
            }
            ai_submit = st.form_submit_button(
                "Proceed to Part 2", disabled=auto_disabled()
            )
            if ai_submit:
                st.session_state["ai_submit"] = True

        if st.session_state["ai_submit"]:
            st.subheader("Part 2")

            if "messages" not in st.session_state:
                bio = "\n".join([f"{key}: {value}" for key, value in user_data.items()])
                initial = [
                    {"role": "system", "content": SYSTEM_PROMPT},
                    {"role": "user", "content": PROMPT.format(bio)},
                ]
                st.session_state.messages = initial + [
                    {"role": "assistant", "content": ai_generate(initial)}
                ]

            for message in st.session_state.messages[2:]:
                with st.chat_message(message["role"]):
                    st.markdown(message["content"])

            if prompt := st.chat_input("What is up?"):
                st.chat_message("user").markdown(prompt)
                st.session_state.messages.append({"role": "user", "content": prompt})

                response = ai_generate(st.session_state.messages)
                with st.chat_message("assistant"):
                    st.markdown(response)
                st.session_state.messages.append(
                    {"role": "assistant", "content": response}
                )

            if st.button("Finish Conversation"):
                user_data["AI Chat"] = st.session_state.messages
                save_to_json(user_data)
                st.balloons()
                st.success(f"Your information has been submitted, thanks {name}!")


if __name__ == "__main__":
    user_registration()
