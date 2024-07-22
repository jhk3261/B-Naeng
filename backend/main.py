from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from routers import auth, html
from config.database import engine, Base

app = FastAPI()

# static 폴더 연결
app.mount("/static", StaticFiles(directory="../front-web/static"), name="static")

# 데이터베이스 초기화
Base.metadata.create_all(bind=engine)

# 라우터 포함
app.include_router(auth.router)
app.include_router(html.router)
