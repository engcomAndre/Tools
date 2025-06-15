#!/bin/bash

set -e

echo "🚀 Iniciando instalação de ferramentas de desenvolvimento..."

# Atualiza sistema
sudo apt update && sudo apt upgrade -y

echo "🧰 Instalando utilitários CLI"
sudo apt install -y curl git unzip gnupg ca-certificates lsb-release software-properties-common

echo "📦 Instalando ferramentas de terminal: bat, fzf, ripgrep"
sudo apt install -y bat fzf ripgrep
echo "alias cat='batcat'" >> ~/.zshrc

echo "📦 Instalando httpie"
sudo apt install -y httpie

echo "🧭 Instalando zoxide (navegação inteligente)"
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc

echo "📂 Instalando SDKMAN! (Java/Kotlin)"
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 21-tem
sdk install kotlin

echo "📦 Instalando NVM e Node.js LTS"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
source "$NVM_DIR/nvm.sh"
nvm install --lts

echo "📦 Instalando Helm"
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "📦 Instalando k9s"
curl -LO https://github.com/derailed/k9s/releases/download/v0.32.4/k9s_Linux_amd64.tar.gz
tar -xzf k9s_Linux_amd64.tar.gz
sudo mv k9s /usr/local/bin/
rm -f k9s_Linux_amd64.tar.gz

echo "🐳 Instalando LazyDocker"
curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash

echo ""
echo "✅ Todas as ferramentas foram instaladas com sucesso!"
echo ""
echo "🔄 Reinicie o terminal ou execute: source ~/.zshrc"
echo "⚙️ Ferramentas disponíveis: bat, fzf, ripgrep, http, zoxide, sdk, nvm, helm, k9s, lazydocker"e
