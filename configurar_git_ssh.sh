#!/bin/bash

set -e

echo "🔧 CONFIGURADOR DE GIT COM SSH"

# 🧑 Nome e e-mail
read -rp "📝 Digite seu nome completo para o Git (ex: Andre Vieira): " GIT_NAME
read -rp "📧 Digite seu e-mail para o Git (ex: voce@email.com): " GIT_EMAIL

# 👤 Nome de usuário e serviço
read -rp "👤 Digite seu nome de usuário no serviço Git remoto (ex: engcomAndre): " GIT_USERNAME
read -rp "🌐 Qual serviço você está usando? (github/gitlab/bitbucket): " GIT_SERVICE

# 🔠 Normaliza o nome do serviço
GIT_SERVICE=$(echo "$GIT_SERVICE" | tr '[:upper:]' '[:lower:]')

# ⚙️ Configura Git global
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

# 🗝️ Caminho da chave
SSH_FILE="$HOME/.ssh/id_ed25519"

if [ -f "$SSH_FILE" ]; then
    echo "⚠️ Chave SSH já existe em: $SSH_FILE"
else
    echo "🔐 Gerando nova chave SSH..."
    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_FILE" -N ""
    echo "✅ Chave gerada com sucesso."
fi

# 🔄 Adiciona ao ssh-agent
eval "$(ssh-agent -s)"
ssh-add "$SSH_FILE"

# 🔑 Exibe chave pública
echo ""
echo "🔑 SUA CHAVE PÚBLICA (adicione no seu Git remoto):"
echo "--------------------------------------------------"
cat "$SSH_FILE.pub"
echo "--------------------------------------------------"

# 🌍 URL de cadastro
case "$GIT_SERVICE" in
    github)
        echo "➡️ Adicione em: https://github.com/settings/keys"
        SSH_TEST_TARGET="git@github.com"
        ;;
    gitlab)
        echo "➡️ Adicione em: https://gitlab.com/-/profile/keys"
        SSH_TEST_TARGET="git@gitlab.com"
        ;;
    bitbucket)
        echo "➡️ Adicione em: https://bitbucket.org/account/settings/ssh-keys/"
        SSH_TEST_TARGET="git@bitbucket.org"
        ;;
    *)
        echo "❌ Teste automático não executado. Serviço remoto desconhecido."
        exit 0
        ;;
esac

# 🧪 Teste de conexão SSH
echo ""
echo "🧪 Testando conexão com $GIT_SERVICE..."

set +e  # desativa saída imediata em erro
OUTPUT=$(ssh -T "$SSH_TEST_TARGET" 2>&1)
EXIT_CODE=$?
set -e

echo "$OUTPUT"
if [[ $EXIT_CODE -eq 1 && "$OUTPUT" == *"successfully authenticated"* ]]; then
    echo "✅ Conexão SSH com $GIT_SERVICE funcionando corretamente!"
else
    echo "⚠️ Conexão falhou ou a chave ainda não foi adicionada ao serviço remoto."
fi

