# README

## Build Docker Image

### AWS

aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 606502636908.dkr.ecr.us-west-2.amazonaws.com
docker build -f src/Dockerfile -t 606502636908.dkr.ecr.us-west-2.amazonaws.com/callsign:1.0.0 src/
docker push 606502636908.dkr.ecr.us-west-2.amazonaws.com/callsign:1.0.0

### AZURE

az acr login --name callsign.azurecr.io
docker build -f src/Dockerfile -t callsign.azurecr.io/callsign:latest src/
docker push callsign.azurecr.io/callsign:latest

### GCP

gcloud auth configure-docker
docker build -f src/Dockerfile -t us-central1-docker.pkg.dev/callsign-438509/callsign/callsign:latest --platform linux/amd4 src/
docker push us-central1-docker.pkg.dev/callsign-438509/callsign/callsign:latest
