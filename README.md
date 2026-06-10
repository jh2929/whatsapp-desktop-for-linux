# WhatsApp Desktop for Linux

Aplicación nativa de escritorio para WhatsApp Web, construida con **Rust + Tauri v2**.

Ultraligera, rápida y con notificaciones nativas. Sin Electron, sin Chromium empaquetado, sin trackers, sin telemetría. Solo un webview nativo apuntando a `web.whatsapp.com` con un puente de notificaciones.

## Por qué este proyecto

WhatsApp no ofrece un cliente nativo de escritorio para Linux. Las alternativas existentes —ZapZap, Franz, Rambox, el wrapper no oficial de Electron— empaquetan Chromium, consumen cientos de megas de RAM, y en muchos casos añaden telemetría, trackers o capas intermedias que procesan tus datos.

Este proyecto nace con una filosofía clara: **ser un puente, no un intermediario**.

Construido con Rust y Tauri v2, la app no es más que un webview nativo del sistema apuntando a `web.whatsapp.com`. No hay servidores intermedios, no hay cuentas externas, no hay recolección de datos. Tu sesión, tus mensajes y tus contactos van directamente a WhatsApp —exactamente como cuando abres la web en tu navegador, pero en una ventana propia con notificaciones nativas y soporte de bandeja del sistema.

El objetivo es simple: que cualquier usuario de Linux pueda instalar, escanear el código QR y tener WhatsApp funcionando en su escritorio en menos de un minuto, sin tener que lidiar con dependencias de desarrollo, compilaciones desde código ni configuraciones de WebKit.

## Comparativa

| Característica | WhatsApp Desktop (Tauri) | ZapZap / Electron | WhatsApp Web (Chrome) |
|---|---|---|---|
| Tamaño del binario | **~13 MB** | ~120 MB | — |
| RAM en reposo | **~60 MB** | ~200 MB | ~150 MB |
| RAM con uso activo | **~220 MB** | ~400-800 MB | ~400-600 MB |
| Chromium empaquetado | No (usa WebKitGTK del sistema) | Sí | Sí |
| Notificaciones nativas | Sí (notify-send) | Sí | Solo si el navegador está abierto |
| System tray | Sí (minimizar a bandeja) | Sí | No |
| Código abierto | Sí (MIT) | Sí | No |
| Trackers / Telemetría | **Ninguno** | Depende de la implementación | Google + Meta |

## Características

- Nativo de Linux — GTK3/WebKitGTK, sin Electron
- System tray — minimiza a la bandeja al cerrar
- Notificaciones nativas de escritorio via `notify-send`
- Enlaces externos se abren en el navegador predeterminado
- Sin cuentas, sin registro, sin servidores intermedios

## Cómo funciona

```
web.whatsapp.com ──► WebKitGTK (navegador nativo del sistema)
                         │
                    [JS Bridge] ──► intercepta Notification API
                         │               │
                    Tauri IPC            └──► monitoriza document.title
                         │                        para contador de no leídos
                    notify-send
                         │
               Notificación nativa Linux
```

1. Tauri crea una ventana WebKitGTK que carga `https://web.whatsapp.com`
2. Un puente JS se inyecta en la página y reemplaza la API `Notification` del navegador
3. El mismo puente monitorea `document.title` para detectar mensajes no leídos (ej: "(3) WhatsApp")
4. Las notificaciones se envían al sistema via `notify-send`
5. Al cerrar la ventana, la app se minimiza a la bandeja en lugar de cerrarse

## Requisitos del sistema

### Dependencias

**Debian / Ubuntu / Linux Mint:**
```bash
sudo apt install -y \
  libwebkit2gtk-4.1-dev \
  libgtk-3-dev \
  librsvg2-dev \
  libayatana-appindicator3-dev
```

**Fedora / RHEL / AlmaLinux:**
```bash
sudo dnf install -y \
  webkit2gtk4.1-devel \
  gtk3-devel \
  librsvg2-devel \
  libayatana-appindicator-gtk3-devel
```

**Arch / CachyOS / Manjaro:**
```bash
sudo pacman -S \
  webkit2gtk-4.1 \
  gtk3 \
  librsvg \
  libayatana-appindicator
```

### GNOME

Si usas GNOME, instala la extensión AppIndicator para ver el icono en la bandeja:
```bash
sudo dnf install gnome-shell-extension-appindicator   # Fedora
sudo apt install gnome-shell-extension-appindicator    # Ubuntu/Debian
```

## Instalación

### Instalador automático (recomendado para cualquier distro)

Detecta tu distribución, instala dependencias y compila la app automáticamente:

```bash
curl -fsSL https://raw.githubusercontent.com/jh2929/whatsapp-desktop-for-linux/main/install.sh | sudo bash
```

> En sistemas Debian/Ubuntu/Fedora descarga el paquete precompilado. En Arch y derivados compila desde código (~2-3 min).

### Debian / Ubuntu / Linux Mint

```bash
wget https://github.com/jh2929/whatsapp-desktop-for-linux/releases/download/v1.0.0/WhatsApp.Desktop_1.0.0_amd64.deb
sudo dpkg -i WhatsApp.Desktop_1.0.0_amd64.deb
```

### Fedora / RHEL / AlmaLinux

```bash
wget https://github.com/jh2929/whatsapp-desktop-for-linux/releases/download/v1.0.0/WhatsApp.Desktop-1.0.0-1.x86_64.rpm
sudo rpm -i WhatsApp.Desktop-1.0.0-1.x86_64.rpm
```

### Arch / CachyOS / Manjaro

Usa el [instalador automático](#instalador-automático-recomendado-para-cualquier-distro) (compila desde código).  
O sigue las instrucciones de [compilación desde código](#compilar-desde-código).

También hay un [PKGBUILD](./PKGBUILD) disponible para empaquetado manual con `makepkg`.

## Compilar desde código

```bash
# 1. Instalar Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 2. Instalar Node.js
#    (recomendado: https://nodejs.org/ o https://github.com/nvm-sh/nvm)

# 3. Instalar dependencias del sistema (ver más arriba)

# 4. Clonar y compilar
git clone https://github.com/jh2929/whatsapp-desktop-for-linux.git
cd whatsapp-desktop-for-linux
npm install
npm run tauri build
```

Los paquetes compilados estarán en:
```
src-tauri/target/release/bundle/deb/
src-tauri/target/release/bundle/rpm/
```

## Desarrollo

```bash
npm run tauri dev
```

## Estructura del proyecto

```
whatsapp-desktop-for-linux/
├── package.json              # Script npm para Tauri CLI
├── dist/index.html           # Fallback (redirige a web.whatsapp.com)
└── src-tauri/
    ├── Cargo.toml            # Dependencias Rust
    ├── tauri.conf.json       # Config: URL, CSP, ventana, iconos
    ├── capabilities/
    │   └── default.json      # Permisos Tauri
    ├── icons/                # Iconos de la app
    └── src/
        ├── main.rs           # Punto de entrada
        └── lib.rs            # Lógica: tray, notificaciones, JS bridge
```

## Licencia

MIT
