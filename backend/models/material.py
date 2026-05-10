from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from config.database import Base

class Material(Base):
    __tablename__ = "materials"

    id = Column(Integer, primary_key=True, index=True)
    case_id = Column(Integer, ForeignKey("cases.id"))  # 关联的案件ID
    user_id = Column(Integer, ForeignKey("users.id"))  # 关联的用户ID

    # 材料类型：case(案件材料), evidence(举证材料), payment(付款记录), notice(法院通知)
    category = Column(String, index=True) 
    
    # 材料基本信息
    name = Column(String)                    # 材料名称/标题
    file_type = Column(String, nullable=True) # 文件类型 (png, pdf, mp3, txt 等)
    file_size = Column(String, default="0B") # 文件大小
    file_url = Column(String, nullable=True)  # 文件存储地址 (OSS 或本地路径)
    
    # 内容字段 (对于文本或录音转文本的情况)
    content = Column(Text, nullable=True)
    
    # 时间戳
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # 关联关系
    case = relationship("Case")
    owner = relationship("User")
