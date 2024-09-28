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
import time
import httpx
from api.models import Recipe
import requests
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException, TimeoutException
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
import concurrent.futures


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
    return recipes


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
                    f"가지고 있는 재료에 1~2가지의 재료를 구매하면 만들 수 있는 8종류의 음식 레시피를 알려줘. : {ingredient_str}, "
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
    # print("OpenAI 응답:", response.choices[0].message.content)


    return eval(response.choices[0].message.content)


def get_additional_recipes(ingredient : dict):
    load_dotenv()
    openai.api_key = os.getenv("OPENAI_API_KEY")
    ingredient_str = ", ".join([f"{key}: {value}" for key, value in ingredient.items()])

    recipes = recommend_additional_recipe(ingredient_str)
    if (len(recipes) != 8):
        while(True):
            recipes = recommend_additional_recipe(ingredient_str)
            if (len(eval(recipes)) == 8):
                break
    return recipes    

def setup_driver():
    options = webdriver.ChromeOptions()
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument("--disable-blink-features=AutomationControlled")
    options.add_argument('user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36')
    options.add_argument('--disable-gpu')
    service = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service, options=options)
    return driver

# 쿠팡 url 크롤링
def search_coupang_link(keyword : list):
    driver = setup_driver()
    driver.get("https://www.coupang.com/")

    try:
        try:
            closeBtn = WebDriverWait(driver, 5).until(EC.element_to_be_clickable((By.CLASS_NAME, "close")))
            closeBtn.click()
        except:
            pass

        search_box = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.NAME, "q")))
        search_box.send_keys(keyword)
        search_box.send_keys(Keys.RETURN)

        WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.CLASS_NAME, "search-product")))

        products = driver.find_elements(By.CLASS_NAME, "search-product")
        # items = []
        # for product in products:
        #     ahref = product.find_element(By.TAG_NAME, 'a')
        #     item = ahref.get_attribute('href')
        #     items.append(item)

        items = []
        ahref = products[0].find_element(By.TAG_NAME, 'a')
        item = ahref.get_attribute('href')
        items.append(item)
        # return items
        return keyword, items
    except TimeoutException:
        print("페이지 로딩 시간이 초과되었습니다. 네트워크 연결을 확인하거나 나중에 다시 시도해주세요.")
        return []
    except Exception as e:
        print(f"크롤링 중 오류가 발생했습니다: {str(e)}")
        return []
    finally:
        driver.quit()


def search_multiple_keywords(keywords):
    results = {}
    
    with concurrent.futures.ThreadPoolExecutor() as executor:
        future_to_keyword = {executor.submit(search_coupang_link, keyword): keyword for keyword in keywords}
        
        for future in concurrent.futures.as_completed(future_to_keyword):
            keyword = future_to_keyword[future]
            try:
                keyword, links = future.result()
                results[keyword] = links
            except Exception as e:
                print(f"{keyword} 처리 중 오류: {str(e)}")

    return results

# 식재료 기반 레시피 추천 생성
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

# 식재료 기반 추천 레시피 불러오기
@router.get("/recipes/recommend")
async def loadRecommendRecipes(friger_id: int = 1, db: Session = Depends(get_db)):
    user_recipe_db = db.query(Recipe).filter(Recipe.friger_id == friger_id).first()
    user_recipe = user_recipe_db.recommend_recipes
    user_additional_recipe = user_recipe_db.recommend_recipes_more
    # recipe_names = {value["요리 이름"] for key, value in user_recipe.items()}
    recipes = []
    additional_recipes = []
    additional_ingredients = []
    for key, value in user_recipe.items():
        recipes.append({'title' : value['요리 이름'], 'ingredients' : value['재료'], 'steps' : value['레시피']})

    for key, value in user_additional_recipe.items():
        # coupangUrl = search_coupang_link(value['필요한 재료'])
        additional_ingredients.append(value['필요한 재료'])
        additional_recipes.append({'title' : value['요리 이름'], 'ingredients' : value['재료'], 'additional_ingredients' : value['필요한 재료'], 'steps' : value['레시피']})

    additional_ingredients_list = [item for sublist in additional_ingredients for item in sublist]
    additional_ingredients_url = search_multiple_keywords(additional_ingredients_list)
    # print(additional_ingredients_list)

    return {"레시피" : recipes, "추가레시피" : additional_recipes, "추가재료" : additional_ingredients_url}
        
        
# @router.post("/recipes/recommend/additional")
# async def recommendAdditinoalRecipes(ingredient: IngredientInput):
#     recipes = recommend_additional_recipe(ingredient.ingredient)
#     return recipes

@router.post("/recipes/recommend/additional")
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
                recipes = get_additional_recipes(ingredient.ingredient)
                existing_recipes.recommend_recipes = recipes
                existing_recipes.recommend_recipes_more = recipes
                existing_recipes.create_time = datetime.now()
                db.commit()
                db.refresh(existing_recipes)
        else:
            recipes = get_additional_recipes(ingredient.ingredient)
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
