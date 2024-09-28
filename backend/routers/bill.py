from fastapi import APIRouter, UploadFile
import requests, uuid, time, json
import google.generativeai as genai


######################## FUNCTIONS ########################
def process_infer_text(json_file_path):
    # JSON 파일 읽기
    with open(json_file_path, "r", encoding="utf-8") as file:
        data = json.load(file)

    result_text = ""

    # 이미지 내의 필드들 처리
    for image in data["images"]:
        for field in image["fields"]:
            infer_text = field["inferText"]
            line_break = field["lineBreak"]

            # lineBreak 여부에 따라 텍스트 처리
            if line_break:
                result_text += infer_text.strip() + "\n"  # 줄바꿈 추가
            else:
                result_text += infer_text.strip() + " "  # 단어 연결

    return result_text.strip()


def extract_items_from_receipt(receipt_text):
    # Gemini API에 전달할 프롬프트
    prompt = (
        """다음 영수증 텍스트에서 상품명과 개수를 추출하여 JSON 형식으로 만들어주세요.
        상품명이 긴 경우 줄바꿈(\\n)이 일어나있을 수 있으니 금액, 개수, 물품별 총 금액 등 줄 바꿈 양식을 잘 이해해서 상품명도 잘 이어주세요.(이을 때 \\n은 제거해주세요.)
    형식 : [
        {"name": "사과", "quantity": 3},
        {"name": "바나나", "quantity": 2}
    ]

    영수증 텍스트:"""
        + receipt_text
    )

    # Gemini API 호출
    response = chat_session.send_message(prompt)

    # 응답에서 JSON 문자열 추출
    json_string = response.text.strip()[7:-3]
    json_object = json.loads(json_string)

    return json_object


def convertImageToOCRJson(image_file, json_file_path):
    request_json = {
        "images": [{"format": "jpg", "name": "demo"}],
        "requestId": str(uuid.uuid4()),
        "version": "V2",
        "timestamp": int(round(time.time() * 1000)),
    }

    payload = {"message": json.dumps(request_json).encode("UTF-8")}
    files = [("file", image_file)]
    headers = {"X-OCR-SECRET": OCR_API_KEY}

    response = requests.request(
        "POST",
        OCR_API_URI,
        headers=headers,
        data=payload,
        files=files,
    )

    result = response.json()
    with open(json_file_path, "w", encoding="utf-8") as make_file:
        json.dump(result, make_file, indent="\t", ensure_ascii=False)


######################## (SECRET) VARIABLES ########################
OCR_API_URI = "https://iy8py6txd0.apigw.ntruss.com/custom/v1/34683/404b3b089d9d0ef56a6b253f2b598f7a59c7bbc062a7d3f2a07a85aab37c94a6/general"
OCR_API_KEY = "T3NpVVZKeUR4ekNHUkVMcE1iZm1oR01VbXBvZFBuTk8="
GEMINI_API_KEY = "AIzaSyAFwHB81_lgI8Gcfc2-DtnLV9RTjOsFQKU"
json_file_path = "./upload_bill_ocr_tmp/result.json"


######################## GEMINI API ########################
genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel(model_name="gemini-1.5-pro")
chat_session = model.start_chat(history=[])


######################## ROUTER ########################


router = APIRouter(tags=["영수증"])


@router.post("/process_bill")
async def process_bill(file: UploadFile):
    convertImageToOCRJson(await file.read(), json_file_path)  # save ocr json
    formatted_text = process_infer_text(json_file_path)  # ocr json -> text
    bill_json = extract_items_from_receipt(formatted_text)  # text -> bill json
    return bill_json
