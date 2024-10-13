from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import joblib
import json
import time
import logging
import boto3
from azure.storage.blob import BlobServiceClient


# Class to handle object storage (S3/MinIO/Azure)
class ObjectStorageClient:
    def __init__(self, storage_type="minio", bucket_name="my-bucket", endpoint_url=None):
        self.storage_type = storage_type
        self.bucket_name = bucket_name
        self.endpoint_url = endpoint_url
        if storage_type == "minio" or storage_type == "s3":
            self.s3_client = boto3.client(
                "s3",
                endpoint_url=endpoint_url,  # MinIO requires an endpoint URL
                aws_access_key_id="minioadmin",
                aws_secret_access_key="minioadmin"
            )
        elif storage_type == "azure":
            self.azure_client = BlobServiceClient.from_connection_string(endpoint_url)

    def upload_file(self, file_name, content):
        """Uploads a file to object storage."""
        if self.storage_type in ["minio", "s3"]:
            self.s3_client.put_object(Bucket=self.bucket_name, Key=file_name, Body=json.dumps(content))
        elif self.storage_type == "azure":
            blob_client = self.azure_client.get_blob_client(container=self.bucket_name, blob=file_name)
            blob_client.upload_blob(json.dumps(content))


# Initialize FastAPI app
app = FastAPI()

# Load pre-trained model
MODEL_PATH = "../trained_model.pkl"
model = joblib.load(MODEL_PATH)

# Set up logging for latency
logging.basicConfig(filename='latency_logs.log', level=logging.INFO, format='%(asctime)s %(message)s')

# Object Storage Client: Use MinIO locally (You can change to 's3' or 'azure')
storage_client = ObjectStorageClient(
    storage_type="minio",
    bucket_name="my-bucket",
    endpoint_url="http://localhost:9000"  # MinIO endpoint URL
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
