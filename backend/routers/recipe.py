from fastapi import APIRouter, Response, Depends, HTTPException, status
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Dict, List
from datetime import datetime, timedelta
from dotenv import load_dotenv
from config.database import get_db
import openai
import os
import json
import httpx
from api.models import Recipe
import requests
from bs4 import BeautifulSoup

# import pyautogui
# import openpyxl

router = APIRouter(tags=["레시피"])
isAuthenticated = False

class IngredientInput(BaseModel):
    ingredient: Dict[str, int]  

class Recipes(BaseModel):
    friger_unique_code : int
    create_time : datetime
    recommend_recipes : Dict[str, str]
    recommend_recipes_more : Dict[str, str]

class RecipesUpdate(BaseModel):
    create_tiime : datetime
    recommend_recipes : Dict[str, str]
    recommend_recipes_more : Dict[str, str]

# 레시피 추천 함수
def recommend_recipe(ingredient_str : str):
    response = openai.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {
                "role" : "system",
                "content" : "가지고 있는 식재료만을 사용해서 레시피를 추천해줘"
            },
            {
                "role" : "user",
                "content" : (
                    f"해당 재료만을 사용해서 8종류의 음식 레시피를 알려줘. : {ingredient_str}, "
                    "레시피는 5단계로 반환할 수 있도록 해줘. "
                    "레시피를 json 형식으로 다음과 같이 반환해줘 : {{'요리 이름': '<Dish Name>', '재료': ['<ingredient1>', '<ingredient2>', ...], '레시피': ['<step1>', '<step2>', ...]}}"
                )
            }
        ],
        response_format={"type" : "json_object"},
        temperature=0,
        n=1,
        top_p = 1,
        frequency_penalty = 0,
        presence_penalty = 0,
    )

    return eval(response.choices[0].message.content)


# 추가 레시피 추천 함수
def recommend_additional_recipe(ingredient_str : str):
    response = openai.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {
                "role" : "system",
                "content" : "가지고 있는 식재료만을 사용해서 레시피를 추천해줘"
            },
            {
                "role" : "user",
                "content" : (
                    f"해당 재료에 1~2가지의 재료를 구매하면 만들 수 있는 8종류의 음식 레시피를 알려줘. : {ingredient_str}, "
                    "레시피는 5단계로 반환할 수 있도록 해줘."
                    "레시피를 json 형식으로 다음과 같이 반환해줘 : {{'요리 이름': '<Dish Name>', '재료': ['<ingredient1>', '<ingredient2>', ...], '필요한 재료': ['<additional ingredient1>', '<additional ingredient2>', ...], '레시피': ['<step1>', '<step2>', ...]}}"
                )
            }
        ],
        response_format={"type" : "json_object"},
        temperature=0,
        n=1,
        top_p = 1,
        frequency_penalty = 0,
        presence_penalty = 0,
    )

    return response.choices[0].message.content


def get_recipes(ingredient : dict):
    load_dotenv()
    openai.api_key = os.getenv("OPENAI_API_KEY")
    ingredient_str = ", ".join([f"{key}: {value}" for key, value in ingredient.items()])
    
    recipes = recommend_recipe(ingredient_str)
    if (len(recipes) != 8):
        while(True):
            recipes = recommend_recipe(ingredient_str)
            if (len(eval(recipes)) == 8):
                break
    # additional_recipes = recommend_additional_recipe(ingredient_str)

    # recipes_json = json.load(recipes)
    # additional_recipes_json = json.load(additional_recipes)
    
    # if (len(additional_recipes_json) != 8):
    #     while(True):
    #         additional_recipes_json = recommend_recipe(ingredient_str)
    #         if (len(eval(additional_recipes_json)) == 8):
    #             break
    return recipes

@router.post("/recipes/recommend")
async def recommendRecipes(response: Response, ingredient: IngredientInput, friger_id : int = 1, db: Session=Depends(get_db)):
    try:
        existing_recipes = db.query(Recipe).filter(Recipe.friger_id == friger_id).first()
        # existing_recipes = db.query(Recipe).filter(Recipe.friger_unique_code == recipes.friger_unique_code).first()
        if existing_recipes:
            time_gap = datetime.now() - existing_recipes.create_time
            if (time_gap <= timedelta(hours=1)):
                response.status_code = status.HTTP_204_NO_CONTENT
                return 
            else:
                recipes = get_recipes(ingredient.ingredient)
                existing_recipes.recommend_recipes = recipes
                existing_recipes.recommend_recipes_more = recipes
                existing_recipes.create_time = datetime.now()
                db.commit()
                db.refresh(existing_recipes)
        else:
            recipes = get_recipes(ingredient.ingredient)
            new_recipes = Recipe(
                friger_id = friger_id,
                create_time = datetime.now(),
                recommend_recipes = recipes,
                recommend_recipes_more = recipes
            )
            db.add(new_recipes)
            db.commit()
            db.refresh(new_recipes)
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))

    return recipes


# 수정 필요
@router.get("/search/potato")
async def search_potato():
    try:
        # 쿠팡의 검색 URL
        url = "https://www.coupang.com/np/search?q=감자"
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.82 Safari/537.36"
        }
        
        response = requests.get(url, headers=headers)
        
        if response.status_code != 200:
            raise HTTPException(status_code=response.status_code, detail="Failed to retrieve data")
        
        soup = BeautifulSoup(response.text, 'html.parser')
        
        product_link = soup.find("a", class_="search-product-link")
        
        if product_link:
            return {"url": product_link['href']} 
        else:
            return {"message": "No products found"}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/recipes/recommend/additional")
async def recommendAdditinoalRecipes(ingredient: IngredientInput):
    recipes = recommend_additional_recipe(ingredient.ingredient)
    return recipes


@router.post("/additional/ingredient")
async def additional_ingredient(ingredients: List[str]):
    additional_ingredient_list = []
    async with httpx.AsyncClient() as client:
        for ingredient in ingredients:
            url = f"https://www.coupang.com/np/search?component=&q={ingredient}"
            response = await client.get(url)
            if response.status_code == 200:
                soup = BeautifulSoup(response.text, "html.parser")
                first_product = soup.select_one("a.search-product-link")
                if first_product:
                    product_url = "https://www.coupang.com" + first_product["href"]
                    additional_ingredient_list.append(product_url)
    return additional_ingredient_list
