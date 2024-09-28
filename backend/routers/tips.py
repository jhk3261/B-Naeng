import os
from typing import List, Optional
from fastapi import APIRouter, Depends, File, Form, UploadFile
from fastapi import Depends, HTTPException
from fastapi.responses import FileResponse
from pydantic import BaseModel
from datetime import datetime
from sqlalchemy.orm import Session
from api.models import Tip, Like, Comment, Scrap
from config.database import get_db

router = APIRouter(tags=["팁, 좋아요, 댓글, 스크랩"])

UPLOAD_DIR = "./uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

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
    created_at: datetime

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
    locationDong: str


class TipResponse(TipCreate):
    id: int
    pictures: List[str]


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


##########################################################################################


@router.get("/tip_image")
async def get_tip_image(file_path: str):
    # 파일이 존재하는지 확인
    if os.path.exists(file_path):
        return FileResponse(file_path)
    else:
        return {"error": "File not found"}


##########################################################################################


# 1. Tip 생성
@router.post("/tips/")
async def create_tip(
    title: str = Form(...),
    contents: str = Form(...),
    category: int = Form(...),
    locationDong: str = Form(...),
    raw_picture_list: List[UploadFile] = None,
    # raw_picture_list: Optional[List[UploadFile]] = File([]),
    db: Session = Depends(get_db),
):
    # Process and save images

    file_paths = []
    if raw_picture_list:
        for file in raw_picture_list:
            file_path = os.path.join(UPLOAD_DIR, file.filename)
            with open(file_path, "wb") as buffer:
                buffer.write(await file.read())
            file_paths.append(file_path)

    db_tip = Tip(
        title=title,
        contents=contents,
        category=category,
        pictures=file_paths,  # Save the file paths
        locationDong=locationDong,
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
    return [*reversed(result)]


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
                id=comment.id,
                user_id=comment.user_id,
                content=comment.content,
                created_at=comment.created_at,
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


# 9. 특정 사용자의 스크랩 조회
@router.get("/users/{user_id}/scraps", response_model=List[TipResponseWithCounts])
def get_user_scraps(user_id: int, db: Session = Depends(get_db)):
    scraps = db.query(Scrap).filter(Scrap.user_id == user_id).all()

    if not scraps:
        raise HTTPException(status_code=404, detail="No scraps found.")

    # 스크랩한 팁 정보 가져오기
    result = []
    for scrap in scraps:
        tip = db.query(Tip).filter(Tip.id == scrap.tip_id).first()
        if tip:
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
