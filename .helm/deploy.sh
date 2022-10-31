#!/bin/bash

# NGINX INGRESS CONTROLLER
# Optional: deploy NGINX Ingress Controller into your cluster
# to expose the ingress outside the cluster.

# helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx 
# helm repo update

# helm upgrade nginx --version=4.3.0 -f extra/nginx-values.yaml --install ingress-nginx/ingress-nginx

# PROMETHEUS
# Optional: deploy Prometheus & Prometheus Adapter to scrape
# the pod metrics (if PHP-FPM and NGINX exporters are enabled)
# to automatically scale the containers based on the pm.max_children value.

# helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# helm repo add kube-state-metrics https://kubernetes.github.io/kube-state-metrics
# helm repo update

# helm upgrade prometheus \
#     --version=13.6.0 \
#     -f extra/prometheus-values.yaml \
#     --install \
#     prometheus-community/prometheus

# helm upgrade prometheus-adapter \
#     --version=2.12.1 \
#     -f extra/prometheus-adapter-values.yaml \
#     --install \
#     prometheus-community/prometheus-adapter

# INSTALL LARAVEL APPLICATION
# Deploy the Secret that will contain the .env file.
kubectl apply -f secret.yaml

helm repo add jd1378 https://jd1378.github.io/laravel-helm-charts
helm repo update

# Deploy the Laravel app with unit.
helm upgrade laravel --version=^1.0.3 -f laravel-values.yaml --install jd1378/laravel-unit

# Deploy (an example) worker for Laravel Queues.
helm upgrade laravel-worker --version=^1.0.1 -f laravel-worker-values.yaml --install jd1378/laravel-worker
