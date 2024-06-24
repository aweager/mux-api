function __mux-parse-and-call-set-register() {
    eval "$(
        __mux-build-validator \
            regname value
    )"

    "${cmd_prefix}${cmd_name}"
}

function __mux-parse-and-call-regname-only() {
    eval "$(
        __mux-build-validator \
            regname
    )"

    "${cmd_prefix}${cmd_name}"
}

function __mux-validate-regname() {
    regname="$1"
    if [[ "$regname" == "unnamed" ]]; then
        return 0
    fi

    if [[ ${#regname} -ne 1 || "$regname" =~ [^a-z] ]]; then
        echo "Register name must be [a-z] or \"unnamed\" but was \"$regname\"" >&2
        return 1
    fi
}
