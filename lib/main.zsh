#!/bin/zsh

function mux() {
    local -A MuxArgs
    MuxArgs[cmd]="$1"
    if [[ ! -v functions[__mux-cmd-$1] ]]; then
        echo "Unknown mux command $1" >&2
        return 1
    fi

    shift
    "__mux-cmd-${MuxArgs[cmd]}" "$@"
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

        register-child-mux
        unregister-child-mux
        get-child-mux
        get-parent-mux
        get-mux-cmd

        set-info
        update-info
        get-info
        resolve-info

        pin-tab
        unpin-tab
        toggle-pin-tab

        sync-registers-down
        sync-registers-up
    )

    private info_key
    for info_key in icon icon-color title title-style; do
        mux_cmds+=(get-${info_key} set-${info_key} resolve-${info_key})
    done

    private cmd
    for cmd in $mux_cmds; do
        functions[__mux-cmd-${cmd}]="
            $functions[mux-validate-${cmd}]
            $functions[mux-exec-${cmd}]
        "
    done
}
