#!/bin/bash
set -e

echo "Aplicando ConfigMap e Secrets..."
kubectl apply -f kubernetes/base/configmap.yaml
kubectl apply -f kubernetes/base/secrets.yaml

echo "Aplicando Usuario API..."
kubectl apply -f kubernetes/base/usuario-api/

echo "Aplicando Jogo API..."
kubectl apply -f kubernetes/base/jogo-api/

echo "Aplicando Pagamento API..."
kubectl apply -f kubernetes/base/pagamento-api/

echo "Aplicando Ingress..."
kubectl apply -f kubernetes/base/ingress.yaml

echo "Aguardando deployments ficarem prontos..."
kubectl rollout status deployment/usuario-api-deployment
kubectl rollout status deployment/jogo-api-deployment
kubectl rollout status deployment/pagamento-api-deployment

echo "✅ Deploy completo!"
kubectl get pods
kubectl get services
kubectl get ingress
