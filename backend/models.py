from sqlalchemy import Column, Integer, String, Date
from datetime import date
from .database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    questions_used = Column(Integer, default=0)
    plan = Column(String, default="free")  # free or pro
    last_reset = Column(Date, default=date.today)
