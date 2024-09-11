import uvicorn
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from routers import auth, tips, ingredients, kakao_auth
from config.database import engine, Base
from fastapi.responses import FileResponse
from starlette.middleware.cors import CORSMiddleware

app = FastAPI()

# static 폴더 연결
app.mount("/static", StaticFiles(directory="static"), name="static")

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
app.include_router(html.router)
app.include_router(kakao_auth.router)
app.include_router(tips.router)
app.include_router(ingredients.router)

@app.get("/favicon.ico", include_in_schema=False)
async def favicon():
    return FileResponse("favicon.ico")


HOST = "127.0.0.1"
PORT = 8000

if __name__ == "__main__":
    uvicorn.run("main:app", host=HOST, port=PORT, reload=True)
