# app/services/daily_tip_service.py
import os
from dotenv import load_dotenv
from langchain_google_genai import ChatGoogleGenerativeAI
from .prompts import DAILY_TIP_PROMPT

load_dotenv()

def get_daily_tip(
        baby_name: str,
        age_in_months: int,
        weight: float,
        height: float,
        is_actively_breastfed: bool,
        tooth_count: int | None,
        allergies: list,
        medical_history: str | None,
        parent_gender: str,
        ) -> str:

    # sama kayak pattern di _get_single_day, ubah dulu ke display string
    # soalnya PromptTemplate ga bisa inline if/else
    asi_status = 'Ya' if is_actively_breastfed else 'Tidak'
    tooth_count_display = str(tooth_count) if tooth_count is not None else 'Tidak diketahui'
    allergies_display = ', '.join(allergies) if allergies else 'Tidak ada'
    medical_history_display = medical_history if medical_history else 'Tidak ada'
    parent_salutation = 'Ayah' if parent_gender == 'Male' else 'Bunda'

    prompt = DAILY_TIP_PROMPT.format(
        baby_name=baby_name,
        age_in_months=age_in_months,
        weight=weight,
        height=height,
        asi_status=asi_status,
        tooth_count_display=tooth_count_display,
        allergies_display=allergies_display,
        medical_history_display=medical_history_display,
        parent_salutation=parent_salutation,
    )

    # retry + fallback sama persis kayak gemini_service.py punya recommendation,
    # biar konsisten model pair-nya (3.1-flash-lite primary, 3-flash fallback)
    primary_llm = ChatGoogleGenerativeAI(
        model="gemini-3.1-flash-lite",
        google_api_key=os.getenv("GEMINI_API_KEY"),
    ).with_retry(stop_after_attempt=5)

    fallback_llm = ChatGoogleGenerativeAI(
        model="gemini-3-flash",
        google_api_key=os.getenv("GEMINI_API_KEY"),
    ).with_retry(stop_after_attempt=5)

    llm = primary_llm.with_fallbacks([fallback_llm])
    response = llm.invoke(prompt)

    # handle case dimana response.content berupa list of block (sama kayak gemini_service.py)
    if isinstance(response.content, list):
        response_text = "".join(
            block.get("text", "") if isinstance(block, dict) else str(block)
            for block in response.content
        )
    else:
        response_text = response.content

    if not response_text or not response_text.strip():
        raise RuntimeError("Gemini returned empty response")

    return response_text.strip()