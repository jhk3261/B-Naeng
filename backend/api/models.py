from sqlalchemy import JSON, Column, ForeignKey, Integer, String, Text, Boolean
from random import random
from sqlalchemy import JSON, Column, Date, ForeignKey, Integer, String, Text
from config.database import Base
from sqlalchemy import Column, Integer, String, Text, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.sqlite import JSON


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True)
    username = Column(String, nullable=False)
    email = Column(String, unique=True, nullable=False)
    is_admin = Column(Boolean, default=False, nullable=False)

    ingredients = relationship("Ingredient", back_populates="user")
    mypage = relationship("MyPage", uselist=False, back_populates="user")
    owned_friger = relationship("Friger", back_populates="owner")
    

class Chat(Base): # 에러 때문에 임의로 추가
    __tablename__ = "chats"
    id = Column(Integer, primary_key=True)
    ingredient = relationship("Ingredient", back_populates="chat")


# 식재료 나눔 커뮤니티
class Ingredient(Base):
    __tablename__ = "ingredients"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    title = Column(String, nullable=False)
    contents = Column(Text, nullable=False)
    image_url = Column(String, nullable=True)
    is_shared = Column(Boolean, default=False, nullable=False)

    user = relationship("User", back_populates="ingredients")
    likes = relationship("Like", back_populates="ingredient", cascade="all, delete-orphan")
    comments = relationship("Comment", back_populates="ingredient", cascade="all, delete-orphan")
    scraps = relationship("Scrap", back_populates="ingredient", cascade="all, delete-orphan")


# 마이페이지
class MyPage(Base):
    __tablename__ = "mypage"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    profile_image_url = Column(String, nullable=True)
    green_points = Column(Integer, default=0, nullable=False)  # 그린 포인트
    fridge_count = Column(Integer, default=0, nullable=False)  # 냉장고 개수
    scrap_expanded = Column(Boolean, default=False, nullable=False)  # 스크랩 섹션 확장 여부

    user = relationship("User", back_populates="mypage")


class Tip(Base):
    __tablename__ = "tips"

    id = Column(Integer, primary_key=True, autoincrement=True)
    title = Column(String, nullable=False)
    contents = Column(Text, nullable=False)
    category = Column(Integer, nullable=False)  # 0: 레시피, 1: 특가, 2: 냉장고 팁
    pictures = Column(JSON, nullable=True)
    locationDong = Column(Text, nullable=False)

    likes = relationship("Like", back_populates="tip", cascade="all, delete-orphan")
    comments = relationship("Comment", back_populates="tip", cascade="all, delete-orphan")
    scraps = relationship("Scrap", back_populates="tip", cascade="all, delete-orphan")


# 좋아요 모델
class Like(Base):
    __tablename__ = "likes"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, nullable=False)
    tip_id = Column(Integer, ForeignKey("tips.id"), nullable=True)
    ingredient_id = Column(Integer, ForeignKey("ingredients.id"), nullable=True)

    tip = relationship("Tip", back_populates="likes")
    ingredient = relationship("Ingredient", back_populates="likes")


# 댓글 모델
class Comment(Base):
    __tablename__ = "comments"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, nullable=False)
    tip_id = Column(Integer, ForeignKey("tips.id"), nullable=True)
    ingredient_id = Column(Integer, ForeignKey("ingredients.id"), nullable=True)
    content = Column(Text, nullable=False)

    tip = relationship("Tip", back_populates="comments")
    ingredient = relationship("Ingredient", back_populates="comments")


# 스크랩 모델
class Scrap(Base):
    __tablename__ = "scraps"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, nullable=False)
    tip_id = Column(Integer, ForeignKey("tips.id"), nullable=True)
    ingredient_id = Column(Integer, ForeignKey("ingredients.id"), nullable=True)

    tip = relationship("Tip", back_populates="scraps")
    ingredient = relationship("Ingredient", back_populates="scraps")


class Friger(Base) :
    __tablename__ = "friger"

    id = Column(Integer, primary_key=True, autoincrement=True) #db에서의 아이디 
    name = Column(String, nullable=False)  # 냉장고 이름
    unique_code = Column(Integer, unique=True, nullable=False, default=lambda: random.randint(1000, 9999))  # 고유번호
    owner_id = Column(Integer, ForeignKey("users.id"), nullable=False)  # 대표 유저 ID

    inventory_list = relationship("Inventory", back_populates="friger")
    user_list = relationship("User", secondary='friger_user_association', back_populates="friger_list")
    owner = relationship("User", back_populates="owned_friger")  # 대표 유저와의 관계 (User모델에 owned_friger추가해주세요(권한가진냉장고리스트))


class Inventory(Base):
    __tablename__ = "inventory"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String, index=True)
    quantity = Column(Integer)
    date = Column(Date, nullable=True)
    #icon = 이미지 어케넣더라.. #milk.png 검색
    category = Column(String, nullable=False)

    friger_id = Column(Integer, ForeignKey("friger.id"))
    friger = relationship("Friger", back_populates="inventory_list")
    
class RecommendRecipe(Base):
    __tablename__ = "recommendrecipes"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
