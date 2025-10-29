from fastapi import FastAPI, Depends, HTTPException, status
import crud, models, schemas, auth
from db import get_db, engine
from sqlalchemy.orm import Session
from fastapi.security import OAuth2PasswordBearer
from pydantic import BaseModel
from typing import List
from fastapi import Query

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



# ================= Meetings =================
@app.post("/meetings", response_model=schemas.Meeting)
def create_meeting(meeting: schemas.MeetingCreate, db: Session = Depends(get_db), current_user=Depends(auth.get_current_user)):
    # Nota: en un escenario real, validar rol/admin aquí
    return crud.create_meeting(db, meeting)


@app.get("/meetings", response_model=List[schemas.Meeting])
def list_meetings(db: Session = Depends(get_db)):
    return crud.list_meetings(db)

"""
# Resolución de reuniones por beacon en evaluación
@app.get("/meetings/resolve", response_model=schemas.Meeting)
def resolve_meeting_by_beacon(
    uuid: str = Query(..., description="Beacon UUID"),
    major: int = Query(..., description="Beacon major"),
    minor: int = Query(..., description="Beacon minor"),
    db: Session = Depends(get_db),
):
    meeting = crud.resolve_meeting_by_beacon(db, uuid=uuid, major=major, minor=minor)
    if not meeting:
        raise HTTPException(status_code=404, detail="Meeting not found for provided beacon")
    return meeting
"""

# ================= Attendance =================
@app.post("/attendance/mark", response_model=schemas.Attendance)
def mark_attendance(payload: schemas.AttendanceCreate, db: Session = Depends(get_db), current_user=Depends(auth.get_current_user)):
    return crud.mark_attendance(db, user_id=current_user.id, meeting_id=payload.meeting_id, status=payload.status or "present")


@app.get("/attendance/my", response_model=List[schemas.Attendance])
def my_attendance(db: Session = Depends(get_db), current_user=Depends(auth.get_current_user)):
    return crud.list_attendance_for_user(db, user_id=current_user.id)

