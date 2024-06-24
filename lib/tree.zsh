function @get-child-mux() {
    function build-args-parser() {
        .build-standard-parser \
            -b \
            --location
    }

    function impl() {
        MuxArgs[scope]="buffer"
        MuxArgs[namespace]="system"

        {
            .make-fifos "child_mux"
            mux-impl-get-vars &!
            echo "$(< "MuxFifos[child_mux]")"
        } always {
            .cleanup-fifos
        }
    }
}

function @get-parent-mux() {
    function build-args-parser() {
        .build-standard-parser # no args
    }

    function impl() {
        MuxArgs[scope]="session"
        MuxArgs[namespace]="system"

        {
            .make-fifos "parent_mux"
            mux-impl-get-vars &!
            echo "$(< "MuxFifos[parent_mux]")"
        } always {
            .cleanup-fifos
        }
    }
}

function @get-mux-cmd() {
    function build-args-parser() {
        .build-standard-parser # no args
    }

    function impl() {
        local REPLY
        mux-impl-get-mux-cmd
        echo "$REPLY"
    }
}

function .parse-muxcmd() {
    MuxArgs[muxcmd]="$1"

    if [[ "$1" =~ ";" ]]; then
        echo "Mux commands cannot contain ';'" >&2
        return 1
    fi
}
