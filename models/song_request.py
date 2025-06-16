import uuid
from sqlalchemy import Column, String, TEXT, ForeignKey
from sqlalchemy.orm import relationship
from models.base import Base
from models.user import User

class SongRequest(Base):
    __tablename__ = 'song_requests'

    id = Column(String, primary_key=True, default=str(uuid.uuid4()))
    song_name = Column(String, nullable=False)
    user_id = Column(String, ForeignKey('users.id'), nullable=False)
    status = Column(String, default="pending")  
    
    user = relationship("User", back_populates="song_requests")
