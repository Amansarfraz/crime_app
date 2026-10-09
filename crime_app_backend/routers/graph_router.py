# routers/graph_router.py
from fastapi import APIRouter
from database import searches_col, incidents_col
from datetime import datetime, timedelta

router = APIRouter(prefix="/graphs", tags=["graphs"])

@router.get("/city/{city_name}")
async def city_graph(city_name: str):
    # return simple timeseries: daily average severity for last 30 days
    end = datetime.utcnow()
    start = end - timedelta(days=30)
    incidents = await incidents_col.find({"city": {"$regex": f"^{city_name}$", "$options":"i"}, "time": {"$gte": start}}).to_list(10000)
    # bucket by day
    buckets = {}
    for inc in incidents:
        d = inc["time"].date().isoformat()
        buckets.setdefault(d, []).append(inc.get("severity",1))
    series = []
    for i in range(31):
        day = (start + timedelta(days=i)).date().isoformat()
        vals = buckets.get(day, [])
        avg = round(sum(vals)/len(vals),2) if vals else 0
        series.append({"date": day, "avg_severity": avg})
    return {"city": city_name, "series": series}
