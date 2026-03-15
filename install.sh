#!/usr/bin/env bash

# rdp-installer-unoficial
# Auto RDP Installer by aisitheru

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Global variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/rdp-installer.log"
CONFIG_DIR="$HOME/.rdp-installer"
BACKUP_DIR="$HOME/.rdp-installer/backups"
LANG_FILE="$CONFIG_DIR/language.conf"
VERSION="1.0.0"

# Language support
declare -A LANG
load_language() {
    local lang="en"
    if [[ -f "$LANG_FILE" ]]; then
        lang=$(cat "$LANG_FILE")
    fi
    
    if [[ "$lang" == "id" ]]; then
        LANG[menu_title]="PENGINSTAL RDP OTOMATIS"
        LANG[select_menu]="Pilih Menu"
        LANG[install]="Instal RDP"
        LANG[list]="Daftar RDP"
        LANG[back]="Kembali"
        LANG[exit]="Keluar"
        LANG[detecting]="Mendeteksi sistem..."
        LANG[recommend]="Rekomendasi:"
        LANG[light]="Ringan"
        LANG[heavy]="Berat"
        LANG[cancel]="Batal"
        LANG[success]="Berhasil"
        LANG[error]="Error"
        LANG[warning]="Peringatan"
    else
        LANG[menu_title]="AUTO RDP INSTALLER"
        LANG[select_menu]="Select Menu"
        LANG[install]="Install RDP"
        LANG[list]="List RDP"
        LANG[back]="Back"
        LANG[exit]="Exit"
        LANG[detecting]="Detecting system..."
        LANG[recommend]="Recommendation:"
        LANG[light]="Light"
        LANG[heavy]="Heavy"
        LANG[cancel]="Cancel"
        LANG[success]="Success"
        LANG[error]="Error"
        LANG[warning]="Warning"
    fi
}

# Logging function
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    case "$level" in
        "ERROR") echo -e "${RED}[${LANG[error]}] $message${NC}" ;;
        "SUCCESS") echo -e "${GREEN}[${LANG[success]}] $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}[${LANG[warning]}] $message${NC}" ;;
        "INFO") echo -e "${BLUE}[INFO] $message${NC}" ;;
    esac
}

# Error handling
error_exit() {
    log "ERROR" "$1"
    exit 1
}

# Detect init system
detect_init() {
    if [[ -d /run/systemd/system ]]; then
        echo "systemd"
    elif [[ -f /sbin/init ]] && file /sbin/init | grep -q upstart; then
        echo "upstart"
    else
        echo "sysvinit"
    fi
}

# Detect OS and architecture
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
    else
        OS=$(uname -s)
        VER=$(uname -r)
    fi
    
    ARCH=$(uname -m)
    
    log "INFO" "Detected OS: $OS $VER, Architecture: $ARCH"
}

# Get system recommendations
get_recommendation() {
    local total_ram=$(free -m | awk '/^Mem:/{print $2}')
    local cpu_cores=$(nproc)
    local available_disk=$(df -m / | awk 'NR==2 {print $4}')
    
    if [[ $total_ram -lt 1024 ]] || [[ $cpu_cores -lt 2 ]]; then
        echo "light"
    elif [[ $total_ram -lt 2048 ]] || [[ $cpu_cores -lt 4 ]]; then
        echo "medium"
    else
        echo "heavy"
    fi
}

# Show banner
show_banner() {
    clear
    echo -e "${CYAN}==================${NC}"
    echo -e "${GREEN}=      aisitheru      =${NC}"
    echo -e "${YELLOW}=   auto rdp installer  =${NC}"
    echo -e "${CYAN}==================${NC}"
    echo ""
    echo -e "${BLUE}Version: $VERSION${NC}"
    echo ""
}

# Show main menu
show_menu() {
    echo -e "${PURPLE}${LANG[select_menu]} :${NC}"
    echo "1. ${LANG[install]}"
    echo "2. ${LANG[list]}"
    echo ""
    echo "0. ${LANG[back]}"
    echo ""
    echo -n "Select option: "
}

