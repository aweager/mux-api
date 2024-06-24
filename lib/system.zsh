() {
    local no_args="$(__mux-build-validator)"

    functions[mux-validate-sync-registers-down]="$no_args"
    function mux-exec-sync-registers-down() {
        private parent_mux="$(mux-exec-get-parent-mux)"

        if [[ -z $parent_mux ]]; then
            echo "No parent mux" >&2
            return 1
        fi

        private -a parent_regnames
        parent_regnames=($(eval "$parent_mux list-registers"))

        {
            __mux-make-fifos "$parent_regnames[@]"
            eval "$parent_mux dump-registers $MuxFifos[*]" &!
            mux-impl-set-registers

            private child_mux="$(mux-exec-get-child-mux)"
            if [[ -n $child_mux ]]; then
                eval "$child_mux sync-registers-down"
            fi
        } always {
            __mux-cleanup-fifos
        }
    }

    functions[mux-validate-sync-registers-up]="$no_args"
    function mux-exec-sync-registers-up() {
        private child_mux="$(mux-exec-get-child-mux)"

        if [[ -z $child_mux ]]; then
            echo "No child mux" >&2
            return 1
        fi

        private -a child_regnames
        child_regnames=($(eval "$child_mux list-registers"))

        {
            __mux-make-fifos "$child_regnames[@]"
            eval "$child_mux dump-registers $MuxFifos[*]" &!
            mux-impl-set-registers

            private parent_mux="$(mux-exec-get-parent-mux)"
            if [[ -n $parent_mux ]]; then
                eval "$parent_mux sync-registers-up"
            fi
        } always {
            __mux-cleanup-fifos
        }
    }
}
