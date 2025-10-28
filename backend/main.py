from fastapi import FastAPI, Depends, HTTPException, status
import crud, models, schemas, auth
from db import get_db, engine
from sqlalchemy.orm import Session
from fastapi.security import OAuth2PasswordBearer
from pydantic import BaseModel

# ¡IMPORTANTE! Crear todas las tablas automáticamente
models.Base.metadata.create_all(bind=engine)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")
# Crear la aplicación
app = FastAPI()

# Endpoint de prueba
@app.get("/")
def read_root():
    return {"message": "Hola, este es mi backend con FastAPI"}






@app.post("/register", response_model=schemas.User)
def register(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = crud.get_user_by_email(db, user.email)
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    return crud.create_user(db, user)






class LoginRequest(BaseModel):
    email: str
    password: str

@app.post("/login")
def login(data: LoginRequest, db: Session = Depends(get_db)):
    user = auth.authenticate_user(db, data.email, data.password)
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    access_token = auth.create_access_token(data={"sub": user.email})
    return {"access_token": access_token, "token_type": "bearer"}



