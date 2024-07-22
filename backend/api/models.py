from sqlalchemy import Column, Integer, String
from config.database import Base
from pydantic import BaseModel


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True)
    username = Column(String, nullable=False)
    phonenumber = Column(String, unique=True, nullable=False)
    pincode = Column(Integer, nullable=False)
