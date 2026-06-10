# Maintainer: jh2929
# Arch Linux PKGBUILD for WhatsApp Desktop
# Cliente nativo de WhatsApp Web construido con Rust + Tauri v2

pkgname=whatsapp-desktop
pkgver=1.0.0
pkgrel=1
pkgdesc="Native WhatsApp Web wrapper for Linux - ultralight, native notifications, system tray"
arch=('x86_64')
url="https://github.com/jh2929/whatsapp-desktop-for-linux"
license=('MIT')
depends=(
  'webkit2gtk-4.1'
  'gtk3'
  'librsvg'
  'libayatana-appindicator'
)
makedepends=(
  'rust'
  'cargo'
  'nodejs'
  'npm'
)
source=("$url/archive/v$pkgver.tar.gz")
sha256sums=('SKIP')

prepare() {
  cd "$srcdir/$pkgname-for-linux-$pkgver"
  npm install
}

build() {
  cd "$srcdir/$pkgname-for-linux-$pkgver"
  npm run tauri build -- --bundles none
}

package() {
  cd "$srcdir/$pkgname-for-linux-$pkgver"

  install -Dm755 "src-tauri/target/release/$pkgname" \
    "$pkgdir/usr/local/bin/$pkgname"

  install -Dm644 "src-tauri/icons/icon.png" \
    "$pkgdir/usr/local/share/icons/$pkgname.png"

  install -Dm644 "$pkgname.desktop" \
    "$pkgdir/usr/share/applications/$pkgname.desktop"
}
