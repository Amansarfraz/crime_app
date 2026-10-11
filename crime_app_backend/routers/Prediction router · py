from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from datetime import datetime, timedelta
import os
import json
import httpx

from database import crime_cities_col, searches_col, incidents_col
from auth import get_optional_user

router = APIRouter(prefix="/prediction", tags=["Prediction"])

GROQ_API_KEY = os.getenv("GROQ_API_KEY", "")
GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"
GROQ_MODEL = "llama-3.3-70b-versatile"


class PredictRequest(BaseModel):
    city: str


@router.post("/forecast")
async def forecast(req: PredictRequest, user=Depends(get_optional_user)):
    city = req.city.strip()
    if not city:
        raise HTTPException(status_code=400, detail="City required")

    # 1) Seed data se base info
    doc = await crime_cities_col.find_one({"city_lower": city.lower()})
    if not doc:
        doc = await crime_cities_col.find_one(
            {"city_lower": {"$regex": city.lower(), "$options": "i"}}
        )

    base_level = doc.get("crime_level", "Medium") if doc else "Medium"
    base_index = doc.get("crime_index") if doc else None
    matched_city = doc.get("city", city) if doc else city

    # 2) Recent community incidents (last 30 days) is city ke
    month_ago = datetime.utcnow() - timedelta(days=30)
    inc_count = await incidents_col.count_documents(
        {"city": {"$regex": city, "$options": "i"}, "time": {"$gte": month_ago}}
    )

    # incident categories breakdown
    cat_cursor = incidents_col.aggregate(
        [
            {
                "$match": {
                    "city": {"$regex": city, "$options": "i"},
                    "time": {"$gte": month_ago},
                }
            },
            {"$group": {"_id": "$category", "count": {"$sum": 1}}},
            {"$sort": {"count": -1}},
            {"$limit": 5},
        ]
    )
    cat_docs = await cat_cursor.to_list(length=None)
    top_cats = [f"{c['_id']} ({c['count']})" for c in cat_docs if c["_id"]]

    # 3) AI forecast (Groq)
    if not GROQ_API_KEY:
        # fallback bina AI
        return {
            "city": matched_city,
            "base_level": base_level,
            "base_index": base_index,
            "recent_incidents": inc_count,
            "forecast": _fallback_forecast(base_level, inc_count),
            "risk_level": base_level,
            "source": "rule-based",
        }

    context = (
        f"City: {matched_city}, Pakistan\n"
        f"Current crime level (Numbeo perception): {base_level}"
        + (f" (index {base_index}/100)" if base_index else "")
        + f"\nCommunity-reported incidents in last 30 days: {inc_count}\n"
        f"Top reported categories: {', '.join(top_cats) if top_cats else 'none'}\n"
    )

    prompt = (
        "You are a crime-risk analyst for a Pakistan safety app. Based ONLY on "
        "the data below, give a short risk forecast for the NEXT 7 days.\n\n"
        f"{context}\n"
        "Respond in STRICT JSON with keys: "
        "risk_level (one of High/Medium/Low), "
        "summary (1-2 sentences, plain), "
        "tips (array of 3 short safety tips for this city). "
        "Be clear this is an estimate based on perception + community data, "
        "not official prediction. No text outside JSON."
    )

    payload = {
        "model": GROQ_MODEL,
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.5,
        "max_tokens": 400,
        "response_format": {"type": "json_object"},
    }
    headers = {
        "Authorization": f"Bearer {GROQ_API_KEY}",
        "Content-Type": "application/json",
    }

    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            res = await client.post(GROQ_URL, json=payload, headers=headers)

        if res.status_code != 200:
            raise Exception(res.text)

        data = res.json()
        content = data["choices"][0]["message"]["content"].strip()
        ai = json.loads(content)

        return {
            "city": matched_city,
            "base_level": base_level,
            "base_index": base_index,
            "recent_incidents": inc_count,
            "risk_level": ai.get("risk_level", base_level),
            "forecast": ai.get("summary", ""),
            "tips": ai.get("tips", []),
            "source": "ai",
        }
    except Exception as e:
        # AI fail -> fallback
        return {
            "city": matched_city,
            "base_level": base_level,
            "base_index": base_index,
            "recent_incidents": inc_count,
            "risk_level": base_level,
            "forecast": _fallback_forecast(base_level, inc_count),
            "tips": [],
            "source": "rule-based",
        }


def _fallback_forecast(level: str, inc_count: int) -> str:
    trend = "rising" if inc_count > 3 else "stable"
    return (
        f"Based on current {level} crime level and {inc_count} recent "
        f"community reports, risk is expected to stay {level.lower()} "
        f"with a {trend} trend over the next 7 days. (Estimate based on "
        f"perception and community data, not official statistics.)"
    )