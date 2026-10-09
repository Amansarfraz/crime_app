# routers/alerts_router.py
from fastapi import APIRouter, Header
from database import searches_col
from utils import time_ago_str
from datetime import datetime

router = APIRouter(prefix="/alerts", tags=["alerts"])

@router.get("/recent-searches")
async def recent_searches(user_id: str | None = Header(None)):
    # return last 10 searches for user
    q = {"user_id": user_id} if user_id else {}
    docs = await searches_col.find(q).sort("time", -1).to_list(20)
    out = []
    for d in docs:
        out.append({
            "city": d["city"],
            "rate": d.get("rate", "low"),
            "score": d.get("score", 0),
            "time_ago": time_ago_str(d["time"])
        })
    return out
