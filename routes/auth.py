from datetime import datetime, timedelta
import random
import string
from typing import List, Optional
import uuid
import bcrypt
from fastapi import Depends, HTTPException, APIRouter
from fastapi.responses import JSONResponse
import jwt
from database import get_db
from middleware.auth_middleware import auth_middleware
from models.playlist import Playlist
from models.song import Song
from models.song_request import SongRequest
from models.subscription_plans import SubscriptionPlan
from models.user_subscriptions import UserSubscription
from models.user import User
from pydantic_schemas.schemas import CardDetails, SongSchema, SongUpdate
from pydantic_schemas.user_create import UserCreate
from sqlalchemy.orm import Session
from pydantic_schemas.user_login import UserLogin
from sqlalchemy.orm import joinedload
from utils.email import send_reset_email
from pydantic import BaseModel
from rapidfuzz import process


#RapidFuzz is used here to find the best matching song name from a list of available songs based on the user's voice command. 
#If the similarity score is high enough, it returns the matched song.
# python libraries


router = APIRouter()


VALID_GENRES = ["happy", "sad", "rock", "love"]

@router.get("/recommend-songs")
def recommend_songs_by_genre(
    genre: str,  # Genre passed from the frontend
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware),
    limit: Optional[int] = 10,  # Optional parameter to limit the number of results
    offset: Optional[int] = 0   # Optional parameter to offset results for pagination
):
    # Normalize genre to lowercase and validate it
    genre = genre.strip().lower()

    if genre not in VALID_GENRES:
        raise HTTPException(status_code=400, detail=f"Invalid genre '{genre}' provided. Valid genres are: {', '.join(VALID_GENRES)}")

    # Fetch songs from the database that match the genre, with pagination
    songs = db.query(Song).filter(Song.genre == genre).offset(offset).limit(limit).all()

    if not songs:
        raise HTTPException(status_code=404, detail=f"No songs found for genre '{genre}'.")

    # Return the list of recommended songs
    return {
        "recommended_songs": [
            {
                "id": song.id,
                "song_name": song.song_name,
                "artist": song.artist,
                "thumbnail_url": song.thumbnail_url or 'https://via.placeholder.com/150',  # Use a placeholder if no thumbnail
                "song_url": song.song_url,
                "genre": song.genre,
            }
            for song in songs
        ]
    }




@router.put("/admin/reject-song-request/{request_id}")
def reject_song_request(
    request_id: str,
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware)
):
    # Only allow admins to reject requests
    admin = db.query(User).filter(User.id == user_dict["uid"]).first()
    if not admin or admin.role != "admin":
        raise HTTPException(status_code=403, detail="Only admins can reject song requests!")

    # Fetch the song request by ID
    song_request = db.query(SongRequest).filter(SongRequest.id == request_id).first()
    if not song_request:
        raise HTTPException(status_code=404, detail="Song request not found")

    # Reject the song request (set status to "pending" or "rejected")
    song_request.status = "pending"  # You can set it to whatever status you need (pending or rejected)
    db.commit()

    return {"message": "Song request rejected successfully!"}


class SongRequestCreate(BaseModel):
    song_name: str

@router.post("/request-song")
def request_song(
    song_data: SongRequestCreate, 
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware)
):
    if not song_data.song_name:
        raise HTTPException(status_code=400, detail="Song name is required")

    # Generate a unique ID for the new song request
    song_request_id = str(uuid.uuid4())

    # Create the song request
    song_request = SongRequest(
        id=song_request_id,  # Ensure this is unique
        song_name=song_data.song_name,
        user_id=user_dict["uid"],
        status="pending"
    )

    try:
        db.add(song_request)
        db.commit()
        db.refresh(song_request)
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error adding song request: {str(e)}")

    return {"message": "Your song request has been submitted successfully!"}

