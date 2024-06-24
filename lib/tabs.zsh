function __mux-parse-and-call-tab-only() {
    eval "$(
        __mux-build-validator \
            -t \
            --location
    )"

    "${cmd_prefix}${cmd_name}"
}
