from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
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


models.Base.metadata.create_all(bind=engine) # Crear tablas según modelos definidos (solo en desarrollo)

##############################

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")
# Crear la aplicación
app = FastAPI()


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Para pruebas, luego restringe
    allow_credentials=True,
    allow_methods=["*"],  # ← IMPORTANTE para OPTIONS
    allow_headers=["*"],
)


# Al iniciar, eliminar y recrear todas las tablas (destructivo, solo para desarrollo)
#@app.on_event("startup")
#def reset_database():
#    models.Base.metadata.drop_all(bind=engine)
#    models.Base.metadata.create_all(bind=engine)

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

#para perfil
@app.get("/me", response_model=schemas.User)
def get_me(current_user=Depends(auth.get_current_user)):
    return current_user


# ================= Users =================
@app.get("/users", response_model=List[schemas.User])
def list_users(db: Session = Depends(get_db), current_user=Depends(auth.get_current_user)):
    return crud.get_users(db)


# ================= Meetings =================
@app.post("/meetings", response_model=schemas.Meeting)
def create_meeting(meeting: schemas.MeetingCreate, db: Session = Depends(get_db), current_user=Depends(auth.get_current_user)):
    # Nota: en un escenario real, validar rol/admin aquí
    return crud.create_meeting(db, meeting, coordinator_id=current_user.id)

@app.get("/meetings", response_model=List[schemas.Meeting])
def list_meetings(db: Session = Depends(get_db)):
    return crud.list_meetings(db)

#endpoint para obtener reuniones del usuario actual
@app.get("/meetings/my", response_model=List[schemas.Meeting])
def list_meetings_for_user(db: Session = Depends(get_db), current_user=Depends(auth.get_current_user)):
    return crud.list_meetings_for_user(db, user_id=current_user.id)

#endpoint para obtener una reunion por id del usuario actual
@app.get("/meeting/{meeting_id}", response_model=schemas.MeetingDetail, status_code=status.HTTP_200_OK)
def get_meeting_for_user(meeting_id: int, db: Session = Depends(get_db)):
    meeting = crud.get_meeting(db, meeting_id)
    if not meeting:
        raise HTTPException(status_code=404, detail="Meeting not found")
    
    response = schemas.MeetingDetail.model_validate(meeting)
    # Asignar location del beacon si existe
    if meeting.beacon:
        response.location = meeting.beacon.location
    
    return response

# ================= Attendance =================
@app.post("/attendance/mark", response_model=schemas.Attendance)
def mark_attendance(payload: schemas.AttendanceCreate, db: Session = Depends(get_db), current_user=Depends(auth.get_current_user)):
    """Marca la asistencia del usuario autenticado a la reunión indicada.
    Valida que la reunión esté en curso (ventana de tiempo) y actualiza o crea el registro.
    """
    return crud.mark_attendance(db, user_id=current_user.id, meeting_id=payload.meeting_id, status=payload.status or "present")


@app.get("/attendance/my", response_model=List[schemas.Attendance])
def my_attendance(db: Session = Depends(get_db), current_user=Depends(auth.get_current_user)):
    """Devuelve todas las asistencias del usuario autenticado."""
    return crud.list_attendance_for_user(db, user_id=current_user.id)


@app.post("/attendance", response_model=schemas.Attendance)
# Asigna o actualiza la asistencia de un usuario a una reunión (upsert),
# sin restricciones por ventana de tiempo. Solo el coordinador puede agregar asistentes.
def add_attendance(payload: schemas.AttendanceAssign, 
                   db: Session = Depends(get_db), 
                   current_user=Depends(auth.get_current_user)):
    
    # Validar que el coordinador sea el que modifica la asistencia
    meeting = crud.get_meeting(db, payload.meeting_id)
    if not meeting:
        raise HTTPException(status_code=404, detail="Meeting not found")

    if meeting.coordinator_id != current_user.id:
        raise HTTPException(status_code=403, detail="Only the coordinator can add assistants")

    return crud.add_attendance(db,user_id=payload.user_id,meeting_id=payload.meeting_id,status=payload.status or "absent")


@app.get("/attendance/meeting/{meeting_id}", response_model=List[schemas.Attendance])
def list_attendance_for_meeting(meeting_id: int, db: Session = Depends(get_db), current_user=Depends(auth.get_current_user)):
    """Lista todas las asistencias registradas para la reunión indicada."""
    return crud.list_attendance_for_meeting(db, meeting_id=meeting_id)

@app.get("/attendance/my/{meeting_id}", response_model=schemas.Attendance)
def get_my_attendance(meeting_id: int, db: Session = Depends(get_db), current_user=Depends(auth.get_current_user)):
    """Obtiene la asistencia del usuario autenticado a la reunión indicada."""
    return crud.get_attendance_for_user(db, user_id=current_user.id, meeting_id=meeting_id)



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
def update_beacon(beacon_id: str, beacon: schemas.BeaconUpdate, db: Session = Depends(get_db)):
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

# Relationships

# Devuelve la lista de todos los beacons disponibles para asociar a una reunión.
@app.get("/meetings/available-beacons", response_model=List[schemas.Beacon])
def get_available_beacons(db: Session = Depends(get_db), current_user=Depends(auth.get_current_user)):
    return crud.get_beacons(db)