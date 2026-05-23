from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
import os
from config.database import get_db
from models.material import Material as MaterialModel
from models.case import Case as CaseModel
from schemas.material import Material, MaterialCreate, MaterialUpdate
from schemas.base import BaseResponse

router = APIRouter(prefix="/materials", tags=["材料管理"])

# 获取某个案件的所有材料
@router.get("/case/{case_id}", response_model=BaseResponse[List[Material]])
async def get_materials_by_case(
    case_id: int,
    category: str = None,  # 可选参数：按类别筛选 (case, evidence, payment, notice)
    db: Session = Depends(get_db)
):
    query = db.query(MaterialModel).filter(MaterialModel.case_id == case_id)
    if category:
        query = query.filter(MaterialModel.category == category)
    materials = query.order_by(MaterialModel.created_at.desc()).all()
    return BaseResponse.success(result=materials)

# 获取单个材料详情
@router.get("/{material_id}", response_model=BaseResponse[Material])
async def get_material_detail(material_id: int, db: Session = Depends(get_db)):
    material = db.query(MaterialModel).filter(MaterialModel.id == material_id).first()
    if not material:
        raise HTTPException(status_code=404, detail="材料不存在")
    return BaseResponse.success(result=material)

# 创建新材料 (支持文本、录音转文本、文件上传等)
@router.post("", response_model=BaseResponse[Material])
async def create_material(
    material_data: MaterialCreate,
    db: Session = Depends(get_db)
):
    # 验证案件是否存在
    case = db.query(CaseModel).filter(CaseModel.id == material_data.case_id).first()
    if not case:
        raise HTTPException(status_code=404, detail="案件不存在")

    # 创建材料
    db_material = MaterialModel(
        **material_data.model_dump(),
        user_id=case.user_id  # 自动关联到案件所属用户
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
    db: Session = Depends(get_db)
):
    material = db.query(MaterialModel).filter(MaterialModel.id == material_id).first()
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
async def delete_material(material_id: int, db: Session = Depends(get_db)):
    material = db.query(MaterialModel).filter(MaterialModel.id == material_id).first()
    if not material:
        raise HTTPException(status_code=404, detail="材料不存在")
    
    if material.file_url:
        BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        file_path = os.path.join(BASE_DIR, material.file_url.lstrip("/"))
        if os.path.exists(file_path):
            try:
                os.remove(file_path)
            except:
                pass
    
    case = db.query(CaseModel).filter(CaseModel.id == material.case_id).first()
    if case and case.material_count > 0:
        case.material_count = case.material_count - 1
    
    db.delete(material)
    db.commit()
    return BaseResponse.success(result=None, msg="删除成功")
