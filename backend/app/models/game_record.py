from sqlalchemy import Column, String, Integer, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.config.database import Base

class GameRecord(Base):
    __tablename__ = 'game_records'

    id = Column(String(50), primary_key=True, index=True)
    user_id = Column(String(50), nullable=False)  # 暂时用匿名ID
    story_id = Column(String(50), ForeignKey('stories.id'), nullable=False)
    questions_used = Column(Integer, nullable=False)
    hints_used = Column(Integer, nullable=False)
    result = Column(String(20), nullable=False)  # 胜利/失败/放弃
    time_used = Column(Integer, nullable=False)  # 游戏时长（秒）
    created_at = Column(DateTime(timezone=True), server_default=func.now())
