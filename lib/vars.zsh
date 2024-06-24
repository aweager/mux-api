function __mux-parse-and-call-set-var() {
    eval "$(
        __mux-build-validator \
            --scope \
            --location \
            varname value
    )"

    "${cmd_prefix}${cmd_name}"
}

function __mux-parse-and-call-varname-only() {
    eval "$(
        __mux-build-validator \
            --scope \
            --location \
            varname
    )"

    "${cmd_prefix}${cmd_name}"
}

function __mux-validate-varname() {
    varname="$1"
    if ! __mux-check-alphanumeric "$1"; then
        echo "Variable name must be alphanumeric but was: '$varname'" >&2
        return 1
    fi
}
