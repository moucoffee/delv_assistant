from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List, Optional
from schemas.case import CaseItem, CaseDetail, CaseUpdate
from schemas.base import BaseResponse
from config.database import get_db
from models.case import Case
from models.material import Material
from models.user import User
from utils.deps import get_current_user

router = APIRouter(prefix="/cases", tags=["案件管理"])

@router.get("", response_model=BaseResponse[CaseItem])
async def get_cases(
    search: Optional[str] = Query(None, description="搜索关键词"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    query = db.query(Case).filter(Case.user_id == current_user.id)
    
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
async def get_case_detail(
    case_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    case_obj = db.query(Case).filter(Case.id == case_id, Case.user_id == current_user.id).first()
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

@router.put("/{case_id}", response_model=BaseResponse[CaseDetail])
async def update_case(
    case_id: int,
    case_data: CaseUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    case_obj = db.query(Case).filter(Case.id == case_id, Case.user_id == current_user.id).first()
    if not case_obj:
        raise HTTPException(status_code=404, detail="案件不存在")
    
    update_data = case_data.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(case_obj, key, value)
    
    db.commit()
    db.refresh(case_obj)
    
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
