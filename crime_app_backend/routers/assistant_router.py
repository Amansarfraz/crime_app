from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import List
from datetime import datetime
import os
import httpx

from database import chat_history_col
from auth import get_current_user

router = APIRouter(prefix="/assistant", tags=["Assistant"])

GROQ_API_KEY = os.getenv("GROQ_API_KEY", "")
GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"
GROQ_MODEL = "llama-3.3-70b-versatile"

SYSTEM_PROMPT = (
    "You are a helpful Crime Safety Assistant for a Pakistan crime-awareness app. "
    "You answer crime-related questions, give safety guidance, and share general "
    "city crime information for Pakistani cities. Keep answers short, clear, and "
    "practical. If asked about exact live crime statistics, explain that the app's "
    "data is based on Numbeo perception surveys and estimates, not official police "
    "records. Never give instructions that could help commit a crime. If someone is "
    "in immediate danger, tell them to call Police 15 or Rescue 1122."
)

_ttl_ready = False


async def _ensure_ttl():
    """7 din baad chat messages auto-delete (MongoDB TTL index)."""
    global _ttl_ready
    if _ttl_ready:
        return
    # expireAfterSeconds = 7 days = 604800
    await chat_history_col.create_index("time", expireAfterSeconds=604800)
    await chat_history_col.create_index("user_id")
    _ttl_ready = True


class ChatMessage(BaseModel):
    role: str
    content: str


class ChatRequest(BaseModel):
    message: str
    history: List[ChatMessage] = []


@router.post("/chat")
async def chat(req: ChatRequest, user=Depends(get_current_user)):
    if not GROQ_API_KEY:
        raise HTTPException(
            status_code=500,
            detail="GROQ_API_KEY set nahi hai backend .env me",
        )

    await _ensure_ttl()
    uid = user["user_id"]
    now = datetime.utcnow()

    # Build messages for Groq
    messages = [{"role": "system", "content": SYSTEM_PROMPT}]
    for m in req.history[-10:]:
        if m.role in ("user", "assistant"):
            messages.append({"role": m.role, "content": m.content})
    messages.append({"role": "user", "content": req.message})

    payload = {
        "model": GROQ_MODEL,
        "messages": messages,
        "temperature": 0.4,
        "max_tokens": 500,
    }
    headers = {
        "Authorization": f"Bearer {GROQ_API_KEY}",
        "Content-Type": "application/json",
    }

    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            res = await client.post(GROQ_URL, json=payload, headers=headers)

        if res.status_code != 200:
            raise HTTPException(status_code=502, detail=f"Groq error: {res.text}")

        data = res.json()
        reply = data["choices"][0]["message"]["content"].strip()

        # Save user msg + assistant reply (per user, TTL 7 days)
        await chat_history_col.insert_many(
            [
                {"user_id": uid, "role": "user", "content": req.message, "time": now},
                {"user_id": uid, "role": "assistant", "content": reply, "time": now},
            ]
        )

        return {"reply": reply}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Assistant error: {e}")


@router.get("/history")
async def get_history(user=Depends(get_current_user)):
    """Is user ki pichhle 7 din ki chat (purani pehle)."""
    await _ensure_ttl()
    uid = user["user_id"]
    cursor = chat_history_col.find(
        {"user_id": uid}, {"_id": 0, "role": 1, "content": 1, "time": 1}
    ).sort("time", 1)
    msgs = await cursor.to_list(length=None)
    for m in msgs:
        if isinstance(m.get("time"), datetime):
            m["time"] = m["time"].isoformat()
    return {"messages": msgs}


@router.delete("/history")
async def clear_history(user=Depends(get_current_user)):
    uid = user["user_id"]
    await chat_history_col.delete_many({"user_id": uid})
    return {"status": "cleared"}