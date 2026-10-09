from pydantic import BaseModel
from typing import Optional, List

class Category(BaseModel):
    name: str
    description: Optional[str] = None
    safety_tips: List[str] = []
