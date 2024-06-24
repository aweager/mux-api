() {
    functions[mux-validate-set-register]="$(
        __mux-build-validator \
            regname value
    )"

    function mux-exec-set-register() {
        local -A MuxValues
        MuxValues[$MuxArgs[regname]]="$MuxArgs[value]"

        local -A MuxFifos
        {
            __mux-write-values
            mux-impl-update-registers
        } always {
            __mux-cleanup-fifos
        }
    }

    local regname_only="$(
        __mux-build-validator \
            regname
    )"

    functions[mux-validate-get-register]="$regname_only"
    function mux-exec-get-register() {
        private regname="$MuxArgs[regname]"
        local -A MuxFifos
        {
            __mux-make-fifos "$regname"
            mux-impl-get-registers &!
            (< "$MuxFifos[$regname]")
        } always {
            __mux-cleanup-fifos
        }
    }

    functions[mux-validate-show-register]="$regname_only"
    function mux-exec-show-register() {
        echo "$(mux-exec-get-register)"
    }

    functions[mux-validate-delete-register]="$regname_only"
    function mux-exec-delete-register() {
        local -a mux_regnames
        mux_regnames=($MuxArgs[regname])
        mux-impl-delete-registers
    }

    functions[mux-validate-load-register]="$regname_only"
    function mux-exec-load-register() {
        private regname="$MuxArgs[regname]"
        local -A MuxFifos
        {
            __mux-make-fifos "$regname"
            cat > "$MuxFifos[$regname]" &!
            mux-impl-update-registers
        } always {
            __mux-cleanup-fifos
        }
    }

    functions[mux-validate-list-registers]="$(
        __mux-build-validator
    )"

    function mux-exec-list-registers() {
        local -a reply
        mux-impl-list-registers

        private regname
        for regname in "$reply[@]"; do
            echo "$regname"
        done
    }

    function __mux-validate-regname() {
        MuxArgs[regname]="$1"
        if [[ "$1" == "unnamed" ]]; then
            return 0
        fi

        if [[ ${#1} -ne 1 || "$1" =~ [^a-z] ]]; then
            echo "Register name must be [a-z] or \"unnamed\" but was \"$1\"" >&2
            return 1
        fi
    }
}
