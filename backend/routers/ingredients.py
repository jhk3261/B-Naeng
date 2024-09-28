import os
import uuid
from typing import Optional, List
from fastapi import APIRouter, Form, HTTPException, Depends, Query, UploadFile
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from sqlalchemy.orm import Session
from api.models import Ingredient, Like, Comment, Scrap
from config.database import get_db
from slugify import slugify  # pip install python-slugify

router = APIRouter(tags=["식재료 커뮤니티"])

# 업로드 디렉토리 설정
UPLOAD_DIR = os.path.join(os.path.dirname(__file__), "..", "uploads")
if not os.path.exists(UPLOAD_DIR):
    os.makedirs(UPLOAD_DIR)

# 업로드 디렉토리를 정적 파일로 제공
router.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

# Pydantic 모델 정의
class IngredientCreate(BaseModel):
    user_id: int
    title: str
    contents: str
    is_shared: Optional[bool] = False
    pictures: Optional[List[str]] = None 
    locationDong: str

class IngredientUpdate(BaseModel):
    title: Optional[str] = None
    contents: Optional[str] = None
    is_shared: Optional[bool] = None
    pictures: Optional[List[str]] = None
    locationDong: Optional[str] = None 

class IngredientResponse(BaseModel):
    id: int
    title: str
    contents: str
    is_shared: bool
    pictures: Optional[List[str]] = None 
    like_count: int
    comment_count: int
    scrap_count: int
    is_liked: bool
    is_scrapped: bool
    comments: List[str]
    locationDong: str = ""

    class Config:
        from_attributes = True

class LikeCreate(BaseModel):
    user_id: int

class LikeResponse(BaseModel):
    id: int
    user_id: int

    class Config:
        from_attributes = True

class CommentCreate(BaseModel):
    user_id: int
    content: str

class CommentResponse(BaseModel):
    id: int
    user_id: int
    content: str

    class Config:
        from_attributes = True

class ScrapCreate(BaseModel):
    user_id: int

class ScrapResponse(BaseModel):
    id: int
    user_id: int

    class Config:
        from_attributes = True

@router.get("/ingredient_image")
async def get_ingredient_image(file_path: str):
    # 파일이 존재하는지 확인
    if os.path.exists(file_path):
        print("파일 보냅니다~")
        return FileResponse(file_path)
    else:
        return {"error": "File not found"}

# 식재료 추가 (이미지 URL 포함)
@router.post("/ingredients/", response_model=IngredientResponse)
async def create_ingredient(
    user_id: int = Form(...),
    title: str = Form(...),
    contents: str = Form(...),
    is_shared: bool = Form(False),
    pictures: Optional[List[UploadFile]] = None,
    locationDong: str = Form(...),
    db: Session = Depends(get_db)
):
    # 파일 업로드 및 URL 생성 로직
    uploaded_picture_urls = []
    if pictures:
        for picture in pictures:
            # 파일 이름 중복 방지를 위해 UUID 사용
            unique_filename = f"{uuid.uuid4()}_{slugify(picture.filename, separator='_')}"
            file_location = os.path.join(UPLOAD_DIR, unique_filename)
            with open(file_location, "wb") as file:
                file.write(await picture.read())
            file_url = f"/uploads/{unique_filename}"
            uploaded_picture_urls.append(file_url)

    db_ingredient = Ingredient(
        user_id=user_id,
        title=title,
        contents=contents,
        pictures=uploaded_picture_urls,
        is_shared=is_shared,
        locationDong=locationDong,
    )
    db.add(db_ingredient)
    db.commit()
    db.refresh(db_ingredient)

    return IngredientResponse(
        id=db_ingredient.id,
        title=db_ingredient.title,
        contents=db_ingredient.contents,
        is_shared=db_ingredient.is_shared,
        pictures=db_ingredient.pictures,
        locationDong=db_ingredient.locationDong or "",
        like_count=0,
        comment_count=0,
        scrap_count=0,
        is_liked=False,
        is_scrapped=False,
        comments=[]
    )

