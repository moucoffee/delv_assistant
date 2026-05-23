from langchain_core.tools import tool
from sqlalchemy.orm import Session
from config.database import get_db
from models.case import Case as CaseModel
from models.user import User
from typing import Optional
import json


@tool
def create_case_tool(
    title: str,
    parties: str,
    phone: str,
    case_type: str,
    status: str = "新建",
    amount: float = 0.0,
    description: Optional[str] = None,
    user_id: int = 1
) -> str:
    """创建新案件
    
    Args:
        title: 案件标题
        parties: 当事人
        phone: 联系电话
        case_type: 案件类型（如：刑事案件、民事案件等）
        status: 案件状态，默认为"新建"
        amount: 案件金额，默认为0.0
        description: 案件说明，可选
        user_id: 用户ID，默认为1
        
    Returns:
        创建成功的案件信息（JSON格式字符串）
    """
    from config.database import SessionLocal
    
    db = SessionLocal()
    try:
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            return json.dumps({"error": "用户不存在"}, ensure_ascii=False)
        
        new_case = CaseModel(
            user_id=user_id,
            title=title,
            parties=parties,
            phone=phone,
            case_type=case_type,
            status=status,
            amount=amount,
            description=description,
            material_count=0,
            total_file_size="0B"
        )
        
        db.add(new_case)
        db.commit()
        db.refresh(new_case)
        
        return json.dumps({
            "id": new_case.id,
            "title": new_case.title,
            "parties": new_case.parties,
            "phone": new_case.phone,
            "case_type": new_case.case_type,
            "status": new_case.status,
            "amount": float(new_case.amount) if new_case.amount else 0,
            "description": new_case.description
        }, ensure_ascii=False)
    finally:
        db.close()


@tool
def get_case_list_tool(user_id: int = 1, search: Optional[str] = None) -> str:
    """获取案件列表
    
    Args:
        user_id: 用户ID，默认为1
        search: 搜索关键词，可选（按当事人、案件类型、标题搜索）
        
    Returns:
        案件列表（JSON格式字符串）
    """
    from config.database import SessionLocal
    from models.material import Material as MaterialModel
    
    db = SessionLocal()
    try:
        query = db.query(CaseModel).filter(CaseModel.user_id == user_id)
        
        if search:
            query = query.filter(
                (CaseModel.parties.ilike(f"%{search}%")) |
                (CaseModel.case_type.ilike(f"%{search}%")) |
                (CaseModel.title.ilike(f"%{search}%"))
            )
        
        cases = query.all()
        
        result = []
        for case in cases:
            materials = db.query(MaterialModel).filter(MaterialModel.case_id == case.id).all()
            case.material_count = len(materials)
            
            result.append({
                "id": case.id,
                "title": case.title,
                "parties": case.parties,
                "phone": case.phone,
                "case_type": case.case_type,
                "status": case.status,
                "material_count": case.material_count,
                "created_at": case.created_at.strftime("%Y-%m-%d %H:%M") if case.created_at else None
            })
        
        return json.dumps(result, ensure_ascii=False)
    finally:
        db.close()


@tool
def get_case_detail_tool(case_id: int, user_id: int = 1) -> str:
    """获取案件详情
    
    Args:
        case_id: 案件ID
        user_id: 用户ID，默认为1
        
    Returns:
        案件详情（JSON格式字符串）
    """
    from config.database import SessionLocal
    from models.material import Material as MaterialModel
    
    db = SessionLocal()
    try:
        case = db.query(CaseModel).filter(
            CaseModel.id == case_id,
            CaseModel.user_id == user_id
        ).first()
        
        if not case:
            return json.dumps({"error": "案件不存在"}, ensure_ascii=False)
        
        material_stats = {
            "case": 0,
            "evidence": 0,
            "payment": 0,
            "notice": 0
        }
        
        materials = db.query(MaterialModel).filter(MaterialModel.case_id == case_id).all()
        for mat in materials:
            if mat.category in material_stats:
                material_stats[mat.category] += 1
        
        return json.dumps({
            "id": case.id,
            "title": case.title,
            "parties": case.parties,
            "phone": case.phone,
            "case_type": case.case_type,
            "status": case.status,
            "amount": float(case.amount) if case.amount else 0,
            "description": case.description,
            "material_stats": material_stats
        }, ensure_ascii=False)
    finally:
        db.close()


@tool
def update_case_tool(
    case_id: int,
    title: Optional[str] = None,
    parties: Optional[str] = None,
    phone: Optional[str] = None,
    case_type: Optional[str] = None,
    status: Optional[str] = None,
    amount: Optional[float] = None,
    description: Optional[str] = None,
    user_id: int = 1
) -> str:
    """修改案件详情
    
    Args:
        case_id: 案件ID
        title: 案件标题，可选
        parties: 当事人，可选
        phone: 联系电话，可选
        case_type: 案件类型，可选
        status: 案件状态，可选
        amount: 案件金额，可选
        description: 案件说明，可选
        user_id: 用户ID，默认为1
        
    Returns:
        修改后的案件详情（JSON格式字符串）
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
        
        if title is not None:
            case.title = title
        if parties is not None:
            case.parties = parties
        if phone is not None:
            case.phone = phone
        if case_type is not None:
            case.case_type = case_type
        if status is not None:
            case.status = status
        if amount is not None:
            case.amount = amount
        if description is not None:
            case.description = description
        
        db.commit()
        db.refresh(case)
        
        return json.dumps({
            "id": case.id,
            "title": case.title,
            "parties": case.parties,
            "phone": case.phone,
            "case_type": case.case_type,
            "status": case.status,
            "amount": float(case.amount) if case.amount else 0,
            "description": case.description
        }, ensure_ascii=False)
    finally:
        db.close()
