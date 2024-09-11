from fastapi import APIRouter, Request
from fastapi.templating import Jinja2Templates
from pydantic import BaseModel
from typing import Dict, List
from dotenv import load_dotenv
import openai
import os
import re
import json
import ast
import httpx

import requests
from bs4 import BeautifulSoup
# import pyautogui
# import openpyxl


router = APIRouter(tags=["레시피"])
isAuthenticated = False

class IngredientInput(BaseModel):
    ingredient : Dict[str, str]

# 레시피 추천 함수
def recommend_recipe(ingredient : dict):
    load_dotenv()
    openai.api_key = os.getenv("OPENAI_API_KEY")
    response = openai.chat.completions.create(
        model="gpt-4o",
        messages=[
            {
                "role" : "system",
                "content" : "다음 재료를 사용하세요 : " + ", ".join([f"{key} : {value}" for key, value in ingredient.items()])
            },
            {
                "role" : "user",
                "content" : "매개변수로 전달받은 재료만으로 만들 수 있는 요리 8가지 이름과 레시피, 재료에 대해서 dict 자료형으로 recipes = {'name' : '김치볶음밥', 'ingredients' : {'김치' : '1/2 포기', '양파' : '1개', '감자' : '1알'}, '레시피' : ['1. 양파를 얇게 썰어 팬에 볶습니다.', '2. 김치를 잘게 썰어 팬에 볶습니다.']}와 같은 형식으로, 그리고 한국어로 출력해줘."
            }
        ]
    )
    response_text = response.choices[0].message.content
    start_idx = response_text.find("recipes = [")
    if start_idx != -1:
        recipes_text = response_text[start_idx:]
        recipes_text = recipes_text.split("\n\n")[0]
        try:
            recipes_text = recipes_text.replace('"', "'")
            # recipes_dict = json.loads(recipes_text)

            # recipes_json = json.dumps(recipes_dict, ensure_ascii=False, indent=4)
            return recipes_text
        except (SyntaxError, ValueError):
            return "파싱에러!!!!!!!"
    else:
        return "에러발생!! 에러발생!!"
    
# 추가 레시피 추천 함수
def recommend_additinoal_recipe(ingredient : dict):
    load_dotenv()
    openai.api_key = os.getenv("OPENAI_API_KEY")
    response = openai.chat.completions.create(
        model="gpt-4o",
        messages=[
            {
                "role" : "system",
                "content" : "다음 재료를 사용하세요 : " + ", ".join([f"{key} : {value}" for key, value in ingredient.items()])
            },
            {
                "role" : "user",
                "content" : "매개변수로 전달받은 재료에 추가로 1~2가지 재료를 구매하면 만들 수 있는 요리 8가지 이름과 레시피, 재료에 대해서 dict 자료형으로 recipes = {'name' : '김치볶음밥', 'ingredients' : {'김치' : '1/2 포기', '양파' : '1개', '감자' : '1알', '계란(추가)' : '2알'}, '레시피' : ['1. 양파를 얇게 썰어 팬에 볶습니다.', '2. 김치를 잘게 썰어 팬에 볶습니다.']}와 같은 형식으로, 그리고 한국어로 출력해줘."
            }
        ]
    )
    response_text = response.choices[0].message.content
    start_idx = response_text.find("recipes = [")
    if start_idx != -1:
        recipes_text = response_text[start_idx:]
        recipes_text = recipes_text.split("\n\n")[0]
        try:
            recipes_text = recipes_text.replace('"', "'")
            # recipes_dict = json.loads(recipes_text)

            # recipes_json = json.dumps(recipes_dict, ensure_ascii=False, indent=4)
            return recipes_text
        except (SyntaxError, ValueError):
            return "파싱에러!!!!!!!"
    else:
        return "에러발생!! 에러발생!!"
    




# api 두개로 만들긴 했는데 추후에 수정 예정
# 요리 이름만 출력하는 api 하나랑, 모달용 api가 필요할 듯 한데 로딩시간이 오래 걸려서 api 사용 제한을 걸거나 db에 저장하는 방식을 사용하는 것이 좋을 듯
@router.post("/recommend/recipes")
async def recommendRecipes(ingredient : IngredientInput):
    recipes = recommend_recipe(ingredient.ingredient)
    return recipes
 

@router.post("/recommend/recipes/additional")
async def recommendAdditinoalRecipes(ingredient : IngredientInput):
    recipes = recommend_additinoal_recipe(ingredient.ingredient)
    recipes_list = json.load(recipes)
    additional_ingredient = []
    for recipe in recipes_list:
        ingredients = recipe['ingredients']
        for ingredient, amount in ingredients.items():
            if "(추가)" in ingredient:
                additional_ingredient.append(ingredient)
    return recipes, additional_ingredient



@router.post("/additional/ingredient")
async def additional_ingredient(ingredients: List[str]):
    additional_ingredient_list = []
    async with httpx.AsyncClient() as client:
        for ingredient in ingredients:
            url = f"https://www.coupang.com/np/search?component=&q={ingredient}"
            response = await client.get(url)
            if response.status_code == 200:
                soup = BeautifulSoup(response.text, 'html.parser')
                first_product = soup.select_one('a.search-product-link')
                if first_product:
                    product_url = "https://www.coupang.com" + first_product['href']
                    additional_ingredient_list.append(product_url)
    return additional_ingredient_list
        
            

# ingredient = {
    # "돼지고기" : "300g",
    # "사과" : "3개",
    # "양파" : "3개",
    # "양배추" : "100g",
    # "감자" : "5알",
    # "김치" : "1포기"
# }
