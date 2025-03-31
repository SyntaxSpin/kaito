#!/data/data/com.termux/files/usr/bin/bash

# Install package
pkg_install() {
    local pkg="$1"
    local installed=false
    
    # Use shared storage path
    local apk_file="${CACHE_DIR}/${pkg}_${pkg_version}.apk"
    
    # Verify storage permissions
    if [ ! -d "${CACHE_DIR}" ]; then
        error "Storage permission denied! Run: termux-setup-storage"
    fi
    
    info "Resolving dependencies for ${pkg}..."
    
    for repo in "${REPOS[@]}"; do
        IFS='|' read -r name url <<< "${repo}"
        local repo_file="${DB_DIR}/sync/${name}.db"
        
        if [ ! -f "${repo_file}" ]; then
            continue
        fi
        
        # Find package in repository (simplified example)
        local pkg_info=$(unzip -p "${repo_file}" "index-v1.json" | jq -r ".packages[] | select(.name == \"${pkg}\")")
        
        if [ -n "${pkg_info}" ]; then
            local pkg_version=$(echo "${pkg_info}" | jq -r '.versionName')
            local apk_url="${url}/$(echo "${pkg_info}" | jq -r '.apkName')"
            local apk_file="${CACHE_DIR}/${pkg}_${pkg_version}.apk"
            
            info "Downloading ${pkg} (${pkg_version}) from ${name}..."
            
            if command -v wget >/dev/null; then
                wget -q "${apk_url}" -O "${apk_file}" || {
                    warning "Failed to download ${pkg}"
                    continue
                }
            else
                curl -sL "${apk_url}" -o "${apk_file}" || {
                    warning "Failed to download ${pkg}"
                    continue
                }
            fi
            
            info "Installing ${pkg}..."
            if ! termux-open "${apk_file}"; then
                warning "Failed to open ${apk_file} with termux-open"
                continue
            fi
            
            # Record installation in local database
            echo "${pkg}|${pkg_version}|${name}|$(date +%Y-%m-%d)" >> "${DB_DIR}/local.db"
            
            success "${pkg} installed successfully"
            installed=true
            break
        fi
    done

  
    
    # Open APK from shared storage
    if ! termux-open "${apk_file}"; then
        error "Failed to trigger package installer. Manual installation required."
    fi
    
    if ! $installed; then
        error "Package ${pkg} not found in any repository"
    fi
}

# Upgrade all packages
pkg_upgrade() {
    repo_update
    info "Checking for upgrades..."
    
    # Implementation would compare installed versions with repo versions
    # This is a simplified placeholder
    warning "Upgrade functionality not yet implemented"
}

# Remove package
pkg_remove() {
    local pkg="$1"
    
    info "Preparing to remove ${pkg}..."
    
    # This would use Android's package manager via termux-api
    if termux-uninstall "${pkg}"; then
        # Remove from local database
        sed -i "/^${pkg}|/d" "${DB_DIR}/local.db"
        success "${pkg} removed successfully"
    else
        error "Failed to remove ${pkg}"
    fi
}

# Search for packages
pkg_search() {
    local query="$1"
    [ -z "$query" ] && error "Please specify a search query"
    
    info "Searching for '${query}'..."
    repo_search "$query"
}

# List installed packages
pkg_list_installed() {
    if [ ! -f "${DB_DIR}/local.db" ]; then
        info "No packages installed via kaito"
        return
    fi
    
    echo -e "${BLUE}Installed packages:${NC}"
    column -t -s "|" "${DB_DIR}/local.db" | awk '{print NR ". " $0}'
}