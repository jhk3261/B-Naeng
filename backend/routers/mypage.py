import os
from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session, joinedload
from pydantic import BaseModel
from typing import Optional, List
from config.database import get_db
from api.models import Friger, MyPage, Scrap, Tip
from datetime import datetime

from routers.friger import FrigerResponseWithCount

router = APIRouter(tags=["마이페이지"])


# 마이페이지 생성 모델
class MyPageCreate(BaseModel):
    user_id: int
    username: Optional[str]
    profile_image_url: Optional[str]
    green_points: Optional[int] = 0
    fridge_count: Optional[int] = 0
    scrap_expanded: Optional[bool] = False

    class Config:
        from_attributes = True


# 마이페이지 확인 모델
class MyPageResponse(BaseModel):
    id: int
    user_id: int
    username: Optional[str]
    profile_image_url: Optional[str]
    green_points: int
    fridge_count: int
    scrap_expanded: bool

    class Config:
        from_attributes = True


# 스크랩 모델
class ScrapItemResponse(BaseModel):
    id: int
    tip_id: int
    title: str
    picture: Optional[str]
    like_count: int
    comment_count: int
    scrap_count: int
    created_at: datetime

    class Config:
        from_attributes = True


# 그린 포인트 모델
class UsePointsRequest(BaseModel):
    user_id: int
    points: int


@router.get("/scrap_image")
async def get_tip_image(file_path: str):
    # 파일이 존재하는지 확인
    if os.path.exists(file_path):
        print("파일 보냅니다~")
        return FileResponse(file_path)
    else:
        return {"error": "File not found"}


# 마이페이지 생성
@router.post("/mypage/", response_model=MyPageResponse)
def create_my_page(mypage: MyPageCreate, db: Session = Depends(get_db)):
    username = (
        mypage.username.encode("utf-8").decode("utf-8") if mypage.username else None
    )

    db_mypage = MyPage(
        user_id=mypage.user_id,
        username=username,
        profile_image_url=mypage.profile_image_url,
        green_points=mypage.green_points,
        fridge_count=mypage.fridge_count,
        scrap_expanded=mypage.scrap_expanded,
    )
    db.add(db_mypage)
    db.commit()
    db.refresh(db_mypage)
    return db_mypage


# 마이페이지 정보 가져옴
@router.get("/mypage/{user_id}", response_model=MyPageResponse)
def get_my_page(user_id: int, db: Session = Depends(get_db)):
    mypage = (
        db.query(MyPage)
        .options(joinedload(MyPage.user))
        .filter(MyPage.user_id == user_id)
        .first()
    )
    if not mypage:
        raise HTTPException(status_code=404, detail="MyPage data not found.")

    # 유저네임을 UTF-8로 디코딩 (필요한 경우)
    username = (
        mypage.username.encode("utf-8").decode("utf-8") if mypage.username else ""
    )

    return MyPageResponse(
        id=mypage.id,
        user_id=mypage.user_id,
        username=username,
        profile_image_url=mypage.profile_image_url,
        green_points=mypage.green_points,
        fridge_count=mypage.fridge_count,
        scrap_expanded=mypage.scrap_expanded,
    )


# 스크랩
@router.get("/scraps/", response_model=List[ScrapItemResponse])
def get_user_scraps(user_id: int = Query(...), db: Session = Depends(get_db)):
    user_scraps = db.query(Scrap).filter(Scrap.user_id == user_id).all()

    if not user_scraps:
        raise HTTPException(status_code=404, detail="Scrap not found")

    result = []
    for scrap in user_scraps:
        tip = db.query(Tip).filter(Tip.id == scrap.tip_id).first()
        if tip:
            result.append(
                ScrapItemResponse(
                    tip_id=tip.id,
                    title=tip.title,
                    picture=(
                        tip.pictures[0] if tip.pictures else None
                    ),  # 첫 번째 사진만 대표 사진으로 사용
                    like_count=len(tip.likes),
                    comment_count=len(tip.comments),
                    scrap_count=len(tip.scraps),
                    created_at=tip.created_at,
                )
            )
    return result


# 그린 포인트
@router.post("/use_points")
def use_points(request: UsePointsRequest, db: Session = Depends(get_db)):
    mypage = db.query(MyPage).filter(MyPage.user_id == request.user_id).first()
    if not mypage:
        raise HTTPException(status_code=404, detail="MyPage not found.")
    if mypage.green_points < request.points:
        raise HTTPException(status_code=400, detail="Not enough points.")
    mypage.green_points -= request.points
    db.commit()
    return {
        "message": "Points successfully used.",
        "remaining_points": mypage.green_points,
    }

@router.get("/users/{user_id}/frigers/")
def get_user_frigers(user_id: int, db: Session = Depends(get_db)):
    user_frigers = db.query(Friger).filter(Friger.owner_id == user_id).all()
    if not user_frigers:
        raise HTTPException(status_code=404, detail="No frigers found for this user")

    return [
        FrigerResponseWithCount(
            id=friger.id,
            name=friger.name,
            inventory_count=len(friger.inventory_list),
            owner_id=friger.owner_id,
            user_count=len(friger.user_list) if isinstance(friger.user_list, list) else 1,
        )
        for friger in user_frigers
    ]


@router.get("/frigers/{friger_id}/users/")
def get_frigers_users(friger_id: int, db: Session = Depends(get_db)):
    # 냉장고 존재 여부 확인
    friger = db.query(Friger).filter(Friger.id == friger_id).first()
    if not friger:
        raise HTTPException(status_code=404, detail="Friger not found")

    # 냉장고에 속한 사용자 목록 조회
    users = friger.user_list
    return {"users": users}
