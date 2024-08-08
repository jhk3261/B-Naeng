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


router = APIRouter(tags=["HTML"])
templates = Jinja2Templates(directory="../front-web/templates")


@router.get("/", response_class=HTMLResponse)
async def landing(request: Request):
    return templates.TemplateResponse("QR/landing.html", {"request": request})


@router.get("/main", response_class=HTMLResponse)
async def main(request: Request):
    return templates.TemplateResponse("main/main.html", {"request": request})


@router.get("/mobile_authenticated", response_class=HTMLResponse)
async def mobile_authenticated(request: Request):
    return templates.TemplateResponse("QR/mobileQRResponse.html", {"request": request})
