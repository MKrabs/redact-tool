# ===== PROFILE MODULE =====

CONFIG_DIR="$HOME/.config/redact"
PROFILES_DIR="$CONFIG_DIR/profiles"
GLOBAL_CONFIG="$CONFIG_DIR/global.ini"

profile_path() { echo "$PROFILES_DIR/$1"; }

profile_exists() { [[ -d "$PROFILES_DIR/$1" ]]; }

is_disabled() { [[ "$1" == *.disabled ]]; }

get_global_profile() {
    grep active_profile "$GLOBAL_CONFIG" | cut -d= -f2
}

set_global_profile() {
    local p="$1"
    echo "active_profile=$p" > "$GLOBAL_CONFIG"
    info "Global profile set: $p"
}

init_system() {
    mkdir -p "$PROFILES_DIR"

    [[ -f "$GLOBAL_CONFIG" ]] || echo "active_profile=default" > "$GLOBAL_CONFIG"

    if [[ ! -d "$PROFILES_DIR/default" ]]; then
        mkdir "$PROFILES_DIR/default"

        cat <<EOF > "$PROFILES_DIR/default/config.ini"
output_mode=auto
custom_output_name=
additional_replacement_files=
color=true
EOF

        cat <<EOF > "$PROFILES_DIR/default/replacements.txt"
companyA = company1
secret_project = proj1
EOF
    fi
}

list_profiles() {
    info "Profiles:"
    for p in "$PROFILES_DIR"/*; do
        [[ -d "$p" ]] || continue
        base=$(basename "$p")
        if is_disabled "$base"; then
            echo "  $base (disabled)"
        else
            echo "  $base"
        fi
    done
}

profile_new() {
    local p="$1"
    if profile_exists "$p"; then err "Profile exists."; return 1; fi

    mkdir "$PROFILES_DIR/$p"

    cat <<EOF > "$PROFILES_DIR/$p/config.ini"
output_mode=auto
custom_output_name=
additional_replacement_files=
color=true
EOF

    echo "# value = replacement" > "$PROFILES_DIR/$p/replacements.txt"

    info "Created profile: $p"
}

profile_disable() {
    local p="$1"
    mv "$PROFILES_DIR/$p" "$PROFILES_DIR/$p.disabled"
    info "Disabled profile: $p"
}

profile_enable() {
    local p="$1"
    mv "$PROFILES_DIR/$p" "${PROFILES_DIR}/${p%.disabled}"
    info "Enabled profile: ${p%.disabled}"
}

profile_delete() {
    local p="$1"
    rm -rf "$PROFILES_DIR/$p"
    info "Deleted profile: $p"
}

edit_replacements() {
    local profile="$1"
    local editor="$2"

    [[ -n "$editor" ]] || editor="${EDITOR:-nano}"

    "$editor" "$PROFILES_DIR/$profile/replacements.txt"
}

load_profile_config() {
    local profile="$1"
    local config_file="$PROFILES_DIR/$profile/config.ini"

    declare -gA CONFIG

    if [[ ! -f "$config_file" ]]; then
        err "Config file not found: $config_file"
        return 1
    fi

    while IFS='=' read -r key value; do
        # Skip empty lines and comments
        [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]] && continue
        # Trim whitespace
        key="${key#"${key%%[![:space:]]*}"}"
        key="${key%"${key##*[![:space:]]}"}"
        value="${value#"${value%%[![:space:]]*}"}"
        value="${value%"${value##*[![:space:]]}"}"
        CONFIG["$key"]="$value"
    done < "$config_file"
}

