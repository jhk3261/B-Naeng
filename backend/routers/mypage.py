from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload
from pydantic import BaseModel
from typing import Optional, List
from config.database import get_db
from api.models import MyPage, Scrap, User

router = APIRouter(tags=["마이페이지"])

# 마이페이지 스키마 정의
class MyPageResponse(BaseModel):
    id: int
    user_id: int
    username: Optional[str]  # 유저네임 추가
    profile_image_url: Optional[str]
    green_points: int
    fridge_count: int
    scrap_expanded: bool

    class Config:
        orm_mode = True

class MyPageCreate(BaseModel):
    user_id: int
    username: Optional[str]  # 유저네임 추가
    profile_image_url: Optional[str]
    green_points: Optional[int] = 0
    fridge_count: Optional[int] = 0
    scrap_expanded: Optional[bool] = False

    class Config:
        orm_mode = True

# 스크랩 아이템 스키마 정의
class ScrapItemResponse(BaseModel):
    id: int
    user_id: int
    tip_id: Optional[int]  # 스크랩 관련 필드 추가
    ingredient_id: Optional[int]  # 스크랩 관련 필드 추가

    class Config:
        orm_mode = True

class ScrapItemCreate(BaseModel):
    user_id: int
    tip_id: Optional[int]  # 추가된 부분
    ingredient_id: Optional[int]  # 추가된 부분

    class Config:
        orm_mode = True

# 마이페이지 정보를 추가하는 엔드포인트
@router.post("/mypage/", response_model=MyPageResponse)
def create_my_page(mypage: MyPageCreate, db: Session = Depends(get_db)):
    db_mypage = MyPage(
        user_id=mypage.user_id,
        username=mypage.username,  # 유저네임 저장
        profile_image_url=mypage.profile_image_url,
        green_points=mypage.green_points,
        fridge_count=mypage.fridge_count,
        scrap_expanded=mypage.scrap_expanded,
    )
    db.add(db_mypage)
    db.commit()
    db.refresh(db_mypage)
    return db_mypage

# 마이페이지 정보를 가져오는 엔드포인트
@router.get("/mypage/{user_id}", response_model=MyPageResponse)
def get_my_page(user_id: int, db: Session = Depends(get_db)):
    mypage = (
        db.query(MyPage)
        .options(joinedload(MyPage.user))  # 유저 관계 로드
        .filter(MyPage.user_id == user_id)
        .first()
    )
    if not mypage:
        raise HTTPException(status_code=404, detail="MyPage data not found.")

    # username이 None인 경우 빈 문자열로 대체
    username = mypage.username if mypage.username else ""

    return MyPageResponse(
        id=mypage.id,
        user_id=mypage.user_id,
        username=username,  # 유저네임 반환
        profile_image_url=mypage.profile_image_url,
        green_points=mypage.green_points,
        fridge_count=mypage.fridge_count,
        scrap_expanded=mypage.scrap_expanded,
    )

# 스크랩 아이템 추가 엔드포인트
@router.post("/scrap_items/", response_model=ScrapItemResponse)
def create_scrap_item(scrap_item: ScrapItemCreate, db: Session = Depends(get_db)):
    db_scrap_item = Scrap(
        user_id=scrap_item.user_id,
        tip_id=scrap_item.tip_id,
        ingredient_id=scrap_item.ingredient_id,
    )
    db.add(db_scrap_item)
    db.commit()
    db.refresh(db_scrap_item)
    return db_scrap_item

# 특정 유저의 스크랩 아이템 목록을 가져오는 엔드포인트
@router.get("/scrap_items/{user_id}", response_model=List[ScrapItemResponse])
def get_scrap_items(user_id: int, db: Session = Depends(get_db)):
    scrap_items = db.query(Scrap).filter(Scrap.user_id == user_id).all()
    if not scrap_items:
        raise HTTPException(status_code=404, detail="Scrap items not found.")

    return scrap_items

# 포인트 차감 엔드포인트
class UsePointsRequest(BaseModel):
    user_id: int
    points: int

@router.post("/use_points")
def use_points(request: UsePointsRequest, db: Session = Depends(get_db)):
    # 마이페이지 조회
    mypage = db.query(MyPage).filter(MyPage.user_id == request.user_id).first()
    if not mypage:
        raise HTTPException(status_code=404, detail="MyPage not found.")
    
    # 포인트 차감
    if mypage.green_points < request.points:
        raise HTTPException(status_code=400, detail="Not enough points.")
    
    mypage.green_points -= request.points
    db.commit()
    
    return {"message": "Points successfully used.", "remaining_points": mypage.green_points}
