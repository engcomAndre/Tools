#!/bin/bash

set -e

echo "🔍 Verificando se o Docker está instalado..."
if ! command -v docker &> /dev/null; then
  echo "❌ Docker não está instalado. Instale o Docker antes de continuar."
  exit 1
fi

echo "⬇️ Instalando Docker Compose v2 (plugin)..."

DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins

curl -SL https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64 \
  -o $DOCKER_CONFIG/cli-plugins/docker-compose

chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

echo "✅ Docker Compose instalado como plugin CLI."
echo "🧪 Versão instalada:"
docker compose version

