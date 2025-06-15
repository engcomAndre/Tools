#!/bin/bash

set -e

echo "🔧 [1/6] Atualizando pacotes..."
sudo apt update

echo "📦 [2/6] Instalando Flameshot..."
sudo apt install flameshot -y

echo "🛠️ [3/6] Criando configuração personalizada..."
mkdir -p ~/.config/flameshot
cat > ~/.config/flameshot/flameshot.ini <<EOF
[General]
contrastOpacity=180
drawColor=#ff0000
savePath=$HOME/Pictures
filenamePattern=Screenshot_%Y-%m-%d_%H-%M-%S.png
uiColor=#ff9100
showHelp=false
saveAfterCopy=true
copyPathAfterSave=false
EOF

echo "✅ Configuração salva em ~/.config/flameshot/flameshot.ini"

echo "⚙️ [4/6] Forçando sessão X11 (Xorg) no Ubuntu..."

GDM_CONFIG="/etc/gdm3/custom.conf"
if grep -q "^#WaylandEnable=false" "$GDM_CONFIG"; then
    echo "Descomentando WaylandEnable=false em $GDM_CONFIG"
    sudo sed -i 's/^#WaylandEnable=false/WaylandEnable=false/' "$GDM_CONFIG"
elif ! grep -q "^WaylandEnable=false" "$GDM_CONFIG"; then
    echo "Adicionando WaylandEnable=false ao $GDM_CONFIG"
    echo "WaylandEnable=false" | sudo tee -a "$GDM_CONFIG"
else
    echo "Wayland já está desabilitado."
fi

echo "🖱️ [5/6] Criando atalho de teclado para Print → flameshot gui"
# Apaga qualquer entrada anterior
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[]"
sleep 1
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/flameshot/']"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/flameshot/ name 'Flameshot GUI'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/flameshot/ command 'flameshot gui'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/flameshot/ binding 'Print'

echo ""
echo "🚀 [6/6] Tudo pronto!"
echo "🔁 Reinicie o sistema para entrar automaticamente em sessão X11 e ativar o atalho Print com Flameshot."
echo ""
echo "🧪 Depois do reboot, pressione Print e o Flameshot deve iniciar a captura da tela."

