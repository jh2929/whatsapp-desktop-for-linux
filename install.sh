#!/usr/bin/env bash
set -euo pipefail

REPO="jh2929/whatsapp-desktop-for-linux"
BASE="https://github.com/$REPO/releases/download"
TAG="v1.0.0"

DEB="WhatsApp.Desktop_1.0.0_amd64.deb"
RPM="WhatsApp.Desktop-1.0.0-1.x86_64.rpm"
APPIMAGE="WhatsApp.Desktop_1.0.0_amd64.AppImage"

detect_distro() {
  if command -v apt &>/dev/null; then echo "deb"
  elif command -v dnf &>/dev/null; then echo "rpm"
  elif command -v rpm &>/dev/null; then echo "rpm"
  elif command -v pacman &>/dev/null; then echo "arch"
  else echo "appimage"
  fi
}

install_deb() {
  echo "Detectada distribución basada en Debian/Ubuntu"
  local url="$BASE/$TAG/$DEB"
  local tmp=$(mktemp --suffix=.deb)
  curl -fsSL "$url" -o "$tmp"
  sudo dpkg -i "$tmp"
  rm -f "$tmp"
  echo "Instalación completada."
}

install_rpm() {
  echo "Detectada distribución basada en Fedora/RHEL"
  local url="$BASE/$TAG/$RPM"
  local tmp=$(mktemp --suffix=.rpm)
  curl -fsSL "$url" -o "$tmp"
  sudo rpm -i "$tmp"
  rm -f "$tmp"
  echo "Instalación completada."
}

install_arch() {
  echo "Detectada distribución basada en Arch Linux"
  echo "Descargando AppImage..."
  local url="$BASE/$TAG/$APPIMAGE"
  local dest="/usr/local/bin/whatsapp-desktop"
  sudo curl -fsSL "$url" -o "$dest"
  sudo chmod +x "$dest"
  echo "Instalación completada."
  echo "Ejecuta: whatsapp-desktop"
}

install_appimage() {
  echo "Usando AppImage universal"
  local url="$BASE/$TAG/$APPIMAGE"
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