@router.get("/user-song-requests")
def get_user_song_requests(
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware)
):
    # Fetch song requests for the currently authenticated user
    song_requests = db.query(SongRequest).filter(SongRequest.user_id == user_dict["uid"]).all()

    return [
        {
            "id": request.id,
            "song_name": request.song_name,
            "status": request.status,
        }
        for request in song_requests
    ]
@router.get("/admin/song-requests")
def get_admin_song_requests(
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware)
):
    # Only allow admin to view requests
    admin = db.query(User).filter(User.id == user_dict["uid"]).first()
    if not admin or admin.role != "admin":
        raise HTTPException(status_code=403, detail="Only admins can view song requests!")

    song_requests = db.query(SongRequest).all()

    return [
        {
            "id": request.id,
            "song_name": request.song_name,
            "status": request.status,
        }
        for request in song_requests
    ]

@router.put("/admin/confirm-song-request/{request_id}")
def confirm_song_request(
    request_id: str,
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware)
):
    # Only allow admin to confirm requests
    admin = db.query(User).filter(User.id == user_dict["uid"]).first()
    if not admin or admin.role != "admin":
        raise HTTPException(status_code=403, detail="Only admins can confirm song requests!")

    song_request = db.query(SongRequest).filter(SongRequest.id == request_id).first()
    if not song_request:
        raise HTTPException(status_code=404, detail="Song request not found")

    song_request.status = "approved"
    db.commit()

    return {"message": "Song request confirmed successfully!"}

@router.get("/admin/song-requests")
def get_song_requests(
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware)
):
    # Only allow admin to view requests
    admin = db.query(User).filter(User.id == user_dict["uid"]).first()
    if not admin or admin.role != "admin":
        raise HTTPException(status_code=403, detail="Only admins can view song requests!")

    song_requests = db.query(SongRequest).all()

    return [
        {
            "id": request.id,
            "song_name": request.song_name,
            "user_name": request.user.name,
            "status": request.status,
        }
        for request in song_requests
    ]

@router.put("/admin/approve-song-request/{request_id}")
def approve_song_request(
    request_id: str,
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware)
):
    # Only allow admin to approve requests
    admin = db.query(User).filter(User.id == user_dict["uid"]).first()
    if not admin or admin.role != "admin":
        raise HTTPException(status_code=403, detail="Only admins can approve song requests!")

    song_request = db.query(SongRequest).filter(SongRequest.id == request_id).first()
    if not song_request:
        raise HTTPException(status_code=404, detail="Song request not found")

    song_request.status = "approved"
    db.commit()

    return {"message": "Song request approved!"}


class ResetPasswordRequest(BaseModel):
    email: str
    reset_code: str
    new_password: str

@router.post("/reset-password")
def reset_password(request: ResetPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == request.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Verify the reset code
    if user.reset_code != request.reset_code:
        raise HTTPException(status_code=400, detail="Invalid reset code")

    # Ensure the new password is at least 5 characters long
    if len(request.new_password) < 5:
        raise HTTPException(status_code=400, detail="New password must be at least 5 characters long")

    # Hash and update new password
    hashed_pw = bcrypt.hashpw(request.new_password.encode(), bcrypt.gensalt())
    user.password = hashed_pw
    db.commit()

    return {"message": "✅ Password reset successfully"}

class ForgotPasswordRequest(BaseModel):
    email: str

@router.post("/forgot-password")
def forgot_password(request: ForgotPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == request.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Generate random 6-digit code
    reset_code = ''.join(random.choices(string.digits, k=6))

    # Save code in DB
    user.reset_code = reset_code
    db.commit()

    # Send it via email
    try:
        send_reset_email(user.email, reset_code)
    except Exception as e:
        print(f"Error sending email: {e}")
        raise HTTPException(status_code=500, detail="Error sending email")

    return {"message": "Reset code sent to your email"}


class UpdateProfileRequest(BaseModel):
    name: str
    email: str

@router.put("/update-profile")
def update_profile(
    request: UpdateProfileRequest,
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware)  # Use authenticated user
):
    user = db.query(User).filter(User.id == user_dict["uid"]).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Update the user's name and email
    user.name = request.name
    user.email = request.email

    # Commit the changes to the database
    db.commit()
    db.refresh(user)

    return {"message": "✅ Profile updated successfully!", "user": user}

@router.delete("/delete-account")
def delete_account(
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware)  # Use authenticated user
):
    user = db.query(User).filter(User.id == user_dict["uid"]).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Delete related data (optional, depending on your data model)
    db.query(Playlist).filter(Playlist.user_id == user.id).delete()
    db.query(UserSubscription).filter(UserSubscription.user_id == user.id).delete()

    # Now delete the user
    db.delete(user)
    db.commit()

    return {"message": "✅ Account deleted successfully!"}


