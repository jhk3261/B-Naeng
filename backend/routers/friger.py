from random import random
from sqlite3 import IntegrityError
from typing import List
from fastapi import APIRouter, Depends
from fastapi import Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session
from api.models import Friger,Inventory, User
from config.database import get_db

router = APIRouter(tags=["식재료, 냉장고"])

def generate_unique_code(db: Session):
    while True:
        code = random.randint(1000, 9999)
        existing_friger = db.query(Friger).filter_by(unique_code=code).first()
        if not existing_friger:
            return code

# 식재료 모델
class InventoryCreate(BaseModel):
    name: str
    quantity: int
    category: str
    date: str = None

class InventoryResponse(BaseModel):
    id: int
    name: str
    quantity: int
    category: str
    date: str = None

    class Config:
        orm_mode = True

# 냉장고 모델
class FrigerCreate(BaseModel):
    name: str

class FrigerResponse(FrigerCreate):
    id: int

class FrigerUpdate(BaseModel):
    name: str
    user_list: List[int]  # User ID 리스트

class FrigerResponseWithCount(BaseModel):
    id: int
    name: str
    unique_code: int
    owner_id: int
    user_count : int
    inventory_count : int

    class Config:
        orm_mode = True

class FrigerDetailResponse(FrigerResponse):
    user_list: List[int]  # 포함된 유저 ID 리스트
    inverntory_list : List[InventoryResponse] #포함된 인벤토리 리스트

    class Config:
        orm_mode = True

# 1. Friger 생성
@router.post("/frigers/")
def create_friger(friger: FrigerCreate, db: Session = Depends(get_db), current_user: User = Depends()):
    unique_code = generate_unique_code(db)
    new_friger = Friger(
        name=friger.name, 
        owner_id=current_user.id, 
        unique_code=unique_code,
    )
    db.add(new_friger)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=400, detail="Failed to create unique Friger")
    db.refresh(new_friger)
    return new_friger

# 2. 내가 포함된 Friger List 조회
@router.get("/frigers/my/")
def get_my_frigers(db: Session = Depends(get_db), current_user: User = Depends()):
    frigers = db.query(Friger).filter(Friger.user_list.any(User.id == current_user.id)).all()

    result = []
    for friger in frigers:
        result.append(
            FrigerResponseWithCount(
                id=friger.id,
                name=friger.name,
                unique_code=friger.unique_code,
                owner_id=friger.owner_id,
                user_count=len(friger.user_list),
                inventory_count = len(friger.inventory_list)
            )
        )
    return result

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
                inverntory_list= [
                    InventoryResponse (
                        id = inventory.id,
                        name = inventory.name,
                        quantity = inventory.quantity,
                        category = inventory.category,
                        date= inventory.date,
                    )
                    for inventory in db_friger.inverntory_list
                ],
                user_list = User, #유저 스키마 추가 후 수정 필요
            )

# 4. Friger 수정 (Friger name, userlist 수정 가능)
@router.put("/frigers/{friger_id}")
def update_friger(friger_id: int, friger_update: FrigerUpdate, db: Session = Depends(get_db), current_user: User = Depends()):
    friger = db.query(Friger).filter(Friger.id == friger_id).first()
    if not friger:
        raise HTTPException(status_code=404, detail="Friger not found")
    
    if friger.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to update this friger")


    friger.name = friger_update.name
    friger.user_list = friger_update.user_list
    db.commit()
    db.refresh(friger)
    return friger

# 5. owner_id를 가진 user만 Friger 삭제 가능
@router.delete("/frigers/{friger_id}")
def delete_friger(friger_id: int, db: Session = Depends(get_db), current_user: User = Depends()):
    friger = db.query(Friger).filter(Friger.id == friger_id).first()
    if not friger:
        raise HTTPException(status_code=404, detail="Friger not found")
    
    if friger.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Only the owner can delete this friger")

    db.delete(friger)
    db.commit()
    return {"detail": "Friger deleted successfully"}

# 6. Inventory 생성
@router.post("/frigers/{friger_id}/inventories/")
def add_inventory(friger_id: int, inventory: InventoryCreate, db: Session = Depends(get_db)):
    db_inventory = Inventory(
        name =inventory.name,
        quantity = inventory.quantity,
        category = inventory.category,
        date = inventory.date,
        friger_id=friger_id
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
    for inventory in inventories :
        result.append(
            InventoryResponse(
                id = inventory.id,
                name = inventory.name,
                quantity=inventory.quantity,
                category= inventory.category,
                date = inventory.date,
            )
        )
    return result

# 8. 특정 Inventory 조회
@router.get("/frigers/{friger_id}/inventories/{inventory_id}")
def get_inventory(friger_id: int, inventory_id: int, db: Session = Depends(get_db)):
    inventory = db.query(Inventory).filter(Inventory.id == inventory_id, Inventory.friger_id == friger_id).first()
    if not inventory:
        raise HTTPException(status_code=404, detail="Inventory not found")

    return InventoryResponse (
        id = inventory.id,
        name = inventory.name,
        quantity=inventory.quantity,
        category= inventory.category,
        date = inventory.date,
    )

# 9. Inventory 수정
@router.put("/frigers/{friger_id}/inventories/{inventory_id}")
def update_inventory(friger_id: int, inventory_id: int, inventory_update: InventoryCreate, db: Session = Depends(get_db)):
    inventory = db.query(Inventory).filter(Inventory.id == inventory_id, Inventory.friger_id == friger_id).first()
    if not inventory:
        raise HTTPException(status_code=404, detail="Inventory not found")
    
    inventory.name = inventory_update.name
    inventory.quantity = inventory_update.quantity
    inventory.category = inventory_update.category
    inventory.date = inventory_update.date
    db.commit()
    db.refresh(inventory)
    return inventory

# 10. Inventory 삭제
@router.delete("/frigers/{friger_id}/inventories/{inventory_id}")
def delete_inventory(friger_id: int, inventory_id: int, db: Session = Depends(get_db)):
    inventory = db.query(Inventory).filter(Inventory.id == inventory_id, Inventory.friger_id == friger_id).first()
    if not inventory:
        raise HTTPException(status_code=404, detail="Inventory not found")
    
    db.delete(inventory)
    db.commit()
    return {"detail": "Inventory deleted successfully"}