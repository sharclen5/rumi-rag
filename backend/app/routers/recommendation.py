from fastapi import APIRouter
from app.models import WeeklyRecommendationRequest
from app.services.gemini_service import get_weekly_recommendation

router = APIRouter()

@router.post("/recommend/weekly")
def recommend_weekly(request: WeeklyRecommendationRequest):
    results = get_weekly_recommendation(
        uid=request.uid,
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
        start_date=request.start_date,
        days=request.days,
    )

    return {"status": "success", "days_generated": len(results)}