@router.post('/signup', status_code=201)
def signup_user(user: UserCreate, db: Session = Depends(get_db)):
    # check if the user already exists in db
    user_db = db.query(User).filter(User.email == user.email).first()
    if user_db:
        raise HTTPException(400, 'User with the same email already exists!')

    hashed_pw = bcrypt.hashpw(user.password.encode(), bcrypt.gensalt())
    user_db = User(id=str(uuid.uuid4()), email=user.email, password=hashed_pw, name=user.name)

    # add the user to db
    db.add(user_db)
    db.commit()
    db.refresh(user_db)

    return user_db

@router.post('/login')
def login_user(user: UserLogin, db: Session = Depends(get_db)):
    # check if user with the same email already exists
    user_db = db.query(User).filter(User.email == user.email).first()
    if not user_db:
        raise HTTPException(400, 'User with this email does not exist!')
    # password matching or no
    is_match = bcrypt.checkpw(user.password.encode(), user_db.password)
    if not is_match:
        raise HTTPException(400, 'Incorrect password!')

    token = jwt.encode({'id': user_db.id}, 'password_key')
    return {'token': token, 'user': user_db}

@router.get('/')
def current_user_data(db: Session = Depends(get_db), user_dict: dict = Depends(auth_middleware)):
    user = db.query(User).filter(User.id == user_dict['uid']).options(
        joinedload(User.favorites)
    ).first()
    if not user:
        raise HTTPException(404, 'User not found!')
    return user



class ChangePasswordRequest(BaseModel):
    old_password: str
    new_password: str


@router.put("/change-password")
def change_password(
    request: ChangePasswordRequest,
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware)  # ✅ Use authenticated user
):
    user = db.query(User).filter(User.id == user_dict["uid"]).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Ensure stored password is in bytes
    stored_password = user.password if isinstance(user.password, bytes) else user.password.encode()

    # Check if old password is correct
    if not bcrypt.checkpw(request.old_password.encode(), stored_password):
        raise HTTPException(status_code=400, detail="Incorrect old password!")

    # Prevent using the same password again
    if bcrypt.checkpw(request.new_password.encode(), stored_password):
        raise HTTPException(status_code=400, detail="New password must be different from old password.")

    # Check if new password is at least 5 characters long
    if len(request.new_password) < 5:
        raise HTTPException(status_code=400, detail="New password must be at least 5 characters long.")

    # Hash and update new password
    hashed_pw = bcrypt.hashpw(request.new_password.encode(), bcrypt.gensalt())
    user.password = hashed_pw
    db.commit()

    return {"message": "✅ Password changed successfully"}


# ✅ Playlist Create Request
class PlaylistCreate(BaseModel):
    name: str

# ✅ Playlist Update Request
class PlaylistUpdate(BaseModel):
    name: str

# ✅ Playlist Response
class PlaylistResponse(BaseModel):
    id: str
    name: str

    class Config:
        from_attributes = True

