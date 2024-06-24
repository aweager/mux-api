#!/bin/zsh

# This only applies if we are being called as a subprocess
if ! typeset -f __mux-parse-and-call-system > /dev/null; then
    echo "${0:a:h}"
    source "${0:a:h}/../configure.zsh"
fi

function __mux-parse-and-call() {
    local cmd_prefix="$1"
    shift

    local cmd_name parser_name
    __mux-validate-cmd-name "$1" || return 1
    shift

    "__mux-parse-and-call-${parser_name}" "$@" || return 1
}

function __mux-validate-cmd-name() {
    local -A parser_by_cmd
    parser_by_cmd=(
        set-var set-var
        delete-var varname-only
        show-var varname-only
        get-var varname-only

        set-register set-register
        load-register regname-only
        delete-register regname-only
        show-register regname-only
        get-register regname-only
        list-registers no-args

        register-child-mux muxcmd-only
        unregister-child-mux no-args
        get-child-mux no-args
        get-parent-mux no-args
        get-mux-cmd no-args

        set-info info-dict
        update-info info-dict
        get-info info-key-list
        resolve-info resolve-info

        pin-tab tab-only
        unpin-tab tab-only
        toggle-pin-tab tab-only

        sync-registers-down system
        sync-registers-up system
    )

    local info_key
    for info_key in icon icon-color title title-style; do
        parser_by_cmd["get-${info_key}"]="get-info-entry"
        parser_by_cmd["set-${info_key}"]="set-info-entry"
        parser_by_cmd["resolve-${info_key}"]="resolve-info-entry"
    done

    if [[ -z "$parser_by_cmd[$1]" ]]; then
        echo "Invalid command \"$1\"" >&2
        return 1
    fi

    cmd_name="$1"
    parser_name="$parser_by_cmd[$cmd_name]"
}
