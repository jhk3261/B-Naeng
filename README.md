# Hackathon_Team3

멋쟁이사자처럼 12기 해커톤 3팀 Repository 입니다~

### 환경 정리

가상환경 : Python 3.10
의존성 : requirements.txt 참조

### 가상환경 설치법

conda create -n hackathon python=3.10 -y
conda activate hackathon
pip install -r requirements.txt

### 이후 개발할 때

프로젝트 폴더를 Visual Studio Code로 열기
(중요: HACKATHON_TEAM3 폴더 자체를 열어야 함)

conda activate hackathon -> (hackathon) 이 왼쪽에 켜졌나 확인
서버 실행 : uvicorn main:app --reload
서버 종료 : Ctrl + C
