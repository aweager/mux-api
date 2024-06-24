function __mux-parse-and-call-muxcmd-only() {
    eval "$(
        __mux-build-validator \
            muxcmd
    )"

    "${cmd_prefix}${cmd_name}"
}

function __mux-validate-muxcmd() {
    if [[ "$1" =~ ";" ]]; then
        echo "Mux commands cannot contain ';'" >&2
        return 1
    fi
}
