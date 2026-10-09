from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta
import os
from dotenv import load_dotenv

from fastapi import Depends, HTTPException, Request

load_dotenv()

SECRET_KEY = os.getenv("SECRET_KEY", "secret")
ALGORITHM = os.getenv("ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "120"))

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


# ---------- PASSWORD HASHING ----------
def hash_password(password: str) -> str:
    safe_password = password.encode("utf-8")[:72]
    return pwd_context.hash(safe_password)


def verify_password(plain: str, hashed: str) -> bool:
    safe_password = plain.encode("utf-8")[:72]
    return pwd_context.verify(safe_password, hashed)


# ---------- JWT TOKEN ----------
def create_access_token(data: dict, expires_delta: int | None = None):
    to_encode = data.copy()
    expire_time = (
        timedelta(minutes=expires_delta)
        if expires_delta
        else timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    expire = datetime.utcnow() + expire_time
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


def decode_token(token: str):
    try:
        return jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    except JWTError as e:
        print("DECODE ERROR:", e)
        return None


# ---------- helper: request se token nikaalo ----------
def _extract_token(request: Request) -> str | None:
    auth = request.headers.get("Authorization") or request.headers.get(
        "authorization"
    )
    print("AUTH HEADER RECEIVED:", auth)  # debug
    if not auth:
        return None
    parts = auth.split()
    if len(parts) == 2 and parts[0].lower() == "bearer":
        return parts[1].strip()
    # agar sirf token bheja (bina Bearer)
    if len(parts) == 1:
        return parts[0].strip()
    return None


# ---------- CURRENT USER (required) ----------
async def get_current_user(request: Request):
    token = _extract_token(request)
    if not token:
        raise HTTPException(status_code=401, detail="No token provided")

    payload = decode_token(token)
    if payload is None or "user_id" not in payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    return {"user_id": payload["user_id"], "email": payload.get("email", "")}


# ---------- OPTIONAL USER (guest allowed) ----------
async def get_optional_user(request: Request):
    token = _extract_token(request)
    if not token:
        return None
    payload = decode_token(token)
    if payload is None or "user_id" not in payload:
        return None
    return {"user_id": payload["user_id"], "email": payload.get("email", "")}