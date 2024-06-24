### Tree manipulation ###

typeset -ga mux_parents

function mux-impl-tree() {
    local cmd="$1"
    shift

    case "$cmd" in
        list-parents)
            mux-list-parents "$@"
            ;;
        *)
            printf 'Unknown mux command %s\n' >&2
            return 1
    esac
}

function mux-list-parents() {
    .list-parents
}

function mux-publish() {
    .publish-session-info
}

function .populate-parents() {
    setopt local_options no_err_return
    local get_parent_result="$(.list-parents)"

    if [[ -z "$get_parent_result" ]]; then
        mux_parents=()
        return 1
    fi

    mux_parents=("${(f)get_parent_result}")
}

function .publish-session-info() {
    setopt local_options no_err_return

    .populate-parents

    local null=$'\0'
    local resolve_result="$(.resolve INFO "$MUX_SESSION_ID" "$all_info_keys[@]" 2> /dev/null)"
    resolve_result="${resolve_result%${null}}"
    local -a records=("${(0)resolve_result}")

    printf 'Pulblishing %s\n' "$records[@]" >> ~/tmux-mux.log

    local -A InfoToSet
    local key record
    for key record in "${all_info_keys[@]:^records}"; do
        if [[ $#key -ne $#record ]]; then
            InfoToSet[$key]="${record#* }"
        fi
    done

    local socket buffer
    for socket buffer in "$mux_parents[@]"; do
        printf '%s\n' mux -b -I "$socket" set-info "$buffer" "${(@kv)InfoToSet}" >> ~/tmux-mux.log
        mux -I "$socket" set-info "$buffer" "${(@kv)InfoToSet}"
    done
}
