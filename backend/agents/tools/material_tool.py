from langchain_core.tools import tool
from sqlalchemy.orm import Session
from config.database import get_db
from models.material import Material as MaterialModel
from models.case import Case as CaseModel
from typing import Optional
import json
import os


@tool
def upload_material_tool(
    case_id: int,
    name: str,
    category: str,
    file_url: Optional[str] = None,
    content: Optional[str] = None,
    file_type: Optional[str] = None,
    file_size: str = "0B",
    user_id: int = 1
) -> str:
    """上传或创建材料
    
    Args:
        case_id: 关联的案件ID
        name: 材料名称/标题
        category: 材料类别（case:案件材料, evidence:举证材料, payment:付款记录, notice:法院通知）
        file_url: 文件存储地址，可选
        content: 文本内容（对于文本或录音转文本的情况），可选
        file_type: 文件类型（png, pdf, mp3, txt等），可选
        file_size: 文件大小，默认为"0B"
        user_id: 用户ID，默认为1
        
    Returns:
        创建成功的材料信息（JSON格式字符串）
    """
    from config.database import SessionLocal
    
    db = SessionLocal()
    try:
        case = db.query(CaseModel).filter(
            CaseModel.id == case_id,
            CaseModel.user_id == user_id
        ).first()
        
        if not case:
            return json.dumps({"error": "案件不存在"}, ensure_ascii=False)
        
        new_material = MaterialModel(
            case_id=case_id,
            user_id=user_id,
            name=name,
            category=category,
            file_url=file_url,
            content=content,
            file_type=file_type,
            file_size=file_size
        )
        
        db.add(new_material)
        case.material_count = case.material_count + 1
        
        db.commit()
        db.refresh(new_material)
        db.refresh(case)
        
        return json.dumps({
            "id": new_material.id,
            "name": new_material.name,
            "category": new_material.category,
            "file_url": new_material.file_url,
            "content": new_material.content,
            "created_at": new_material.created_at.strftime("%Y-%m-%d %H:%M") if new_material.created_at else None
        }, ensure_ascii=False)
    finally:
        db.close()


@tool
def get_material_list_tool(
    case_id: int,
    category: Optional[str] = None,
    user_id: int = 1
) -> str:
    """获取某个案件的所有材料
    
    Args:
        case_id: 案件ID
        category: 按类别筛选（case, evidence, payment, notice），可选
        user_id: 用户ID，默认为1
        
    Returns:
        材料列表（JSON格式字符串）
    """
    from config.database import SessionLocal
    from models.case import Case as CaseModel
    
    db = SessionLocal()
    try:
        case = db.query(CaseModel).filter(
            CaseModel.id == case_id,
            CaseModel.user_id == user_id
        ).first()
        
        if not case:
            return json.dumps({"error": "案件不存在"}, ensure_ascii=False)
        
        query = db.query(MaterialModel).filter(MaterialModel.case_id == case_id)
        
        if category:
            query = query.filter(MaterialModel.category == category)
        
        materials = query.order_by(MaterialModel.created_at.desc()).all()
        
        result = []
        for mat in materials:
            result.append({
                "id": mat.id,
                "name": mat.name,
                "category": mat.category,
                "file_type": mat.file_type,
                "file_size": mat.file_size,
                "file_url": mat.file_url,
                "content": mat.content,
                "created_at": mat.created_at.strftime("%Y-%m-%d %H:%M") if mat.created_at else None
            })
        
        return json.dumps(result, ensure_ascii=False)
    finally:
        db.close()


@tool
def create_text_material_tool(
    case_id: int,
    name: str,
    content: str,
    category: str = "case",
    user_id: int = 1
) -> str:
    """生成并保存文本材料
    
    Args:
        case_id: 关联的案件ID
        name: 材料名称/标题
        content: 文本内容
        category: 材料类别（case:案件材料, evidence:举证材料, document:文书材料, other:其他材料），默认为case
        user_id: 用户ID，默认为1
        
    Returns:
        创建成功的材料信息（JSON格式字符串）
    """
    from config.database import SessionLocal
    
    db = SessionLocal()
    try:
        case = db.query(CaseModel).filter(
            CaseModel.id == case_id,
            CaseModel.user_id == user_id
        ).first()
        
        if not case:
            return json.dumps({"error": "案件不存在"}, ensure_ascii=False)
        
        new_material = MaterialModel(
            case_id=case_id,
            user_id=user_id,
            name=name,
            category=category,
            file_type="txt",
            file_size="0B",
            content=content
        )
        
        db.add(new_material)
        case.material_count = case.material_count + 1
        
        db.commit()
        db.refresh(new_material)
        db.refresh(case)
        
        return json.dumps({
            "id": new_material.id,
            "name": new_material.name,
            "category": new_material.category,
            "content": new_material.content,
            "created_at": new_material.created_at.strftime("%Y-%m-%d %H:%M") if new_material.created_at else None
        }, ensure_ascii=False)
    finally:
        db.close()
