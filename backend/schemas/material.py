from pydantic import BaseModel
from typing import Optional
from datetime import datetime

# 材料基础模型
class MaterialBase(BaseModel):
    case_id: int
    category: str          # case, evidence, payment, notice
    name: str
    file_type: Optional[str] = None
    file_size: str = "0B"
    file_url: Optional[str] = None
    content: Optional[str] = None

# 创建材料请求
class MaterialCreate(MaterialBase):
    pass

# 更新材料请求
class MaterialUpdate(BaseModel):
    name: Optional[str] = None
    category: Optional[str] = None
    file_url: Optional[str] = None
    content: Optional[str] = None

# 材料详情响应
class Material(MaterialBase):
    id: int
    user_id: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True
