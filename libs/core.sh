#!/data/data/com.termux/files/usr/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Error handling
error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" >&2
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Check dependencies
check_dependencies() {
    local missing=()
    
    # Check for termux-api for installation
    if ! command -v termux-open >/dev/null; then
        missing+=("termux-api")
    fi
    
    # Check for jq for JSON parsing
    if ! command -v jq >/dev/null; then
        missing+=("jq")
    fi
    
    # Check for wget or curl
    if ! command -v wget >/dev/null && ! command -v curl >/dev/null; then
        missing+=("wget or curl")
    fi
    
    if [ ${#missing[@]} -ne 0 ]; then
        error "Missing dependencies: ${missing[*]}. Install them first."
    fi
}

# Initialize directories
init_dirs() {
    mkdir -p "${CONFIG_DIR}" "${CACHE_DIR}" "${DB_DIR}" "${DB_DIR}/sync"
    touch "${LOG_FILE}"
}

# Log actions
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "${LOG_FILE}"
}