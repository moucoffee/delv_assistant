import string
from turtle import title
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class CaseItem(BaseModel):
    id: int
    user_id: int          # 关联的用户ID
    title: str            # 案件标题
    case_type: str        # 案件类型：刑事案件、民事案件等
    status: str           # 状态：新建、结案等
    created_at: str       # 创建时间
    parties: str          # 当事人：张某、李某；a公司等
    material_count: int   # 材料份数
    total_file_size: str  # 总文件大小：如 "15.5MB"
    phone: str            # 手机号码

    class Config:
        from_attributes = True

class CaseDetail(BaseModel):
    id: int
    user_id: int          # 关联的用户ID
    title: str            # 案件标题
    parties: str          # 当事人
    phone: str            # 联系电话
    case_type: str        # 案件类型
    status: str           # 案件状态
    amount: float         # 案件金额
    description: str      # 案件说明
    # 材料统计
    material_stats: Optional[dict] = None  # {"case": 5, "evidence": 3, "payment": 2, "notice": 1}

    class Config:
        from_attributes = True

class CaseUpdate(BaseModel):
    title: Optional[str] = None
    parties: Optional[str] = None
    phone: Optional[str] = None
    case_type: Optional[str] = None
    status: Optional[str] = None
    amount: Optional[float] = None
    description: Optional[str] = None

class CaseCreate(BaseModel):
    title: str
    parties: str
    phone: str
    case_type: str
    status: str = "新建"
    amount: float = 0.0
    description: Optional[str] = None
