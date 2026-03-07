import sympy as sp
import numpy as np
import matplotlib
matplotlib.use("Agg")  # Production safe
import matplotlib.pyplot as plt
import io
import base64


def process_math(text):
    text = text.strip()

    if text.lower().startswith("plot"):
        return plot_function(text)

    if "solve" in text.lower() and "=" in text:
        return solve_equation(text)

    if "differentiate" in text.lower():
        return differentiate_expression(text)

    if "integrate" in text.lower():
        return integrate_expression(text)

    return None


# ---------------- SOLVE ----------------

def solve_equation(text):
    try:
        text = text.lower().replace("solve", "").strip()
        text = text.replace("^", "**")

        x = sp.symbols('x')

        left, right = text.split("=")
        eq = sp.Eq(sp.sympify(left), sp.sympify(right))

        solution = sp.solve(eq, x)

        return {
    "type": "math",
    "equation": sp.latex(eq),
    "solution": sp.latex(solution)
    }

    except Exception as e:
        return f"Could not solve: {str(e)}"


# ---------------- DIFFERENTIATE ----------------

def differentiate_expression(text):
    try:
        text = text.lower().replace("differentiate", "").strip()
        text = text.replace("^", "**")

        x = sp.symbols('x')
        expr = sp.sympify(text)
        derivative = sp.diff(expr, x)

        return f"$$ {sp.latex(derivative)} $$"

    except Exception as e:
        return f"Could not differentiate: {str(e)}"


# ---------------- INTEGRATE ----------------

def integrate_expression(text):
    try:
        text = text.lower().replace("integrate", "").strip()
        text = text.replace("^", "**")

        x = sp.symbols('x')
        expr = sp.sympify(text)
        integral = sp.integrate(expr, x)

        return f"$$ {sp.latex(integral)} + C $$"

    except Exception as e:
        return f"Could not integrate: {str(e)}"


# ---------------- PLOT ----------------

def plot_function(text):
    try:
        text = text.lower().replace("plot", "").strip()

        if "=" in text:
            parts = text.split("=")
            text = parts[1].strip()

        text = text.replace("^", "**")

        x = sp.symbols('x')
        expr = sp.sympify(text)

        f = sp.lambdify(x, expr, "numpy")

        x_vals = np.linspace(-10, 10, 400)
        y_vals = f(x_vals)

        plt.figure()
        plt.plot(x_vals, y_vals)
        plt.axhline(0)
        plt.axvline(0)
        plt.title(f"Graph of y = {text}")
        plt.grid()

        buf = io.BytesIO()
        plt.savefig(buf, format="png")
        buf.seek(0)
        plt.close()

        img_base64 = base64.b64encode(buf.read()).decode("utf-8")

        return {"type": "plot", "image": img_base64}

    except Exception as e:
        return {"type": "error", "message": f"Could not plot: {str(e)}"}