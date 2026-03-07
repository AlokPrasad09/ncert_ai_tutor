from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI, Depends, HTTPException, Header
from sqlalchemy.orm import Session
from pydantic import BaseModel
from .database import SessionLocal, engine
from .models import Base, User
from .rag_engine import generate_answer
from .auth import hash_password, verify_password, create_access_token, verify_token
import os
import uvicorn

Base.metadata.create_all(bind=engine)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ---------- DB Dependency ----------
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ---------- Schemas ----------
class Signup(BaseModel):
    email: str
    password: str

class Login(BaseModel):
    email: str
    password: str

class Question(BaseModel):
    messages: list


# ---------- Signup ----------
@app.post("/signup")
def signup(data: Signup, db: Session = Depends(get_db)):

    existing = db.query(User).filter(User.email == data.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="User already exists")

    new_user = User(
        email=data.email,
        hashed_password=hash_password(data.password)
    )

    db.add(new_user)
    db.commit()

    return {"message": "User created successfully"}

# ---------- Login ----------
@app.post("/login")
def login(data: Login, db: Session = Depends(get_db)):

    user = db.query(User).filter(User.email == data.email).first()

    if not user or not verify_password(data.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid credentials")

    token = create_access_token({"sub": user.email})

    return {"access_token": token}

# ---------- Protected Ask ----------
from datetime import date

@app.post("/ask")
def ask_question(
    data: Question,
    authorization: str = Header(...),
    db: Session = Depends(get_db)
):

    token = authorization.replace("Bearer ", "")
    email = verify_token(token)

    if not email:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    user = db.query(User).filter(User.email == email).first()

    # 🔥 DAILY RESET LOGIC
    if user.last_reset != date.today():
        user.questions_used = 0
        user.last_reset = date.today()
        db.commit()

    # 🔥 PLAN CHECK
    if user.plan == "free" and user.questions_used >= 20:
        raise HTTPException(status_code=403, detail="Daily limit reached (Free Plan)")

    answer = generate_answer(data.messages)
    #if isinstance(answer, dict):
     #   return answer

    user.questions_used += 1
    db.commit()

    return {
    "answer": answer,
    "plan": user.plan,
    "questions_used": user.questions_used,
    "remaining": 20 - user.questions_used if user.plan == "free" else "Unlimited"
}
