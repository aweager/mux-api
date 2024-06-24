() {
    local no_args="$(__mux-build-validator)"

    functions[mux-validate-sync-registers-down]="$no_args"
    function mux-exec-sync-registers-down() {
        private parent_mux_cmd="$(mux-impl-get-parent-mux)"
        if [[ -z $parent_mux_cmd ]]; then
            echo "No parent mux" >&2
            return 1
        fi

        private -a parent_regnames
        parent_regnames=($(eval "$parent_mux_cmd list-registers"))

        private regname
        for regname in $parent_regnames; do
            private value="$(eval "$parent_mux_cmd get-register $regname")"
            MuxArgs[regname]="$regname"
            MuxArgs[value]="$value"
            "mux-impl-set-register"
        done

        unset "MuxArgs[value]"

        private -a my_regnames
        my_regnames=($(mux-impl-list-registers))

        for regname in $my_regnames; do
            if ! (($parent_regnames[(Ie)$regname])); then
                MuxArgs[regname]="$regname"
                mux-impl-delete-register
            fi
        done
    }

    functions[mux-validate-sync-registers-up]="$no_args"
    function mux-exec-sync-registers-up() {
        private child_mux_cmd="$(mux-impl-get-child-mux)"
        if [[ -z $child_mux_cmd ]]; then
            echo "No child mux" >&2
            return 1
        fi

        private -a child_regnames
        child_regnames=($(eval "$child_mux_cmd" list-registers))

        private regname
        for regname in $child_regnames; do
            MuxArgs[regname]="$regname"
            MuxArgs[value]="$(eval "$child_mux_cmd get-register $regname")"
            mux-impl-set-register
        done

        unset "MuxArgs[value]"

        private -a my_regnames
        my_regnames=($(mux-impl-list-registers))

        for regname in $my_regnames; do
            if ! (($child_regnames[(Ie)$regname])); then
                MuxArgs[regname]="$regname"
                mux-impl-delete-register
            fi
        done
    }
}
