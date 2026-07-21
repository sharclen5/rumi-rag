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
)

# CHANGED: tetep pake PersistentClient chromadb yang sama buat connect ke collection yang udah ada,
# tapi sekarang dibungkus LangChain punya Chroma vectorstore, bukan dipanggil manual
chroma_client = chromadb.PersistentClient(path=str(CHROMA_DB_PATH))

vectorstore = Chroma(
    client=chroma_client,
    collection_name="mpasi_kb",
    embedding_function=embeddings,
)

# ADDED: expose sebagai LangChain Retriever object, biar bisa langsung disambung ke chain (LCEL) nanti di Pass 3
retriever = vectorstore.as_retriever(search_kwargs={"k": 5})


# CHANGED: sanity test disesuaikan ke API baru — .invoke() balikin list of Document,
# bukan list of dict kayak sebelumnya (pake .page_content bukan ['text'], .metadata tetep sama)
if __name__ == "__main__":
    test_query = "resep MPASI untuk bayi 6 bulan"
    results = retriever.invoke(test_query)
    for doc in results:
        print(f"[Sumber: {doc.metadata.get('source', 'unknown')}]")
        print(f"  {doc.page_content[:100]}...")
        print()