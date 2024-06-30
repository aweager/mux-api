### Info variables ###

typeset -ga all_info_keys=(icon icon_color title title_style)

function mux-impl-info() {
    local cmd="$1"
    shift

    case "$cmd" in
        get-info)
            mux-get-info "$@"
            ;;
        resolve-info)
            mux-resolve-info "$@"
            ;;
        set-info)
            mux-set-info "$@"
            ;;
        merge-info)
            mux-merge-info "$@"
            ;;
        delete-info)
            mux-delete-info "$@"
            ;;
        has-info)
            mux-has-info "$@"
            ;;
        list-info)
            mux-list-info "$@"
            ;;
        *)
            printf 'Unknown mux command %s\n' "$cmd" >&2
            return 1
            ;;
    esac
}

function mux-get-info() {
    local location="$1"
    shift

    setopt local_options no_err_return

    local get_result="$(.get INFO "$location" "$@")"
    local get_status="$?"

    setopt err_return

    if [[ $get_status -ne 0 ]]; then
        printf 'Location %s does not exist\n' "$location" >&2
        return $get_status
    fi

    local null=$'\0'
    get_result="${get_result%${null}}"
    printf '%s\n' "${(0)get_result}"
}

function mux-resolve-info() {
    local location="$1"
    shift

    setopt local_options no_err_return

    local resolve_result="$(.resolve INFO "$location" "$@")"
    local resolve_status="$?"

    setopt err_return

    if [[ $resolve_status -ne 0 ]]; then
        printf 'Location %s does not exist\n' "$location" >&2
        return $resolve_status
    fi

    local null=$'\0'
    resolve_result="${resolve_result%${null}}"
    printf '%s\n' "${(0)resolve_result}"
}

function mux-set-info() {
    setopt local_options no_err_return

    local location="$1"
    shift

    local -A InfoToSet
    InfoToSet=("$@")
    local -a keys_to_set=("${(@k)InfoToSet}")
    local -a keys_to_delete=("${all_info_keys[@]:|keys_to_set}")

    local key
    local -a records
    for key in "$keys_to_set[@]"; do
        records+=("${key} $InfoToSet[$key]")
    done
    for key in "$keys_to_delete[@]"; do
        records+=("${key}")
    done

    printf '%s\0' "${(pj:\0:)records}" | .set INFO "$location"
}

function mux-merge-info() {
    setopt local_options err_return

    local location="$1"
    shift

    local -A InfoToSet
    InfoToSet=("$@")
    local -a keys_to_set=("${(@k)InfoToSet}")

    local key
    local -a records
    for key in "$keys_to_set[@]"; do
        records+=("${key} $InfoToSet[$key]")
    done

    printf '%s\0' "${(pj:\0:)records}" | .set INFO "$location"
}

function mux-delete-info() {
    local location="$1"
    shift

    printf '%s\0' "${(pj:\0:)argv}" | .set INFO "$location"
}

function mux-has-info() {
    .list INFO "$1" | grep "^$2\$" > /dev/null
    return $?
}

function mux-list-info() {
    .list INFO "$1" | sort
}
