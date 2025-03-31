#!/data/data/com.termux/files/usr/bin/bash

# Create cache directory in shared storage
mkdir -p "/sdcard/Download/kaito-cache"
ln -s "/sdcard/Download/kaito-cache" "$HOME/.kaito/cache"

# Create database directory
mkdir -p "$HOME/.kaito/db"

# Kaito installation script
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Installation paths
PREFIX="/data/data/com.termux/files/usr"
BIN_DIR="${PREFIX}/bin"
ETC_DIR="${PREFIX}/etc/kaito"
LIB_DIR="${PREFIX}/lib/kaito"
VAR_DIR="${PREFIX}/var/lib/kaito"
CACHE_DIR="${PREFIX}/var/cache/kaito"

# Check if script is being run as root
if [ "$(id -u)" -eq 0 ]; then
    echo -e "${RED}Error: Do not run as root!${NC}"
    exit 1
fi

# Check dependencies
check_deps() {
    local missing=()
    for dep in git wget jq termux-api; do
        if ! command -v "${dep}" >/dev/null 2>&1; then
            missing+=("${dep}")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${YELLOW}Installing missing dependencies...${NC}"
        pkg update -y
        pkg install -y "${missing[@]}"
    fi
}

# Main installation
install_kaito() {
    echo -e "${GREEN}Starting Kaito installation...${NC}"
    
    # Create directories
    echo -e "${YELLOW}Creating directories...${NC}"
    mkdir -p "${ETC_DIR}" "${LIB_DIR}" "${VAR_DIR}/sync" "${CACHE_DIR}"
    
    # Copy files
    echo -e "${YELLOW}Copying files...${NC}"
    cp kaito "${BIN_DIR}/kaito"
    cp lib/*.sh "${LIB_DIR}/"
    cp config/repos.conf "${ETC_DIR}/"
    
    # Set permissions
    echo -e "${YELLOW}Setting permissions...${NC}"
    chmod 755 "${BIN_DIR}/kaito"
    chmod 644 "${LIB_DIR}"/*.sh
    chmod 644 "${ETC_DIR}/repos.conf"
    
    # Initialize database
    echo -e "${YELLOW}Initializing database...${NC}"
    touch "${VAR_DIR}/local.db"
    chmod 644 "${VAR_DIR}/local.db"
    
    # Symlink config
    ln -sf "${ETC_DIR}" "${PREFIX}/etc/kaito"
}

# Post-install message
post_install() {
    echo -e "${GREEN}Installation completed successfully!${NC}"
    echo -e "\nFirst-time setup:"
    echo -e "1. Run: ${YELLOW}termux-setup-storage${NC}"
    echo -e "2. Run: ${YELLOW}kaito -Sy${NC} to update repositories"
    echo -e "\nUsage examples:"
    echo -e "  kaito -S package_name    # Install package"
    echo -e "  kaito -R package_name    # Remove package"
    echo -e "  kaito -Ss search_term   # Search packages\n"
}

# Main flow
main() {
    check_deps
    install_kaito
    post_install
}

# Run installation
main