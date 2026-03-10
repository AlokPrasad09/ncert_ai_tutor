FROM python:3.11-slim

# Prevent Python from writing .pyc files and keep logs flowing
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app

# Copy and install dependencies first (leverages Docker cache)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Cloud Run ignores EXPOSE, but it's good for documentation
EXPOSE 8080

# Use shell form to allow environment variable substitution for the port
CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8080"]