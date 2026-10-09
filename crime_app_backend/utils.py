# utils.py
from datetime import datetime, timedelta
from bson import ObjectId

def time_ago_str(dt: datetime):
    now = datetime.utcnow()
    diff = now - dt
    sec = diff.total_seconds()
    if sec < 60:
        return "just now"
    if sec < 3600:
        m = int(sec//60)
        return f"{m} min ago"
    if sec < 86400:
        h = int(sec//3600)
        return f"{h} hours ago"
    days = int(sec//86400)
    return f"{days} days ago"

def compute_city_crime_rate(incidents):
    # incidents: list of dicts with 'severity' (1..5)
    if not incidents:
        return {"rate":"low","score":0}
    total = sum(i.get("severity",1) for i in incidents)
    avg = total / len(incidents)
    # thresholds - tweak as needed
    if avg >= 4.0:
        rate = "high"
    elif avg >= 2.5:
        rate = "medium"
    else:
        rate = "low"
    return {"rate": rate, "score": round(avg, 2)}