# 특정 식재료 조회
@router.get("/ingredients/{ingredient_id}", response_model=IngredientResponse)
def read_ingredient(
    ingredient_id: int,
    user_id: Optional[int] = Query(None, description="Optional User ID for like and scrap status"),
    db: Session = Depends(get_db)
):
    db_ingredient = db.query(Ingredient).filter(Ingredient.id == ingredient_id).first()
    if db_ingredient is None:
        raise HTTPException(status_code=404, detail="Ingredient not found")

    like_count = db.query(Like).filter(Like.ingredient_id == ingredient_id).count()
    comment_count = db.query(Comment).filter(Comment.ingredient_id == ingredient_id).count()
    scrap_count = db.query(Scrap).filter(Scrap.ingredient_id == ingredient_id).count()

    is_liked = False
    is_scrapped = False
    if user_id is not None:
        is_liked = db.query(Like).filter(Like.ingredient_id == ingredient_id, Like.user_id == user_id).first() is not None
        is_scrapped = db.query(Scrap).filter(Scrap.ingredient_id == ingredient_id, Scrap.user_id == user_id).first() is not None

    comments = db.query(Comment).filter(Comment.ingredient_id == ingredient_id).all()
    comments_text = [comment.content for comment in comments]

    return IngredientResponse(
        id=db_ingredient.id,
        title=db_ingredient.title,
        contents=db_ingredient.contents,
        is_shared=db_ingredient.is_shared,
        pictures=db_ingredient.pictures,
        locationDong=db_ingredient.locationDong or "",
        like_count=like_count,
        comment_count=comment_count,
        scrap_count=scrap_count,
        is_liked=is_liked,
        is_scrapped=is_scrapped,
        comments=comments_text
    )

# 식재료 업데이트
@router.put("/ingredients/{ingredient_id}", response_model=IngredientResponse)
def update_ingredient(
    ingredient_id: int, ingredient: IngredientUpdate, db: Session = Depends(get_db)
):
    db_ingredient = db.query(Ingredient).filter(Ingredient.id == ingredient_id).first()
    if db_ingredient is None:
        raise HTTPException(status_code=404, detail="Ingredient not found")

    if ingredient.title is not None:
        db_ingredient.title = ingredient.title
    if ingredient.contents is not None:
        db_ingredient.contents = ingredient.contents
    if ingredient.pictures is not None:
        db_ingredient.pictures = ingredient.pictures
    if ingredient.is_shared is not None:
        db_ingredient.is_shared = ingredient.is_shared
    if ingredient.locationDong is not None:
        db_ingredient.locationDong = ingredient.locationDong

    db.commit()
    db.refresh(db_ingredient)

    like_count = db.query(Like).filter(Like.ingredient_id == ingredient_id).count()
    comment_count = db.query(Comment).filter(Comment.ingredient_id == ingredient_id).count()
    scrap_count = db.query(Scrap).filter(Scrap.ingredient_id == ingredient_id).count()

    return IngredientResponse(
        id=db_ingredient.id,
        title=db_ingredient.title,
        contents=db_ingredient.contents,
        is_shared=db_ingredient.is_shared,
        pictures=db_ingredient.pictures,
        locationDong=db_ingredient.locationDong or "",
        like_count=like_count,
        comment_count=comment_count,
        scrap_count=scrap_count,
        is_liked=False,  # 업데이트 후 기본값 설정
        is_scrapped=False,  # 업데이트 후 기본값 설정
        comments=[]
    )