# Install RDP function
install_rdp() {
    log "INFO" "Starting RDP installation"
    
    # Detect system
    echo -e "\n${BLUE}${LANG[detecting]}...${NC}"
    detect_os
    
    local init_system=$(detect_init)
    local recommendation=$(get_recommendation)
    
    echo -e "${GREEN}${LANG[recommend]} ${LANG[$recommendination]}${NC}"
    echo ""
    
    # Show installation options
    echo "Select installation type:"
    echo "1) ${LANG[light]} (XFCE4 + xrdp) - Recommended for low-end systems"
    echo "2) Heavy (KDE/ GNOME + xrdp) - For high-end systems"
    echo "3) Custom installation"
    echo "0) ${LANG[cancel]}"
    echo ""
    echo -n "Choice [1-3, 0]: "
    
    read -r install_choice
    
    case $install_choice in
        1) install_light ;;
        2) install_heavy ;;
        3) install_custom ;;
        0) return ;;
        *) log "ERROR" "Invalid choice"; sleep 2 ;;
    esac
}

# Light installation
install_light() {
    log "INFO" "Starting light installation"
    
    # Check if running in codespace
    if [[ -n "${CODESPACES:-}" ]]; then
        log "INFO" "Running in GitHub Codespace"
        install_codespace
        return
    fi
    
    # Backup current configuration
    backup_config
    
    # Update system
    log "INFO" "Updating package lists"
    if command -v apt &>/dev/null; then
        apt update || log "WARNING" "Failed to update package lists"
        apt install -y xfce4 xfce4-goodies xrdp firefox || log "ERROR" "Failed to install packages"
    elif command -v yum &>/dev/null; then
        yum install -y epel-release
        yum groupinstall -y "Xfce"
        yum install -y xrdp firefox
    elif command -v dnf &>/dev/null; then
        dnf install -y @xfce-desktop
        dnf install -y xrdp firefox
    else
        error_exit "Unsupported package manager"
    fi
    
    # Configure xrdp
    configure_xrdp
    
    # Configure firewall
    configure_firewall
    
    # Enable services
    enable_services
    
    log "SUCCESS" "Light installation completed"
}

# Heavy installation
install_heavy() {
    log "INFO" "Starting heavy installation"
    
    echo "Choose desktop environment:"
    echo "1) GNOME"
    echo "2) KDE Plasma"
    echo -n "Choice [1-2]: "
    
    read -r de_choice
    
    case $de_choice in
        1) install_gnome ;;
        2) install_kde ;;
        *) log "ERROR" "Invalid choice"; return ;;
    esac
}

# Install GNOME
install_gnome() {
    if command -v apt &>/dev/null; then
        apt update
        apt install -y ubuntu-desktop xrdp firefox chromium-browser
    elif command -v dnf &>/dev/null; then
        dnf groupinstall -y "GNOME Desktop"
        dnf install -y xrdp firefox chromium
    fi
    
    configure_xrdp
    configure_firewall
    enable_services
    install_additional_tools
    
    log "SUCCESS" "GNOME installation completed"
}

# Install KDE
install_kde() {
    if command -v apt &>/dev/null; then
        apt update
        apt install -y kde-plasma-desktop xrdp firefox chromium-browser
    elif command -v dnf &>/dev/null; then
        dnf groupinstall -y "KDE Plasma Workspaces"
        dnf install -y xrdp firefox chromium
    fi
    
    configure_xrdp
    configure_firewall
    enable_services
    install_additional_tools
    
    log "SUCCESS" "KDE installation completed"
}

# Custom installation
install_custom() {
    echo "Custom installation options:"
    echo "1) Select desktop environment"
    echo "2) Select additional tools"
    echo "3) Configure RDP settings"
    echo -n "Choice: "
    
    read -r custom_choice
    # Custom installation logic here
}

# Codespace installation
install_codespace() {
    log "INFO" "Configuring for GitHub Codespace"
    
    # Install light desktop environment
    sudo apt update
    sudo apt install -y xfce4 xfce4-goodies tightvncserver
    
    # Setup VNC server
    mkdir -p ~/.vnc
    echo "123456" | vncpasswd -f > ~/.vnc/passwd
    chmod 600 ~/.vnc/passwd
    
    # Create VNC startup script
    cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
startxfce4 &
EOF
    chmod +x ~/.vnc/xstartup
    
    log "SUCCESS" "Codespace configuration completed"
    echo "Start VNC server with: vncserver -localhost no :1"
}

