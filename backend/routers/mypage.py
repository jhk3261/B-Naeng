from fastapi import APIRouter, HTTPException, Depends, status 
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
from config.database import get_db
from api.models import MyPage, User, Friger

router = APIRouter()

# 스키마 정의
class MyPageBase(BaseModel):
    profile_image_url: Optional[str] = None  # 프로필 이미지 URL
    green_points: Optional[int] = None  # 그린 포인트
    fridge_count: Optional[int] = None  # 냉장고 개수
    scrap_expanded: Optional[bool] = None  # 스크랩 확장 상태
    is_admin: Optional[bool] = None  # 냉장고 관리자 여부

class MyPageCreate(MyPageBase):
    user_id: int  # 사용자 ID

class MyPageUpdate(MyPageBase):
    pass

class MyPageResponse(MyPageBase):
    id: int  # MyPage ID
    user_id: int  # 사용자 ID

    class Config:
        orm_mode = True

# MyPage 생성
@router.post("/mypage/", response_model=MyPageResponse, status_code=status.HTTP_201_CREATED)
def create_mypage(mypage: MyPageCreate, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == mypage.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="사용자를 찾을 수 없습니다")

    # 냉장고 관리자 여부 확인
    is_admin = db.query(Friger).filter(Friger.owner_id == mypage.user_id).first() is not None

    db_mypage = MyPage(
        user_id=mypage.user_id,
        profile_image_url=mypage.profile_image_url,
        green_points=mypage.green_points,
        fridge_count=mypage.fridge_count,
        scrap_expanded=mypage.scrap_expanded
    )
    db.add(db_mypage)
    db.commit()
    db.refresh(db_mypage)
    return db_mypage

# 사용자 ID로 MyPage 조회
@router.get("/mypage/{user_id}", response_model=MyPageResponse)
def get_mypage(user_id: int, db: Session = Depends(get_db)):
    db_mypage = db.query(MyPage).filter(MyPage.user_id == user_id).first()
    if db_mypage is None:
        raise HTTPException(status_code=404, detail="MyPage를 찾을 수 없습니다")

    # 냉장고 관리자 여부 확인
    is_admin = db.query(Friger).filter(Friger.owner_id == user_id).first() is not None
    db_mypage.is_admin = is_admin

    return db_mypage

# 사용자 ID로 MyPage 업데이트
@router.put("/mypage/{user_id}", response_model=MyPageResponse)
def update_mypage(user_id: int, mypage_update: MyPageUpdate, db: Session = Depends(get_db)):
    db_mypage = db.query(MyPage).filter(MyPage.user_id == user_id).first()
    if db_mypage is None:
        raise HTTPException(status_code=404, detail="MyPage를 찾을 수 없습니다")

    if mypage_update.profile_image_url is not None:
        db_mypage.profile_image_url = mypage_update.profile_image_url
    if mypage_update.green_points is not None:
        db_mypage.green_points = mypage_update.green_points
    if mypage_update.fridge_count is not None:
        db_mypage.fridge_count = mypage_update.fridge_count
    if mypage_update.scrap_expanded is not None:
        db_mypage.scrap_expanded = mypage_update.scrap_expanded

    db.commit()
    db.refresh(db_mypage)
    return db_mypage