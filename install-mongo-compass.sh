#!/bin/bash

set -e

echo "🔍 Verificando dependências..."
sudo apt update
sudo apt install -y wget gpg

echo "⬇️ Baixando MongoDB Compass..."
COMPASS_VERSION="1.43.0"
wget -O mongodb-compass.deb "https://downloads.mongodb.com/compass/mongodb-compass_${COMPASS_VERSION}_amd64.deb"

echo "📦 Instalando MongoDB Compass..."
sudo dpkg -i mongodb-compass.deb || sudo apt --fix-broken install -y

echo "🧹 Limpando arquivos temporários..."
rm -f mongodb-compass.deb

echo "✅ MongoDB Compass instalado com sucesso!"
echo "🚀 Você pode iniciar digitando: mongodb-compass &"

