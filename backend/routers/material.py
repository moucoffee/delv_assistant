from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from config.database import get_db
from models.material import Material as MaterialModel
from models.case import Case as CaseModel
from models.user import User
from schemas.material import Material, MaterialCreate, MaterialUpdate
from schemas.base import BaseResponse
from utils.deps import get_current_user

router = APIRouter(prefix="/materials", tags=["材料管理"])

# 获取某个案件的所有材料
@router.get("/case/{case_id}", response_model=BaseResponse[List[Material]])
async def get_materials_by_case(
    case_id: int,
    category: str = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """获取案件的所有材料（仅当前用户的案件）"""
    case = db.query(CaseModel).filter(CaseModel.id == case_id, CaseModel.user_id == current_user.id).first()
    if not case:
        raise HTTPException(status_code=404, detail="案件不存在")
    
    query = db.query(MaterialModel).filter(MaterialModel.case_id == case_id)
    if category:
        query = query.filter(MaterialModel.category == category)
    materials = query.order_by(MaterialModel.created_at.desc()).all()
    return BaseResponse.success(result=materials)

# 获取单个材料详情
@router.get("/{material_id}", response_model=BaseResponse[Material])
async def get_material_detail(
    material_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """获取材料详情（仅当前用户的材料）"""
    material = db.query(MaterialModel).join(CaseModel).filter(
        MaterialModel.id == material_id,
        CaseModel.user_id == current_user.id
    ).first()
    if not material:
        raise HTTPException(status_code=404, detail="材料不存在")
    return BaseResponse.success(result=material)

# 创建新材料 (支持文本、录音转文本、文件上传等)
@router.post("", response_model=BaseResponse[Material])
async def create_material(
    material_data: MaterialCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """创建新材料（仅当前用户的案件）"""
    case = db.query(CaseModel).filter(CaseModel.id == material_data.case_id, CaseModel.user_id == current_user.id).first()
    if not case:
        raise HTTPException(status_code=404, detail="案件不存在")

    db_material = MaterialModel(
        **material_data.model_dump(),
        user_id=current_user.id
    )
    db.add(db_material)
    case.material_count = case.material_count + 1
    
    db.commit()
    db.refresh(db_material)
    db.refresh(case)
    
    return BaseResponse.success(result=db_material)

# 更新材料
@router.put("/{material_id}", response_model=BaseResponse[Material])
async def update_material(
    material_id: int,
    material_data: MaterialUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """更新材料（仅当前用户的材料）"""
    material = db.query(MaterialModel).join(CaseModel).filter(
        MaterialModel.id == material_id,
        CaseModel.user_id == current_user.id
    ).first()
    if not material:
        raise HTTPException(status_code=404, detail="材料不存在")
    
    update_data = material_data.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(material, key, value)
    
    db.commit()
    db.refresh(material)
    return BaseResponse.success(result=material)

# 删除材料
@router.delete("/{material_id}", response_model=BaseResponse)
async def delete_material(
    material_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """删除材料（仅当前用户的材料）"""
    material = db.query(MaterialModel).join(CaseModel).filter(
        MaterialModel.id == material_id,
        CaseModel.user_id == current_user.id
    ).first()
    if not material:
        raise HTTPException(status_code=404, detail="材料不存在")
    
    case = db.query(CaseModel).filter(CaseModel.id == material.case_id).first()
    if case and case.material_count > 0:
        case.material_count = case.material_count - 1
    
    db.delete(material)
    db.commit()
    return BaseResponse.success(result=None, msg="删除成功")
