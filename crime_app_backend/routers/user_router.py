# routers/user_router.py
from fastapi import APIRouter, Header, HTTPException
from database import users_col, settings_col

router = APIRouter(prefix="/user", tags=["user"])

@router.get("/settings")
async def get_settings(user_id: str | None = Header(None)):
    if not user_id:
        raise HTTPException(status_code=401, detail="Unauthorized")
    s = await settings_col.find_one({"user_id": user_id})
    if not s:
        # defaults
        s = {"user_id": user_id, "dark_mode": False, "notifications": True, "language": "en"}
    return s

@router.post("/settings")
async def update_settings(payload: dict, user_id: str | None = Header(None)):
    if not user_id:
        raise HTTPException(status_code=401, detail="Unauthorized")
    await settings_col.replace_one({"user_id": user_id}, {**payload, "user_id": user_id}, upsert=True)
    return {"status":"ok"}

@router.post("/logout")
async def logout(user_id: str | None = Header(None)):
    # For JWT stateless logout: front-end just deletes token.
    # If you want server-side invalidation, implement token blacklist collection.
        return {"status":"logged_out"}
