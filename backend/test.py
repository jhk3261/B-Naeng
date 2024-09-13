from config.database import get_db, SessionLocal
from api.models import User
from fastapi import Depends

db = SessionLocal()

user = User(username = "seojiwon",
        email = "seojiwon@gmail.com",
        nickname = "지원연구소",
        birth = 2002-10-30,
        gender = 1,
        recommender = "jiwon",
        location = "경상남도 진주시 가좌동",
        friger = "지원냉장고")

db.add(user)
db.commit()
db.refresh()