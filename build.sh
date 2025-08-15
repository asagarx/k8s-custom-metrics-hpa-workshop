#!/bin/bash

# Set variables
AWS_REGION=${AWS_REGION:-us-east-1}
ECR_REPO_NAME="app_custom_metrics"
IMAGE_TAG=${IMAGE_TAG:-latest}

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"

# Login to ECR
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# Build image for linux/amd64 platform and tag for ECR
docker buildx build --platform linux/amd64 -t ${ECR_URI}:${IMAGE_TAG} --load .

# Push image to ECR
docker push ${ECR_URI}:${IMAGE_TAG}

echo "Image pushed to: ${ECR_URI}:${IMAGE_TAG}"