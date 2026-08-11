from fastapi import APIRouter
from app.models import DailyTipRequest
from app.services.daily_tip_service import get_daily_tip

router = APIRouter()

@router.post("/daily-tip")
def daily_tip(request: DailyTipRequest):
    tip = get_daily_tip(
        baby_name=request.baby.baby_name,
        age_in_months=request.baby.age_in_months,
        weight=request.baby.weight,
        height=request.baby.height,
        is_actively_breastfed=request.baby.is_actively_breastfed,
        tooth_count=request.baby.tooth_count,
        allergies=request.baby.allergies,
        medical_history=request.baby.medical_history,
        parent_gender=request.baby.parent_gender,
    )

    return {"tip": tip}