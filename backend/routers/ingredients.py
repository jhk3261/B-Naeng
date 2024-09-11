from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session
from api.models import Ingredient
from config.database import get_db
from typing import List

router = APIRouter(tags=["식재료"])


# 식재료 생성 모델
class IngredientCreate(BaseModel):
    user_id: int
    contents: str


# 식재료 업데이트 모델
class IngredientUpdate(BaseModel):
    contents: str


# 식재료 조회 모델
class IngredientResponse(BaseModel):
    id: int
    user_id: int
    contents: str

    class Config:
        from_attributes = True


# 식재료 추가
@router.post("/ingredients/", response_model=IngredientResponse)
def create_ingredient(ingredient: IngredientCreate, db: Session = Depends(get_db)):
    db_ingredient = Ingredient(user_id=ingredient.user_id, contents=ingredient.contents)
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
    db_ingredient.contents = ingredient.contents
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

# 게시글 형식처럼??? 수정 (tips처럼)