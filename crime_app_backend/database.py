from motor.motor_asyncio import AsyncIOMotorClient
import os
from dotenv import load_dotenv

load_dotenv()

MONGO_URL = os.getenv("MONGO_URL", "mongodb://localhost:27017")
client = AsyncIOMotorClient(MONGO_URL)
db = client["crime_alert_db"]

# Collections
users_col = db["users"]
incidents_col = db["incidents"]         # each reported incident
categories_col = db["categories"]       # crime categories + tips
searches_col = db["searches"]           # user search history (city, time, result)
alerts_col = db["alerts"]               # alerts (if you send push alerts)
settings_col = db["settings"]           # per-user settings (if needed)
crime_cities_col = db["crime_cities"]   # seeded Pakistan cities + crime index + coords
chat_history_col = db["chat_history"]   # AI assistant chat (per user, 7-day TTL)