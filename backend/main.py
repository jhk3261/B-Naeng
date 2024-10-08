import uvicorn
from fastapi import FastAPI
from config.database import engine, Base
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.cors import CORSMiddleware
from routers import (
    auth,
    tips,
    ingredients,
    users,
    recipe,
    mypage,
    friger,
    bill,
)


app = FastAPI()


# CORS 설정 추가
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 또는 허용할 도메인 목록
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# 데이터베이스 초기화
Base.metadata.create_all(bind=engine)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 라우터 포함
app.include_router(auth.router)
app.include_router(tips.router)
app.include_router(ingredients.router)
app.include_router(users.router)
app.include_router(recipe.router)
app.include_router(friger.router)
app.include_router(mypage.router)
app.include_router(bill.router)


@app.get("/favicon.ico", include_in_schema=False)
async def favicon():
    return FileResponse("favicon.ico")


HOST = "127.0.0.1:8000"
PORT = 8000

if __name__ == "__main__":
    uvicorn.run("main:app", host=HOST, port=PORT, reload=True)
