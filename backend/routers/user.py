from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from schemas.user import UserInfo, LoginRequest
from schemas.base import BaseResponse
from config.database import get_db
from models.user import User
from models.case import Case
from utils.auth import (
    verify_password,
    create_access_token,
)
from utils.deps import get_current_user

router = APIRouter(prefix="/user", tags=["User"])


def get_user_info_with_case_count(user: User, db: Session, token: str = None) -> UserInfo:
    case_count = db.query(Case).filter(Case.user_id == user.id).count()
    
    user_info = UserInfo(
        id=user.id,
        username=user.username,
        phone=user.phone,
        avatar=user.avatar,
        coins=user.coins,
        trial_days=user.trial_days,
        case_count=case_count,
        token=token,
    )
    return user_info


@router.post("/login", response_model=BaseResponse[UserInfo])
async def login(
    login_data: LoginRequest,
    db: Session = Depends(get_db),
):
    """用户登录"""
    user = db.query(User).filter(User.phone == login_data.phone).first()
    
    if not user:
        return BaseResponse.error(msg="用户不存在")
    
    if not verify_password(login_data.password, user.password_hash):
        return BaseResponse.error(msg="密码错误")
    
    token = create_access_token(data={"user_id": user.id})
    
    user_info = get_user_info_with_case_count(user, db, token=token)
    
    return BaseResponse.success(result=user_info)


@router.get("/me", response_model=BaseResponse[UserInfo])
async def get_user_info(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """获取当前登录用户信息"""
    user_info = get_user_info_with_case_count(current_user, db)
    return BaseResponse.success(result=user_info)
