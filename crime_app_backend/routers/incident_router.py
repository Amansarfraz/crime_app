from fastapi import APIRouter, HTTPException, Depends
from datetime import datetime
from pydantic import BaseModel
from typing import Optional

from database import incidents_col
from auth import get_current_user

router = APIRouter(prefix="/incidents", tags=["Incidents"])


class IncidentRequest(BaseModel):
    category: str          # Theft, Robbery, Harassment, etc.
    city: str
    description: str
    anonymous: bool = True
    lat: Optional[float] = None
    lng: Optional[float] = None


@router.post("/report")
async def report_incident(
    req: IncidentRequest,
    user=Depends(get_current_user),
):
    if not req.category.strip() or not req.city.strip():
        raise HTTPException(status_code=400, detail="Category and city required")

    doc = {
        "user_id": user["user_id"],
        "reporter": "Anonymous" if req.anonymous else user.get("email", "User"),
        "category": req.category.strip(),
        "city": req.city.strip(),
        "description": req.description.strip(),
        "lat": req.lat,
        "lng": req.lng,
        "time": datetime.utcnow(),
    }
    result = await incidents_col.insert_one(doc)

    return {"status": "reported", "id": str(result.inserted_id)}


@router.get("/feed")
async def get_feed(city: Optional[str] = None, limit: int = 50):
    """
    Saare incidents (latest pehle). Optional city filter.
    """
    query = {}
    if city:
        query["city"] = {"$regex": city, "$options": "i"}

    cursor = incidents_col.find(query).sort("time", -1).limit(limit)
    docs = await cursor.to_list(length=None)

    feed = []
    for d in docs:
        feed.append(
            {
                "id": str(d["_id"]),
                "reporter": d.get("reporter", "Anonymous"),
                "category": d.get("category", ""),
                "city": d.get("city", ""),
                "description": d.get("description", ""),
                "lat": d.get("lat"),
                "lng": d.get("lng"),
                "time": d["time"].isoformat()
                if isinstance(d.get("time"), datetime)
                else "",
            }
        )

    return {"count": len(feed), "incidents": feed}


@router.get("/my-reports")
async def my_reports(user=Depends(get_current_user)):
    """Sirf is user ki reports."""
    cursor = incidents_col.find({"user_id": user["user_id"]}).sort("time", -1)
    docs = await cursor.to_list(length=None)
    reports = []
    for d in docs:
        reports.append(
            {
                "id": str(d["_id"]),
                "category": d.get("category", ""),
                "city": d.get("city", ""),
                "description": d.get("description", ""),
                "time": d["time"].isoformat()
                if isinstance(d.get("time"), datetime)
                else "",
            }
        )
    return {"count": len(reports), "reports": reports}