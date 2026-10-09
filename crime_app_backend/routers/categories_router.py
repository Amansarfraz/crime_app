# from fastapi import APIRouter
# from datetime import datetime, timedelta
# from database import categories_col, incidents_col, searches_col
# from utils import compute_city_crime_rate

# router = APIRouter(prefix="/categories", tags=["categories"])


# # ===================== GET ALL CATEGORIES =====================
# @router.get("/")
# async def list_categories():
#     cats = await categories_col.find().to_list(100)
#     for c in cats:
#         c["id"] = str(c["_id"])
#     return cats


# # ===================== ADD CATEGORY =====================
# @router.post("/")
# async def add_category(cat: dict):
#     res = await categories_col.insert_one(cat)
#     return {"status": "ok", "id": str(res.inserted_id)}


# # ===================== CITY + CATEGORY DETAILS =====================
# @router.get("/{category_name}/city/{city_name}")
# async def category_city_rate(category_name: str, city_name: str):
#     """
#     ✔ Saves incident in incidents collection
#     ✔ Reads incidents
#     ✔ Calculates incident count
#     ✔ Calculates severity index
#     ✔ Calculates crime rate
#     ✔ Saves search history
#     """

#     now = datetime.utcnow()
#     cutoff = now - timedelta(days=365)

#     # =====================================================
#     # ✅ STEP 1: SAVE INCIDENT (THIS WAS MISSING ❗)
#     # =====================================================
#     incident_doc = {
#         "city": city_name,
#         "crime_type": category_name,
#         "severity": 5,          # default severity
#         "time": now,
#         "created_at": now
#     }
#     await incidents_col.insert_one(incident_doc)

#     # =====================================================
#     # ✅ STEP 2: READ INCIDENTS (FLEXIBLE QUERY)
#     # =====================================================
#     incidents = await incidents_col.find({
#         "$and": [
#             {
#                 "$or": [
#                     {"city": {"$regex": city_name, "$options": "i"}},
#                     {"city_name": {"$regex": city_name, "$options": "i"}}
#                 ]
#             },
#             {
#                 "$or": [
#                     {"crime_type": {"$regex": category_name, "$options": "i"}},
#                     {"type": {"$regex": category_name, "$options": "i"}}
#                 ]
#             },
#             {
#                 "$or": [
#                     {"time": {"$gte": cutoff}},
#                     {"created_at": {"$gte": cutoff}}
#                 ]
#             }
#         ]
#     }).to_list(3000)

#     incidents_count = len(incidents)

#     # =====================================================
#     # ✅ STEP 3: SEVERITY INDEX
#     # =====================================================
#     if incidents_count > 0:
#         severity_index = int(
#             sum(
#                 i.get("severity", i.get("severity_level", 5))
#                 for i in incidents
#             ) / incidents_count * 10
#         )
#     else:
#         severity_index = 0

#     # =====================================================
#     # ✅ STEP 4: CRIME RATE
#     # =====================================================
#     rate_data = compute_city_crime_rate(incidents)
#     crime_rate = rate_data.get("rate", 0)

#     # =====================================================
#     # ✅ STEP 5: SAFETY TIPS
#     # =====================================================
#     category = await categories_col.find_one({
#         "name": {"$regex": f"^{category_name}$", "$options": "i"}
#     })
#     safety_tips = category.get("safety_tips", []) if category else []

#     # =====================================================
#     # ✅ STEP 6: SAVE SEARCH HISTORY
#     # =====================================================
#     await searches_col.insert_one({
#         "city": city_name,
#         "crime_type": category_name,
#         "incidents_count": incidents_count,
#         "severity_index": severity_index,
#         "crime_rate": crime_rate,
#         "time": now
#     })

#     # =====================================================
#     # ✅ RESPONSE
#     # =====================================================
#     return {
#         "city": city_name,
#         "crime_type": category_name,
#         "incidents_count": incidents_count,
#         "severity_index": severity_index,
#         "crime_rate": crime_rate,
#         "safety_tips": safety_tips
#     }
from fastapi import APIRouter
from datetime import datetime, timedelta
from database import categories_col, incidents_col
from utils import compute_city_crime_rate

router = APIRouter(prefix="/categories", tags=["categories"])

# GET ALL CATEGORIES
@router.get("/")
async def list_categories():
    cats = await categories_col.find().to_list(100)
    for c in cats:
        c["id"] = str(c["_id"])
    return cats

# ADD CATEGORY
@router.post("/")
async def add_category(cat: dict):
    res = await categories_col.insert_one(cat)
    return {"status": "ok", "id": str(res.inserted_id)}

# REPORT INCIDENT / FETCH CRIME DETAILS
@router.post("/city-crime")
async def category_city_rate(city_name: str, category_name: str):
    """
    ✔ Save incident in incidents collection
    ✔ Calculate real incident count, severity index, crime rate
    ✔ Return for Flutter UI
    """

    cutoff = datetime.utcnow() - timedelta(days=365)

    # ================= GET EXISTING INCIDENTS LAST YEAR =================
    existing_incidents = await incidents_col.find({
        "$and": [
            {"city": {"$regex": f"^{city_name}$", "$options": "i"}},
            {"crime_type": {"$regex": f"^{category_name}$", "$options": "i"}},
            {"time": {"$gte": cutoff}}
        ]
    }).to_list(5000)

    incidents_count = len(existing_incidents)

    # 🧠 Severity calculation
    if incidents_count > 0:
        severity_index = int(
            sum(i.get("severity", i.get("severity_level", 5)) for i in existing_incidents) / incidents_count * 10
        )
    else:
        severity_index = 0

    # 🔹 Crime rate calculation
    rate_data = compute_city_crime_rate(existing_incidents)
    crime_rate = rate_data.get("rate", 0)

    # 💡 Fetch safety tips
    category = await categories_col.find_one({"name": {"$regex": f"^{category_name}$", "$options": "i"}})
    safety_tips = category.get("safety_tips", []) if category else []

    # ✅ Save new incident in incidents collection
    new_incident = {
        "city": city_name,
        "crime_type": category_name,
        "severity": severity_index,
        "time": datetime.utcnow()
    }
    await incidents_col.insert_one(new_incident)
    incidents_count += 1  # Add the new incident to count

    # ✅ Return to Flutter
    return {
        "city": city_name,
        "crime_type": category_name,
        "incidents_count": incidents_count,
        "severity_index": severity_index,
        "crime_rate": crime_rate,
        "safety_tips": safety_tips
    }
