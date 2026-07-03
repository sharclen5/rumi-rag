import os
from google import genai
from dotenv import load_dotenv
import json
import firebase_admin
from firebase_admin import credentials, firestore
from datetime import date, timedelta
import time
from google.genai.errors import ServerError, ClientError

load_dotenv()  # loads GEMINI_API_KEY from .env

client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))  # authenticates with Gemini

# initialize Firebase Admin SDK for backend Firestore writes
if not firebase_admin._apps:
    cred = credentials.Certificate('../script/serviceAccountKey.json')
    firebase_admin.initialize_app(cred)
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
        ) -> str:
    
    
    # build the prompt with all baby context
    prompt = f"""
    Kamu adalah ahli gizi bayi. Berikan rekomendasi menu MPASI untuk hari ini dalam format JSON.

    Data bayi:
    - Usia kronologis: {age_in_months} bulan
    - Usia koreksi: {corrected_age_in_months} bulan {'(bayi prematur)' if is_premature else ''}
    - Berat badan: {weight} kg
    - Tinggi badan: {height} cm
    - Jenis kelamin: {gender}
    - Masih menyusu ASI: {'Ya' if is_actively_breastfed else 'Tidak'}
    - Jumlah gigi: {tooth_count if tooth_count is not None else 'Tidak diketahui'}
    - Alergi: {', '.join(allergies) if allergies else 'Tidak ada'}
    - Riwayat medis: {medical_history if medical_history else 'Tidak ada'}
    - Menu sebelumnya: {', '.join(previous_meals) if previous_meals else 'Belum ada'}
    - Tanggal: {date}

    Gunakan usia koreksi sebagai acuan utama untuk menentukan jadwal dan tekstur MPASI.
    {'Sertakan slot ASI sesuai kebutuhan bayi.' if is_actively_breastfed else 'Bayi tidak lagi menyusu ASI, jangan sertakan slot ASI.'}
    {'Sesuaikan tekstur makanan dengan jumlah gigi bayi.' if tooth_count is not None else ''}

    Tentukan jadwal makan yang sesuai berdasarkan usia koreksi bayi sesuai panduan WHO dan IDAI.
    
    Kembalikan HANYA JSON valid tanpa teks lain, tanpa markdown, tanpa backtick.
    Format JSON:
    {{
      "meals": [
        {{
          "time": "08.00",
          "type": "Sarapan",
          "name": "nama menu",
          "ingredients": ["bahan 1", "bahan 2"],
          "steps": ["langkah 1", "langkah 2"],
          "reason": "alasan pemilihan menu"
        }},
        {{
          "time": "06.00",
          "type": "ASI",
          "name": null,
          "ingredients": null,
          "steps": null,
          "reason": null
        }}
      ]
    }}

    Type hanya boleh: "ASI", "Sarapan", "Makan Siang", "Makan Malam", atau "Snack".
    """

    # CHANGED: retry with exponential backoff, fallback to secondary model on repeated failure
    models_to_try = ["models/gemini-2.5-flash-lite", "models/gemini-2.5-flash"]
    max_retries_per_model = 3
    last_error = None
    response = None

    for model_name in models_to_try:
        for attempt in range(max_retries_per_model):
            try:
                response = client.models.generate_content(
                    model=model_name,
                    contents=prompt,
                )
                break  # success, exit retry loop
            except (ServerError, ClientError) as e:
                last_error = e
                wait_time = 2 ** attempt  # 1s, 2s, 4s
                print(f"[gemini_service] {model_name} attempt {attempt+1} failed ({e}), retrying in {wait_time}s...")
                time.sleep(wait_time)
        if response is not None:
            break  # success, exit model loop too

    if response is None:
        raise RuntimeError(f"All models exhausted retries. Last error: {last_error}")

    if not response.text or not response.text.strip():
        candidate = response.candidates[0] if response.candidates else None
        finish_reason = getattr(candidate, "finish_reason", "UNKNOWN") if candidate else "NO_CANDIDATE"
        raise RuntimeError(f"Gemini returned empty response (finish_reason={finish_reason})")

    return _clean_json_text(response.text)

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
        )

        parsed = json.loads(raw)

        # write to Firestore immediately after each day is generated
        doc_id = f'{baby_id}_{current_date}'
        db.collection('users').document(uid).collection('recommendations').document(doc_id).set({
            'baby_id': baby_id,
            'date': current_date,
            'meals': parsed['meals'],
            'created_at': date.today().isoformat(),
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