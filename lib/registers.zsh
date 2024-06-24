() {
    functions[mux-validate-set-register]="$(
        __mux-build-validator \
            regname value
    )"

    function mux-exec-set-register() {
        mux-impl-set-register
    }

    local regname_only="$(
        __mux-build-validator \
            regname
    )"

    functions[mux-validate-get-register]="$regname_only"
    function mux-exec-get-register() {
        mux-impl-get-register
    }

    functions[mux-validate-show-register]="$regname_only"
    function mux-exec-show-register() {
        mux-impl-show-register
    }

    functions[mux-validate-delete-register]="$regname_only"
    function mux-exec-delete-register() {
        mux-impl-delete-register
    }

    functions[mux-validate-load-register]="$regname_only"
    function mux-exec-load-register() {
        mux-impl-load-register
    }

    functions[mux-validate-list-registers]="$(
        __mux-build-validator
    )"

    function mux-exec-list-registers() {
        mux-impl-list-registers
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
}
