from sqlalchemy import (
    JSON,
    Column,
    ForeignKey,
    Integer,
    String,
    Text,
    Boolean,
    DateTime,
    Table,
)

from random import random
from sqlalchemy import JSON, Column, Date, ForeignKey, Integer, String, Text
from config.database import Base
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.sqlite import JSON
from datetime import datetime


# 유저와 냉장고 관계 테이블 (다대다 관계 설정)
friger_user_association = Table(
    "friger_user_association",
    Base.metadata,
    Column("user_id", Integer, ForeignKey("users.id")),
    Column("friger_id", Integer, ForeignKey("frigers.id")),
)

# 유저 모델
class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, autoincrement=True)
    username = Column(String, nullable=False)
    email = Column(String, unique=True, nullable=False)
    is_admin = Column(Boolean, default=False, nullable=False)
    nickname = Column(String, nullable=False)
    birth = Column(DateTime, nullable=False)
    gender = Column(Integer, nullable=False)
    recommender = Column(String, nullable=True)
    location = Column(String, nullable=False)

    owned_friger = relationship(
        "Friger", back_populates="owner", cascade="all, delete-orphan"
    )
    frigers = relationship(
        "Friger", secondary=friger_user_association, back_populates="users"
    )
    ingredients = relationship("Ingredient", back_populates="users")
    
    # MyPage와의 관계 설정
    mypage = relationship("MyPage", back_populates="user", uselist=False)


# 마이페이지 모델
class MyPage(Base):
    __tablename__ = "mypage"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    username = Column(Text, nullable=False)
    profile_image_url = Column(String, nullable=True)
    green_points = Column(Integer, default=0, nullable=False)  # 그린 포인트
    fridge_count = Column(Integer, default=0, nullable=False)  # 냉장고 개수
    scrap_expanded = Column(Boolean, default=False, nullable=False)  # 스크랩 섹션 확장 여부

    user = relationship("User", back_populates="mypage")


# 식재료 나눔 커뮤니티
class Ingredient(Base):
    __tablename__ = "ingredients"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    title = Column(String, nullable=False)
    contents = Column(Text, nullable=False)
    image_url = Column(String, nullable=True)
    is_shared = Column(Boolean, default=False, nullable=False)

    users = relationship("User", back_populates="ingredients")
    likes = relationship(
        "Like", back_populates="ingredient", cascade="all, delete-orphan"
    )
    comments = relationship(
        "Comment", back_populates="ingredient", cascade="all, delete-orphan"
    )
    scraps = relationship(
        "Scrap", back_populates="ingredient", cascade="all, delete-orphan"
    )


# 냉장고 모델
class Friger(Base):
    __tablename__ = "frigers"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String, nullable=False)  # 냉장고 이름
    unique_code = Column(Integer, unique=True, nullable=False, default=lambda: random.randint(1000, 9999))  # 고유번호
    owner_id = Column(Integer, ForeignKey("users.id"), nullable=False)  # 대표 유저 ID

    inventory_list = relationship("Inventory", back_populates="friger")
    users = relationship("User", secondary=friger_user_association, back_populates="frigers")
    owner = relationship("User", back_populates="owned_friger")


# 냉장고 인벤토리
class Inventory(Base):
    __tablename__ = "inventory"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String, index=True)
    quantity = Column(Integer)
    date = Column(Date, nullable=True)
    category = Column(String, nullable=False)

    friger_id = Column(Integer, ForeignKey("frigers.id"))
    friger = relationship("Friger", back_populates="inventory_list")


# 추천 레시피
class RecommendRecipe(Base):
    __tablename__ = "recommendrecipes"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)


# 팁 모델
class Tip(Base):
    __tablename__ = "tips"

    id = Column(Integer, primary_key=True, autoincrement=True)
    title = Column(String, nullable=False)
    contents = Column(Text, nullable=False)
    category = Column(Integer, nullable=False)  # 0: 레시피, 1: 특가, 2: 냉장고 팁
    pictures = Column(JSON, nullable=True)
    locationDong = Column(Text, nullable=False)

    likes = relationship("Like", back_populates="tip", cascade="all, delete-orphan")
    comments = relationship(
        "Comment", back_populates="tip", cascade="all, delete-orphan"
    )
    scraps = relationship("Scrap", back_populates="tip", cascade="all, delete-orphan")


# 좋아요 모델
class Like(Base):
    __tablename__ = "likes"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    tip_id = Column(Integer, ForeignKey("tips.id"), nullable=True)
    ingredient_id = Column(Integer, ForeignKey("ingredients.id"), nullable=True)

    tip = relationship("Tip", back_populates="likes")
    ingredient = relationship("Ingredient", back_populates="likes")


# 댓글 모델
class Comment(Base):
    __tablename__ = "comments"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    tip_id = Column(Integer, ForeignKey("tips.id"), nullable=True)
    ingredient_id = Column(Integer, ForeignKey("ingredients.id"), nullable=True)
    content = Column(Text, nullable=False)
    created_at = Column(DateTime, nullable=True, default=datetime.now())

    tip = relationship("Tip", back_populates="comments")
    ingredient = relationship("Ingredient", back_populates="comments")


# 스크랩 모델
class Scrap(Base):
    __tablename__ = "scraps"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    tip_id = Column(Integer, ForeignKey("tips.id"), nullable=True)
    ingredient_id = Column(Integer, ForeignKey("ingredients.id"), nullable=True)

    tip = relationship("Tip", back_populates="scraps")
    ingredient = relationship("Ingredient", back_populates="scraps")
