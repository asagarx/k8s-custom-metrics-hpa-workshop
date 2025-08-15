#!/bin/bash

# Set variables
AWS_REGION=${AWS_REGION:-us-east-1}
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/app_custom_metrics:latest"

# Generate deployment with ECR image
sed "s|ECR_IMAGE_URI|${ECR_URI}|g" k8s/deployment-template.yaml > k8s/deployment.yaml

# Create namespaces
kubectl create namespace custom-metrics --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Deploy the application
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/servicemonitor.yaml

# Deploy cert-manager certificates
kubectl apply -f k8s/cert-manager.yaml

# Deploy Prometheus
kubectl apply -f k8s/prometheus-rbac.yaml
kubectl apply -f k8s/prometheus.yaml

# Wait for Prometheus to be ready
kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n monitoring

# Deploy RBAC for Prometheus adapter
kubectl apply -f k8s/adapter-rbac.yaml

# Deploy Prometheus adapter (requires Prometheus to be running)
kubectl apply -f k8s/prometheus-adapter.yaml

# Register custom metrics API
kubectl apply -f k8s/apiservice.yaml

# Deploy HPA
kubectl apply -f k8s/hpa.yaml

# Deploy Grafana
kubectl apply -f grafana/datasource.yaml
kubectl apply -f grafana/configmap.yaml
kubectl apply -f grafana/deployment.yaml

echo "Deployment complete. Check status with:"
echo "kubectl get pods"
echo "kubectl get hpa"
echo "kubectl get configmap grafana-dashboard-config -n monitoring"
echo ""
echo "To start stress testing (100 req/s):"
echo "kubectl apply -f k8s/stress-test.yaml"
echo ""
echo "To stop stress testing:"
echo "kubectl delete -f k8s/stress-test.yaml"