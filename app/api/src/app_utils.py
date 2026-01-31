from typing import Annotated
import os
from fastapi import HTTPException, Header

API_KEY = os.getenv("API_KEY")


async def api_key_required(api_key: Annotated[str, Header()]):
    if api_key != API_KEY:
        raise HTTPException(status_code=403, detail="Invalid or missing API key")
