import os
from google import genai
from dotenv import load_dotenv
import json
import firebase_admin
from firebase_admin import credentials, firestore
from datetime import date, timedelta
from langchain_google_genai import ChatGoogleGenerativeAI
from .prompts import MPASI_PROMPT
# CHANGED: relative import untuk kerja di dalam package (uvicorn), fallback ke sibling import kalau dijalanin standalone
try:
    from .retriever import retriever
except ImportError:
    from retriever import retriever
# END CHANGED

load_dotenv()  # loads GEMINI_API_KEY from .env

# initialize Firebase Admin SDK for backend Firestore writes
if not firebase_admin._apps:
    firebase_creds_json = os.getenv("FIREBASE_SERVICE_ACCOUNT")
    if firebase_creds_json:
        cred_dict = json.loads(firebase_creds_json)
        cred = credentials.Certificate(cred_dict)
    else:
        cred = credentials.Certificate('../script/serviceAccountKey.json')
    firebase_admin.initialize_app(cred)
# END CHANGED
db = firestore.client()

# ADDED: strip markdown fences in case Gemini wraps JSON despite prompt instructions
def _clean_json_text(text: str) -> str:
    cleaned = text.strip()
    if cleaned.startswith("```"):
        first_newline = cleaned.find("\n")
        if first_newline != -1:
            cleaned = cleaned[first_newline + 1:]
        if cleaned.rstrip().endswith("```"):
            cleaned = cleaned.rstrip()[:-3]
    return cleaned.strip()
# END ADDED

def _get_single_day(
        baby_id: str, 
        age_in_months: int, 
        corrected_age_in_months: int, 
        weight: float, 
        height: float, 
        gender: str, 
        is_premature: bool,                 
        is_actively_breastfed: bool,        
        tooth_count: int | None,            
        allergies: list, 
        medical_history: str | None,
        previous_meals: list, 
        date: str,
        context_block: str,
        ) -> str:
    
    # hitung semua bagian conditional sebagai string biasa dulu,
    # soalnya PromptTemplate ga bisa inline if/else
    premature_note = '(bayi prematur)' if is_premature else ''
    asi_status = 'Ya' if is_actively_breastfed else 'Tidak'
    tooth_count_display = str(tooth_count) if tooth_count is not None else 'Tidak diketahui'
    allergies_display = ', '.join(allergies) if allergies else 'Tidak ada'
    medical_history_display = medical_history if medical_history else 'Tidak ada'
    previous_meals_display = ', '.join(previous_meals) if previous_meals else 'Belum ada'
    asi_instruction = (
        'Sertakan slot ASI sesuai kebutuhan bayi.' if is_actively_breastfed
        else 'Bayi tidak lagi menyusu ASI, jangan sertakan slot ASI.'
    )
    tooth_instruction = (
        'Sesuaikan tekstur makanan dengan jumlah gigi bayi.' if tooth_count is not None else ''
    )
    
#isi template pake .format() bukan f-string manual lagi
    prompt = MPASI_PROMPT.format(
        age_in_months=age_in_months,
        corrected_age_in_months=corrected_age_in_months,
        premature_note=premature_note,
        weight=weight,
        height=height,
        gender=gender,
        asi_status=asi_status,
        tooth_count_display=tooth_count_display,
        allergies_display=allergies_display,
        medical_history_display=medical_history_display,
        previous_meals_display=previous_meals_display,
        date=date,
        asi_instruction=asi_instruction,
        tooth_instruction=tooth_instruction,
        context_block=context_block,
    )
    

    # CHANGED: retry + fallback pake LangChain .with_retry() dan .with_fallbacks(),
    # gantiin nested for-loop manual yang lama. Primary = 3.1-flash-lite (cepat/murah),
    # fallback = 3-flash (lebih capable, dipanggil kalau primary gagal terus setelah 5x retry)
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
    # END CHANGED
    if isinstance(response.content, list):
        response_text = "".join(
            block.get("text", "") if isinstance(block, dict) else str(block)
            for block in response.content
        )
    else:
        response_text = response.content
    # END CHANGED
    # END CHANGED

    if not response_text or not response_text.strip():
        raise RuntimeError("Gemini returned empty response")

    return _clean_json_text(response_text)

 # ADDED: allowed foodGroup values, kept in sync with prompt enum
