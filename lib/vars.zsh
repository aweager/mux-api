function @set-var() {
    function build-args-parser() {
        .build-standard-parser \
            --scope \
            --location \
            varname value
    }

    function impl() {
        private varname="$MuxArgs[varname]"

        MuxValues[$varname]="$MuxArgs[value]"
        {
            .write-values

            MuxArgs[namespace]="user"
            mux-impl-update-vars
        } always {
            .cleanup-fifos
        }
    }
}

function @get-var() {
    function build-args-parser() {
        .build-standard-parser \
            --scope \
            --location \
            varname
    }

    function impl() {
        private varname="$MuxArgs[varname]"

        {
            .make-fifos "$varname"

            MuxArgs[namespace]="user"
            mux-impl-get-vars &!

            (< "$MuxFifos[$varname]")
        } always {
            .cleanup-fifos
        }
    }
}

function @show-var() {
    function build-args-parser() {
        .build-standard-parser \
            --scope \
            --location \
            varname
    }

    function impl() {
        echo "$(@get-var.impl)"
    }
}

function @delete-var() {
    function build-args-parser() {
        .build-standard-parser \
            --scope \
            --location \
            varname
    }

    function impl() {
        local mux_varnames=("$varname")
        MuxArgs[namespace]="user"
        mux-impl-delete-vars
    }
}

function .parse-varname() {
    MuxArgs[varname]="$1"
    if ! .check-alphanumeric "$1"; then
        echo "Variable name must be alphanumeric but was: '$1'" >&2
        return 1
    fi
}
