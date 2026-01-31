import openai
import os
import re

openai.api_key = os.getenv("OPENAI_API_KEY")


def ai_generate(messages: list[dict[str, str]], temperature=0) -> str:
    response = openai.chat.completions.create(
        model="gpt-3.5-turbo", messages=messages, temperature=temperature
    )
    return response.choices[0].message.content


def parse_llm_answer(input_str):
    pattern = re.compile(r"\\boxed{(\d+(\.\d+)?)[^\d]*}")
    matches = pattern.findall(input_str)
    if matches:
        return float(matches[-1][0])
    else:
        matches = re.findall(re.compile(r"\d+"), input_str)
        if matches:
            return float(matches[-1])
        else:
            return 0
