import os
from dotenv import load_dotenv
from groq import Groq
from .utils import retrieve_context
from .math_engine import process_math
import re

load_dotenv()
# -----------------------------
# 🔥 Math Question Detection
# -----------------------------

def is_math_question(query):

    math_keywords = [
        "solve",
        "integrate",
        "differentiate",
        "derivative",
        "equation",
        "plot",
        "limit",
        "matrix",
        "determinant",
        "find x",
        "simplify"
    ]

    return any(word in query.lower() for word in math_keywords)


# -----------------------------
# 🔥 Groq Client
# -----------------------------

client = Groq(
    api_key=os.getenv("GROQ_API_KEY")
)


# -----------------------------
# 🔥 Main Answer Generator
# -----------------------------

def generate_answer(messages):

    latest_question = messages[-1]["content"]

    # ----------------------------------
    # 🔥 Math Engine First
    # ----------------------------------

    math_result = process_math(latest_question)

    if math_result:
        return math_result

    # ----------------------------------
    # 🔥 Retrieve Context (RAG)
    # ----------------------------------

    context = retrieve_context(latest_question)

    if not context or not context.strip():
        return "This topic is not available in the NCERT database."

    # ----------------------------------
    # 🔥 PASS 1 : Answer Generation
    # ----------------------------------

    generation_prompt = f"""
You are an AI tutor trained strictly on NCERT textbooks.

RULES:
- Use ONLY the provided context.
- Do NOT add outside knowledge.
- Do NOT invent identity.
- If answer not in context, say unavailable.
- Explain in simple student-friendly language.
- If possible give step-by-step solution.
- Give examples if possible.
- Give real-life applications if possible.
- If question is mathematical, provide clear LaTeX formatted equations.
- Never use markdown or any formatting except LaTeX for equations.
- Use LaTeX only for equations.
    Example:
    Force equation: $$F=ma$$
    Integral: $$\int_a^b f(x) dx$$
    Fraction: $$\frac{{a}}{{b}}$$


CONTEXT:
{context}

QUESTION:
{latest_question}

Provide a clear structured answer.
"""

    # 🔥 Temperature Control

    if is_math_question(latest_question):
        temp = 0.2
    else:
        temp = 0.6

    response = client.chat.completions.create(

        model="llama-3.3-70b-versatile",

        messages=[

            {
                "role": "system",
                "content": "You are a helpful NCERT school teacher."
            },

            {
                "role": "user",
                "content": generation_prompt
            }

        ],

        temperature=temp,
        top_p=0.9,
        max_tokens=1000

    )

    answer = response.choices[0].message.content
    # -----------------------------
# 🔥 Text Formatting Fix
# -----------------------------

    answer = re.sub(r'([a-z])([A-Z])', r'\1 \2', answer)   # Fix joined words
    #answer = answer.replace(".", ". ")
    #answer = answer.replace(",", ", ")
    #answer = re.sub(r"\n{3,}", "\n\n", answer)  # Remove extra blank lines
    answer = re.sub(r"\\*(.*?)\*\*", r"\1", answer)  # Convert **text** to LaTeX inline math
    # Convert \( \) to $$ $$

    answer = answer.replace("\\(", "$$")
    answer = answer.replace("\\)", "$$")

    # 🔥 Fix LaTeX Escape
    answer = answer.replace("\\\\", "\\")

    # ----------------------------------
    # 🔥 PASS 2 : Verification Layer
    # ----------------------------------

    verification_prompt = f"""
You are a strict AI answer auditor.

RULES:

- Do NOT invent identity.
- Do NOT claim to be a real person.
- If asked your name say:
"I am an AI tutor based on NCERT textbooks."
Concept:
Explain clearly.

Formula (if any):
Use $$LaTeX$$.

Example:
Give one simple example.

Application:
Explain real-life use if possible.

- Answer must be strictly supported by context.
- If unsupported mark INVALID.

Reply with ONLY ONE WORD:

VALID
PARTIAL
INVALID

CONTEXT:
{context}

ANSWER:
{answer}
"""

    verification = client.chat.completions.create(

        model="llama-3.3-70b-versatile",

        messages=[

            {
                "role": "system",
                "content": "You are a strict answer verifier."
            },

            {
                "role": "user",
                "content": verification_prompt
            }

        ],

        temperature=0.2,
        max_tokens=1000

    )

    verdict = verification.choices[0].message.content.strip().upper()

    # ----------------------------------
    # 🔥 Final Decision Logic
    # ----------------------------------

    if "INVALID" in verdict:

        return "⚠ The answer could not be reliably generated from the NCERT context."

    elif "PARTIAL" in verdict:

        return f"{answer}\n\n⚠ Some parts may not be fully supported by the NCERT context."

    else:

        return answer