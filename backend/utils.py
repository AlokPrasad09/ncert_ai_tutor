import chromadb
from sentence_transformers import SentenceTransformer

DB_PATH = "vector_db"

model = None
def get_model():
    global model
    if model is None:
        from sentence_transformers import SentenceTransformer
        model = SentenceTransformer("all-MiniLM-L6-v2")
    return model


#embed_model = SentenceTransformer("all-MiniLM-L6-v2")

client = chromadb.PersistentClient(path=DB_PATH)

collection = client.get_or_create_collection("ncert_kb")


# -----------------------------
# 🔥 Multi Query Generator
# -----------------------------

def generate_queries(question):

    queries = [
        question,
        f"{question} definition",
        f"{question} explanation",
        f"{question} example",
        f"explain {question} in simple words"
    ]

    return queries


# -----------------------------
# 🔥 Smart Context Retrieval
# -----------------------------

def retrieve_context(question):

    queries = generate_queries(question)

    all_docs = []

    # search multiple queries
    for q in queries:

        query_embedding = get_model.encode(q).tolist()

        results = collection.query(
            query_embeddings=[query_embedding],
            n_results=3
        )

        docs = results["documents"][0]

        if docs:
            all_docs.extend(docs)

    if not all_docs:
        return None

    # -----------------------------
    # 🔥 Remove duplicates
    # -----------------------------

    unique_docs = list(set(all_docs))

    # -----------------------------
    # 🔥 Smart Ranking
    # -----------------------------

    # rank by length (more informative chunks first)
    ranked_docs = sorted(
        unique_docs,
        key=lambda x: model.similarity(
            model.encode(question),
            model.encode(x)
        ),
        reverse=True
    )

    # select best chunks
    best_docs = ranked_docs[:5]

    return "\n\n".join(best_docs)