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

    PENTING - Ketersediaan bahan:
    Gunakan HANYA bahan makanan yang mudah ditemukan di pasar tradisional, warung,
    atau supermarket umum di Indonesia, dan tidak hanya di perkotaan, 
    tetapi juga di pedesaan. Prioritaskan bahan lokal, musiman, dan terjangkau 
    secara ekonomi untuk rumah tangga Indonesia pada umumnya.
    Hindari bahan impor atau sulit didapat (contoh yang HARUS dihindari: quinoa,
    chia seed, kale, blueberry, keju impor khusus). Sebagai gantinya gunakan
    padanan lokal (contoh: beras/beras merah, biji selasih atau tanpa substitusi,
    bayam/kangkung, pisang/pepaya, tempe/tahu untuk protein nabati).
    Metode masak juga harus realistis untuk dapur rumahan (kukus, rebus, tim),
    tanpa alat khusus seperti oven atau blender mahal, kecuali blender/saringan
    biasa yang umum dimiliki.

    PENTING - Nama menu:
    Buat nama menu singkat dan sederhana, maksimal 3-4 kata, seperti nama masakan
    sehari-hari yang biasa didengar orang tua (contoh: "Bubur Ayam Wortel",
    "Tim Tahu Bayam", "Nasi Tim Ikan"). JANGAN gunakan nama yang panjang atau
    terlalu deskriptif (contoh yang HARUS dihindari: "Bubur Saring Ayam Wortel
    dengan Tambahan Minyak Zaitun untuk Tekstur Lembut").

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
          "reason": "alasan pemilihan menu",
          "foodGroup": ["karbohidrat", "protein_hewani"]
        }},
        {{
          "time": "06.00",
          "type": "ASI",
          "name": null,
          "ingredients": null,
          "steps": null,
          "reason": null,
          "foodGroup": null
        }}
      ]
    }}

    Type hanya boleh: "ASI", "Sarapan", "Makan Siang", "Makan Malam", atau "Snack".

    # ADDED: foodGroup tagging rules
    foodGroup harus berupa array berisi satu atau lebih dari nilai berikut
    (gunakan HANYA nilai ini, tulis dalam bahasa Inggris/snake_case persis seperti contoh):
    "karbohidrat", "protein_hewani", "protein_nabati", "sayuran", "buah", "lemak_tambahan".
    Isi foodGroup sesuai kandungan nyata pada menu (boleh lebih dari satu jika menu campuran,
    misal tim ayam wortel = ["karbohidrat", "protein_hewani", "sayuran"]).
    Untuk slot dengan type "ASI", foodGroup harus null.
    # END ADDED
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