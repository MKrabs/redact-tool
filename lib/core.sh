# ===== CORE MODULE =====

main() {
    init_system

    local INPUT=""
    local OUTPUT=""
    local PROFILE_OVERRIDE=""
    local EDIT_PROFILE=""
    local EDITOR=""
    local LIST_TYPE=""
    local DO_LOG=false

    declare -a EXTRA_FILES=()

    # ----- Parse CLI -----
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help) show_help; exit 0 ;;
            --log) DO_LOG=true ;;
            --output|-o) shift; OUTPUT="$1" ;;
            --add|-a) shift; EXTRA_FILES+=("$1") ;;
            --profile|-p) shift; PROFILE_OVERRIDE="$1" ;;
            --profile-set) shift; set_global_profile "$1"; exit 0 ;;
            --profile-new) shift; profile_new "$1"; exit 0 ;;
            --profile-disable) shift; profile_disable "$1"; exit 0 ;;
            --profile-enable) shift; profile_enable "$1"; exit 0 ;;
            --profile-delete) shift; profile_delete "$1"; exit 0 ;;
            --edit-replacements) shift; EDIT_PROFILE="$1"; EDITOR="$2"; edit_replacements "$EDIT_PROFILE" "$EDITOR"; exit 0 ;;
            --list) shift; LIST_TYPE="$1" ;;
            *) INPUT="$1" ;;
        esac
        shift
    done

    # ---- Handle list ----
    if [[ -n "$LIST_TYPE" ]]; then
        case "$LIST_TYPE" in
            profile|profiles) list_profiles ;;
            replacement|replacements)
                list_replacements "$(get_global_profile)"
                ;;
            *) list_profiles; list_replacements "$(get_global_profile)" ;;
        esac
        exit 0
    fi

    if [[ -z "$INPUT" ]]; then err "No input file."; exit 1; fi

    # ---- Select profile ----
    local PROFILE="${PROFILE_OVERRIDE:-$(get_global_profile)}"
    if is_disabled "$PROFILE"; then err "Profile disabled."; exit 1; fi

    # ---- Load profile config ----
    load_profile_config "$PROFILE"

    # ---- Build output filename ----
    if [[ -z "$OUTPUT" ]]; then
        local mode="${CONFIG[output_mode]}"
        case "$mode" in
            auto)
                base="${INPUT%.*}"
                ext="${INPUT##*.}"
                OUTPUT="${base}_redacted.${ext}"
                ;;
            overwrite) OUTPUT="$INPUT" ;;
            custom) OUTPUT="${CONFIG[custom_output_name]}" ;;
            *) OUTPUT="${INPUT}_redacted" ;;
        esac
    fi

    # ---- Check overwrite ----
    if ! confirm_overwrite "$OUTPUT"; then exit 1; fi

    # ---- Load replacement map ----
    MAP=()
    load_replacements_file "$PROFILES_DIR/$PROFILE/replacements.txt"

    IFS=';' read -ra conf_files <<< "${CONFIG[additional_replacement_files]}"
    for f in "${conf_files[@]}"; do [[ -n "$f" ]] && load_replacements_file "$f"; done

    for f in "${EXTRA_FILES[@]}"; do load_replacements_file "$f"; done

    # ---- Apply ----
    apply_replacements "$INPUT" "$OUTPUT"

    # ---- Log ----
    if [[ "$DO_LOG" == true ]]; then print_log; fi
}

show_help() {
cat <<EOF
Usage:
  redact [options] <file>

Profile Management:
  --profile-set NAME
  --profile-new NAME
  --profile-disable NAME
  --profile-enable NAME
  --profile-delete NAME

Run Options:
  -p, --profile NAME         Use profile for this run
  -o, --output NAME          Output file
  -a, --add FILE             Extra replacement file
  --log                      Print replacement counts
  --edit-replacements [p]    Edit replacements of profile
  --list [profile|replacements]

EOF
}
