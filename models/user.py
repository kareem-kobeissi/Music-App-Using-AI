from sqlalchemy.orm import relationship
from sqlalchemy import Column, TEXT, VARCHAR, LargeBinary, String
from models.base import Base

class User(Base):
    __tablename__ = 'users'

    id = Column(TEXT, primary_key=True)
    name = Column(VARCHAR(100))
    email = Column(VARCHAR(100), unique=True, index=True)
    password = Column(LargeBinary)
    role = Column(VARCHAR(20), default="user")
    reset_code = Column(String, nullable=True)
    card_number = Column(String, nullable=True)
    card_expiry = Column(String, nullable=True)
    card_cvv = Column(String, nullable=True)

    

    playlists = relationship("Playlist", back_populates="user", cascade="all, delete")
    favorites = relationship("Favorite", back_populates="user")
    subscriptions = relationship("UserSubscription", back_populates="user")
    song_requests = relationship("SongRequest", back_populates="user")

