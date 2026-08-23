import os
from pathlib import Path
import sys 
from dotenv import load_dotenv
from langchain_google_genai import GoogleGenerativeAIEmbeddings
from langchain_chroma import Chroma
import chromadb

sys.stdout.reconfigure(encoding='utf-8')

#load .env dari root backend/ (bukan kb-prep/, karena file ini sekarang hidup di rumi-rag)
load_dotenv()

#pakai __file__-anchored path, bukan relative path biasa
#waktu ingest.py, relative path resolve ke cwd terminal,
#bukan ke lokasi file .py-nya. Jadi absolute path dari __file__ lebih aman.
CHROMA_DB_PATH = Path(__file__).resolve().parent.parent.parent / "chroma_db"

#embeddings sekarang lewat LangChain punya wrapper, bukan genai.Client.embed_content langsung
#model name harus sama persis kayak yang dipake pas ingest chunks dulu (gemini-embedding-001),
embeddings = GoogleGenerativeAIEmbeddings(
    model="models/gemini-embedding-001",
    google_api_key=os.getenv("GEMINI_API_KEY"),
    task_type="RETRIEVAL_QUERY",  # ADDED: sama kayak fix di rumi-eval/retriever.py, biar konsisten dan gak gantung ke default
)

# CHANGED: tetep pake PersistentClient chromadb yang sama buat connect ke collection yang udah ada,
# tapi sekarang dibungkus LangChain punya Chroma vectorstore, bukan dipanggil manual
chroma_client = chromadb.PersistentClient(path=str(CHROMA_DB_PATH))

vectorstore = Chroma(
    client=chroma_client,
    collection_name="mpasi_kb",
    embedding_function=embeddings,
)

# CHANGED: dulu retriever di-buat sekali pas module di-load, sekarang jadi function
# biar filter age_range bisa disesuaikan per baby, bukan k=5 generik tanpa filter

def age_to_bucket(months: int) -> str:
    # ADDED: mapping usia (bulan) ke age_range bucket yang sama kayak di metadata chunk
    if months <= 8:
        return "6-8bulan"
    elif months <= 11:
        return "9-11bulan"
    else:
        return "12-23bulan"

# CHANGED: k dinaikin dari 5 ke 10 — biar lebih banyak resep yang ke-retrieve
# dan LLM punya lebih banyak variasi buat dipilih tiap harinya
def get_retriever(age_in_months: int, k: int = 10):
    bucket = age_to_bucket(age_in_months)
    # ADDED: filter pake $or, soalnya selain chunk yang match usia spesifik,
    # chunk yang ditag "all" (berlaku semua usia, misal prinsip umum/WHO rec)
    # juga tetep harus ikut kepertimbangkan
    return vectorstore.as_retriever(
        search_kwargs={
            "k": k,
            "filter": {"$or": [{"age_range": bucket}, {"age_range": "all"}]},
        }
    )


# CHANGED: sanity test disesuaikan ke API baru — .invoke() balikin list of Document,
# bukan list of dict kayak sebelumnya (pake .page_content bukan ['text'], .metadata tetep sama)
if __name__ == "__main__":
    test_query = "resep MPASI untuk bayi 6 bulan"
    retriever = get_retriever(age_in_months=6)
    results = retriever.invoke(test_query)
    for doc in results:
        print(f"[Sumber: {doc.metadata.get('source', 'unknown')}]")
        print(f"  {doc.page_content[:100]}...")
        print()