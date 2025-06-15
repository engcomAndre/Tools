#!/bin/bash

# Atualiza os pacotes do sistema
echo "Atualizando o sistema..."
sudo apt update

# Baixa o pacote .deb do Google Chrome
echo "Baixando o Google Chrome..."
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

# Instala o pacote .deb
echo "Instalando o Google Chrome..."
sudo dpkg -i google-chrome-stable_current_amd64.deb

# Corrige dependências, se necessário
echo "Corrigindo dependências (se houver)..."
sudo apt install -f -y

# Remove o pacote .deb baixado
echo "Limpando o instalador..."
rm google-chrome-stable_current_amd64.deb

# Confirma a instalação
echo "Instalação concluída. Versão instalada:"
google-chrome --version

