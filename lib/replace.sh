# ===== REPLACER MODULE =====

declare -A MAP
declare -A LOG

load_replacements_file() {
    local file="$1"
    [[ -f "$file" ]] || { warn "Missing replacements file: $file"; return; }

    while IFS='=' read -r left right; do
        left=$(echo "$left" | xargs)
        right=$(echo "$right" | xargs)

        [[ -z "$left" || "$left" = \#* ]] && continue

        MAP["$left"]="$right"
    done < "$file"
}

list_replacements() {
    local p="$1"
    local file="$PROFILES_DIR/$p/replacements.txt"
    info "Replacements for profile '$p':"
    sed 's/^/  /' "$file"
}

apply_replacements() {
    local input="$1"
    local output="$2"
    cp "$input" "$output"

    for key in "${!MAP[@]}"; do
        sed -i "s/${key}/${MAP[$key]}/g" "$output"
        log_replacement "$key" "$input"
    done

    info "Redacted → $output"
}
