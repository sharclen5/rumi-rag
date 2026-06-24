from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import recommendation

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # tighten this in production
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(recommendation.router)

@app.get("/")
def root():
    return {"message": "Rumi API is running"}