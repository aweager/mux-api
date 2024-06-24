() {
    functions[mux-validate-set-var]="$(
        __mux-build-validator \
            --scope \
            --location \
            varname value
    )"

    function mux-exec-set-var() {
        private varname="$MuxArgs[varname]"

        local -A MuxValues
        MuxValues[$varname]="$MuxArgs[value]"

        local -A MuxFifos
        {
            __mux-write-values

            MuxArgs[namespace]="user"
            mux-impl-update-vars
        } always {
            __mux-cleanup-fifos
        }
    }

    local varname_only="$(
        __mux-build-validator \
            --scope \
            --location \
            varname
    )"

    functions[mux-validate-get-var]="$varname_only"
    function mux-exec-get-var() {
        private varname="$MuxArgs[varname]"

        local -A MuxFifos
        {
            __mux-make-fifos "$varname"

            MuxArgs[namespace]="user"
            mux-impl-get-vars &!

            (< "$MuxFifos[$varname]")
        } always {
            __mux-cleanup-fifos
        }
    }

    functions[mux-validate-show-var]="$varname_only"
    function mux-exec-show-var() {
        echo "$(mux-exec-get-var)"
    }

    functions[mux-validate-delete-var]="$varname_only"
    function mux-exec-delete-var() {
        local mux_varnames=("$varname")
        MuxArgs[namespace]="user"
        mux-impl-delete-vars
    }

    function __mux-validate-varname() {
        MuxArgs[varname]="$1"
        if ! __mux-check-alphanumeric "$1"; then
            echo "Variable name must be alphanumeric but was: '$1'" >&2
            return 1
        fi
    }
}
