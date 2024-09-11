from typing import List
from fastapi import APIRouter, Depends
from fastapi import Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session
from api.models import Tip, Like, Comment, Scrap
from config.database import get_db

router = APIRouter(tags=["팁, 좋아요, 댓글, 스크랩"])


############ 좋아요 모델 형식 ############


class LikeCreate(BaseModel):
    user_id: int


class LikeResponse(BaseModel):
    id: int
    user_id: int

    class Config:
        from_attributes = True


############ 댓글 모델 형식 ############


class CommentCreate(BaseModel):
    user_id: int
    content: str


class CommentResponse(BaseModel):
    id: int
    user_id: int
    content: str

    class Config:
        from_attributes = True


############ 스크랩 모델 형식 ############


class ScrapCreate(BaseModel):
    user_id: int


class ScrapResponse(BaseModel):
    id: int
    user_id: int

    class Config:
        from_attributes = True


############ 팁 모델 형식 ############


class TipCreate(BaseModel):
    title: str
    contents: str
    category: int
    pictures: List[str] = []
    locationDong: str


class TipResponse(TipCreate):
    id: int


class TipResponseWithCounts(BaseModel):
    id: int
    title: str
    contents: str
    category: int
    pictures: List[str]
    locationDong: str
    like_count: int
    comment_count: int
    scrap_count: int

    class Config:
        from_attributes = True


class TipDetailsResponse(TipResponse):
    like_count: int
    scrap_count: int
    comments: List[CommentResponse]

    class Config:
        from_attributes = True


# 1. Tip 생성
@router.post("/tips/")
def create_tip(tip: TipCreate, db: Session = Depends(get_db)):
    db_tip = Tip(
        title=tip.title,
        contents=tip.contents,
        category=tip.category,
        pictures=tip.pictures,
        locationDong=tip.locationDong,
    )
    db.add(db_tip)
    db.commit()
    db.refresh(db_tip)
    return db_tip


# 2. 모든 Tip 조회
@router.get("/tips/")
def get_tips(db: Session = Depends(get_db)):
    tips = db.query(Tip).all()

    # 각 Tip에 대해 좋아요, 댓글, 스크랩 개수를 포함하여 반환
    result = []
    for tip in tips:
        result.append(
            TipResponseWithCounts(
                id=tip.id,
                title=tip.title,
                contents=tip.contents,
                category=tip.category,
                pictures=tip.pictures,
                locationDong=tip.locationDong,
                like_count=len(tip.likes),
                comment_count=len(tip.comments),
                scrap_count=len(tip.scraps),
            )
        )
    return result


# 3. 특정 Tip 조회
@router.get("/tips/{tip_id}")
def get_tip(tip_id: int, db: Session = Depends(get_db)):
    db_tip = db.query(Tip).filter(Tip.id == tip_id).first()
    if db_tip is None:
        raise HTTPException(status_code=404, detail="Tip not found")

    # 좋아요, 댓글, 스크랩 객체들을 리스트로 반환
    return TipDetailsResponse(
        id=db_tip.id,
        title=db_tip.title,
        contents=db_tip.contents,
        category=db_tip.category,
        pictures=db_tip.pictures,
        locationDong=db_tip.locationDong,
        like_count=len(db_tip.likes),
        comments=[
            CommentResponse(
                id=comment.id, user_id=comment.user_id, content=comment.content
            )
            for comment in db_tip.comments
        ],
        scrap_count=len(db_tip.scraps),
    )


# 4. Tip 업데이트
@router.put("/tips/{tip_id}")
def update_tip(tip_id: int, tip: TipCreate, db: Session = Depends(get_db)):
    db_tip = db.query(Tip).filter(Tip.id == tip_id).first()
    if db_tip is None:
        raise HTTPException(status_code=404, detail="Tip not found")

    db_tip.title = tip.title
    db_tip.contents = tip.contents
    db_tip.category = tip.category
    db_tip.pictures = tip.pictures
    db.commit()
    db.refresh(db_tip)
    return db_tip


# 5. Tip 삭제
@router.delete("/tips/{tip_id}")
def delete_tip(tip_id: int, db: Session = Depends(get_db)):
    db_tip = db.query(Tip).filter(Tip.id == tip_id).first()
    if db_tip is None:
        raise HTTPException(status_code=404, detail="Tip not found")

    db.delete(db_tip)
    db.commit()
    return {"message": "Tip deleted successfully"}


##########################################################################################


# 6. Like 추가
@router.post("/tips/{tip_id}/likes")
def add_like(tip_id: int, like: LikeCreate, db: Session = Depends(get_db)):
    db_like = Like(
        user_id=like.user_id,
        tip_id=tip_id,
    )
    db.add(db_like)
    db.commit()
    return db_like


# 7. Comment 추가
@router.post("/tips/{tip_id}/comments")
def add_comment(tip_id: int, comment: CommentCreate, db: Session = Depends(get_db)):
    db_comment = Comment(
        user_id=comment.user_id,
        content=comment.content,
        tip_id=tip_id,
    )
    db.add(db_comment)
    db.commit()
    return db_comment


# 8. Scrap 추가
@router.post("/tips/{tip_id}/scraps")
def add_scrap(tip_id: int, scrap: ScrapCreate, db: Session = Depends(get_db)):
    db_scrap = Scrap(
        user_id=scrap.user_id,
        tip_id=tip_id,
    )
    db.add(db_scrap)
    db.commit()
    return db_scrap
