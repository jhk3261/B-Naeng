from fastapi import APIRouter, Request
from fastapi.templating import Jinja2Templates
from dotenv import load_dotenv
import openai
import os
import re

router = APIRouter(tags=["추천레시피"])
isAuthenticated = False

templates = Jinja2Templates(directory="../front-web/templates")

def recommend_recipe(ingredient : dict):
    load_dotenv()
    openai.api_key = os.getenv("OPENAI_API_KEY")
    model = "gpt-4o"

    query = "매개변수로 전달받은 재료만으로 만들 수 있는 8가지 요리 이름과 레시피, 재료에 대해서 dict자료형으로 recipes = {'name' : '김치볶음밥', 'ingredients' : {'김치' : '1/2 포기', '양파' : '1개', '감자' : '1알'}, '레시피' : ['1. 양파를 얇게 썰어 팬에 볶습니다.', '2. 김치를 잘게 썰어 팬에 볶습니다.']}와 같은 형식으로, 그리고 한국어로 출력해줘."

    messages = [{
        "role" : "system",
        "content" : "다음 재료를 사용하세요: " + ", ".join([f"{key}: {value}" for key, value in ingredient.items()])
    },{
        "role" : "user",
        "content" : query
    }]

    completion = openai.chat.completions.create(model=model, messages=messages)
    text = completion.choices[0].message.content
    recipes = re.findall(r'```(.*?)```', text, re.DOTALL)
    # print(recipes[0].strip())
    return recipes

@router.get("/recommend/recipes")
async def recommendRecipes(request : Request, ingredient : dict):
    # 정제해서 사용하도록 수정하고 templates 수정 필요
    return templates.TemplateResponse(name="레시피페이지 들어갈 부분", context={"recipes" : recommend_recipe(ingredient)})


# ingredient = {
#     "돼지고기" : "300g",
#     "사과" : "3개",
#     "양파" : "3개",
#     "양배추" : "100g",
#     "감자" : "5알",
#     "김치" : "1포기"
# }
# print(recommend_recipe(ingredient))