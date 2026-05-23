from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session
from typing import List, Optional
import json
from datetime import datetime

from config.database import get_db
from models.chat import ChatMessage as ChatMessageModel
from models.chat import MessageRole
from models.user import User
from schemas.chat import ChatMessage, ChatRequest
from schemas.base import BaseResponse
from utils.deps import get_current_user
from agents.lawyer_agent import agent
from langchain_core.runnables import RunnableConfig

router = APIRouter(prefix="/chat", tags=["AI聊天"])


@router.get("/messages", response_model=BaseResponse[List[ChatMessage]])
async def get_chat_messages(
    case_id: Optional[int] = None,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """获取聊天消息列表"""
    query = db.query(ChatMessageModel).filter(
        ChatMessageModel.user_id == user.id
    )
    
    if case_id:
        query = query.filter(ChatMessageModel.case_id == case_id)
    
    messages = query.order_by(ChatMessageModel.created_at.asc()).all()
    return BaseResponse.success(result=messages)


async def generate_stream(user_id: int, user_message: str, case_id: Optional[int] = None, file_urls_str: Optional[str] = None):
    from config.database import SessionLocal
    db = SessionLocal()
    
    try:
        config: RunnableConfig = {
            "configurable": {
                "thread_id": str(user_id),
            }
        }
        
        full_content = ""
        
        async for chunk in agent.astream(
            {"messages": [("user", user_message)]},
            config=config,
        ):
            if "model" in chunk and "messages" in chunk["model"]:
                for msg in chunk["model"]["messages"]:
                    if hasattr(msg, "content") and msg.content:
                        full_content += msg.content
                        yield f"data: {json.dumps({'content': msg.content}, ensure_ascii=False)}\n\n"
        
        assistant_message = ChatMessageModel(
            user_id=user_id,
            case_id=case_id,
            role=MessageRole.ASSISTANT,
            content=full_content
        )
        db.add(assistant_message)
        db.commit()
        
        yield "data: [DONE]\n\n"
        
    finally:
        db.close()


@router.post("/message")
async def send_chat_message(
    request: ChatRequest,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """发送聊天消息（非流式）"""
    user_message = ChatMessageModel(
        user_id=user.id,
        case_id=request.case_id,
        role=MessageRole.USER,
        content=request.message,
        file_urls=json.dumps(request.file_urls, ensure_ascii=False) if request.file_urls else None
    )
    db.add(user_message)
    db.commit()
    
    config: RunnableConfig = {
        "configurable": {
            "thread_id": str(user.id),
        }
    }
    
    result = await agent.ainvoke(
        {"messages": [("user", request.message)]},
        config=config,
    )
    
    ai_content = result["messages"][-1].content
    
    assistant_message = ChatMessageModel(
        user_id=user.id,
        case_id=request.case_id,
        role=MessageRole.ASSISTANT,
        content=ai_content
    )
    db.add(assistant_message)
    db.commit()
    
    return BaseResponse.success(result={
        "message": ai_content
    })


@router.post("/message/stream")
async def send_chat_message_stream(
    request: ChatRequest,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """发送聊天消息（流式输出）"""
    user_message = ChatMessageModel(
        user_id=user.id,
        case_id=request.case_id,
        role=MessageRole.USER,
        content=request.message,
        file_urls=json.dumps(request.file_urls, ensure_ascii=False) if request.file_urls else None
    )
    db.add(user_message)
    db.commit()
    
    file_urls_str = json.dumps(request.file_urls, ensure_ascii=False) if request.file_urls else None
    
    return StreamingResponse(
        generate_stream(user.id, request.message, request.case_id, file_urls_str),
        media_type="text/event-stream"
    )
