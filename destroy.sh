#!/bin/bash

echo "Destroying all resources..."

# Remove stress test if running
kubectl delete -f k8s/stress-test.yaml --ignore-not-found=true

# Remove HPA
kubectl delete -f k8s/hpa.yaml --ignore-not-found=true

# Remove APIService first to avoid stale discovery
kubectl delete apiservice v1beta1.custom.metrics.k8s.io --ignore-not-found=true

# Remove Prometheus adapter
kubectl delete -f k8s/prometheus-adapter.yaml --ignore-not-found=true
kubectl delete -f k8s/adapter-rbac.yaml --ignore-not-found=true

# Remove remaining APIService resources
kubectl delete -f k8s/apiservice.yaml --ignore-not-found=true

# Remove Prometheus
kubectl delete -f k8s/prometheus.yaml --ignore-not-found=true
kubectl delete -f k8s/prometheus-rbac.yaml --ignore-not-found=true

# Remove Grafana
kubectl delete -f grafana/deployment.yaml --ignore-not-found=true
kubectl delete -f grafana/configmap.yaml --ignore-not-found=true
kubectl delete -f grafana/datasource.yaml --ignore-not-found=true

# Remove cert-manager certificates
kubectl delete -f k8s/cert-manager.yaml --ignore-not-found=true

# Remove application
kubectl delete -f k8s/servicemonitor.yaml --ignore-not-found=true
kubectl delete -f k8s/service.yaml --ignore-not-found=true
kubectl delete -f k8s/deployment.yaml --ignore-not-found=true

# Remove namespaces (this will delete everything in them)
kubectl delete namespace custom-metrics --ignore-not-found=true
kubectl delete namespace monitoring --ignore-not-found=true

# Clean up generated deployment file
rm -f k8s/deployment.yaml

echo "All resources destroyed successfully!"
echo ""
echo "Note: ECR repository and images are not deleted."
echo "To delete ECR repository manually:"
echo "aws ecr delete-repository --repository-name app_custom_metrics --region ${AWS_REGION:-us-east-1} --force"