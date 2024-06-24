function __mux-parse-and-call-system() {
    if [[ $# -ne 0 ]]; then
        echo "mux system calls have no args" >&2
        return 1
    fi

    "__mux-system-${cmd_name}"
}

function __mux-system-sync-registers-down() {
    local parent_mux_cmd="$("${cmd_prefix}get-parent-mux")"
    if [[ -z $parent_mux_cmd ]]; then
        echo "No parent mux" >&2
        return 1
    fi

    local -a parent_regnames
    parent_regnames=($(eval "$parent_mux_cmd" list-registers))

    for regname in $parent_regnames; do
        local value="$(eval "$parent_mux_cmd" get-register $regname)"
        "${cmd_prefix}set-register"
    done

    local -a my_regnames
    my_regnames=($("${cmd_prefix}list-registers"))

    for regname in $my_regnames; do
        if ! (($parent_regnames[(Ie)$regname])); then
            "${cmd_prefix}delete-register"
        fi
    done
}

function __mux-system-sync-registers-up() {
    local child_mux_cmd="$("${cmd_prefix}get-child-mux")"
    if [[ -z $child_mux_cmd ]]; then
        echo "No child mux" >&2
        return 1
    fi

    local -a child_regnames
    child_regnames=($(eval "$child_mux_cmd" list-registers))

    for regname in $child_regnames; do
        local value="$(eval "$child_mux_cmd" get-register $regname)"
        "${cmd_prefix}set-register"
    done

    local -a my_regnames
    my_regnames=($("${cmd_prefix}list-registers"))

    for regname in $my_regnames; do
        if ! (($child_regnames[(Ie)$regname])); then
            "${cmd_prefix}delete-register"
        fi
    done
}
