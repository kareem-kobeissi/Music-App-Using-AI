from pydantic import BaseModel
from typing import Optional

class SongSchema(BaseModel):
    id: str
    song_name: str
    artist: str
    thumbnail_url: Optional[str] = None
    audio_url: Optional[str] = None
    lyrics: Optional[str] = ""
    genre: Optional[str] = None  

    class Config:
        from_attributes = True

class SongUpdate(BaseModel):
    song_name: Optional[str] = None
    artist: Optional[str] = None
    thumbnail_url: Optional[str] = None
    audio_url: Optional[str] = None
    lyrics: Optional[str] = None
    genre: Optional[str] = None  

class CardDetails(BaseModel):
    card_number: str
    card_expiry: str
    card_cvv: str    
