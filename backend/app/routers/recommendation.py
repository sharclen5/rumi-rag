import json
from fastapi import APIRouter
from app.models import RecommendationRequest
from app.services.gemini_service import get_recommendation

router = APIRouter()

@router.post("/recommend")
def recommend(request: RecommendationRequest):
    result = get_recommendation(
        baby_id=request.baby_id,
        age_in_months=request.baby.age_in_months,
        corrected_age_in_months=request.baby.corrected_age_in_months,  
        weight=request.baby.weight,
        height=request.baby.height,
        gender=request.baby.gender,
        is_premature=request.baby.is_premature,                        
        is_actively_breastfed=request.baby.is_actively_breastfed,      
        tooth_count=request.baby.tooth_count,                          
        allergies=request.baby.allergies,
        medical_history=request.baby.medical_history,                  
        previous_meals=request.previous_meals,
        date=request.date,
    )

    # parse Gemini's text response into actual JSON
    parsed = json.loads(result)
    return parsed