# ✅ Create Playlist
@router.post("/create-playlist")
def create_playlist(
    playlist_data: PlaylistCreate,
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware),
):
    user_id = user_dict["uid"]
    now = datetime.utcnow()

    sub = db.query(UserSubscription).join(SubscriptionPlan).filter(
        UserSubscription.user_id == user_id,
        UserSubscription.end_date >= now
    ).first()

    if not sub:
        raise HTTPException(status_code=403, detail="❌ You must subscribe to create playlists.")

    # Normalize plan name
    plan_name = sub.plan.name.strip().lower().replace(" plan", "").replace(" ", "_")

    print(f"[DEBUG] User plan: {sub.plan.name} → Normalized: {plan_name}")

    allowed_plans = ["basic", "premium", "yearly_premium"]

    if plan_name not in allowed_plans:
        raise HTTPException(status_code=403, detail="❌ Your plan does not support creating playlists.")

    new_playlist = Playlist(
        id=str(uuid.uuid4()),
        name=playlist_data.name,
        user_id=user_id
    )

    db.add(new_playlist)
    db.commit()
    db.refresh(new_playlist)

    return {"message": "✅ Playlist created successfully!", "playlist": new_playlist}


@router.get("/get-playlists", response_model=List[PlaylistResponse])
def get_playlists(
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware),
):
    user_id = user_dict["uid"]
    playlists = db.query(Playlist).filter(Playlist.user_id == user_id).all()
    return playlists

# ✅ Update Playlist
@router.put("/update-playlist/{playlist_id}")
def update_playlist(
    playlist_id: str,
    playlist_data: PlaylistUpdate,
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware),
):
    playlist = db.query(Playlist).filter(
        Playlist.id == playlist_id,
        Playlist.user_id == user_dict["uid"]
    ).first()

    if not playlist:
        raise HTTPException(status_code=404, detail="Playlist not found")

    playlist.name = playlist_data.name
    db.commit()
    db.refresh(playlist)

    return {"message": "✅ Playlist updated successfully!", "updated_playlist": playlist}

# ✅ Delete Playlist
@router.delete("/delete-playlist/{playlist_id}")
def delete_playlist(
    playlist_id: str,
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware),
):
    playlist = db.query(Playlist).filter(
        Playlist.id == playlist_id,
        Playlist.user_id == user_dict["uid"]
    ).first()

    if not playlist:
        raise HTTPException(status_code=404, detail="Playlist not found")

    db.delete(playlist)
    db.commit()

    return {"message": "✅ Playlist deleted successfully!"}

@router.get("/playlist-songs/{playlist_id}")
def get_songs_in_playlist(
    playlist_id: str,
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware)
):
    playlist = db.query(Playlist).filter(
        Playlist.id == playlist_id,
        Playlist.user_id == user_dict["uid"]
    ).first()

    if not playlist:
        raise HTTPException(status_code=404, detail="Playlist not found")

    return {
        "songs": [
            {
                "id": song.id,
                "song_name": song.song_name,
                "artist": song.artist,
                "thumbnail_url": song.thumbnail_url,
            }
            for song in playlist.songs
        ]
    }


# ✅ 2. Remove song from playlist
@router.delete("/remove-from-playlist/{playlist_id}/{song_id}")
def remove_song_from_playlist(
    playlist_id: str,
    song_id: str,
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware)
):
    playlist = db.query(Playlist).filter(
        Playlist.id == playlist_id,
        Playlist.user_id == user_dict["uid"]
    ).first()

    if not playlist:
        raise HTTPException(status_code=404, detail="Playlist not found!")

    song_to_remove = next((song for song in playlist.songs if song.id == song_id), None)
    if not song_to_remove:
        raise HTTPException(status_code=404, detail="Song not found in playlist!")

    playlist.songs.remove(song_to_remove)
    db.commit()

    return {"message": "✅ Song removed from playlist successfully!"}

@router.get("/get-songs")
def get_songs(
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware)
):
    user_id = user_dict["uid"]
    now = datetime.utcnow()

    # Check if user has premium access
    sub = db.query(UserSubscription).join(SubscriptionPlan).filter(
        UserSubscription.user_id == user_id,
        UserSubscription.end_date >= now,
        SubscriptionPlan.is_premium == True
    ).first()

    is_premium = bool(sub)

    songs = db.query(Song).all()
    return [
        {
            "id": song.id,
            "song_name": song.song_name,
            "artist": song.artist,
            "thumbnail_url": song.thumbnail_url,
            "song_url": song.song_url,  # Updated to use song_url
            "lyrics": song.lyrics if is_premium else None
        }
        for song in songs
    ]





