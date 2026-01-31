from fastapi import FastAPI
from contextlib import asynccontextmanager
from src import LOGGER
from routers import fake, chat, matches, profile


@asynccontextmanager
async def lifespan(app: FastAPI):
    LOGGER.info("Starting up!")
    yield
    LOGGER.info("Shutting down!")


app = FastAPI(lifespan=lifespan)
app.include_router(fake.router)
app.include_router(chat.router)
app.include_router(matches.router)
app.include_router(profile.router)


@app.get("/")
def healthcheck():
    return {"Hello": "World"}
