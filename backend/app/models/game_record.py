from sqlalchemy import Column, String, Integer, DateTime, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.config.database import Base

class GameRecord(Base):
    __tablename__ = 'game_records'

    id = Column(String(50), primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    story_id = Column(Integer, ForeignKey('stories.id'), nullable=False)
    questions_used = Column(Integer, nullable=False)
    hints_used = Column(Integer, nullable=False)
    result = Column(String(20), nullable=False)
    time_used = Column(Integer, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship('User', backref='game_records')
    story = relationship('Story', backref='game_records')
