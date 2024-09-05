from typing import List
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session
from api.models import Ingredient, Like, Comment, Scrap
from config.database import get_db

router = APIRouter(tags=["식재료 나눔"])


############ 좋아요 모델 형식 ############


class LikeCreate(BaseModel):
    user_id: int


class LikeResponse(BaseModel):
    id: int
    user_id: int

    class Config:
        orm_mode = True


############ 댓글 모델 형식 ############


class CommentCreate(BaseModel):
    user_id: int
    content: str


class CommentResponse(BaseModel):
    id: int
    user_id: int
    content: str

    class Config:
        orm_mode = True


############ 스크랩 모델 형식 ############


class ScrapCreate(BaseModel):
    user_id: int


class ScrapResponse(BaseModel):
    id: int
    user_id: int

    class Config:
        orm_mode = True


############ 식재료 게시글 모델 형식 ############


class IngredientCreate(BaseModel):
    title: str
    contents: str
    image_url: str
    user_id: int


class IngredientResponse(BaseModel):
    id: int
    title: str
    contents: str
    image_url: str
    user_id: int
    is_shared: bool

    class Config:
        orm_mode = True


class IngredientResponseWithCounts(BaseModel):
    id: int
    title: str
    contents: str
    image_url: str
    user_id: int
    is_shared: bool
    like_count: int
    comment_count: int
    scrap_count: int

    class Config:
        orm_mode = True


class IngredientDetailsResponse(IngredientResponse):
    like_count: int
    scrap_count: int
    comments: List[CommentResponse]

    class Config:
        orm_mode = True


############ API 엔드포인트 ############


# 1. 식재료 게시글 생성
@router.post("/ingredients/", response_model=IngredientResponse)
def create_ingredient(ingredient: IngredientCreate, db: Session = Depends(get_db)):
    db_ingredient = Ingredient(
        title=ingredient.title,
        contents=ingredient.contents,
        image_url=ingredient.image_url,
        user_id=ingredient.user_id,
        is_shared=False,
    )
    db.add(db_ingredient)
    db.commit()
    db.refresh(db_ingredient)
    return db_ingredient


# 2. 모든 식재료 게시글 조회
@router.get("/ingredients/", response_model=List[IngredientResponseWithCounts])
def get_ingredients(db: Session = Depends(get_db)):
    ingredients = db.query(Ingredient).all()

    result = []
    for ingredient in ingredients:
        result.append(
            IngredientResponseWithCounts(
                id=ingredient.id,
                title=ingredient.title,
                contents=ingredient.contents,
                image_url=ingredient.image_url,
                user_id=ingredient.user_id,
                is_shared=ingredient.is_shared,
                like_count=len(ingredient.likes),
                comment_count=len(ingredient.comments),
                scrap_count=len(ingredient.scraps),
            )
        )
    return result


# 3. 특정 식재료 게시글 조회
@router.get("/ingredients/{ingredient_id}", response_model=IngredientDetailsResponse)
def get_ingredient(ingredient_id: int, db: Session = Depends(get_db)):
    db_ingredient = db.query(Ingredient).filter(Ingredient.id == ingredient_id).first()
    if db_ingredient is None:
        raise HTTPException(status_code=404, detail="Ingredient not found")

    return IngredientDetailsResponse(
        id=db_ingredient.id,
        title=db_ingredient.title,
        contents=db_ingredient.contents,
        image_url=db_ingredient.image_url,
        user_id=db_ingredient.user_id,
        is_shared=db_ingredient.is_shared,
        like_count=len(db_ingredient.likes),
        comments=[
            CommentResponse(
                id=comment.id, user_id=comment.user_id, content=comment.content
            )
            for comment in db_ingredient.comments
        ],
        scrap_count=len(db_ingredient.scraps),
    )


# 4. 식재료 게시글 업데이트
@router.put("/ingredients/{ingredient_id}", response_model=IngredientResponse)
def update_ingredient(
    ingredient_id: int, ingredient: IngredientCreate, db: Session = Depends(get_db)
):
    db_ingredient = db.query(Ingredient).filter(Ingredient.id == ingredient_id).first()
    if db_ingredient is None:
        raise HTTPException(status_code=404, detail="Ingredient not found")

    db_ingredient.title = ingredient.title
    db_ingredient.contents = ingredient.contents
    db_ingredient.image_url = ingredient.image_url
    db_ingredient.is_shared = ingredient.is_shared
    db.commit()
    db.refresh(db_ingredient)
    return db_ingredient


# 5. 식재료 게시글 삭제
@router.delete("/ingredients/{ingredient_id}", response_model=IngredientResponse)
def delete_ingredient(ingredient_id: int, db: Session = Depends(get_db)):
    db_ingredient = db.query(Ingredient).filter(Ingredient.id == ingredient_id).first()
    if db_ingredient is None:
        raise HTTPException(status_code=404, detail="Ingredient not found")

    db.delete(db_ingredient)
    db.commit()
    return db_ingredient


# 6. 좋아요 추가
@router.post("/ingredients/{ingredient_id}/likes", response_model=LikeResponse)
def add_like(ingredient_id: int, like: LikeCreate, db: Session = Depends(get_db)):
    db_like = Like(user_id=like.user_id, ingredient_id=ingredient_id)
    db.add(db_like)
    db.commit()
    return db_like


# 7. 댓글 추가
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


# 8. 스크랩 추가
@router.post("/ingredients/{ingredient_id}/scraps", response_model=ScrapResponse)
def add_scrap(ingredient_id: int, scrap: ScrapCreate, db: Session = Depends(get_db)):
    db_scrap = Scrap(user_id=scrap.user_id, ingredient_id=ingredient_id)
    db.add(db_scrap)
    db.commit()
    return db_scrap
