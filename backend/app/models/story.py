from sqlalchemy import Column, String, Text, DateTime, Integer
from sqlalchemy.sql import func
from app.config.database import Base

class Story(Base):
    __tablename__ = 'stories'

    id = Column(Integer, primary_key=True, autoincrement=True, index=True)
    title = Column(String(100), nullable=False)
    surface = Column(Text, nullable=False)
    truth = Column(Text, nullable=False)
    tags = Column(Text, nullable=False)  # 存储为JSON字符串
    difficulty = Column(String(20), nullable=False)
    keywords = Column(Text, nullable=False)  # 存储为JSON字符串
    created_at = Column(DateTime(timezone=True), server_default=func.now())
