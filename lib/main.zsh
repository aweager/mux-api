#!/bin/zsh

function this-mux() {
    # initialize variables that impls will read or write
    local -A MuxArgs
    local -A MuxValues
    local -A MuxFifos
    local -a mux_argv
    local -a mux_varnames
    local -a mux_regnames

    MuxArgs[cmd]="$1"
    if [[ ! -v functions[@$1] ]]; then
        echo "Unknown mux command $1" >&2
        return 1
    fi

    shift
    "@${MuxArgs[cmd]}" "$@"
}

() {
    private -a mux_cmds
    mux_cmds=(
        set-var
        delete-var
        show-var
        get-var

        set-register
        load-register
        delete-register
        show-register
        get-register
        list-registers
        dump-registers

        get-child-mux
        get-parent-mux
        get-mux-cmd

        link-child
        link-parent
        unlink-child
        unlink-parent

        set-info
        update-info
        get-info
        resolve-info

        sync-registers-down
        sync-registers-up
    )

    private info_key
    for info_key in icon icon-color title title-style; do
        mux_cmds+=(get-${info_key} set-${info_key} resolve-${info_key})
    done

    private cmd
    for cmd in $mux_cmds; do
        "@$cmd"
        functions[@$cmd.parse-args]="$(build-args-parser)"
        functions[@$cmd.impl]="$functions[impl]"
        functions[@$cmd]="
            \"@$cmd.parse-args\" \"\$@\" &&
            \"@$cmd.impl\"
        "

        unfunction build-args-parser impl
    done
}
