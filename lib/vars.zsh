() {
    functions[mux-validate-set-var]="$(
        __mux-build-validator \
            --scope \
            --location \
            varname value
    )"

    function mux-exec-set-var() {
        mux-impl-set-var
    }

    local varname_only="$(
        __mux-build-validator \
            --scope \
            --location \
            varname
    )"

    functions[mux-validate-get-var]="$varname_only"

    function mux-exec-get-var() {
        mux-impl-get-var
    }

    functions[mux-validate-show-var]="$varname_only"

    function mux-exec-show-var() {
        mux-impl-show-var
    }

    functions[mux-validate-delete-var]="$varname_only"

    function mux-exec-delete-var() {
        mux-impl-delete-var
    }

    function __mux-validate-varname() {
        varname="$1"
        if ! __mux-check-alphanumeric "$varname"; then
            echo "Variable name must be alphanumeric but was: '$varname'" >&2
            return 1
        fi
    }
}
