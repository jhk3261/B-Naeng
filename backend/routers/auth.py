from fastapi import APIRouter, Form, Response, Depends, Request
from fastapi.responses import RedirectResponse

router = APIRouter()
isAuthenticated = False


@router.get("/api/QRLogin/{refrigerator_id}")
async def login(request: Request, refrigerator_id: int):
    global isAuthenticated
    isAuthenticated = True
    return RedirectResponse("/mobile_authenticated")


@router.get("/api/checkCondition")
async def check_condition(request: Request):
    return {"condition": isAuthenticated}