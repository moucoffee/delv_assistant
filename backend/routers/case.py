from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List, Optional
import os
from schemas.case import CaseItem, CaseDetail, CaseUpdate, CaseCreate
from schemas.base import BaseResponse
from config.database import get_db
from models.case import Case
from models.material import Material
from models.chat import ChatMessage
from models.user import User
from utils.deps import get_current_user

router = APIRouter(prefix="/cases", tags=["案件管理"])

@router.post("", response_model=BaseResponse[CaseDetail])
async def create_case(
    case_data: CaseCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    new_case = Case(
        user_id=current_user.id,
        title=case_data.title,
        parties=case_data.parties,
        phone=case_data.phone,
        case_type=case_data.case_type,
        status=case_data.status,
        amount=case_data.amount,
        description=case_data.description,
        material_count=0,
        total_file_size="0B"
    )
    
    db.add(new_case)
    db.commit()
    db.refresh(new_case)
    
    new_case.material_stats = {
        "case": 0,
        "evidence": 0,
        "payment": 0,
        "notice": 0
    }
    return BaseResponse.success(result=CaseDetail.from_orm(new_case))

@router.get("", response_model=BaseResponse[List[CaseItem]])
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
    
    # 为每个案件计算材料数量和文件总大小
    for c in cases:
        materials = db.query(Material).filter(Material.case_id == c.id).all()
        c.material_count = len(materials)
        
        total_bytes = 0
        for mat in materials:
            size_str = mat.file_size
            if size_str.endswith('KB'):
                total_bytes += float(size_str[:-2]) * 1024
            elif size_str.endswith('MB'):
                total_bytes += float(size_str[:-2]) * 1024 * 1024
            elif size_str.endswith('GB'):
                total_bytes += float(size_str[:-2]) * 1024 * 1024 * 1024
            elif size_str.endswith('B'):
                total_bytes += float(size_str[:-1])
        
        if total_bytes >= 1024 * 1024 * 1024:
            c.total_file_size = f"{total_bytes / (1024 * 1024 * 1024):.2f}GB"
        elif total_bytes >= 1024 * 1024:
            c.total_file_size = f"{total_bytes / (1024 * 1024):.2f}MB"
        elif total_bytes >= 1024:
            c.total_file_size = f"{total_bytes / 1024:.2f}KB"
        else:
            c.total_file_size = f"{total_bytes}B"
        
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

@router.delete("/{case_id}", response_model=BaseResponse[None])
async def delete_case(
    case_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    case_obj = db.query(Case).filter(Case.id == case_id, Case.user_id == current_user.id).first()
    if not case_obj:
        raise HTTPException(status_code=404, detail="案件不存在")
    
    materials = db.query(Material).filter(Material.case_id == case_id).all()
    
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    for mat in materials:
        if mat.file_url:
            file_path = os.path.join(BASE_DIR, mat.file_url.lstrip("/"))
            if os.path.exists(file_path):
                try:
                    os.remove(file_path)
                except:
                    pass
    
    db.query(Material).filter(Material.case_id == case_id).delete()
    
    db.query(ChatMessage).filter(ChatMessage.case_id == case_id).delete()
    
    db.delete(case_obj)
    db.commit()
    
    return BaseResponse.success(result=None, msg="删除成功")
