from fastapi import APIRouter, Request, Cookie
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from urllib.parse import unquote


def isLogined(username):
    try:
        tmp_username = unquote(username)
        if tmp_username:
            return True
    except:
        return False


router = APIRouter()
templates = Jinja2Templates(directory="../front-web/templates")


@router.get("/", response_class=HTMLResponse)
async def landing(
    request: Request, login_error: bool = False, username: str = Cookie(None)
):
    # if isLogined(username):
    #     return RedirectResponse(url="/main")
    # else:
        return templates.TemplateResponse(
            "landing.html", {"request": request, "login_error": login_error}
        )


@router.get("/main", response_class=HTMLResponse)
async def main(request: Request, username: str = Cookie(None)):
    # if not isLogined(username):
    #     return RedirectResponse(url="/")

    return templates.TemplateResponse(
        "main.html", {"request": request, "username": username}
    )


@router.get("/payment", response_class=HTMLResponse)
async def payment(request: Request, counselor_item: int, username: str = Cookie(None)):
    # if not isLogined(username):
    #     return RedirectResponse(url="/")

    return templates.TemplateResponse(
        "payment.html",
        {"request": request, "username": username, "counselor_item": counselor_item},
    )
