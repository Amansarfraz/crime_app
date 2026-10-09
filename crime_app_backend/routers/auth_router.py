from fastapi import APIRouter, HTTPException
from database import users_col
from auth import hash_password, verify_password, create_access_token
from models.user_model import UserCreate, LoginRequest, Token
from datetime import datetime

router = APIRouter(prefix="/auth", tags=["Auth"])

# ---------- SIGNUP ----------
@router.post("/signup", response_model=Token)
async def signup(user: UserCreate):
    email = user.email.lower()

    # Check if email already exists
    try:
        existing = await users_col.find_one({"email": email})
    except Exception as e:
        print("MongoDB Find Error:", e)
        raise HTTPException(status_code=500, detail=f"DB Find Error: {e}")

    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")

    # Hash password (truncate bytes in hash_password function)
    try:
        hashed = hash_password(user.password)
    except Exception as e:
        print("Password Hashing Error:", e)
        raise HTTPException(status_code=500, detail=f"Password Hashing Error: {e}")

    # Insert user in DB
    try:
        res = await users_col.insert_one({
            "name": user.name,
            "email": email,
            "password": hashed,
            "created_at": datetime.utcnow()
        })
    except Exception as e:
        print("DB Insert Exception:", e)
        raise HTTPException(status_code=500, detail=f"DB Insert Error: {e}")

    # Generate JWT token
    try:
        token = create_access_token({
            "user_id": str(res.inserted_id),
            "email": email
        })
    except Exception as e:
        print("Token Creation Exception:", e)
        raise HTTPException(status_code=500, detail=f"Token Creation Error: {e}")

    print("Signup successful for:", email)
    return {
        "access_token": token,
        "token_type": "bearer"
    }


# ---------- LOGIN ----------
@router.post("/login", response_model=Token)
async def login(form: LoginRequest):
    email = form.email.lower()

    # Fetch user
    try:
        user = await users_col.find_one({"email": email})
    except Exception as e:
        print("MongoDB Find Error:", e)
        raise HTTPException(status_code=500, detail=f"DB Find Error: {e}")

    if not user:
        raise HTTPException(status_code=401, detail="User not found")

    # Verify password
    try:
        if not verify_password(form.password, user["password"]):
            raise HTTPException(status_code=401, detail="Invalid password")
    except HTTPException:
        raise
    except Exception as e:
        print("Password Verification Error:", e)
        raise HTTPException(status_code=500, detail=f"Password Verification Error: {e}")

    # Generate JWT token
    try:
        token = create_access_token({
            "user_id": str(user["_id"]),
            "email": email
        })
    except Exception as e:
        print("Token Creation Exception:", e)
        raise HTTPException(status_code=500, detail=f"Token Creation Error: {e}")

    print("Login successful for:", email)
    return {
        "access_token": token,
        "token_type": "bearer"
    }
