# RDP Installer Unofficial

Auto RDP Installer by aisitheru

## Features

- 🚀 Multi-platform support (Debian/Ubuntu, CentOS/RHEL, Fedora)
- 🖥️ Multiple desktop environments (XFCE, GNOME, KDE)
- 🔥 Automatic firewall configuration
- 🔒 Security options
- 💾 Backup & restore functionality
- 📊 Performance monitoring
- 🌐 Network configuration
- 🐳 Docker support
- 🔄 Auto-update checking
- 🌍 Multi-language support (English/Indonesian)
- 📝 Comprehensive error handling and logging

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/aisitheru/rdp-installer-unoficial/main/install.sh | bash
```

Or with wget:

```bash
wget -qO- https://raw.githubusercontent.com/aisitheru/rdp-installer-unoficial/main/install.sh | bash
```

Requirements

· Linux-based OS (Ubuntu 18.04+, Debian 10+, CentOS 7+, Fedora 30+)
· Root or sudo access
· Internet connection
· At least 1GB RAM (2GB+ recommended for heavy installations)

Features Details

Installation Types

· Light: XFCE desktop environment (recommended for low-end systems)
· Heavy: GNOME or KDE desktop environment (for high-end systems)
· Custom: Select specific components

Supported Systems

· GitHub Codespaces
· VPS/Dedicated servers
· Local machines
· Docker containers

Security Features

· Firewall configuration (UFW, firewalld, iptables)
· SSL/TLS configuration for xrdp
· User management
· Port forwarding options

Management Tools

· Performance monitoring
· Backup/Restore system
· Uninstall option
· Network diagnostics
· Docker integration

Language Support

Change language with:

```bash
curl -fsSL https://raw.githubusercontent.com/aisitheru/rdp-installer-unoficial/main/install.sh | bash -s -- --lang id
```

Directory Structure

```
~/.rdp-installer/
├── backups/          # Configuration backups
├── logs/            # Installation logs
└── config/          # User configuration
```

Logging

All operations are logged to /tmp/rdp-installer.log

Contributing

Feel free to submit issues and pull requests.

License

MIT License

Author

aisitheru

```

## Cara Upload ke GitHub

```bash
# Inisialisasi repository
git init
git add .
git commit -m "Initial commit: RDP Installer Unofficial v1.0.0"

# Buat repository di GitHub (manual via website)
# Nama repository: rdp-installer-unoficial

# Hubungkan dengan remote
git remote add origin https://github.com/aisitheru/rdp-installer-unoficial.git
git branch -M main
git push -u origin main
```

Fitur yang sudah diimplementasikan:

✅ Multi-platform support (apt, yum, dnf)
✅ System init detection (systemd, upstart, sysvinit)
✅ Firewall configuration (UFW, firewalld, iptables)
✅ Security options
✅ Backup & restore
✅ Multiple desktop environments
✅ Additional tools installation
✅ User management
✅ Performance monitoring
✅ Error handling & logging
✅ Uninstall options
✅ Language support (EN/ID)
✅ Auto update check
✅ Network configuration
✅ Docker support
✅ GitHub Codespace support
✅ Minimal file structure

Cara penggunaan:

```bash
# Langsung dari curl
curl -fsSL https://raw.githubusercontent.com/aisitheru/rdp-installer-unoficial/main/install.sh | bash

# Atau download dulu
wget https://raw.githubusercontent.com/aisitheru/rdp-installer-unoficial/main/install.sh
chmod +x install.sh
./install.sh
```
