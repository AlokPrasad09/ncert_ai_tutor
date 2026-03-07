import os
import chromadb
from sentence_transformers import SentenceTransformer
from langchain_community.document_loaders import PyMuPDFLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter

DATA_PATH = "data"
DB_PATH = "vector_db"

embed_model = SentenceTransformer("all-MiniLM-L6-v2")
client = chromadb.PersistentClient(path=DB_PATH)

collection = client.get_or_create_collection("ncert_kb")

text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=900,
    chunk_overlap=150
)

def ingest():

    for class_folder in os.listdir(DATA_PATH):

        class_path = os.path.join(DATA_PATH, class_folder)
        if not os.path.isdir(class_path):
            continue

        class_number = int(class_folder.split("_")[1])

        for subject_folder in os.listdir(class_path):

            subject_path = os.path.join(class_path, subject_folder)

            for file in os.listdir(subject_path):

                if file.endswith(".pdf"):

                    pdf_path = os.path.join(subject_path, file)
                    chapter_name = file.replace(".pdf", "")

                    loader = PyMuPDFLoader(pdf_path)

                    documents = loader.load()
                    chunks = text_splitter.split_documents(documents)

                    for i, chunk in enumerate(chunks):

                        embedding = embed_model.encode(chunk.page_content).tolist()

                        collection.add(
                            documents=[chunk.page_content],
                            embeddings=[embedding],
                            ids=[f"{class_number}_{subject_folder}_{chapter_name}_{i}"],
                            metadatas=[{
                                "class": class_number,
                                "subject": subject_folder.lower(),
                                "chapter": chapter_name
                            }]
                        )

    print("✅ Knowledge Base Ready!")

if __name__ == "__main__":
    ingest()