# Configure xrdp
configure_xrdp() {
    log "INFO" "Configuring xrdp"
    
    # Backup original config
    if [[ -f /etc/xrdp/xrdp.ini ]]; then
        cp /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.backup
    fi
    
    # Basic xrdp configuration
    cat > /etc/xrdp/xrdp.ini << 'EOF'
[Globals]
ini_version=1
port=3389
security_layer=negotiate
crypt_level=high
certificate=
key_file=
ssl_protocols=TLSv1.2, TLSv1.3

[Xorg]
name=Xorg
lib=libxup.so
username=ask
password=ask
ip=127.0.0.1
port=-1
code=20
EOF
    
    log "SUCCESS" "xrdp configured"
}

# Configure firewall
configure_firewall() {
    log "INFO" "Configuring firewall"
    
    local init_system=$(detect_init)
    
    if command -v ufw &>/dev/null; then
        ufw allow 3389/tcp
        ufw reload
        log "SUCCESS" "UFW configured"
    elif command -v firewall-cmd &>/dev/null; then
        firewall-cmd --permanent --add-port=3389/tcp
        firewall-cmd --reload
        log "SUCCESS" "FirewallD configured"
    elif [[ -f /etc/iptables/rules.v4 ]]; then
        iptables -A INPUT -p tcp --dport 3389 -j ACCEPT
        iptables-save > /etc/iptables/rules.v4
        log "SUCCESS" "iptables configured"
    else
        log "WARNING" "No supported firewall found"
    fi
}

# Enable services
enable_services() {
    log "INFO" "Enabling services"
    
    local init_system=$(detect_init)
    
    case $init_system in
        "systemd")
            systemctl enable xrdp
            systemctl start xrdp
            ;;
        "upstart")
            service xrdp start
            ;;
        "sysvinit")
            update-rc.d xrdp defaults
            service xrdp start
            ;;
    esac
    
    log "SUCCESS" "Services enabled"
}

# Backup configuration
backup_config() {
    log "INFO" "Creating backup"
    
    mkdir -p "$BACKUP_DIR"
    local backup_file="$BACKUP_DIR/backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    
    if [[ -d /etc/xrdp ]]; then
        tar -czf "$backup_file" /etc/xrdp 2>/dev/null || log "WARNING" "Backup failed"
    fi
    
    log "SUCCESS" "Backup created: $backup_file"
}

# Restore configuration
restore_config() {
    log "INFO" "Restoring from backup"
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        log "ERROR" "No backups found"
        return
    fi
    
    echo "Available backups:"
    ls -1 "$BACKUP_DIR"
    echo ""
    echo -n "Enter backup filename: "
    
    read -r backup_file
    
    if [[ -f "$BACKUP_DIR/$backup_file" ]]; then
        tar -xzf "$BACKUP_DIR/$backup_file" -C /
        log "SUCCESS" "Backup restored"
    else
        log "ERROR" "Backup not found"
    fi
}

# Install additional tools
install_additional_tools() {
    log "INFO" "Installing additional tools"
    
    local tools=(
        "htop"
        "neofetch"
        "git"
        "curl"
        "wget"
        "vim"
        "nano"
        "net-tools"
    )
    
    if command -v apt &>/dev/null; then
        apt install -y "${tools[@]}"
    elif command -v yum &>/dev/null; then
        yum install -y "${tools[@]}"
    elif command -v dnf &>/dev/null; then
        dnf install -y "${tools[@]}"
    fi
    
    # Install Docker if requested
    echo -n "Install Docker? (y/n): "
    read -r install_docker
    
    if [[ "$install_docker" =~ ^[Yy]$ ]]; then
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        rm get-docker.sh
        log "SUCCESS" "Docker installed"
    fi
    
    log "SUCCESS" "Additional tools installed"
}

