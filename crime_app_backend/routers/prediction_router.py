from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from datetime import datetime, timedelta
import os
import json
import random
import httpx

from database import crime_cities_col, searches_col, incidents_col
from auth import get_optional_user

router = APIRouter(prefix="/prediction", tags=["Prediction"])

GROQ_API_KEY = os.getenv("GROQ_API_KEY", "")
GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"
GROQ_MODEL = "llama-3.3-70b-versatile"

DAYS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]


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

    # category breakdown (percentages ke liye)
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
            {"$limit": 6},
        ]
    )
    cat_docs = await cat_cursor.to_list(length=None)
    total_cat = sum(c["count"] for c in cat_docs) or 1
    categories = [
        {
            "name": (c["_id"] or "Other"),
            "count": c["count"],
            "percent": round(c["count"] * 100 / total_cat),
        }
        for c in cat_docs
        if c["_id"]
    ]
    top_cats = [f"{c['name']} ({c['count']})" for c in categories]

    # 7-day risk chart base (0-100 numbers)
    daily = _build_daily(base_level, inc_count)

    # 3) AI forecast (Groq)
    if not GROQ_API_KEY:
        return {
            "city": matched_city,
            "base_level": base_level,
            "base_index": base_index,
            "recent_incidents": inc_count,
            "risk_level": base_level,
            "forecast": _fallback_forecast(base_level, inc_count),
            "tips": _fallback_tips(base_level),
            "categories": categories,
            "daily": daily,
            "peak_day": _peak_day(daily),
            "safest_time": _safe_time(base_level),
            "source": "rule-based",
        }

    context = (
        f"City: {matched_city}, Pakistan\n"
        f"Current crime level (Numbeo perception): {base_level}"
        + (f" (index {base_index}/100)" if base_index else "")
        + f"\nCommunity-reported incidents in last 30 days: {inc_count}\n"
        f"Top reported categories: {', '.join(top_cats) if top_cats else 'none reported'}\n"
    )

    prompt = (
        "You are a crime-risk analyst for a Pakistan safety app. Based ONLY on "
        "the data below, give a detailed risk forecast for the NEXT 7 days.\n\n"
        f"{context}\n"
        "Respond in STRICT JSON with these keys:\n"
        "risk_level: one of High/Medium/Low\n"
        "summary: 2-3 sentences, plain language, what to expect this week\n"
        "trend: one of 'rising'/'stable'/'falling'\n"
        "peak_day: the weekday most risky (Mon..Sun)\n"
        "safest_time: short phrase e.g. 'Morning 6am-10am'\n"
        "high_risk_areas: array of up to 3 short area/behavior notes\n"
        "tips: array of 4 short, specific safety tips for this city\n"
        "Be clear this is an estimate from perception + community data, "
        "not official prediction. Output ONLY the JSON object."
    )

    payload = {
        "model": GROQ_MODEL,
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.5,
        "max_tokens": 700,
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

        risk = ai.get("risk_level", base_level)
        # agar AI risk base se mukhtalif ho to daily chart usi hisaab se
        daily = _build_daily(risk, inc_count, peak=ai.get("peak_day"))

        return {
            "city": matched_city,
            "base_level": base_level,
            "base_index": base_index,
            "recent_incidents": inc_count,
            "risk_level": risk,
            "forecast": ai.get("summary", ""),
            "trend": ai.get("trend", "stable"),
            "peak_day": ai.get("peak_day", _peak_day(daily)),
            "safest_time": ai.get("safest_time", _safe_time(risk)),
            "high_risk_areas": ai.get("high_risk_areas", []),
            "tips": ai.get("tips", []),
            "categories": categories,
            "daily": daily,
            "source": "ai",
        }
    except Exception:
        return {
            "city": matched_city,
            "base_level": base_level,
            "base_index": base_index,
            "recent_incidents": inc_count,
            "risk_level": base_level,
            "forecast": _fallback_forecast(base_level, inc_count),
            "trend": "stable",
            "peak_day": _peak_day(daily),
            "safest_time": _safe_time(base_level),
            "high_risk_areas": [],
            "tips": _fallback_tips(base_level),
            "categories": categories,
            "daily": daily,
            "source": "rule-based",
        }


# ---------------- helpers ----------------
def _base_score(level: str) -> int:
    return {"High": 75, "Medium": 50, "Low": 28}.get(level, 50)


def _build_daily(level: str, inc_count: int, peak: str | None = None):
    """7 din ke liye risk score (0-100) + weekday. Chart ke liye."""
    base = _base_score(level)
    bump = min(inc_count * 2, 20)  # zyada reports -> thoda upar
    base = min(base + bump, 95)

    # weekend par thoda zyada risk (typical pattern)
    peak = (peak or "Sat")[:3].title()
    out = []
    for i, d in enumerate(DAYS):
        v = base
        if d in ("Fri", "Sat"):
            v += 8
        if d == "Sun":
            v += 4
        if d == peak:
            v += 6
        v += random.randint(-4, 4)
        v = max(5, min(98, v))
        out.append({"day": d, "score": int(v)})
    return out


def _peak_day(daily):
    if not daily:
        return "Sat"
    return max(daily, key=lambda x: x["score"])["day"]


def _safe_time(level: str) -> str:
    return "Morning 7am–11am" if level != "Low" else "Daytime"


def _fallback_tips(level: str):
    common = [
        "Share your live location with family when traveling at night.",
        "Avoid displaying phones, cash or jewelry in crowded areas.",
        "Prefer well-lit, busy roads over shortcuts and empty streets.",
        "Keep emergency numbers (15 Police, 1122) on speed dial.",
    ]
    return common


def _fallback_forecast(level: str, inc_count: int) -> str:
    trend = "rising" if inc_count > 3 else "stable"
    return (
        f"Based on the current {level} crime level and {inc_count} recent "
        f"community reports, risk is expected to stay {level.lower()} "
        f"with a {trend} trend over the next 7 days. Street crime and "
        f"snatching are the most common concerns. This is an estimate based on "
        f"perception and community data, not official statistics."
    )