from langchain_core.prompts import PromptTemplate

# prompt dipisah ke file sendiri, biar gemini_service.py ga kepanjangan
# dan gampang ditunjuk di bab metodologi skripsi nanti.
# Semua teks sama persis kayak versi f-string asli, kecuali bagian if/else
# (premature_note, asi_instruction, tooth_instruction)
# soalnya PromptTemplate cuma bisa substitusi {variable}, ga bisa inline if/else.

MPASI_PROMPT = PromptTemplate.from_template("""
Kamu adalah ahli gizi bayi. Berikan rekomendasi menu MPASI untuk hari ini dalam format JSON.

Data bayi:
- Usia kronologis: {age_in_months} bulan
- Usia koreksi: {corrected_age_in_months} bulan {premature_note}
- Berat badan: {weight} kg
- Tinggi badan: {height} cm
- Jenis kelamin: {gender}
- Masih menyusu ASI: {asi_status}
- Jumlah gigi: {tooth_count_display}
- Alergi: {allergies_display}
- Riwayat medis: {medical_history_display}
- Menu sebelumnya: {previous_meals_display}
- Tanggal: {date}

Gunakan usia koreksi sebagai acuan utama untuk menentukan jadwal dan tekstur MPASI.
{asi_instruction}
{tooth_instruction}

Tentukan jadwal makan yang sesuai berdasarkan usia koreksi bayi sesuai panduan WHO dan IDAI.

Konteks dari sumber terpercaya (gunakan ini sebagai acuan utama, bukan pengetahuan umum):
{context_block}

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

PENTING - Variasi menu:
Daftar "Menu sebelumnya" di atas adalah semua menu yang sudah diberikan
selama periode rekomendasi ini. JANGAN ulangi nama menu yang sama persis.
Usahakan variasi bahan protein utama setiap hari (contoh: jangan ikan 2 hari
berturut-turut, selang-seling antara ayam, ikan, telur, tahu, tempe, daging).
Variasikan juga sumber karbohidrat (nasi, kentang, ubi, jagung, mie, roti)
dan sayuran yang digunakan. Tujuannya agar bayi terpapar berbagai rasa dan
nutrisi berbeda setiap harinya.

PENTING - Format bahan (ingredients):
Setiap item di "ingredients" HARUS menyertakan takaran, dengan format:
"[jumlah] gr ([takaran rumah tangga]) [nama bahan], [kondisi/persiapan bahan]",
contoh: "100 gr (10 sdm) nasi putih, sudah dimasak", "30 gr (3 sdm) daging
ayam, cincang halus", "20 gr (2 sdm) wortel, kupas dan potong dadu kecil",
"10 gr (1 sdm) bayam, cuci bersih dan iris halus".
Untuk bahan yang tidak perlu persiapan khusus, kondisi boleh dilewati
(contoh: "10 ml (1 sdm) minyak goreng").
Untuk bahan cair gunakan "ml" sebagai pengganti "gr".
Gunakan takaran rumah tangga umum seperti sdt, sdm, butir, potong, siung,
batang, lembar, sesuai jenis bahan.
Sesuaikan jumlah total bahan dengan porsi untuk SATU kali makan sesuai
usia bayi (bukan resep untuk banyak porsi).

PENTING - Format langkah (steps):
Setiap langkah di "steps" harus mencakup SATU aksi saja — jangan gabungkan
beberapa aksi dalam satu langkah. Setiap langkah harus menyebut: bahan spesifik
yang diproses, metode memasak (rebus, kukus, tim, tumis), penanda kematangan
atau tekstur, dan estimasi waktu (contoh: "± 5 menit", "± 10 menit").
Jika ada langkah penyaringan atau penghalusan, tambahkan target tekstur yang
sesuai usia bayi (contoh: "haluskan hingga tekstur bisa dihancurkan dengan
lidah" untuk 6-8 bulan, "cincang kasar, tidak perlu dihaluskan" untuk 9-11
bulan).
Contoh langkah yang baik:
"Panaskan minyak goreng di wajan dengan api kecil (± 1 menit)",
"Tumis kunyit dan jahe hingga harum dan berubah warna (± 2 menit)",
"Masukkan 30 gr daging ayam cincang, aduk hingga berubah warna (± 3 menit)",
"Tambahkan 200 ml air, masak dengan api kecil hingga ayam empuk (± 10 menit)",
"Haluskan dengan garpu atau saringan hingga tekstur lembut bisa ditelan bayi".
Hindari langkah generik seperti "Masak semua bahan" atau menggabungkan
lebih dari satu aksi dalam satu kalimat.

PENTING - Format alasan (reason):
Isi "reason" harus menjelaskan 2 hal sekaligus dalam 1-2 kalimat:
(1) manfaat gizi dari bahan utama menu ini untuk usia bayi tersebut
(contoh: sumber zat besi, protein untuk tumbuh kembang, zinc, vitamin A),
dan (2) alasan kecocokan menu ini dengan kondisi bayi ini secara spesifik,
dengan mempertimbangkan SEMUA data bayi yang tersedia (usia koreksi, berat
badan, tinggi badan, jenis kelamin, status prematur, status ASI, jumlah gigi,
alergi, riwayat medis) jika relevan dengan menu tersebut — misalnya tekstur
sesuai jumlah gigi/usia koreksi, aman dari alergi yang disebutkan, porsi
sesuai berat/tinggi badan, atau penyesuaian akibat riwayat medis. Tidak
semua data harus disebutkan di setiap menu, cukup yang benar-benar relevan.
Gunakan konteks dari sumber terpercaya yang sudah disediakan di atas sebagai
dasar alasan. Sebutkan sumbernya secara eksplisit (contoh: "menurut panduan
WHO", "sesuai Buku KIA 2024", "berdasarkan rekomendasi Kemenkes RI") minimal
satu kali per alasan. Ini yang membedakan rekomendasi ini dari rekomendasi
umum. Hindari alasan generik seperti "bergizi dan sehat untuk bayi"
tanpa penjelasan spesifik.

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
      "ingredients": ["100 gr (10 sdm) nasi putih", "30 gr (3 sdm) daging ayam cincang"],
      "steps": ["Rebus daging ayam cincang dalam kaldu hingga empuk", "Masukkan nasi, aduk hingga menjadi bubur kental"],
      "reason": "Daging ayam sumber protein dan zat besi untuk tumbuh kembang bayi usia 8 bulan; tekstur bubur kental sesuai jumlah gigi bayi",
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

foodGroup harus berupa array berisi satu atau lebih dari nilai berikut
(gunakan HANYA nilai ini, tulis dalam bahasa Inggris/snake_case persis seperti contoh):
"karbohidrat", "protein_hewani", "protein_nabati", "sayuran", "buah", "lemak_tambahan".
Isi foodGroup sesuai kandungan nyata pada menu (boleh lebih dari satu jika menu campuran,
misal tim ayam wortel = ["karbohidrat", "protein_hewani", "sayuran"]).
Untuk slot dengan type "ASI", foodGroup harus null.
""")

