from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime


class ChatMessageBase(BaseModel):
    content: str
    file_urls: Optional[str] = None


class ChatMessageCreate(ChatMessageBase):
    case_id: Optional[int] = None


class ChatMessage(ChatMessageBase):
    id: int
    user_id: int
    case_id: Optional[int] = None
    role: str
    created_at: datetime

    class Config:
        from_attributes = True


class ChatRequest(BaseModel):
    message: str = Field(..., description="用户输入的消息")
    case_id: Optional[int] = Field(None, description="关联的案件ID")
    file_urls: Optional[List[str]] = Field(None, description="上传的文件URL列表")
