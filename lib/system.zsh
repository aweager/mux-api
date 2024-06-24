function @register-child-mux() {
    function build-args-parser() {
        .build-standard-parser \
            -b \
            --location \
            muxcmd
    }

    function impl() {
        MuxArgs[scope]="buffer"
        MuxArgs[namespace]="system"
        MuxValues[child_mux]="$MuxArgs[muxcmd]"

        {
            .write-values
            mux-impl-update-vars
        } always {
            .cleanup-fifos
        }
    }
}

function @unregister-child-mux() {
    function build-args-parser() {
        .build-standard-parser \
            -b \
            --location
    }

    function impl() {
        MuxArgs[scope]="buffer"
        MuxArgs[namespace]="system"
        mux_varnames=("child_mux")

        mux-impl-delete-vars
    }
}

function @redraw-status() {
    function build-args-parser() {
        .build-standard-parser # no args
    }

    function impl() {
        mux-impl-redraw-status
    }
}

function @sync-registers-down() {
    function build-args-parser() {
        .build-standard-parser # no args
    }

    function impl() {
        private parent_mux="$(.get-parent-mux)"

        if [[ -z $parent_mux ]]; then
            echo "No parent mux" >&2
            return 1
        fi

        private -a parent_regnames
        parent_regnames=($(eval "$parent_mux list-registers"))

        {
            .make-fifos "$parent_regnames[@]"
            eval "$parent_mux dump-registers $MuxFifos[*]" &!
            mux-impl-set-registers

            private child_mux="$(.get-child-mux)"
            if [[ -n $child_mux ]]; then
                eval "$child_mux sync-registers-down"
            fi
        } always {
            .cleanup-fifos
        }
    }
}

function @sync-registers-up() {
    function build-args-parser() {
        .build-standard-parser \
            -b \
            --location
    }

    function impl() {
        private child_mux="$(.get-child-mux)"

        if [[ -z $child_mux ]]; then
            echo "No child mux" >&2
            return 1
        fi

        private -a child_regnames
        child_regnames=($(eval "$child_mux list-registers"))

        {
            .make-fifos "$child_regnames[@]"
            eval "$child_mux dump-registers $MuxFifos[*]" &!
            mux-impl-set-registers

            private parent_mux="$(.get-parent-mux)"
            if [[ -n $parent_mux ]]; then
                eval "$parent_mux sync-registers-up"
            fi
        } always {
            .cleanup-fifos
        }
    }
}