# List RDP connections
list_rdp() {
    log "INFO" "Listing RDP connections"
    
    echo -e "\n${CYAN}RDP Connections:${NC}"
    echo "=================="
    
    if command -v netstat &>/dev/null; then
        netstat -tlnp 2>/dev/null | grep :3389 && echo -e "${GREEN}RDP service is running on port 3389${NC}" || echo -e "${RED}RDP service is not running${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}Connection info:${NC}"
    echo "IP Address: $(curl -s ifconfig.me || hostname -I | awk '{print $1}')"
    echo "Port: 3389"
    echo "Username: $USER"
    echo ""
    
    # Performance monitoring
    echo -e "${PURPLE}System Performance:${NC}"
    echo "CPU Load: $(uptime | awk -F'load average:' '{print $2}')"
    echo "Memory Usage: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    echo "Disk Usage: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')"
    
    log "SUCCESS" "RDP listing completed"
}

# Uninstall RDP
uninstall_rdp() {
    log "INFO" "Starting uninstallation"
    
    echo -e "${RED}Warning: This will remove all RDP related packages${NC}"
    echo -n "Are you sure? (y/N): "
    
    read -r confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        return
    fi
    
    # Stop services
    local init_system=$(detect_init)
    case $init_system in
        "systemd")
            systemctl stop xrdp
            systemctl disable xrdp
            ;;
        *)
            service xrdp stop
            ;;
    esac
    
    # Remove packages based on package manager
    if command -v apt &>/dev/null; then
        apt remove --purge -y xrdp xfce4 xfce4-goodies
    elif command -v yum &>/dev/null; then
        yum remove -y xrdp xfce4
    fi
    
    # Remove configuration
    rm -rf /etc/xrdp
    
    log "SUCCESS" "Uninstallation completed"
}

# Check for updates
check_updates() {
    log "INFO" "Checking for updates"
    
    local remote_version=$(curl -s https://raw.githubusercontent.com/aisitheru/rdp-installer-unoficial/main/version.txt 2>/dev/null || echo "$VERSION")
    
    if [[ "$remote_version" != "$VERSION" ]]; then
        echo -e "${YELLOW}Update available: $remote_version${NC}"
        echo -n "Update now? (y/n): "
        
        read -r update_choice
        if [[ "$update_choice" =~ ^[Yy]$ ]]; then
            curl -fsSL https://raw.githubusercontent.com/aisitheru/rdp-installer-unoficial/main/install.sh -o /tmp/install.sh
            chmod +x /tmp/install.sh
            exec /tmp/install.sh
        fi
    else
        log "SUCCESS" "You have the latest version"
    fi
}

# Network configuration
configure_network() {
    log "INFO" "Configuring network"
    
    echo "Network Configuration:"
    echo "1) Show network interfaces"
    echo "2) Show IP addresses"
    echo "3) Test RDP port"
    echo "4) Configure port forwarding (requires sudo)"
    echo -n "Choice: "
    
    read -r net_choice
    
    case $net_choice in
        1) ip link show ;;
        2) ip addr show ;;
        3) nc -zv localhost 3389 2>&1 && echo "Port 3389 is open" || echo "Port 3389 is closed" ;;
        4) 
            echo -n "Enter port to forward (e.g., 3390:3389): "
            read -r port_forward
            iptables -t nat -A PREROUTING -p tcp --dport ${port_forward%:*} -j REDIRECT --to-port ${port_forward#*:}
            ;;
        *) log "ERROR" "Invalid choice" ;;
    esac
}

# Change language
change_language() {
    echo "Select language / Pilih bahasa:"
    echo "1) English"
    echo "2) Indonesian / Bahasa Indonesia"
    echo -n "Choice: "
    
    read -r lang_choice
    
    case $lang_choice in
        1) echo "en" > "$LANG_FILE" ;;
        2) echo "id" > "$LANG_FILE" ;;
        *) log "ERROR" "Invalid choice"; return ;;
    esac
    
    log "SUCCESS" "Language changed"
    exec "$0"
}

# Main menu loop
main() {
    # Create config directory
    mkdir -p "$CONFIG_DIR"
    
    # Load language
    load_language
    
    # Check for updates in background
    (check_updates &>/dev/null) &
    
    while true; do
        show_banner
        show_menu
        read -r choice
        
        case $choice in
            1) install_rdp ;;
            2) list_rdp ;;
            0) 
                echo -e "\n${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *) 
                log "ERROR" "Invalid option"
                sleep 2
                ;;
        esac
        
        echo ""
        echo -n "Press Enter to continue..."
        read -r
    done
}

# Run main function
main "$@"
