from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from config.database import Base

class Case(Base):
    __tablename__ = "cases"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    
    case_type = Column(String)    # 案件类型
    status = Column(String)       # 状态
    title = Column(String)        # 案件标题
    parties = Column(String)      # 当事人
    phone = Column(String)        # 联系电话
    amount = Column(Float, default=0.0)  # 案件金额
    description = Column(String, nullable=True) # 案件说明
    
    material_count = Column(Integer, default=0)
    total_file_size = Column(String, default="0B")
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # 关联到用户
    owner = relationship("User", back_populates="cases")