# 식재료 삭제
@router.delete("/ingredients/{ingredient_id}", response_model=IngredientResponse)
def delete_ingredient(ingredient_id: int, db: Session = Depends(get_db)):
    db_ingredient = db.query(Ingredient).filter(Ingredient.id == ingredient_id).first()
    if db_ingredient is None:
        raise HTTPException(status_code=404, detail="Ingredient not found")
    
    # 삭제 전 필요한 정보 저장
    title = db_ingredient.title
    contents = db_ingredient.contents
    is_shared = db_ingredient.is_shared
    pictures = db_ingredient.pictures
    locationDong = db_ingredient.locationDong

    db.delete(db_ingredient)
    db.commit()
    
    return IngredientResponse(
        id=id,
        title=title,
        contents=contents,
        is_shared=is_shared,
        pictures=pictures,
        locationDong=locationDong or "",
        like_count=0,
        comment_count=0,
        scrap_count=0,
        is_liked=False,
        is_scrapped=False,
        comments=[]
    )

# 모든 식재료 조회
@router.get("/ingredients/", response_model=List[IngredientResponse])
def read_ingredients(
    user_id: Optional[int] = Query(None, description="Optional User ID for like and scrap status"),
    db: Session = Depends(get_db)
):
    db_ingredients = db.query(Ingredient).all()

    if not db_ingredients:
        raise HTTPException(status_code=404, detail="No ingredients found")

    result = []
    for ingredient in db_ingredients:
        like_count = db.query(Like).filter(Like.ingredient_id == ingredient.id).count()
        comment_count = db.query(Comment).filter(Comment.ingredient_id == ingredient.id).count()
        scrap_count = db.query(Scrap).filter(Scrap.ingredient_id == ingredient.id).count()

        is_liked = False
        is_scrapped = False
        if user_id is not None:
            is_liked = db.query(Like).filter(Like.ingredient_id == ingredient.id, Like.user_id == user_id).first() is not None
            is_scrapped = db.query(Scrap).filter(Scrap.ingredient_id == ingredient.id, Scrap.user_id == user_id).first() is not None

        comments = db.query(Comment).filter(Comment.ingredient_id == ingredient.id).all()
        comments_text = [comment.content for comment in comments]

        result.append(IngredientResponse(
            id=ingredient.id,
            title=ingredient.title,
            contents=ingredient.contents,
            is_shared=ingredient.is_shared,
            pictures=ingredient.pictures,
            locationDong=ingredient.locationDong or "",
            like_count=like_count,
            comment_count=comment_count,
            scrap_count=scrap_count,
            is_liked=is_liked,
            is_scrapped=is_scrapped,
            comments=comments_text
        ))

    return result

# 좋아요 추가
@router.post("/ingredients/{ingredient_id}/likes", response_model=LikeResponse)
def add_like(ingredient_id: int, like: LikeCreate, db: Session = Depends(get_db)):
    db_like = Like(
        user_id=like.user_id,
        ingredient_id=ingredient_id,
    )
    db.add(db_like)
    db.commit()
    db.refresh(db_like)  # 새롭게 추가된 like의 ID를 가져오기 위해 refresh

    return LikeResponse(
        id=db_like.id,
        user_id=db_like.user_id
    )

# 댓글 추가
@router.post("/ingredients/{ingredient_id}/comments", response_model=CommentResponse)
def add_comment(
    ingredient_id: int, comment: CommentCreate, db: Session = Depends(get_db)
):
    db_comment = Comment(
        user_id=comment.user_id,
        content=comment.content,
        ingredient_id=ingredient_id,
    )
    db.add(db_comment)
    db.commit()
    db.refresh(db_comment)  # 새롭게 추가된 comment의 ID를 가져오기 위해 refresh

    return CommentResponse(
        id=db_comment.id,
        user_id=db_comment.user_id,
        content=db_comment.content
    )

# 스크랩 추가
@router.post("/ingredients/{ingredient_id}/scraps", response_model=ScrapResponse)
def add_scrap(ingredient_id: int, scrap: ScrapCreate, db: Session = Depends(get_db)):
    db_scrap = Scrap(
        user_id=scrap.user_id,
        ingredient_id=ingredient_id,
    )
    db.add(db_scrap)
    db.commit()
    db.refresh(db_scrap)  # 새롭게 추가된 scrap의 ID를 가져오기 위해 refresh

    return ScrapResponse(
        id=db_scrap.id,
        user_id=db_scrap.user_id
    )
