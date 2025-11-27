_redact_complete() {
    local cur prev opts profiles
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    opts="--help --output --add --profile --log \
          --profile-set --profile-new --profile-disable --profile-enable --profile-delete \
          --list --edit-replacements"

    profiles=$(ls ~/.config/redact/profiles 2>/dev/null | sed 's/\.disabled$//')

    case "$prev" in
        --profile|--profile-set|--profile-new|--profile-disable|--profile-enable|--profile-delete)
            COMPREPLY=( $(compgen -W "${profiles}" -- "$cur") )
            return 0
            ;;
        --list)
            COMPREPLY=( $(compgen -W "profile profiles replacements replacement all" -- "$cur") )
            return 0
            ;;
    esac

    COMPREPLY=( $(compgen -W "$opts $profiles" -- "$cur") )
}

complete -F _redact_complete redact
