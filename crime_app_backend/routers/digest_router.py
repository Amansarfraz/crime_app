from fastapi import APIRouter
from datetime import datetime, timedelta

from database import searches_col, crime_cities_col

router = APIRouter(prefix="/digest", tags=["Digest"])


@router.get("/trending")
async def trending_unsafe_zones():
    """
    Trending unsafe zones:
    - Pichhle 7 din me sabse zyada search hui High/Medium crime cities
    - Agar searches kam hon to seed data se top High-crime cities
    """
    week_ago = datetime.utcnow() - timedelta(days=7)

    # 1) Recent searches se trending (High/Medium)
    cursor = searches_col.aggregate(
        [
            {
                "$match": {
                    "time": {"$gte": week_ago},
                    "crime_level": {"$in": ["High", "Medium"]},
                }
            },
            {
                "$group": {
                    "_id": "$matched_city",
                    "count": {"$sum": 1},
                    "level": {"$first": "$crime_level"},
                }
            },
            {"$sort": {"count": -1}},
            {"$limit": 5},
        ]
    )
    trending = await cursor.to_list(length=None)

    result = [
        {
            "city": t["_id"] or "Unknown",
            "level": t.get("level", "Medium"),
            "searches": t["count"],
        }
        for t in trending
        if t["_id"]
    ]

    # 2) Agar recent searches kam -> seed data se top High crime cities
    if len(result) < 5:
        existing = {r["city"].lower() for r in result}
        seed_cursor = crime_cities_col.find(
            {"crime_level": {"$in": ["High", "Medium"]}},
            {"_id": 0, "city": 1, "crime_level": 1, "crime_index": 1},
        ).sort("crime_index", -1)
        seed_cities = await seed_cursor.to_list(length=None)

        for c in seed_cities:
            if len(result) >= 5:
                break
            if c["city"].lower() in existing:
                continue
            result.append(
                {
                    "city": c["city"],
                    "level": c["crime_level"],
                    "searches": 0,
                }
            )
            existing.add(c["city"].lower())

    return {"trending": result, "date": datetime.utcnow().strftime("%Y-%m-%d")}