# Use the official Python image as base
FROM python:3.10-slim

# Set working directory in the container
WORKDIR /app

# Install dependencies from requirements.txt
COPY requirements.txt .
RUN pip install -r requirements.txt

# Expose port 8080 to the outside world
EXPOSE 8080

# Copy the application files
COPY routers/ ./routers/
COPY src/ ./src/
COPY .env .

# Command to run the FastAPI application with Uvicorn
COPY app.py .
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080", "--env-file", ".env"]