@router.put("/update-song/{song_id}")
def update_song(
    song_id: str,
    song_data: SongUpdate,
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware)
):
    current_user = db.query(User).filter(User.id == user_dict["uid"]).first()

    if not current_user or current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Only admins can update songs.")

    song = db.query(Song).filter(Song.id == song_id).first()
    if not song:
        raise HTTPException(status_code=404, detail="Song not found")

    update_data = song_data.dict(exclude_unset=True)
    if "song_name" in update_data:
        song.song_name = update_data["song_name"]
    if "artist" in update_data:
        song.artist = update_data["artist"]

    db.commit()
    db.refresh(song)

    return {
        "message": "✅ Song updated successfully!",
        "updated_song": {
            "id": song.id,
            "song_name": song.song_name,
            "artist": song.artist,
        }
    }
@router.delete("/delete-song/{song_id}")
def delete_song(
    song_id: str,
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware)
):
    current_user = db.query(User).filter(User.id == user_dict["uid"]).first()

    if not current_user or current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Only admins can delete songs.")

    song = db.query(Song).filter(Song.id == song_id).first()
    if not song:
        raise HTTPException(status_code=404, detail="❌ Song not found!")

    db.delete(song)
    db.commit()

    return {"message": "✅ Song deleted successfully!"}



class AddSongToPlaylistRequest(BaseModel):
    playlist_id: str
    song_id: str

@router.post("/add-song-to-playlist")
def add_song_to_playlist(
    data: AddSongToPlaylistRequest,
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware)
):
    playlist = db.query(Playlist).filter(
        Playlist.id == data.playlist_id,
        Playlist.user_id == user_dict["uid"]
    ).first()

    if not playlist:
        raise HTTPException(status_code=404, detail="❌ Playlist not found")

    song = db.query(Song).filter(Song.id == data.song_id).first()
    if not song:
        raise HTTPException(status_code=404, detail="❌ Song not found")

    if song in playlist.songs:
        raise HTTPException(status_code=400, detail="❗ Song already in playlist!")

    playlist.songs.append(song)
    db.commit()

    return {"message": "✅ Song added to playlist!"}
class RestoreUserRequest(BaseModel):
    id: str
    name: str
    email: str
    role: str

# ✅ 1. Get All Users (Admin Only)
@router.get("/get-users")
def get_users(
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware)
):
    current_user = db.query(User).filter(User.id == user_dict["uid"]).first()
    if not current_user or current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Only admins can view users!")
    
    return db.query(User).all()

@router.delete("/delete-user/{user_id}")
def delete_user(
    user_id: str,
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware)
):
    admin = db.query(User).filter(User.id == user_dict["uid"]).first()
    if not admin or admin.role != "admin":
        raise HTTPException(status_code=403, detail="Only admins can delete users!")

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found!")

    db.delete(user)
    db.commit()

    return {"message": f"✅ User {user_id} deleted successfully!"}

