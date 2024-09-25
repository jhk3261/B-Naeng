from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session

DATABASE_URL = "sqlite:///./B_Naeng.db"

engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def get_session():
    with Session(engine) as session:
        yield session


def reset_database():
    # 기존 테이블 삭제
    Base.metadata.drop_all(bind=engine)
    
    # 테이블 재생성
    Base.metadata.create_all(bind=engine)
    
    print("Database reset completed.")


# 이 함수는 필요할 때 호출하여 데이터베이스를 초기화할 수 있습니다.
#reset_database()
