#!/bin/bash

set -e

echo "🔧 [1/6] Atualizando sistema..."
sudo apt update -y

echo "📦 [2/6] Instalando dependências básicas..."
sudo apt install -y curl apt-transport-https

echo "📥 [3/6] Baixando Minikube..."
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

echo "📂 Instalando Minikube..."
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

echo "📥 Baixando kubectl versão estável mais recente..."

curl -fL -o kubectl https://dl.k8s.io/release/v1.30.1/bin/linux/amd64/kubectl

if [ ! -f kubectl ]; then
  echo "❌ Falha ao baixar kubectl. Verifique a URL ou sua conexão."
  exit 1
fi

echo "📂 Instalando kubectl..."
sudo install kubectl /usr/local/bin/
rm kubectl

echo "🚀 [5/6] Iniciando Minikube com driver Docker..."
minikube start --driver=docker

echo ""
echo "✅ Minikube inicializado com sucesso."
echo ""

echo "🧪 [6/6] Testando ambiente Kubernetes..."

# Teste com timeout de 20 segundos
ATTEMPTS=0
MAX_ATTEMPTS=10
while true; do
  OUTPUT=$(kubectl get nodes 2>&1 || true)
  if echo "$OUTPUT" | grep -q "Ready"; then
    echo "✅ Cluster está funcionando:"
    echo "$OUTPUT"
    break
  fi
  ATTEMPTS=$((ATTEMPTS+1))
  if [ $ATTEMPTS -ge $MAX_ATTEMPTS ]; then
    echo "❌ Falha: Cluster não respondeu após várias tentativas."
    echo "$OUTPUT"
    exit 1
  fi
  echo "⏳ Aguardando cluster ficar pronto... (tentativa $ATTEMPTS/$MAX_ATTEMPTS)"
  sleep 2
done

echo ""
echo "🎉 Kubernetes instalado e testado com sucesso!"
echo "👉 Use: kubectl get pods -A ou minikube dashboard"

