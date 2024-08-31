from sqlalchemy import JSON, Column, ForeignKey, Integer, String, Text
from config.database import Base
from sqlalchemy import Column, Integer, String, Text, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.sqlite import JSON


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True)
    username = Column(String, nullable=False)
    phonenumber = Column(String, unique=True, nullable=False)
    pincode = Column(Integer, nullable=False)


class Tip(Base):
    __tablename__ = "tips"

    id = Column(Integer, primary_key=True, autoincrement=True)
    title = Column(String, nullable=False)
    contents = Column(Text, nullable=False)
    category = Column(Integer, nullable=False)  # 0: 레시피, 1: 특가, 2: 냉장고 팁
    pictures = Column(JSON, nullable=True)

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
