#!/data/data/com.termux/files/usr/bin/bash

# Utility functions for Kaito

# Check if package is installed
pkg_installed() {
    grep -q "^$1|" "${DB_DIR}/local.db"
}

# Clean cache
clean_cache() {
    info "Cleaning package cache..."
    rm -f "${CACHE_DIR}"/*.apk
    success "Cache cleaned successfully"
}

# Show package files (requires termux-api)
pkg_files() {
    local pkg="$1"
    if ! termux-package-list | grep -q "${pkg}"; then
        error "Package ${pkg} not found"
    fi
    
    echo -e "${BLUE}Files for ${pkg}:${NC}"
    termux-package-files "${pkg}"
}

# Confirm action
confirm() {
    echo -ne "${YELLOW}$1 [y/N] ${NC}"
    read -r response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Progress spinner
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}
check_storage() {
    if [ ! -d "/sdcard/Download" ]; then
        error "Storage access required! Run: termux-setup-storage"
    fi
}