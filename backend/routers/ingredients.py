from typing import Optional, List
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session
from api.models import Ingredient, Like, Comment, Scrap
from config.database import get_db


router = APIRouter(tags=["식재료 커뮤니티"])


# 식재료 생성 모델
class IngredientCreate(BaseModel):
    user_id: int
    title: str
    contents: str
    image_url: Optional[str] = None
    is_shared: Optional[bool] = False


# 식재료 업데이트 모델
class IngredientUpdate(BaseModel):
    title: Optional[str] = None
    contents: Optional[str] = None
    image_url: Optional[str] = None
    is_shared: Optional[bool] = None


# 식재료 조회 모델
class IngredientResponse(BaseModel):
    id: int
    user_id: int
    title: str
    contents: str
    image_url: Optional[str] = None
    is_shared: bool

    class Config:
        from_attributes = True


# 좋아요 모델 형식
class LikeCreate(BaseModel):
    user_id: int


class LikeResponse(BaseModel):
    id: int
    user_id: int

    class Config:
        from_attributes = True


# 댓글 모델 형식
class CommentCreate(BaseModel):
    user_id: int
    content: str


class CommentResponse(BaseModel):
    id: int
    user_id: int
    content: str

    class Config:
        from_attributes = True


# 스크랩 모델 형식
class ScrapCreate(BaseModel):
    user_id: int


class ScrapResponse(BaseModel):
    id: int
    user_id: int

    class Config:
        from_attributes = True


# 식재료 추가
@router.post("/ingredients/", response_model=IngredientResponse)
def create_ingredient(ingredient: IngredientCreate, db: Session = Depends(get_db)):
    db_ingredient = Ingredient(
        user_id=ingredient.user_id,
        title=ingredient.title,
        contents=ingredient.contents,
        image_url=ingredient.image_url,
        is_shared=ingredient.is_shared,
    )
    db.add(db_ingredient)
    db.commit()
    db.refresh(db_ingredient)
    return db_ingredient


# 특정 식재료 조회
@router.get("/ingredients/{ingredient_id}", response_model=IngredientResponse)
def read_ingredient(ingredient_id: int, db: Session = Depends(get_db)):
    db_ingredient = db.query(Ingredient).filter(Ingredient.id == ingredient_id).first()
    if db_ingredient is None:
        raise HTTPException(status_code=404, detail="Ingredient not found")
    return db_ingredient


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
    if ingredient.image_url is not None:
        db_ingredient.image_url = ingredient.image_url
    if ingredient.is_shared is not None:
        db_ingredient.is_shared = ingredient.is_shared

    db.commit()
    db.refresh(db_ingredient)
    return db_ingredient


# 식재료 삭제
@router.delete("/ingredients/{ingredient_id}", response_model=IngredientResponse)
def delete_ingredient(ingredient_id: int, db: Session = Depends(get_db)):
    db_ingredient = db.query(Ingredient).filter(Ingredient.id == ingredient_id).first()
    if db_ingredient is None:
        raise HTTPException(status_code=404, detail="Ingredient not found")
    db.delete(db_ingredient)
    db.commit()
    return db_ingredient


# 모든 식재료 조회
@router.get("/ingredients/", response_model=List[IngredientResponse])
def read_ingredients(db: Session = Depends(get_db)):
    db_ingredients = db.query(Ingredient).all()
    return db_ingredients


# 좋아요 추가
@router.post("/ingredients/{ingredient_id}/likes", response_model=LikeResponse)
def add_like(ingredient_id: int, like: LikeCreate, db: Session = Depends(get_db)):
    db_like = Like(
        user_id=like.user_id,
        ingredient_id=ingredient_id,
    )
    db.add(db_like)
    db.commit()
    return db_like


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
    return db_comment


# 스크랩 추가
@router.post("/ingredients/{ingredient_id}/scraps", response_model=ScrapResponse)
def add_scrap(ingredient_id: int, scrap: ScrapCreate, db: Session = Depends(get_db)):
    db_scrap = Scrap(
        user_id=scrap.user_id,
        ingredient_id=ingredient_id,
    )
    db.add(db_scrap)
    db.commit()
    return db_scrap
