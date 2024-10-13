# Use the official Python slim image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy requirements file
COPY ../requirements.txt .

# Install required packages
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY ../API/post_request.py ./post_request.py
COPY ../trained_model.pkl ./trained_model.pkl

# Copy SSL certificates
COPY key.pem /app/key.pem
COPY cert.pem /app/cert.pem

# Expose the HTTPS port
EXPOSE 8887

# Run the FastAPI app with Uvicorn using HTTPS
CMD ["uvicorn", "post_request:app", "--host", "0.0.0.0", "--port", "8887", "--ssl-keyfile", "/app/key.pem", "--ssl-certfile", "/app/cert.pem"]
