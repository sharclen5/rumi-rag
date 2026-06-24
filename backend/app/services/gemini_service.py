import os
from google import genai
from dotenv import load_dotenv

load_dotenv()  # loads GEMINI_API_KEY from .env

client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))  # authenticates with Gemini

def get_recommendation(
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

    response = client.models.generate_content(
    model="models/gemini-2.5-flash-lite",
    contents=prompt,)  # send prompt to Gemini
    return response.text  # return the generated text