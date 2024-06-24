() {
    functions[mux-validate-register-child-mux]="$(
        __mux-build-validator \
            -b \
            --location \
            muxcmd
    )"

    function mux-exec-register-child-mux() {
        mix-impl-register-child-mux
    }

    local location="$(
        __mux-build-validator \
            -b \
            --location
    )"

    functions[mux-validate-unregister-child-mux]="$location"
    function mux-exec-unregister-child-mux() {
        mux-impl-unregister-child-mux
    }

    functions[mux-validate-get-child-mux]="$location"
    function mux-exec-get-child-mux() {
        mux-impl-get-child-mux
    }

    local no_args="$(__mux-build-validator)"

    functions[mux-validate-get-parent-mux]="$no_args"
    function mux-exec-get-parent-mux() {
        mux-impl-get-parent-mux
    }

    functions[mux-validate-get-mux-cmd]="$no_args"
    function mux-exec-get-mux-cmd() {
        mux-impl-get-mux-cmd
    }

    function __mux-validate-muxcmd() {
        MuxArgs[muxcmd]="$1"

        if [[ "$1" =~ ";" ]]; then
            echo "Mux commands cannot contain ';'" >&2
            return 1
        fi
    }
}
