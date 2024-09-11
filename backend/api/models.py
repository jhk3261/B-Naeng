from sqlalchemy import JSON, Column, ForeignKey, Integer, String, Text, Boolean
from config.database import Base
from sqlalchemy import Column, Integer, String, Text, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.sqlite import JSON

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True)
    username = Column(String, nullable=False)
    email = Column(String, unique=True, nullable=False)

    ingredients = relationship("Ingredient", back_populates="user")

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
    image_url = Column(String, nullable=True) # 이미지 url 저장
    contents = Column(Text, nullable=False)
    is_shared = Column(Boolean, default=False, nullable=False)
    ingredient_id = Column(Integer, ForeignKey('ingredients.id'), nullable=True)
    chat_id = Column(Integer, ForeignKey('chats.id'))
    
    user = relationship("User", back_populates="ingredients")
    chat = relationship('Chat', back_populates='ingredient')


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


class Like(Base):
    __tablename__ = "likes"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, nullable=False)
    tip_id = Column(Integer, ForeignKey("tips.id"), nullable=False)

    tip = relationship("Tip", back_populates="likes")


class Comment(Base):
    __tablename__ = "comments"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, nullable=False)
    tip_id = Column(Integer, ForeignKey("tips.id"), nullable=False)
    content = Column(Text, nullable=False)

    tip = relationship("Tip", back_populates="comments")


class Scrap(Base):
    __tablename__ = "scraps"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, nullable=False)
    tip_id = Column(Integer, ForeignKey("tips.id"), nullable=False)

    tip = relationship("Tip", back_populates="scraps")


class RecommendRecipe(Base):
    __tablename__ = "recommendrecipes"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)