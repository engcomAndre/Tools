#!/bin/bash

set -e

echo "🔧 CONFIGURADOR DE GIT COM SSH"

# 🧑 Nome e e-mail do Git
read -rp "📝 Digite seu nome completo para o Git (ex: Andre Vieira): " GIT_NAME
read -rp "📧 Digite seu e-mail para o Git (ex: voce@email.com): " GIT_EMAIL

# 👤 Nome de usuário (login no GitHub/GitLab/Bitbucket)
read -rp "👤 Digite seu nome de usuário no serviço Git remoto (ex: andrevieira): " GIT_USERNAME

# 🌐 Serviço remoto
read -rp "🌐 Qual serviço você está usando? (github/gitlab/bitbucket): " GIT_SERVICE

# Configurações globais do Git
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

echo "✅ Nome, e-mail e usuário configurados."

# 🔐 Geração de chave SSH
SSH_FILE="$HOME/.ssh/id_ed25519"

if [ -f "$SSH_FILE" ]; then
    echo "⚠️ Chave SSH já existe em: $SSH_FILE"
else
    echo "🔐 Gerando nova chave SSH..."
    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_FILE" -N ""
    echo "✅ Chave gerada com sucesso."
fi

# Iniciar ssh-agent e adicionar chave
eval "$(ssh-agent -s)"
ssh-add "$SSH_FILE"

# Mostrar chave pública
echo ""
echo "🔑 SUA CHAVE PÚBLICA (adicione no site remoto):"
echo "--------------------------------------------------"
cat "$SSH_FILE.pub"
echo "--------------------------------------------------"

# URLs para colar a chave
echo ""
case "$GIT_SERVICE" in
    github)
        echo "➡️ Adicione sua chave aqui: https://github.com/settings/keys"
        SSH_TEST_TARGET="git@github.com"
        ;;
    gitlab)
        echo "➡️ Adicione sua chave aqui: https://gitlab.com/-/profile/keys"
        SSH_TEST_TARGET="git@gitlab.com"
        ;;
    bitbucket)
        echo "➡️ Adicione sua chave aqui: https://bitbucket.org/account/settings/ssh-keys/"
        SSH_TEST_TARGET="git@bitbucket.org"
        ;;
    *)
        echo "⚠️ Serviço desconhecido. Teste manualmente após adicionar a chave."
        SSH_TEST_TARGET=""
        ;;
esac

# Testar a conexão
if [ -n "$SSH_TEST_TARGET" ]; then
    echo ""
    echo "🧪 Testando conexão com $GIT_SERVICE..."
    ssh -T "$SSH_TEST_TARGET" || echo "⚠️ Erro de conexão (talvez a chave ainda não foi adicionada no site?)"
else
    echo "🛑 Teste automático não foi executado. Serviço remoto desconhecido."
fi

