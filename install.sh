#!/data/data/com.termux/files/usr/bin/bash

# Kaito Package Manager Installer
# Version: 1.1.0
# License: MIT

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Installation paths
PREFIX="/data/data/com.termux/files/usr"
BIN_DIR="$PREFIX/bin"
ETC_DIR="$PREFIX/etc/kaito"
LIB_DIR="$PREFIX/lib/kaito"
VAR_DIR="$PREFIX/var/lib/kaito"
CACHE_SOURCE="/sdcard/Download/kaito-cache"

# Verify critical files exist
verify_files() {
    local missing=0
    declare -a required_files=(
        "$SCRIPT_DIR/kaito"
        "$SCRIPT_DIR/lib/core.sh"
        "$SCRIPT_DIR/lib/repos.sh"
        "$SCRIPT_DIR/lib/pkg.sh"
        "$SCRIPT_DIR/lib/utils.sh"
        "$SCRIPT_DIR/config/repos.conf"
    )

    echo -e "${BLUE}Verifying installation files...${NC}"
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            echo -e "${RED}Missing: ${file/$SCRIPT_DIR\//}${NC}"
            missing=$((missing+1))
        fi
    done

    if [ $missing -gt 0 ]; then
        echo -e "${RED}Error: $missing files missing. Please check repository integrity.${NC}"
        exit 1
    fi
}

# Create directory structure
create_dirs() {
    echo -e "${BLUE}Creating directories...${NC}"
    mkdir -p "$ETC_DIR" "$LIB_DIR" "$VAR_DIR/sync" || {
        echo -e "${RED}Failed to create directories!${NC}"
        exit 1
    }
    
    # Create cache directory with user confirmation
    if [ ! -d "$CACHE_SOURCE" ]; then
        echo -e "${YELLOW}Create cache directory at $CACHE_SOURCE? [Y/n]${NC}"
        read -r answer
        if [[ "$answer" =~ ^[Yy]?$ ]]; then
            mkdir -p "$CACHE_SOURCE" || {
                echo -e "${RED}Failed to create cache directory!${NC}"
                exit 1
            }
        fi
    fi
}

# Install main files
install_files() {
    echo -e "${BLUE}Installing files...${NC}"
    
    # Main executable
    install -Dm755 "$SCRIPT_DIR/kaito" "$BIN_DIR/kaito" || {
        echo -e "${RED}Failed to install main executable!${NC}"
        exit 1
    }
    
    # Library files
    install -Dm644 "$SCRIPT_DIR"/lib/*.sh -t "$LIB_DIR" || {
        echo -e "${RED}Failed to install library files!${NC}"
        exit 1
    }
    
    # Configuration
    install -Dm644 "$SCRIPT_DIR/config/repos.conf" "$ETC_DIR/repos.conf" || {
        echo -e "${RED}Failed to install configuration!${NC}"
        exit 1
    }
    
    # Create cache symlink
    ln -sf "$CACHE_SOURCE" "$PREFIX/var/cache/kaito" 2>/dev/null || true
}

# Post-install setup
post_install() {
    echo -e "\n${GREEN}Installation complete!${NC}"
    echo -e "${YELLOW}First-time setup required:${NC}"
    echo -e "1. Run: ${BLUE}termux-setup-storage${NC}"
    echo -e "2. Run: ${BLUE}kaito -Sy${NC} to update repositories"
    echo -e "\nView documentation: ${BLUE}man kaito${NC}"
}

# Main installation flow
main() {
    verify_files
    create_dirs
    install_files
    post_install
}

# Run main function
main