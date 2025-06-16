from sqlalchemy import VARCHAR, Column, String
from sqlalchemy.orm import relationship
from models.base import Base
from models.playlist import playlist_song_table  

class Song(Base):
    __tablename__ = 'songs'

    id = Column(String, primary_key=True)
    song_name = Column(String, nullable=False)
    artist = Column(String, nullable=False)
    thumbnail_url = Column(String, nullable=True)
    lyrics = Column(String, nullable=True)
    hex_code = Column(VARCHAR(6))
    song_url = Column(String, nullable=False)  
    genre = Column(String, nullable=True)  




    playlists = relationship("Playlist", secondary=playlist_song_table, back_populates="songs")



    favorites = relationship('Favorite', back_populates='song')
