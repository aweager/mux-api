() {
    functions[mux-validate-register-child-mux]="$(
        __mux-build-validator \
            -b \
            --location \
            muxcmd
    )"
    function mux-exec-register-child-mux() {
        MuxArgs[scope]="buffer"
        MuxArgs[namespace]="system"
        MuxValues[child_mux]="$MuxArgs[muxcmd]"

        {
            __mux-write-values
            mux-impl-update-vars
        } always {
            __mux-cleanup-fifos
        }
    }

    local location="$(
        __mux-build-validator \
            -b \
            --location
    )"

    functions[mux-validate-unregister-child-mux]="$location"
    function mux-exec-unregister-child-mux() {
        MuxArgs[scope]="buffer"
        MuxArgs[namespace]="system"
        mux_varnames=("child_mux")

        mux-impl-delete-vars
    }

    functions[mux-validate-get-child-mux]="$location"
    function mux-exec-get-child-mux() {
        MuxArgs[scope]="buffer"
        MuxArgs[namespace]="system"

        {
            __mux-make-fifos "child_mux"
            mux-impl-get-vars &!
            echo "$(< "MuxFifos[child_mux]")"
        } always {
            __mux-cleanup-fifos
        }
    }

    local no_args="$(__mux-build-validator)"

    functions[mux-validate-get-parent-mux]="$no_args"
    function mux-exec-get-parent-mux() {
        MuxArgs[scope]="session"
        MuxArgs[namespace]="system"

        {
            __mux-make-fifos "parent_mux"
            mux-impl-get-vars &!
            echo "$(< "MuxFifos[parent_mux]")"
        } always {
            __mux-cleanup-fifos
        }
    }

    functions[mux-validate-get-mux-cmd]="$no_args"
    function mux-exec-get-mux-cmd() {
        local REPLY
        mux-impl-get-mux-cmd
        echo "$REPLY"
    }

    function __mux-validate-muxcmd() {
        MuxArgs[muxcmd]="$1"

        if [[ "$1" =~ ";" ]]; then
            echo "Mux commands cannot contain ';'" >&2
            return 1
        fi
    }
}
