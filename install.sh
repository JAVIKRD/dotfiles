#!/bin/bash
set -e

CONFIGS=(hypr waybar kitty fish tmux wofi dunst rofi)
FILES=(starship.toml)

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config.bak.$(date +%Y%m%d_%H%M%S)"

declare -A DEP_PACKAGES=(
  [hyprland]=hyprland
  [waybar]=waybar
  [kitty]=kitty
  [fish]=fish
  [tmux]=tmux
  [wofi]=wofi
  [dunst]=dunst
  [rofi]=rofi
  [starship]=starship
  [wpctl]=wireplumber
  [pactl]=pipewire-pulse
  [aplay]=alsa-utils
  [checkupdates]=pacman-contrib
  [nmcli]=networkmanager
  [blueman-manager]=blueman
  [pavucontrol]=pavucontrol
  [hyprpaper]=hyprpaper
)

check_deps() {
  echo "Verificando dependencias..."
  local missing=()
  for cmd in "${!DEP_PACKAGES[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
      missing+=("${DEP_PACKAGES[$cmd]}")
    fi
  done
  if [ ${#missing[@]} -gt 0 ]; then
    echo "[!] Faltan estos paquetes: ${missing[*]}"
    echo "    Instala con: sudo pacman -S ${missing[*]}"
  else
    echo "[+] Todas las dependencias están instaladas"
  fi
  echo ""
}

install_configs() {
  for name in "${CONFIGS[@]}"; do
    src="$DOTFILES_DIR/$name"
    dst="$CONFIG_DIR/$name"
    if [ ! -e "$src" ]; then
      echo "[!] No encontrado: $name, saltando"
      continue
    fi
    if [ -e "$dst" ]; then
      mkdir -p "$BACKUP_DIR"
      cp -r "$dst" "$BACKUP_DIR/${name}.bak"
      echo "[!] Backup de $name guardado en $BACKUP_DIR"
    fi
    mkdir -p "$CONFIG_DIR"
    cp -r "$src" "$dst"
    echo "[+] Instalado: $name"
  done

  for name in "${FILES[@]}"; do
    src="$DOTFILES_DIR/$name"
    dst="$CONFIG_DIR/$name"
    if [ ! -e "$src" ]; then
      echo "[!] No encontrado: $name, saltando"
      continue
    fi
    if [ -e "$dst" ]; then
      mkdir -p "$BACKUP_DIR"
      cp "$dst" "$BACKUP_DIR/${name}.bak"
      echo "[!] Backup de $name guardado en $BACKUP_DIR"
    fi
    cp "$src" "$dst"
    echo "[+] Instalado: $name"
  done
}

install_wallpapers() {
  local src="$DOTFILES_DIR/wallpapers"
  local dst="$HOME/Pictures/Wallpapers"
  if [ ! -d "$src" ]; then
    echo "[!] No hay carpeta de wallpapers, saltando"
    return
  fi
  mkdir -p "$dst"
  cp -r "$src"/* "$dst"/
  echo "[+] Wallpapers copiados a $dst"

  # Reemplazar el placeholder __HOME__ por el HOME real de este usuario
  local hyprpaper="$CONFIG_DIR/hypr/hyprpaper.conf"
  if [ -f "$hyprpaper" ]; then
    sed -i "s|__HOME__|$HOME|g" "$hyprpaper"
    echo "[+] Ruta de wallpaper ajustada en hyprpaper.conf"
  fi
}

main() {
  echo "Instalando dotfiles desde $DOTFILES_DIR"
  echo ""
  check_deps
  install_configs
  install_wallpapers
  echo ""
  echo "Listo. Si algo ya existía, quedó respaldado en: $BACKUP_DIR"
  echo "Reinicia Hyprland/waybar para aplicar los cambios."
}

main
