from fastapi import APIRouter
from pymongo import MongoClient

router = APIRouter()

client = MongoClient("mongodb://localhost:27017")
db = client["crimeDB"]
collection = db["crimes"]

@router.get("/heatmap/{city}")
def get_heatmap(city: str):

    crimes = collection.find({
        "city": {"$regex": city, "$options": "i"}
    })

    heatmap_data = []

    for crime in crimes:
        heatmap_data.append({
            "lat": crime["location"]["lat"],
            "lng": crime["location"]["lng"],
            "weight": crime.get("crime_count", 1)
        })

    return heatmap_data