from fastapi import FastAPI, Depends, HTTPException, status
import crud, models, schemas, auth
from db import get_db, engine
from sqlalchemy.orm import Session
from fastapi.security import OAuth2PasswordBearer
from pydantic import BaseModel
from typing import List
from fastapi import Query



##############################

# Crear todas las tablas automáticamente (esto crea lo que esta en models.py)
# ESTO ES TEMPORAL, DEBERIAMOS USAR ALEMBIC PARA MIGRACIONES


# models.Base.metadata.drop_all(bind=engine) # Descomentar para borrar todas las tablas (solo en desarrollo)


# models.Base.metadata.create_all(bind=engine) # Crear tablas según modelos definidos (solo en desarrollo)

##############################

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")
# Crear la aplicación
app = FastAPI()

# Al iniciar, eliminar y recrear todas las tablas (destructivo, solo para desarrollo)
@app.on_event("startup")
def reset_database():
    models.Base.metadata.drop_all(bind=engine)
    models.Base.metadata.create_all(bind=engine)

# Constantes
BEACON_NOT_FOUND = "Beacon not found"

# Endpoint de prueba
@app.get("/")
def read_root():
    return {"message": "FastAPI"}






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
    return crud.create_meeting(db, meeting, coordinator_id=current_user.id)


@app.get("/meetings", response_model=List[schemas.Meeting])
def list_meetings(db: Session = Depends(get_db)):
    return crud.list_meetings(db)

@app.get("/meetings/my", response_model=List[schemas.Meeting])
def list_meetings_for_user(db: Session = Depends(get_db), current_user=Depends(auth.get_current_user)):
    return crud.list_meetings_for_user(db, user_id=current_user.id)

# ================= Attendance =================
@app.post("/attendance/mark", response_model=schemas.Attendance)
def mark_attendance(payload: schemas.AttendanceCreate, db: Session = Depends(get_db), current_user=Depends(auth.get_current_user)):
    return crud.mark_attendance(db, user_id=current_user.id, meeting_id=payload.meeting_id, status=payload.status or "present")


@app.get("/attendance/my", response_model=List[schemas.Attendance])
def my_attendance(db: Session = Depends(get_db), current_user=Depends(auth.get_current_user)):
    return crud.list_attendance_for_user(db, user_id=current_user.id)



# ================= Beacon =================
@app.post("/beacons", response_model=schemas.Beacon)
def create_beacon(beacon: schemas.BeaconCreate, db: Session = Depends(get_db)):
    return crud.create_beacon(db, beacon)

@app.get("/beacons", response_model=list[schemas.Beacon])
def list_beacons(db: Session = Depends(get_db)):
    return crud.get_beacons(db)

@app.get("/beacons/{beacon_id}", response_model=schemas.Beacon)
def get_beacon(beacon_id: str, db: Session = Depends(get_db)):
    beacon = crud.get_beacon(db, beacon_id)
    if not beacon:
        raise HTTPException(status_code=404, detail=BEACON_NOT_FOUND)
    return beacon

@app.put("/beacons/{beacon_id}", response_model=schemas.Beacon)
def update_beacon(beacon_id: str, beacon: schemas.BeaconCreate, db: Session = Depends(get_db)):
    updated = crud.update_beacon(db, beacon_id, beacon)
    if not updated:
        raise HTTPException(status_code=404, detail=BEACON_NOT_FOUND)
    return updated

@app.delete("/beacons/{beacon_id}")
def delete_beacon(beacon_id: str, db: Session = Depends(get_db)):
    deleted = crud.delete_beacon(db, beacon_id)
    if not deleted:
        raise HTTPException(status_code=404, detail=BEACON_NOT_FOUND)
    return {"message": "Beacon deleted successfully"}
