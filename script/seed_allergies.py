import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate("serviceAccountKey.json") 
firebase_admin.initialize_app(cred)

db = firestore.client()

allergies = [
    "Telur",
    "Susu Sapi",
    "Kacang Tanah",
    "Kacang Pohon",
    "Gandum",
    "Kedelai",
    "Ikan",
    "Udang",
    "Kepiting",
    "Wijen",
]

collection_ref = db.collection("baby_allergies")

for name in allergies:
    collection_ref.add({"name": name}) #idnya auto generate

print("Done seeding baby_allergies!")