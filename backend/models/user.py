from sqlalchemy import Column, Integer, String, Float
from sqlalchemy.orm import relationship
from config.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, index=True)
    phone = Column(String, unique=True, index=True)
    password_hash = Column(String)
    avatar = Column(String, nullable=True)
    coins = Column(Integer, default=0)
    trial_days = Column(Integer, default=0)
    
    cases = relationship("Case", back_populates="owner")
    chat_messages = relationship("ChatMessage", back_populates="user", cascade="all, delete-orphan")
