#!/bin/bash
set -e

echo "Deletando Ingress..."
kubectl delete -f kubernetes/base/ingress.yaml --ignore-not-found=true

echo "Deletando APIs..."
kubectl delete -f kubernetes/base/usuario-api/ --ignore-not-found=true
kubectl delete -f kubernetes/base/jogo-api/ --ignore-not-found=true
kubectl delete -f kubernetes/base/pagamento-api/ --ignore-not-found=true

echo "Deletando ConfigMap e Secrets..."
kubectl delete -f kubernetes/base/configmap.yaml --ignore-not-found=true
kubectl delete -f kubernetes/base/secrets.yaml --ignore-not-found=true

echo "✅ Tudo deletado!"
