from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import List
from datetime import datetime
from pydantic import BaseModel

# ----------------- Models -----------------
class CityLevel(BaseModel):
    city: str
    level: str  # High / Medium / Low

class RecentSearch(CityLevel):
    searched_at: datetime

# ----------------- In-memory Data -----------------
crime_data = {
    "karachi": 8.5,
    "lahore": 5.2,
    "islamabad": 3.6,
    "peshawar": 6.0,
    "quetta": 7.0,
}

recent_searches: List[dict] = []

# ----------------- Backend Functions -----------------
def get_crime_level_backend(city_name: str) -> CityLevel:
    city_lower = city_name.lower()
    rate = crime_data.get(city_lower)
    if rate is None:
        raise ValueError("City not found")

    if rate >= 7:
        level = "High"
    elif rate >= 4:
        level = "Medium"
    else:
        level = "Low"

    recent_searches.append({"city": city_name, "level": level, "searched_at": datetime.utcnow()})
    if len(recent_searches) > 10:
        recent_searches.pop(0)

    return CityLevel(city=city_name, level=level)

def get_recent_searches_backend() -> List[RecentSearch]:
    return [RecentSearch(city=s["city"], level=s["level"], searched_at=s["searched_at"]) for s in recent_searches]

# ----------------- FastAPI App -----------------
app = FastAPI(title="Crime Rate Backend")

# ----------------- CORS -----------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Flutter app origin, "*" for testing
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ----------------- Routes -----------------
@app.get("/crime/{city}", response_model=CityLevel)
def get_city_crime(city: str):
    try:
        return get_crime_level_backend(city)
    except ValueError:
        raise HTTPException(status_code=404, detail="City not found")

@app.get("/crime/recent", response_model=List[RecentSearch])
def recent_searches_route():
    return get_recent_searches_backend()
