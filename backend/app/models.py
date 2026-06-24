from pydantic import BaseModel
from typing import List, Optional

class BabyContext(BaseModel):
    age_in_months: int                          # usia kronologis
    corrected_age_in_months: int                # usia koreksi (sama dengan age_in_months jika tidak prematur)
    weight: float
    height: float
    gender: str
    is_premature: bool = False
    is_actively_breastfed: bool = True          
    tooth_count: Optional[int] = None           
    allergies: Optional[List[str]] = []         # nama alergi (bukan ID)
    medical_history: Optional[str] = None

class RecommendationRequest(BaseModel):
    baby_id: str
    baby: BabyContext
    date: str
    previous_meals: Optional[List[str]] = []