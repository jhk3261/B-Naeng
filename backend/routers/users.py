from datetime import datetime, timedelta, timezone
from fastapi import APIRouter, HTTPException, status, Depends, Response
from fastapi.security import OAuth2PasswordBearer
from pydantic import BaseModel
from pydantic_settings import BaseSettings
from typing import Optional
from jose import JWTError, jwt
from config.database import get_db, get_session
from dotenv import load_dotenv
from api.models import User
from sqlalchemy.orm import Session
import re
load_dotenv()

class Settings(BaseSettings):
    SECRET_KEY: str
    DATABASE_URL: str

    class Config:
        env_file = ".env"

settings = Settings()

# < JWT 토큰 관련 함수 정의 >
def create_access_token(user: str, exp: int):
    expires = datetime.now(timezone.utc) + timedelta(seconds=exp)
    
    payload = {
        "user": user,  # 사용자
        "expires": expires.timestamp(),  # 만료시간
    }

    token = jwt.encode(payload, settings.SECRET_KEY, algorithm="HS256")
    return token

def verify_access_token(token: str):
    try:
        # 토큰 decode
        data = jwt.decode(token, settings.SECRET_KEY, algorithms=["HS256"])
        # 토큰 만료 확인
        expires = data.get("expires")
        if expires is None:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No Access Token Supplied")
        if datetime.now(timezone.utc) > datetime.fromtimestamp(expires, tz=timezone.utc):
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Token Expired")
        # 정상 토큰일 경우 데이터 반환
        return data
    except JWTError:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid Token")


# < Authentication 관련 함수 >
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/user/login")

# 토큰을 받아서 유효검사 후 payload의 user 필드 반환
async def authenticate(token: str = Depends(oauth2_scheme)) -> str:
    if not token:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Sign in for access")
    
    decode_token = verify_access_token(token)
    return decode_token["user"]

router = APIRouter(tags=["User"])

class UserLogin(BaseModel):
    email: str
    username: str
    exp: int

class TokenResponse(BaseModel):
    access_token: str
    token_type: str


@router.post("/login", response_model=TokenResponse)
async def login(body: UserLogin, response : Response, db : Session=Depends(get_db)) -> dict:
    try:
        # 이메일로 기존 유저 조회
        existing_user = db.query(User).filter(User.email == body.email).first()
        
        if existing_user:
            access_token = create_access_token(body.email, body.exp)
        else:
            # 새로운 유저를 DB에 추가할 때 exp 필드를 포함하지 않음
            new_user = User(email=body.email, username=body.username)
            db.add(new_user)
            db.commit()
            db.refresh(new_user)
            access_token = create_access_token(new_user.email, body.exp)
        
        response.set_cookie(key="access_token", value=access_token, httponly=True, secure=True, samesite='Lax')

        
        return {
            "access_token": access_token,
            "token_type": "Bearer"
        }

    except Exception as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))