#!/usr/bin/env bash
set -euo pipefail

REPO="jh2929/whatsapp-desktop-for-linux"
RELEASE="v1.0.0"
API="https://api.github.com/repos/$REPO/releases/tags/$RELEASE"

detect_distro() {
  if command -v apt &>/dev/null; then
    echo "deb"
  elif command -v dnf &>/dev/null; then
    echo "rpm"
  elif command -v rpm &>/dev/null; then
    echo "rpm"
  elif command -v pacman &>/dev/null; then
    echo "arch"
  else
    echo "appimage"
  fi
}

get_asset_url() {
  local suffix="$1"
  curl -fsSL "$API" | grep -oP '"browser_download_url":.*?\K(https.*?'"$suffix"')' | head -1
}

install_deb() {
  echo "Detectada distribución basada en Debian/Ubuntu"
  local url=$(get_asset_url '\.deb$')
  local tmp=$(mktemp --suffix=.deb)
  curl -fsSL "$url" -o "$tmp"
  sudo dpkg -i "$tmp"
  rm -f "$tmp"
  echo "Instalación completada."
}

install_rpm() {
  echo "Detectada distribución basada en Fedora/RHEL"
  local url=$(get_asset_url '\.rpm$')
  local tmp=$(mktemp --suffix=.rpm)
  curl -fsSL "$url" -o "$tmp"
  sudo rpm -i "$tmp"
  rm -f "$tmp"
  echo "Instalación completada."
}

install_arch() {
  echo "Detectada distribución basada en Arch Linux"
  local url=$(get_asset_url '\.AppImage$')
  local dest="/usr/local/bin/whatsapp-desktop"
  sudo curl -fsSL "$url" -o "$dest"
  sudo chmod +x "$dest"
  echo "Instalación completada. Ejecuta: whatsapp-desktop"
}

install_appimage() {
  echo "Usando AppImage universal"
  local url=$(get_asset_url '\.AppImage$')
  local dest="./WhatsApp.Desktop.AppImage"
  curl -fsSL "$url" -o "$dest"
  chmod +x "$dest"
  echo "Descargado: $dest"
  echo "Ejecuta: ./WhatsApp.Desktop.AppImage"
}

case "$(detect_distro)" in
  deb) install_deb ;;
  rpm) install_rpm ;;
  arch) install_arch ;;
  *) install_appimage ;;
esac
