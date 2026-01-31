#!/bin/bash

PROJECT=$(gcloud config get-value project)
REGION=europe-west2
REPO=ume
SERVICE=ume-api
JOB=ume-algo
SA=firebase-adminsdk-fbsvc@$PROJECT.iam.gserviceaccount.com
IMG="$REGION-docker.pkg.dev/$PROJECT/$REPO/$SERVICE:latest"
JOB_IMG="$REGION-docker.pkg.dev/$PROJECT/$REPO/$JOB:latest"

# Docker auth
gcloud auth configure-docker "$REGION-docker.pkg.dev" --quiet

# Ensure repo exists
gcloud artifacts repositories describe "$REPO" --location "$REGION" \
  || gcloud artifacts repositories create "$REPO" --location "$REGION" --repository-format=docker

# Build & push images
docker build -t "$IMG" .
docker build -t "$JOB_IMG" -f Dockerfile.job .
docker push "$IMG"
docker push "$JOB_IMG"
echo "✅ Built & Pushed Docker images to Artifact Registry"

# Deploy Cloud Run service
gcloud run deploy "$SERVICE" \
  --image "$IMG" --region "$REGION" \
  --platform managed --allow-unauthenticated \
  --service-account "$SA"

# Deploy or update Cloud Run job
gcloud run jobs deploy "$JOB" \
  --image "$JOB_IMG" --region "$REGION" \
  --service-account "$SA" --memory 2Gi --task-timeout 24h

# Ensure scheduler exists (create or update)
gcloud scheduler jobs describe "$JOB-scheduler" --location "$REGION" \
  || gcloud scheduler jobs create http "$JOB-scheduler" \
      --schedule "1 8 * * *" --location "$REGION" \
      --time-zone "UTC" --http-method POST \
      --uri "https://$REGION-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/$PROJECT/jobs/$JOB:run" \
      --oauth-service-account-email "$SA"

echo "✅ Deployment of cloud run, task and scheduler done"

# Remove local images to free up space (only the ones just built)
docker rmi "$IMG" || echo "Image $IMG not found locally, skipping removal."
docker rmi "$JOB_IMG" || echo "Image $JOB_IMG not found locally, skipping removal."

echo "✅ Cleaned up local Docker images"