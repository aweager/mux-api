### User variables ###

function mux-impl-var() {
    local cmd="$1"
    shift

    case "$cmd" in
        get-var)
            mux-get-var "$@"
            ;;
        resolve-var)
            mux-resolve-var "$@"
            ;;
        set-var)
            mux-set-var "$@"
            ;;
        delete-var)
            mux-delete-var "$@"
            ;;
        has-var)
            mux-has-var "$@"
            ;;
        list-vars)
            mux-list-vars "$@"
            ;;
        *)
            printf 'Unknown mux command %s\n' "$cmd" >&2
            return 1
            ;;
    esac
}

function mux-get-var() {
    local location="$1"
    local varname="$2"

    setopt local_options no_err_return

    local get_result="$(.get USER "$location" "$varname")"
    local get_status="$?"

    setopt err_return

    if [[ $get_status -ne 0 ]]; then
        printf 'Location %s does not exist\n' "$location" >&2
        return $get_status
    fi

    local null=$'\0'
    get_result="${get_result%${null}}"
    if [[ $#get_result == $#varname ]]; then
        printf 'Variable %s does not exist at location %s\n' "$varname" "$location" >&2
        return 1
    fi

    printf '%s' "${get_result#* }"
}

function mux-resolve-var() {
    local location="$1"
    local varname="$2"

    setopt local_options no_err_return

    local resolve_result="$(.resolve USER "$location" "$varname")"
    local resolve_status="$?"

    setopt err_return

    if [[ $resolve_status -ne 0 ]]; then
        printf 'Location %s does not exist\n' "$location" >&2
        return $resolve_status
    fi

    local null=$'\0'
    resolve_result="${resolve_result%${null}}"
    if [[ $#resolve_result == $#varname ]]; then
        printf ''
    else
        printf '%s' "${resolve_result#* }"
    fi
}

function mux-set-var() {
    local location="$1"
    local varname="$2"

    { printf '%s ' "$varname"; cat; printf '\0' } | .set USER "$location"
}

function mux-delete-var() {
    local location="$1"
    local varname="$2"

    printf '%s\0' "$varname" | .set USER "$location"
}

function mux-has-var() {
    .list USER "$1" | grep "^$2\$" > /dev/null
    return $?
}

function mux-list-vars() {
    .list USER "$1" | sort
}
