from fastapi import APIRouter, Response, Request
from fastapi.responses import HTMLResponse, JSONResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
import requests
from session import set_session

router = APIRouter(tags=["인증"])
isAuthenticated = False

templates = Jinja2Templates(directory="../front-web/templates")

CLIENT_ID = "e5e58a0694a84359c10573f8208b6c40"
CLIENT_SECRET = "KCF9TckDfroEY2idqKgYwqOLWKNPHYwt"
REDIRECT_URI = "http://localhost:8000/oauth/kakao"
KAUTH_HOST = "https://kauth.kakao.com"
KAPI_HOST = "https://kapi.kakao.com"


@router.get("/login", response_class=HTMLResponse)
async def index(request: Request):
    return templates.TemplateResponse(name="index.html", request=request)


@router.get("/authorize")
async def authorize(request: Request):
    scope_param = ""
    scope = request.query_params.get("scope")
    if scope:
        scope_param = "&scope={}".format(scope)

    oauth_url = (
        "{}/oauth/authorize?response_type=code&client_id={}&redirect_url={}{}".format(
            KAUTH_HOST, CLIENT_ID, REDIRECT_URI, scope_param
        )
    )
    return RedirectResponse(url=oauth_url)


@router.get("/oauth/kakao")
async def redirect_page(request: Request, response: Response):
    data = {
        "grant_type": "authorization_code",
        "client_id": CLIENT_ID,
        "redirect_uri": REDIRECT_URI,
        "client_secret": CLIENT_SECRET,
        "code": request.query_params.get("code"),
    }
    resp = requests.post(KAUTH_HOST + "/oauth/token", data=data)
    access_token = resp.json().get("access_token")

    if access_token:
        set_session(response, {"access_token": access_token})
        return RedirectResponse(url="/login")
    else:
        return JSONResponse(
            content={"error": "Failed to obtain access token"}, status_code=400
        )
