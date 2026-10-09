from pydantic import BaseModel, EmailStr, constr
from typing import Annotated

# Annotated type for password
PasswordStr = Annotated[str, constr(min_length=6, max_length=72)]

class UserCreate(BaseModel):
    name: str
    email: EmailStr
    password: PasswordStr  # password 6-72 chars

class LoginRequest(BaseModel):
    email: EmailStr
    password: PasswordStr  # password 6-72 chars

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
