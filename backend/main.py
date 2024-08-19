import uvicorn
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from routers import auth, html
from config.database import engine, Base
from fastapi.responses import FileResponse

app = FastAPI()

# static 폴더 연결
app.mount("/static", StaticFiles(directory="../front-web/static"), name="static")

# 데이터베이스 초기화
Base.metadata.create_all(bind=engine)

# 라우터 포함
app.include_router(auth.router)
app.include_router(html.router)


@app.get("/favicon.ico", include_in_schema=False)
async def favicon():
    return FileResponse("favicon.ico")


# HOST와 PORT 설정
# HOST = "127.0.0.1"
# PORT = 8000

# if __name__ == "__main__":
#     uvicorn.run("main:app", host=HOST, port=PORT, reload=True)

HOST = "0.0.0.0"
PORT = 8000

if __name__ == "__main__":
    uvicorn.run("main:app", host=HOST, port=PORT, reload=True)