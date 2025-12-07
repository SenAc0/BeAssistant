from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
import os

# Usar variable de entorno para la URL de la base de datos
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:admin1234@localhost:5432/mhu")
#DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:admin1234@postgres:5432/beacon_db")

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def create_table():
    Base.metadata.create_all(bind=engine)