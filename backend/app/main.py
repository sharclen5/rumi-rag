from fastapi import FastAPI
from app.routers import recommendation

app = FastAPI()

app.include_router(recommendation.router)

@app.get("/")
def root():
    return {"message": "Rumi API is running"}