#!/data/data/com.termux/files/usr/bin/bash

# Repository configuration
REPOS=(
    "fdroid|https://f-droid.org/repo"
    "izzy|https://apt.izzysoft.de/fdroid/repo"
    "openapk|https://dl.openapk.org/repo"
)

# Update repository databases
repo_update() {
    info "Synchronizing repository databases..."
    
    for repo in "${REPOS[@]}"; do
        IFS='|' read -r name url <<< "${repo}"
        local repo_file="${DB_DIR}/sync/${name}.db"
        
        info "Updating ${name} repository..."
        
        if command -v wget >/dev/null; then
            wget -q "${url}/index-v1.jar" -O "${repo_file}.tmp" || {
                warning "Failed to update ${name} repository"
                continue
            }
        else
            curl -sL "${url}/index-v1.jar" -o "${repo_file}.tmp" || {
                warning "Failed to update ${name} repository"
                continue
            }
        fi
        
        mv "${repo_file}.tmp" "${repo_file}"
        success "${name} repository updated successfully"
    done
}

# Search all repositories
repo_search() {
    local query="$1"
    local results=()
    
    for repo in "${REPOS[@]}"; do
        IFS='|' read -r name url <<< "${repo}"
        local repo_file="${DB_DIR}/sync/${name}.db"
        
        if [ ! -f "${repo_file}" ]; then
            warning "${name} database not found. Run 'kaito -Sy' first."
            continue
        fi
        
        # Extract package information (simplified example)
        while read -r pkg; do
            if [[ "${pkg}" =~ ${query} ]]; then
                results+=("${pkg}")
            fi
        done < <(unzip -p "${repo_file}" "index-v1.json" | jq -r '.packages[].name')
    done
    
    printf "%s\n" "${results[@]}" | sort -u
}