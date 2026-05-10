from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List, Optional
from schemas.case import CaseItem, CaseDetail
from schemas.base import BaseResponse
from config.database import get_db
from models.case import Case
from models.material import Material

router = APIRouter(prefix="/cases", tags=["Cases"])

@router.get("", response_model=BaseResponse[CaseItem])
async def get_cases(
    user_id: Optional[int] = Query(None, description="筛选特定用户的案件"),
    search: Optional[str] = Query(None, description="搜索关键词"),
    db: Session = Depends(get_db)
):
    query = db.query(Case) #查询Case表
    
    if user_id:
        query = query.filter(Case.user_id == user_id)
    
    if search:
        query = query.filter(
            (Case.parties.ilike(f"%{search}%")) | 
            (Case.case_type.ilike(f"%{search}%")) |
            (Case.title.ilike(f"%{search}%"))
        )
        
    cases = query.all()
    # 格式化时间为字符串以匹配 schema
    for c in cases:
        c.created_at = c.created_at.strftime("%Y-%m-%d %H:%M")
        
    return BaseResponse.success(result=cases)

@router.get("/{case_id}", response_model=BaseResponse[CaseDetail])
async def get_case_detail(case_id: int, db: Session = Depends(get_db)):
    case_obj = db.query(Case).filter(Case.id == case_id).first()
    if not case_obj:
        return BaseResponse.error(msg="案件不存在")
    
    material_stats = {
        "case": 0,
        "evidence": 0,
        "payment": 0,
        "notice": 0
    }

    materials = db.query(Material).filter(Material.case_id == case_id).all()
    for mat in materials:
        if mat.category in material_stats:
            material_stats[mat.category] += 1

    case_obj.material_stats = material_stats

    return BaseResponse.success(result=CaseDetail.from_orm(case_obj))
