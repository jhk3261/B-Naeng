from fastapi import APIRouter, Form, Response, Depends
from fastapi.responses import RedirectResponse
from sqlalchemy.orm import Session
from urllib.parse import quote
from config.database import get_db
from api.models import User
import re

router = APIRouter()


@router.post("/api/login")
async def login(
    response: Response,
    username: str = Form(...),
    phonenumber: str = Form(...),
    PINCode: int = Form(...),
    db: Session = Depends(get_db),
):
    pass

    # phone_pattern = re.compile(r"^010-\d{4}-\d{4}$")
    # pin_pattern = re.compile(r"^\d{4}$")

    # if not phone_pattern.match(phonenumber) or not pin_pattern.match(str(PINCode)):
    #     response = RedirectResponse(url="/", status_code=302)
    #     response.set_cookie(key="form_error", value=True)
    #     return response

    # user = db.query(User).filter(User.phonenumber == phonenumber).first()

    # if not user:  # 신규유저
    #     print("신규 유저")
    #     new_user = User(username=username, phonenumber=phonenumber, pincode=PINCode)
    #     db.add(new_user)
    #     db.commit()
    #     db.refresh(new_user)

    #     response = RedirectResponse(url="/main", status_code=302)
    #     response.set_cookie(key="username", value=quote(username))
    #     response.set_cookie(key="welcome_new_user", value=True)
    #     return response
    # else:  # 기존 유저
    #     if user.username == username and user.pincode == PINCode:  # 로그인 성공
    #         print("기존 유저, 로그인 성공")
    #         response = RedirectResponse(url="/main", status_code=302)
    #         response.set_cookie(key="username", value=quote(username))
    #         return response
    #     else:  # 로그인 정보 일치 안함
    #         print("기존 유저, 로그인 실패")
    #         response = RedirectResponse(url="/", status_code=302)
    #         response.set_cookie(key="login_error", value=True)
    #         return response


@router.post("/api/logout")
async def logout(response: Response):
    pass
    # response = RedirectResponse(url="/", status_code=302)
    # response.delete_cookie(key="username")
    # return response
