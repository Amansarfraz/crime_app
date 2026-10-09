from fastapi import APIRouter, HTTPException, Depends
from datetime import datetime
from pydantic import BaseModel

from database import crime_cities_col, searches_col
from auth import get_optional_user

router = APIRouter(prefix="/crime", tags=["Crime"])


def estimate_level(city: str) -> str:
    c = city.lower()
    if any(x in c for x in ["karachi", "quetta", "peshawar", "turbat", "khuzdar"]):
        return "High"
    if any(x in c for x in ["lahore", "multan", "hyderabad", "sukkur", "mardan"]):
        return "Medium"
    return "Low"


class CrimeRequest(BaseModel):
    city: str


@router.post("/crime-level")
async def get_crime_level(
    request: CrimeRequest,
    user=Depends(get_optional_user),
):
    city = request.city.strip()
    if not city:
        raise HTTPException(status_code=400, detail="City is required")

    doc = await crime_cities_col.find_one({"city_lower": city.lower()})
    if not doc:
        doc = await crime_cities_col.find_one(
            {"city_lower": {"$regex": city.lower(), "$options": "i"}}
        )

    if doc:
        matched_city = doc["city"]
        crime_index = doc.get("crime_index")
        crime_level = doc.get("crime_level", estimate_level(matched_city))
        lat = doc.get("lat")
        lng = doc.get("lng")
        province = doc.get("province", "")
        source = doc.get("source", "seed")
    else:
        matched_city = city
        crime_index = None
        crime_level = estimate_level(city)
        lat = None
        lng = None
        province = ""
        source = "fallback"

    # Save search WITH user_id (agar logged in)
    await searches_col.insert_one(
        {
            "user_id": user["user_id"] if user else None,
            "city": city,
            "matched_city": matched_city,
            "crime_index": crime_index,
            "crime_level": crime_level,
            "source": source,
            "time": datetime.utcnow(),
        }
    )

    return {
        "matched_city": matched_city,
        "crime_level": crime_level,
        "crime_index": crime_index,
        "lat": lat,
        "lng": lng,
        "province": province,
        "country": "Pakistan",
        "source": source,
    }


@router.get("/all-cities")
async def get_all_cities():
    cursor = crime_cities_col.find({}, {"_id": 0})
    cities = await cursor.to_list(length=None)
    return {"count": len(cities), "cities": cities}