from pydantic import BaseModel
from typing import List, Optional

class BabyContext(BaseModel):
    age_in_months: int
    weight: float
    height: float
    gender: str
    allergies: Optional[List[str]] = []

class RecommendationRequest(BaseModel):
    baby_id: str
    baby: BabyContext
    date: str
    previous_meals: Optional[List[str]] = []