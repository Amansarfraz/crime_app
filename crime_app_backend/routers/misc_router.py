# routers/misc_router.py
from fastapi import APIRouter
router = APIRouter(prefix="/misc", tags=["misc"])

@router.get("/emergency-contacts")
async def emergency_contacts():
    return [
        {"name":"Police", "number":"15"},
        {"name":"Fire Brigade", "number":"16"},
        {"name":"Rescue 1122", "number":"1122"}
    ]

@router.get("/safety-tips")
async def safety_tips():
    # static tips - you said you added them manually; you can store in categories collection too
    return {
        "generic": [
            "Avoid isolated areas at night",
            "Share your live location with trusted contacts",
            "Keep emergency numbers saved"
        ]
    }
