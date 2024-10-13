from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import joblib
import json
import time
import logging
import boto3
from azure.storage.blob import BlobServiceClient
import os

# Class to handle object storage (MinIO, S3, Azure)
class ObjectStorageClient:
    def __init__(self, storage_type="minio", bucket_name="my-fastapi-bucket-callsign", endpoint_url=None, region_name=None):
        self.storage_type = storage_type
        self.bucket_name = bucket_name
        self.endpoint_url = endpoint_url
        if storage_type == "minio" or storage_type == "s3":
            # Initialize Boto3 client for MinIO or AWS S3
            self.s3_client = boto3.client(
                "s3",
                endpoint_url=endpoint_url,  # Required for MinIO (ignored for S3)
                aws_access_key_id=os.getenv('AWS_ACCESS_KEY_ID') if storage_type == "s3" else "minioadmin",
                aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS_KEY') if storage_type == "s3" else "minioadmin",
                region_name=region_name
            )
        elif storage_type == "azure":
            # Initialize Azure Blob Storage client
            connection_string = os.getenv('AZURE_STORAGE_CONNECTION_STRING')
            if not connection_string:
                raise ValueError("AZURE_STORAGE_CONNECTION_STRING environment variable is not set")
            self.azure_client = BlobServiceClient.from_connection_string(connection_string)
            self.container_client = self.azure_client.get_container_client(bucket_name)
            # Ensure the container exists
            if not self.container_client.exists():
                self.container_client.create_container()

    def upload_file(self, file_name, content):
        """Uploads a file to object storage."""
        if self.storage_type in ["minio", "s3"]:
            self.s3_client.put_object(Bucket=self.bucket_name, Key=file_name, Body=json.dumps(content))
        elif self.storage_type == "azure":
            blob_client = self.container_client.get_blob_client(file_name)
            blob_client.upload_blob(json.dumps(content), overwrite=True)

# Initialize FastAPI app
app = FastAPI()

# Load pre-trained model
MODEL_PATH = "../trained_model.pkl"
model = joblib.load(MODEL_PATH)

# Set up logging for latency
logging.basicConfig(filename='latency_logs.log', level=logging.INFO, format='%(asctime)s %(message)s')

# Determine storage type (minio for local, s3 for AWS, azure for Azure Blob)
storage_type = os.getenv('STORAGE_TYPE', 'minio')  # Default to 'minio'
bucket_name = "my-fastapi-bucket-callsign"
region_name = 'eu-north-1'  # Change this to your region if necessary

# Configure Object Storage Client
if storage_type == "minio":
    # Use MinIO endpoint
    storage_client = ObjectStorageClient(
        storage_type="minio",
        bucket_name=bucket_name,
        endpoint_url="http://localhost:9000"  # MinIO endpoint URL for local
    )
elif storage_type == "s3":
    # Use AWS S3
    storage_client = ObjectStorageClient(
        storage_type="s3",
        bucket_name=bucket_name,
        region_name=region_name
    )
elif storage_type == "azure":
    # Use Azure Blob Storage
    storage_client = ObjectStorageClient(
        storage_type="azure",
        bucket_name=bucket_name
    )

# Define the request body schema using Pydantic
class BotScoreRequest(BaseModel):
    x1: float
    x2: float

@app.post("/bot-score")
async def get_bot_score(request: BotScoreRequest):
    start_time = time.time()

    # Convert input features to list format for the model
    features = [request.x1, request.x2]

    try:
        # Predict the probability of the transaction being a bot
        probability = model.predict_proba([features])[0][1]

        # Create response
        response_data = {"p_bot": probability}

        # Upload request and response data to object storage
        request_data = request.dict()
        storage_client.upload_file(f"requests/{time.time()}_request.json", request_data)
        storage_client.upload_file(f"responses/{time.time()}_response.json", response_data)

        # Log latency
        latency = (time.time() - start_time) * 1000  # Convert to ms
        logging.info(f"Latency: {latency} ms")

        # If latency exceeds 200ms, raise an error
        if latency > 200:
            raise HTTPException(status_code=500, detail="Latency exceeded 200ms")

        return response_data

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# If running locally, start the FastAPI server on HTTP
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8887)