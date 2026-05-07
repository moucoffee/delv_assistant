from pydantic import BaseModel
from typing import Optional

class UserInfo(BaseModel):
    id: int
    username: str
    phone: str
    avatar: Optional[str] = None
    coins: int = 0
    trial_days: int = 0
    case_count: int = 0

    class Config:
        from_attributes = True
