# README

## For Local Testing:

`pip install -r API/requirements.txt
`
### with minIO:

`docker-compose up -d
`
Check MinIO: Access MinIO at http://localhost:9001 and check if the request and response data are stored in the bucket.

#### Login with the following credentials:
Username: minioadmin

Password: minioadmin

#### Start the FastAPI application:

`uvicorn post_request_all:app --host 0.0.0.0 --port 8887
`

#### Test the API:

You can send a POST request using Postman or cURL to http://localhost:8887/bot-score with the following body:

`{
  "x1": 0.754,
  "x2": 0.156
}`

## For Cloud Environments:
### AWS, Azure, and GCP Setup:
The project is designed to run on AWS, Azure, and Google Cloud Platform (GCP). To deploy the project to these environments, use Docker and configure the storage for each provider.

Each cloud provider has its own setup process, detailed below:

#### AWS
**Login to AWS Elastic Container Registry (ECR):**


`aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 606502636908.dkr.ecr.us-west-2.amazonaws.com`


**Build the Docker image:**


`docker build -f Dockerfile -t 606502636908.dkr.ecr.us-west-2.amazonaws.com/callsign:1.0.0 
`

**Push the Docker image to ECR:**

`docker push 606502636908.dkr.ecr.us-west-2.amazonaws.com/callsign:1.0.0
`

**Run the application on AWS:**

* Create an ECS task or use AWS Fargate to deploy the container.
* Configure the task to use AWS S3 as the storage backend.


#### Azure

**Login to Azure Container Registry (ACR):**


`az acr login --name callsign.azurecr.io`


**Build the Docker image:**


`docker build -f Dockerfile -t callsign.azurecr.io/callsign:latest 
`

**Push the Docker image to ACR:**

`docker push callsign.azurecr.io/callsign:latest
`

**Run the application on Azure:**

* Use Azure Container Instances (ACI) or Azure Kubernetes Service (AKS) to deploy the container.
* Configure the container to use Azure Blob Storage for storing requests and responses.

#### GCP

**Configure Docker for GCP:**


`gcloud auth configure-docker
`

**Build the Docker image:**


`docker build -f Dockerfile -t us-central1-docker.pkg.dev/callsign-438509/callsign/callsign:latest --platform linux/amd4 
`

**Push the Docker image to GCP Container Registry:**


`docker push us-central1-docker.pkg.dev/callsign-438509/callsign/callsign:latest`


**Run the application on GCP:**

* Use Google Kubernetes Engine (GKE) or Cloud Run to deploy the container.
* Configure the container to use Google Cloud Storage for file storage.


### Infrastructure Management with Terraform
This project includes a Terraform configuration for automating infrastructure provisioning across AWS, Azure, and GCP.

#### High-Level Overview of Terraform Infrastructure:
The `infrastructure/` folder contains Terraform scripts to manage the resources on each cloud provider:

##### AWS:

* Creates an S3 bucket for storage.
* Sets up an Elastic Container Registry (ECR) and Elastic Container Service (ECS) for storing Docker images.
* Provisions the necessary IAM roles and policies for accessing S3 and running ECS tasks.
* Loadbalancing resources for traffic handling and routing.

##### Azure:

* Creates an Azure Storage Account and a Blob Container.
* Sets up Azure Container Registry (ACR) for Docker images.
* Configures Azure Container Instances (ACI) and Networking Capabilities.


##### GCP:

* Creates a Google Cloud Storage (GCS) bucket.
* Sets up Google Artifact Registry for Docker images.
* Provisions the necessary roles for Cloud Run or GKE deployment.



**Monitor the Resources**: Terraform will provision the resources on the selected cloud provider. You can monitor these resources using the respective cloud provider's dashboard:

* **AWS: AWS Management Console.**
* **Azure: Azure Portal.**
* **GCP: Google Cloud Console.**


### Monitoring the Application:
To monitor the application, use the native monitoring tools provided by each cloud provider:

* AWS: Use CloudWatch to monitor logs and performance metrics.
* Azure: Use Azure Monitor and Application Insights for logging and performance tracking.
* GCP: Use Google Cloud Monitoring and Cloud Logging for observability.
* Monitoring Locally
For local deployments, you can use the following tools to monitor the application:

* * Logs:

FastAPI logs are written to `latency_logs.log` by default.
You can also see real-time logs by running the application in the terminal:


`uvicorn post_request_all:app --host 0.0.0.0 --port 8887 --log-level info`

* * MinIO Console:

Monitor the storage of files in the MinIO console at http://localhost:9001.
* * Docker Logs:

To see container logs, run:

`docker logs <container_id>`


## Conclusion


This project supports local testing with MinIO as well as deployment in the cloud on AWS, Azure, and GCP. You can use Terraform to automate infrastructure provisioning for all cloud environments, and monitoring tools are available both locally and in the cloud to track performance and logs.

Make sure to configure the appropriate environment variables and set up the cloud credentials for your chosen environment before running the application. """



