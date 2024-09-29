from random import randint
from sqlite3 import IntegrityError
from typing import List
from fastapi import APIRouter, Depends, Form
from fastapi import Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session
from api.models import Friger, Inventory, User
from config.database import get_db
from routers.users import authenticate
from datetime import date


router = APIRouter(tags=["식재료, 냉장고"])


# 식재료 모델
class InventoryCreate(BaseModel):
    friger_id: int
    name: str
    quantity: int
    date: date
    category: str


class InventoryResponse(BaseModel):
    id: int
    name: str
    quantity: int
    category: str
    date: date

    class Config:
        from_attributes = True


# 냉장고 모델
class FrigerCreate(BaseModel):
    name: str
    unique_code: int
    owner_id: int  # 냉장고 소유자 ID 추가


class FrigerResponse(FrigerCreate):
    name: str
    inventory_list: List[InventoryResponse]
    user_list: List[int]  # 냉장고 사용자의 ID 리스트 추가

    class Config:
        from_attributes = True


class FrigerUpdate(BaseModel):
    name: str


class FrigerResponseWithCount(BaseModel):
    id: int
    name: str
    inventory_count: int
    owner_id: int  # 소유자 ID 추가
    user_count: int

    class Config:
        from_attributes = True


# TO DO : 2. 내가 포함된 Friger List 조회


# 1. Friger 생성
@router.post("/frigers/")
# async def create_friger(name : str, unique_code: int, db: Session = Depends(get_db), current_user: User = Depends(authenticate)):
async def create_friger(name: str, unique_code: int, db: Session = Depends(get_db)):

    # 임시
    new_friger = Friger(
        name=name,
        unique_code=unique_code,
        owner_id=1,
        user_id=1,
    )
    db.add(new_friger)
    db.commit()
    db.refresh(new_friger)

    return new_friger


# 2. 모든 Friger 조회
@router.get("/frigers/")
def get_frigers(db: Session = Depends(get_db)):
    db_frigers = db.query(Friger).all()

    result = []
    for friger in db_frigers:
        result.append(
            FrigerResponseWithCount(
                id=friger.id,
                name=friger.name,
                inventory_count=len(friger.inventory_list),
                owner_id=friger.owner_id,
                user_count=(
                    len(friger.user_list) if isinstance(friger.user_list, list) else 1
                ),
            )
        )

    return [*reversed(result)]


# 3. 특정 Friger 조회
@router.get("/frigers/{friger_id}")
def get_friger(friger_id: int, db: Session = Depends(get_db)):
    db_friger = db.query(Friger).filter(Friger.id == friger_id).first()
    if not db_friger:
        raise HTTPException(status_code=404, detail="Friger not found")

    return FrigerResponse(
        id=db_friger.id,
        name=db_friger.name,
        unique_code=db_friger.unique_code,
        owner_id=db_friger.owner_id,
        user_id=db_friger.user_id,
        inventory_list=[
            InventoryResponse(
                id=inventory.id,
                name=inventory.name,
                quantity=inventory.quantity,
                category=inventory.category,
                date=inventory.date,
            )
            for inventory in db_friger.inventory_list
        ],
        user_list=[1],
    )


# 4. Friger 수정 (Friger name, userlist 수정 가능)
@router.put("/frigers/{friger_id}")
def update_friger(
    friger_id: int, friger_update: FrigerUpdate, db: Session = Depends(get_db)
):
    friger = db.query(Friger).filter(Friger.id == friger_id).first()
    if not friger:
        raise HTTPException(status_code=404, detail="Friger not found")

    friger.name = friger_update.name

    db.commit()
    db.refresh(friger)

    return friger


# 5. owner_id를 가진 user만 Friger 삭제 가능
@router.delete("/frigers/{friger_id}")
def delete_friger(friger_id: int, db: Session = Depends(get_db)):
    friger = db.query(Friger).filter(Friger.id == friger_id).first()
    if not friger:
        raise HTTPException(status_code=404, detail="Friger not found")

    db.delete(friger)
    db.commit()

    return {"detail": "Friger deleted successfully"}


