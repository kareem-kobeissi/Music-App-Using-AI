from fastapi import Depends, FastAPI
from database import engine, get_db
from models.base import Base
from models.song import Song
from pydantic_schemas.schemas import SongSchema
from sqlalchemy.orm import Session
from routes.auth import router as auth_router  
from routes.song import router as song_router  

app = FastAPI()

app.include_router(auth_router, prefix="/auth", tags=["auth"])# # Include the auth router
app.include_router(song_router, prefix="/song", tags=["song"])# # Include the song router

#  Fetch a single song by ID
@app.get("/songs/{song_id}", response_model=SongSchema)
def get_song(song_id: str, db: Session = Depends(get_db)):
    song = db.query(Song).filter(Song.id == song_id).first()
    if not song:
        return {"error": "Song not found"}
    return song  

#  Fetch all songs
@app.get("/songs", response_model=list[SongSchema])
def get_songs(db: Session = Depends(get_db)):
    songs = db.query(Song).all()
    return songs #list of songs 

#  Ensures that all database tables defined in the models are created when the application starts.
Base.metadata.create_all(engine)
