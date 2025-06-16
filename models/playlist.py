from sqlalchemy import Column, String, ForeignKey, Table
from sqlalchemy.orm import relationship
from models.base import Base

playlist_song_table = Table(
    'playlist_songs',
    Base.metadata,
    Column('playlist_id', String, ForeignKey('playlists.id')),
    Column('song_id', String, ForeignKey('songs.id'))
)

class Playlist(Base):
    __tablename__ ='playlists'

    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    user_id = Column(String, ForeignKey('users.id'))

    user = relationship("User", back_populates="playlists")

    songs = relationship("Song", secondary=playlist_song_table, back_populates="playlists")



