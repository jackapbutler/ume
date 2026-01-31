from fastapi import APIRouter, Depends
from src import LOGGER
from src import fire_utils
from src.app_utils import api_key_required

router = APIRouter(prefix="/profile")


@router.post("/delete", dependencies=[Depends(api_key_required)])
def delete_all(user_id: str):
    LOGGER.info(f"Deleting all data for {user_id=}")
    try:
        fire_utils.delete_all(user_id)
    except Exception as e:
        LOGGER.error(f"Failed to delete all data for {user_id=}: {e}")
        return {"message": "Failed to delete data."}
    return {"message": "Data deleted."}

@router.post("/feedback", dependencies=[Depends(api_key_required)])
def give_feedback(user_id: str, text: str, category: str):
    try:
        fire_utils.create_feedback(user_id, text, category)
    except Exception as e:
        LOGGER.error(f"Failed to give feedback for {user_id=}: {e}")
        return {"message": "Failed to give feedback."}
    return {"message": "Feedback submitted."}
