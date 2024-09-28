from sqlalchemy import (
    JSON,
    Boolean,
    Column,
    Date,
    ForeignKey,
    DateTime,
    Integer,
    String,
    Table,
    Text,
)
from random import random
from config.database import Base
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.sqlite import JSON
from datetime import datetime


# 유저 모델
class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, autoincrement=True)
    username = Column(String, nullable=False)
    email = Column(String, unique=True, nullable=False)
    # is_admin = Column(Boolean, default=False, nullable=False)
    nickname = Column(String, nullable=False)
    birth = Column(DateTime, nullable=False)
    gender = Column(Integer, nullable=False)
    recommender = Column(String, default="", nullable=True)
    location = Column(String, nullable=False)
    green_points = Column(Integer, default=0, nullable=False)

<<<<<<< HEAD
    # owned_friger = relationship(
    #     "Friger", back_populates="owner", cascade="all, delete-orphan"
    # )
    # frigers = relationship(
    #     "Friger", secondary=friger_user_association, back_populates="users"
    # )

    frigers = relationship(
        "Friger", secondary=friger_user_association, back_populates="users"
    )

=======
    #냉장고와의 관계 설정
    frigers = relationship(
        "Friger", back_populates="user_list", cascade="all, delete-orphan"
    )
>>>>>>> 80ef084b1cfb344479bec3c5ba5cf37aed478673
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
    green_points = Column(Integer, default=0, nullable=False)
    fridge_count = Column(Integer, default=0, nullable=False)
    scrap_expanded = Column(Boolean, default=False, nullable=False)

    user = relationship("User", back_populates="mypage")


# 식재료 나눔 커뮤니티
class Ingredient(Base):
    __tablename__ = "ingredients"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    title = Column(String, nullable=False)
    contents = Column(Text, nullable=False)
    pictures = Column(JSON, nullable=True)
    is_shared = Column(Boolean, default=False, nullable=False)
    locationDong = Column(Text, nullable=False)

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
    unique_code = Column(Integer, nullable=True)
    owner_id = Column(Integer, nullable=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    users = relationship(
        "User", secondary=friger_user_association, back_populates="frigers"
    )

    inventory_list = relationship(
        "Inventory", back_populates="friger", cascade="all, delete-orphan"
    )
    user_list = relationship(
        "User", back_populates="frigers",
    )


# 냉장고 인벤토리
class Inventory(Base):
    __tablename__ = "inventory"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String, index=True)
    quantity = Column(Integer)
    date = Column(Date, nullable=True)
    category = Column(String, nullable=False)
    friger_id = Column(Integer, ForeignKey("frigers.id"), nullable=False)

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


class Recipe(Base):
    __tablename__ = "recipes"

    id = Column(Integer, primary_key=True, autoincrement=True)
    friger_id = Column(Integer, ForeignKey("frigers.id"), nullable=False)
    create_time = Column(DateTime, nullable=False)
    recommend_recipes = Column(JSON, nullable=False)
    recommend_recipes_more = Column(JSON, nullable=False)
<<<<<<< HEAD
=======

>>>>>>> 80ef084b1cfb344479bec3c5ba5cf37aed478673
