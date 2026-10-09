from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from routers import (
    auth_router,
    crime_router,
    categories_router,
    alerts_router,
    map_routes,
    misc_router,
    graph_router,
    user_router,
    assistant_router,
    analytics_router,
    digest_router,
    incident_router,
)

app = FastAPI(title="Crime Alert Backend")

# -------- CORS --------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -------- ROUTERS --------
app.include_router(auth_router.router)
app.include_router(crime_router.router)
app.include_router(categories_router.router)
app.include_router(alerts_router.router)
app.include_router(misc_router.router)
app.include_router(graph_router.router)
app.include_router(user_router.router)
app.include_router(assistant_router.router)
app.include_router(analytics_router.router)
app.include_router(digest_router.router)
app.include_router(incident_router.router)

# HEATMAP ROUTER
app.include_router(map_routes.router, prefix="/map")


@app.get("/")
def root():
    return {"message": "Crime Alert API running"}