### Tree manipulation ###

typeset -ga mux_parents

function mux-impl-tree() {
    local cmd="$1"
    shift

    case "$cmd" in
        publish)
            mux-publish "$@"
            ;;
        *)
            printf 'Unknown mux command %s\n' "$cmd" >&2
            return 1
    esac
}

function mux-publish() {
    setopt local_options no_err_return

    local session_id="$1"
    local parent_socket="$2"
    local parent_location="$3"
    shift 3
    local -a info_keys=("$@")

    local null=$'\0'
    local resolve_result="$(.resolve INFO "$session_id" "$info_keys[@]" 2> /dev/null)"
    resolve_result="${resolve_result%${null}}"
    local -a records=("${(0)resolve_result}")

    local -A InfoToSet
    local key record
    for key record in "${info_keys[@]:^records}"; do
        if [[ $#key -ne $#record ]]; then
            InfoToSet[$key]="${record#* }"
        else
            InfoToSet[$key]=""
        fi
    done

    mux -bb -I "$parent_socket" set-info "$parent_location" "${(@kv)InfoToSet}"
}