@router.post("/restore-user")
def restore_user(
    data: RestoreUserRequest,
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware)
):
    admin = db.query(User).filter(User.id == user_dict["uid"]).first()
    if not admin or admin.role != "admin":
        raise HTTPException(status_code=403, detail="Only admins can restore users!")

    # Check if the user already exists
    existing_user = db.query(User).filter(User.id == data.id).first()
    if existing_user:
        raise HTTPException(status_code=409, detail="User already exists in DB!")

    default_password = bcrypt.hashpw("password123".encode(), bcrypt.gensalt())

    new_user = User(
        id=data.id,
        name=data.name,
        email=data.email,
        role=data.role,
        password=default_password,
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return {
        "message": "✅ User restored successfully!",
        "user": {
            "id": new_user.id,
            "name": new_user.name,
            "email": new_user.email,
            "role": new_user.role,
        }
    }  


@router.get("/plans")
def get_plans(db: Session = Depends(get_db)):
    plans = db.query(SubscriptionPlan).all()
    return [
        {
            "id": plan.id,
            "name": plan.name,
            "description": plan.description,
            "price": plan.price,
            "duration_days": plan.duration_days,
            "is_premium": plan.is_premium,
        }
        for plan in plans
    ]



@router.post("/subscribe/{plan_id}")
def subscribe(
    plan_id: int,
    card: CardDetails,
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware)
):
    user_id = user_dict["uid"]
    now = datetime.utcnow()

    plan = db.query(SubscriptionPlan).filter(SubscriptionPlan.id == plan_id).first()
    if not plan:
        raise HTTPException(status_code=404, detail="Plan not found")

    existing = db.query(UserSubscription).filter(
        UserSubscription.user_id == user_id,
        UserSubscription.end_date >= now
    ).first()

    if existing:
        return JSONResponse(content={"detail": "❌ You already have an active plan."})

    # Save card info
    user = db.query(User).filter(User.id == user_id).first()
    user.card_number = bcrypt.hashpw(card.card_number.encode(), bcrypt.gensalt()).decode()
    user.card_expiry = bcrypt.hashpw(card.card_expiry.encode(), bcrypt.gensalt()).decode()
    user.card_cvv = bcrypt.hashpw(card.card_cvv.encode(), bcrypt.gensalt()).decode()
    

    new_sub = UserSubscription(
        user_id=user_id,
        plan_id=plan_id,
        start_date=now,
        end_date=now + timedelta(days=plan.duration_days)
    )

    db.add(new_sub)
    db.commit()

    return {"message": "✅ Subscription activated and charged!"}



@router.get("/subscription-status")
def subscription_status(
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware)
):
    user_id = user_dict["uid"]
    now = datetime.utcnow()

    sub = db.query(UserSubscription).join(SubscriptionPlan).filter(
        UserSubscription.user_id == user_id,
        UserSubscription.end_date >= now
    ).first()

    if not sub:
        return {"is_premium": False, "plan_type": None}

    return {
        "is_premium": sub.plan.is_premium,
        "plan_name": sub.plan.name,
        "plan_type": sub.plan.name.lower().replace(" ", "_"),  
        "ends_at": sub.end_date,
    }

class VoiceCommandRequest(BaseModel):
    command: str

@router.post("/voice-command")
def voice_command(request: VoiceCommandRequest, db: Session = Depends(get_db)):
    command = request.command.lower()
    print(f"[VOICE] Received command: {command}")

    # Handle the "navigate to playlist" command
    if "navigate to playlist" in command:
        return {"action": "navigate_to_playlist"}

    if "pause" in command:
        return {"action": "pause"}
    if "continue" in command or "resume" in command:
        return {"action": "continue"}
    if "shuffle" in command:
        songs = db.query(Song).all()
        if songs:
            random_song = random.choice(songs)
            return {
                "action": "play",
                "song_name": random_song.song_name,
                "artist": random_song.artist,
                "song_url": random_song.song_url,
                "thumbnail_url": random_song.thumbnail_url,
            }
        return {"action": "not_found", "message": "No songs found to shuffle."}

    if "volume up" in command or "increase volume" in command: 
        return {"action": "volume_up"}

    if "volume down" in command or "decrease volume" in command:
        return {"action": "volume_down"}

    if "play" in command:
        songs = db.query(Song).all()
        song_names = [f"{song.song_name} {song.artist}".lower() for song in songs]
        best_match, score, index = process.extractOne(command, song_names)
        if score >= 45:
            matched_song = songs[index]
            return {
                "action": "play",
                "song_name": matched_song.song_name,
                "artist": matched_song.artist,
                "song_url": matched_song.song_url,
                "thumbnail_url": matched_song.thumbnail_url,
            }

    return {"action": "none", "message": "Invalid command"}

