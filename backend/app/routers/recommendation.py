from fastapi import APIRouter
from app.models import RecommendationRequest  # import the request shape we defined
from app.services.gemini_service import get_recommendation  # import the Gemini function

router = APIRouter()  # creates a router instance that main.py will register

@router.post("/recommend")  # Flutter will POST to this endpoint
def recommend(request: RecommendationRequest):  # FastAPI auto-validates using our model
    
    result = get_recommendation(
        baby_id=request.baby_id,
        age_in_months=request.baby.age_in_months,
        weight=request.baby.weight,
        height=request.baby.height,
        gender=request.baby.gender,
        allergies=request.baby.allergies,
        previous_meals=request.previous_meals,
        date=request.date,
    )

    return {"recommendation": result}  # return Gemini's response to Flutter