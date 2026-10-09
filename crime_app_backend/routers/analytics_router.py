from fastapi import APIRouter, Depends
from datetime import datetime, timedelta

from database import searches_col
from auth import get_current_user

router = APIRouter(prefix="/crime", tags=["Analytics"])


@router.get("/analytics")
async def get_analytics(user=Depends(get_current_user)):
    """
    Sirf is logged-in user ki searches ka weekly/monthly trend.
    """
    uid = user["user_id"]
    now = datetime.utcnow()

    # ---------------- WEEKLY (last 7 days) ----------------
    week_start = now - timedelta(days=6)
    weekly = []
    for i in range(7):
        day = week_start + timedelta(days=i)
        day_start = datetime(day.year, day.month, day.day)
        day_end = day_start + timedelta(days=1)

        cursor = searches_col.find(
            {"user_id": uid, "time": {"$gte": day_start, "$lt": day_end}}
        )
        docs = await cursor.to_list(length=None)

        high = sum(1 for d in docs if d.get("crime_level") == "High")
        medium = sum(1 for d in docs if d.get("crime_level") == "Medium")
        low = sum(1 for d in docs if d.get("crime_level") == "Low")

        weekly.append(
            {
                "label": day_start.strftime("%a"),
                "date": day_start.strftime("%Y-%m-%d"),
                "total": len(docs),
                "high": high,
                "medium": medium,
                "low": low,
            }
        )

    # ---------------- MONTHLY (last 6 months) ----------------
    monthly = []
    year = now.year
    month = now.month
    months_seq = []
    for _ in range(6):
        months_seq.append((year, month))
        month -= 1
        if month == 0:
            month = 12
            year -= 1
    months_seq.reverse()

    for (y, m) in months_seq:
        m_start = datetime(y, m, 1)
        m_end = datetime(y + 1, 1, 1) if m == 12 else datetime(y, m + 1, 1)

        cursor = searches_col.find(
            {"user_id": uid, "time": {"$gte": m_start, "$lt": m_end}}
        )
        docs = await cursor.to_list(length=None)

        high = sum(1 for d in docs if d.get("crime_level") == "High")
        medium = sum(1 for d in docs if d.get("crime_level") == "Medium")
        low = sum(1 for d in docs if d.get("crime_level") == "Low")

        monthly.append(
            {
                "label": m_start.strftime("%b"),
                "year": y,
                "total": len(docs),
                "high": high,
                "medium": medium,
                "low": low,
            }
        )

    # ---------------- TOP CITIES (is user ke) ----------------
    top_cursor = searches_col.aggregate(
        [
            {"$match": {"user_id": uid}},
            {"$group": {"_id": "$matched_city", "count": {"$sum": 1}}},
            {"$sort": {"count": -1}},
            {"$limit": 5},
        ]
    )
    top_docs = await top_cursor.to_list(length=None)
    top_cities = [
        {"city": d["_id"] or "Unknown", "count": d["count"]} for d in top_docs
    ]

    return {
        "weekly": weekly,
        "monthly": monthly,
        "top_cities": top_cities,
        "total_searches": await searches_col.count_documents({"user_id": uid}),
    }