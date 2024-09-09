from fastapi import Request, Response
from itsdangerous import URLSafeSerializer


SECRET_KEY = 'your_secret_key'
serializer = URLSafeSerializer(SECRET_KEY)

SESSION_COOKIE_NAME = "session_cookie"

def set_session(response : Response, data : dict):
    session_cookie = serializer.dumps(data)
    response.set_cookie(key=SESSION_COOKIE_NAME,
                        value=session_cookie,
                        httponly=True)
    
def get_session(request : Request):
    session_cookie = request.cookies.get(SESSION_COOKIE_NAME)
    if session_cookie:
        try:
            return serializer.loads(session_cookie)
        except Exception:
            return {}
    return {}