ALLOWED_FOOD_GROUPS = {
    "karbohidrat",
    "protein_hewani",
    "protein_nabati",
    "sayuran",
    "buah",
    "lemak_tambahan",
}

def _validate_food_groups(meals: list) -> list:
    for meal in meals:
        if meal.get('type') == 'ASI':
            meal['foodGroup'] = None
            continue

        fg = meal.get('foodGroup')
        if fg is None:
            meal['foodGroup'] = []
            continue

        if not isinstance(fg, list):
            fg = [fg]

        valid = [g for g in fg if isinstance(g, str) and g in ALLOWED_FOOD_GROUPS]
        invalid = [g for g in fg if g not in valid]

        if invalid:
            print(f"[gemini_service] Dropped invalid foodGroup values {invalid} for meal '{meal.get('name')}'")

        meal['foodGroup'] = valid
        meal['isEaten'] = False
    return meals
# END ADDED

# ADDED: weekly recommendation loop with per-day Firestore writes
def get_weekly_recommendation(
        uid: str,
        baby_id: str,
        age_in_months: int,
        corrected_age_in_months: int,
        weight: float,
        height: float,
        gender: str,
        is_premature: bool,
        is_actively_breastfed: bool,
        tooth_count: int | None,
        allergies: list,
        medical_history: str | None,
        start_date: str,
        days: int = 7,
        ) -> list:
    
    # retrieval sekali aja di sini, bukan tiap hari — soalnya profil bayi
    # (usia koreksi/alergi/gigi) ga berubah dalam satu minggu, jadi query-nya bakal sama terus
    query_parts = [f"MPASI untuk bayi usia {corrected_age_in_months} bulan"]
    if allergies:
        query_parts.append(f"dengan alergi {', '.join(allergies)}")
    if tooth_count is not None:
        query_parts.append(f"jumlah gigi {tooth_count}")
    retrieval_query = " ".join(query_parts)

    # CHANGED: retriever.py sekarang exposes LangChain retriever object, dipanggil pake .invoke()
    # balikin list of Document (pake .page_content, bukan ['text']), bukan list of dict lagi
    retrieved_docs = retriever.invoke(retrieval_query)
    context_block = "\n\n".join(
        f"[Sumber: {doc.metadata.get('source', 'unknown')}]\n{doc.page_content}"
        for doc in retrieved_docs
    )
    # END CHANGED
    # END ADDED

    results = []
    previous_meals = []

    for i in range(days):
        current_date = (date.fromisoformat(start_date) + timedelta(days=i)).isoformat()

        # generate single day
        raw = _get_single_day(
            baby_id=baby_id,
            age_in_months=age_in_months,
            corrected_age_in_months=corrected_age_in_months,
            weight=weight,
            height=height,
            gender=gender,
            is_premature=is_premature,
            is_actively_breastfed=is_actively_breastfed,
            tooth_count=tooth_count,
            allergies=allergies,
            medical_history=medical_history,
            previous_meals=previous_meals,
            date=current_date,
            context_block=context_block,
        )

        parsed = json.loads(raw)

        # ADDED: validate/sanitize foodGroup tags before persisting
        parsed['meals'] = _validate_food_groups(parsed.get('meals', []))
        # END ADDED

        # write to Firestore immediately after each day is generated
        doc_id = f'{baby_id}_{current_date}'
        db.collection('users').document(uid).collection('recommendations').document(doc_id).set({
            'baby_id': baby_id,
            'date': current_date,
            'meals': parsed['meals'],
            'created_at': date.today().isoformat(),
            'source': 'rag',
        })

        print(f'[gemini_service] Day {i+1}/{days} saved to Firestore: {doc_id}')

        # extract non-ASI meal names as context for next day
        previous_meals = [
            meal['name']
            for meal in parsed.get('meals', [])
            if meal.get('name') is not None
        ]

        results.append({'date': current_date, 'meals': parsed['meals']})

    return results
# END ADDED