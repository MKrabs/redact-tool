# ===== UTIL MODULE =====

err() { echo -e "${RED}Error:${RESET} $*" >&2; }
warn() { echo -e "${YELLOW}Warning:${RESET} $*" >&2; }

info() {
    if [[ "${CONFIG[color]}" == "true" ]]; then
        echo -e "${GREEN}$*${RESET}"
    else
        echo "$*"
    fi
}

confirm_overwrite() {
    local file="$1"
    if [[ -f "$file" ]]; then
        echo -ne "${YELLOW}File '$file' exists. Overwrite? [y/N]: ${RESET}"
        read -r ans
        [[ "$ans" =~ ^[Yy]$ ]]
        return $?
    fi
    return 0
}

color_init() {
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    RESET='\033[0m'
}
color_init

log_replacement() {
    local key="$1"
    local file="$2"
    local count
    count=$(grep -o "$key" "$file" 2>/dev/null | wc -l | xargs)
    LOG["$key"]="$count"
}

print_log() {
    echo "Replacement log:"
    for key in "${!LOG[@]}"; do
        printf " %4dx %s\n" "${LOG[$key]}" "$key"
    done
}