# 6. Inventory 생성
@router.post("/frigers/{friger_id}/inventories/")
def add_inventory(
    friger_id: int, inventory: InventoryCreate, db: Session = Depends(get_db)
):
    # 냉장고 존재 여부 확인
    friger = db.query(Friger).filter(Friger.id == friger_id).first()
    if not friger:
        raise HTTPException(status_code=404, detail="Friger not found")

    db_inventory = Inventory(
        name=inventory.name,
        quantity=inventory.quantity,
        category=inventory.category,
        date=inventory.date,
        friger_id=friger_id,
    )
    db.add(db_inventory)
    db.commit()
    db.refresh(db_inventory)
    return db_inventory


# 7. 특정 Friger의 모든 Inventory 조회
@router.get("/frigers/{friger_id}/inventories/")
def get_frigers_inventories(friger_id: int, db: Session = Depends(get_db)):
    inventories = db.query(Inventory).filter(Inventory.friger_id == friger_id).all()
    result = []
    for inventory in inventories:
        result.append(
            InventoryResponse(
                id=inventory.id,
                name=inventory.name,
                quantity=inventory.quantity,
                category=inventory.category,
                date=inventory.date,
            )
        )
    return result


# 8. 특정 Inventory 조회
@router.get("/frigers/{friger_id}/inventories/{inventory_id}/")
def get_inventory(friger_id: int, inventory_id: int, db: Session = Depends(get_db)):
    inventory = (
        db.query(Inventory)
        .filter(Inventory.id == inventory_id, Inventory.friger_id == friger_id)
        .first()
    )
    if not inventory:
        raise HTTPException(status_code=404, detail="Inventory not found")

    return InventoryResponse(
        id=inventory.id,
        name=inventory.name,
        quantity=inventory.quantity,
        category=inventory.category,
        date=inventory.date,
    )


# 9. Inventory 수정
@router.put("/frigers/{friger_id}/inventories/{inventory_id}/")
def update_inventory(
    friger_id: int,
    inventory_id: int,
    name: str,
    quantity: int,
    date: date,
    category: str,
    db: Session = Depends(get_db),
):
    inventory = (
        db.query(Inventory)
        .filter(Inventory.id == inventory_id, Inventory.friger_id == friger_id)
        .first()
    )
    if not inventory:
        raise HTTPException(status_code=404, detail="Inventory not found")

    inventory.name = name
    inventory.quantity = quantity
    inventory.category = category
    inventory.date = date

    db.commit()
    db.refresh(inventory)
    return inventory


# 10. Inventory 삭제
@router.delete("/frigers/{friger_id}/inventories/{inventory_id}")
def delete_inventory(friger_id: int, inventory_id: int, db: Session = Depends(get_db)):
    inventory = (
        db.query(Inventory)
        .filter(Inventory.id == inventory_id, Inventory.friger_id == friger_id)
        .first()
    )
    if not inventory:
        raise HTTPException(status_code=404, detail="Inventory not found")

    db.delete(inventory)
    db.commit()
    return {"detail": "Inventory deleted successfully"}


# 11. 냉장고에 유저 추가
@router.post("/frigers/{friger_id}/users/{user_id}")
def add_user_to_friger(friger_id: int, user_id: int, db: Session = Depends(get_db)):
    friger = db.query(Friger).filter(Friger.id == friger_id).first()
    if not friger:
        raise HTTPException(status_code=404, detail="Friger not found")

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # 유저가 이미 냉장고에 추가되어 있는지 확인
    if user in friger.users:
        raise HTTPException(status_code=400, detail="User already in Friger")

    # 유저를 냉장고에 추가
    friger.users.append(user)
    db.commit()

    return {"detail": f"User {user.username} added to Friger {friger.name}"}


# 12. 냉장고에서 유저 삭제
@router.delete("/frigers/{friger_id}/users/{user_id}")
def remove_user_from_friger(
    friger_id: int, user_id: int, db: Session = Depends(get_db)
):
    friger = db.query(Friger).filter(Friger.id == friger_id).first()
    if not friger:
        raise HTTPException(status_code=404, detail="Friger not found")

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # 유저가 냉장고에 있는지 확인
    if user not in friger.users:
        raise HTTPException(status_code=400, detail="User not in Friger")

    # 유저를 냉장고에서 제거
    friger.users.remove(user)
    db.commit()

    return {"detail": f"User {user.username} removed from Friger {friger.name}"}


# 13. 특정 Friger의 모든 Users 조회
@router.get("/users/{user_id}/frigers/")
def get_user_frigers(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    frigers = user.frigers  # assuming there's a relationship defined in User model
    return [{"id": friger.id, "name": friger.name} for friger in frigers]
