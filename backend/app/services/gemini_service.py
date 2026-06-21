import os
from google import genai
from dotenv import load_dotenv

load_dotenv()  # loads GEMINI_API_KEY from .env

client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))  # authenticates with Gemini

def get_recommendation(baby_id: str, age_in_months: int, weight: float, height: float, gender: str, allergies: list, previous_meals: list, date: str) -> str:
    
    # build the prompt with all baby context
    prompt = f"""
    Kamu adalah ahli gizi bayi. Berikan rekomendasi menu MPASI untuk hari ini.

    Data bayi:
    - Usia: {age_in_months} bulan
    - Berat badan: {weight} kg
    - Tinggi badan: {height} cm
    - Jenis kelamin: {gender}
    - Alergi: {', '.join(allergies) if allergies else 'Tidak ada'}
    - Menu sebelumnya: {', '.join(previous_meals) if previous_meals else 'Belum ada'}
    - Tanggal: {date}

    Tentukan jadwal makan yang sesuai berdasarkan usia bayi, yang dapat mencakup:
    - ASI (Air Susu Ibu)
    - Makan utama (sarapan, makan siang, makan malam)
    - Snack (selingan)

    Frekuensi dan kombinasi waktu makan harus disesuaikan dengan usia bayi sesuai panduan WHO dan IDAI.
    Untuk setiap waktu makan (kecuali ASI), berikan:
    1. Nama menu
    2. Bahan-bahan
    3. Cara membuat
    4. Alasan pemilihan menu ini

    Untuk jadwal ASI, cukup cantumkan waktu dan frekuensinya.

    Jawab dalam Bahasa Indonesia.
    """

    response = client.models.generate_content(
    model="gemini-1.5-flash",
    contents=prompt,)  # send prompt to Gemini
    return response.text  # return the generated text