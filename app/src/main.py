# app/src/main.py
from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from . import database, config

app = FastAPI()

# Dependency to get database session
def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/")
def read_root():
    return {"message": "Hello World"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}