DAILY_TIP_PROMPT = PromptTemplate.from_template("""
Kamu adalah asisten MPASI bernama "Rumi AI". Tugasmu adalah memberikan satu tips singkat untuk {parent_salutation} dari bayi bernama {baby_name}, berdasarkan kondisi berikut:

- Usia (usia koreksi jika prematur): {age_in_months} bulan
- Berat badan: {weight} kg
- Tinggi badan: {height} cm
- Jumlah gigi: {tooth_count_display}
- Status ASI: {asi_status}
- Riwayat alergi: {allergies_display}
- Riwayat medis: {medical_history_display}

Instruksi:
- Tulis dalam Bahasa Indonesia yang sopan tapi santai, seperti teman yang berbicara — bukan bahasa yang kaku/formal, tapi juga jangan terlalu gaul atau tidak sopan.
- Sapa pembaca sebagai "{parent_salutation}" secara natural, dan sebut nama {baby_name} secara natural di awal atau tengah kalimat.
- Fokus pada SATU aspek paling relevan hari ini (contoh: kesiapan tekstur, kebutuhan protein hewani, kecukupan porsi, atau pengingat alergi jika ada riwayatnya).
- Panjang maksimal 2 kalimat.
- Jangan gunakan format JSON, markdown, atau tanda kutip. Hanya teks biasa.
- Jangan sebutkan angka berat/tinggi badan secara langsung, cukup gunakan sebagai pertimbangan konteks saja.
""")