#!/bin/bash

# Verificar se o script está sendo executado como root
if [[ $EUID -ne 0 ]]; then
   echo "Este script deve ser executado como root"
   exit 1
fi

# Função para converter bytes para uma unidade legível
convert_bytes() {
    local size=$1
    local units=("B" "KB" "MB" "GB" "TB")
    local i=0
    while ((size > 1024 && i < ${#units[@]} - 1)); do
        size=$((size / 1024))
        ((i++))
    done
    echo "$size ${units[i]}"
}

# Obter o espaço livre inicial
initial_free=$(df --output=avail / | tail -n 1)

echo "Iniciando a limpeza do sistema..."

# Atualizar a lista de pacotes
echo "Atualizando a lista de pacotes..."
apt update

# Atualizar pacotes do Flatpak
echo "Atualizando pacotes do Flatpak..."
flatpak update -y

# Limpar o cache do apt
echo "Limpando o cache do apt..."
apt clean
apt autoclean

# Remover pacotes desnecessários
echo "Removendo pacotes desnecessários..."
apt autoremove -y

# Limpar arquivos temporários
echo "Limpando arquivos temporários..."
rm -rf /tmp/*
rm -rf /var/tmp/*

# Limpar cache de miniaturas
echo "Limpando cache de miniaturas..."
rm -rf ~/.cache/thumbnails/*

# Limpar logs antigos
echo "Limpando logs antigos..."
find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;

# Limpar cache de usuários (opcional)
echo "Limpando cache de usuários..."
rm -rf ~/.cache/*

# Limpar cache do navegador (Firefox)
echo "Limpando cache do navegador Firefox..."
rm -rf ~/.mozilla/firefox/*.default-release/cache2/*

# Limpar dados do Google Chrome
echo "Limpando cache do Google Chrome..."
rm -rf ~/.cache/google-chrome/*

echo "Limpando cookies do Google Chrome..."
rm -rf ~/.config/google-chrome/Default/Cookies

echo "Limpando histórico de navegação do Google Chrome..."
rm -rf ~/.config/google-chrome/Default/History

# Limpar a lixeira
echo "Limpando a lixeira..."
rm -rf ~/.local/share/Trash/*

# Limpar logs do journalctl
echo "Limpando logs do journalctl..."
journalctl --vacuum-time=2weeks

# Reiniciar a memória swap
echo "Reiniciando a memória swap..."
swapoff -a
swapon -a

# Obter o espaço livre final
final_free=$(df --output=avail / | tail -n 1)

# Calcular o espaço liberado
space_freed=$((initial_free - final_free))
space_freed_human=$(convert_bytes $space_freed)

echo "Limpeza do sistema concluída!"
echo "Espaço total liberado: $space_freed_human"

exit 0
