from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from schemas.user import UserInfo
from schemas.base import BaseResponse
from config.database import get_db
from models.user import User

router = APIRouter(prefix="/user", tags=["User"])

@router.get("/me", response_model=BaseResponse[UserInfo])
async def get_user_info(db: Session = Depends(get_db)):
    # 暂时默认获取第一个用户（模拟当前登录用户）
    user = db.query(User).first()
    if not user:
        return BaseResponse.error(msg="用户不存在")
    
    # 转换成 UserInfo schema
    return BaseResponse.success(result=[UserInfo.from_orm(user)])
