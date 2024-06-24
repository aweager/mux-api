#!/bin/zsh

() {
    source "$1/utils.zsh"
    source "$1/validators.zsh"

    local -a mux_cmds
    source "$1/vars.zsh"
    source "$1/registers.zsh"
    source "$1/tree.zsh"
    source "$1/info.zsh"
    source "$1/system.zsh"

    private -A MuxCmds
    private cmd
    for cmd in $mux_cmds; do
        "@$cmd"
        functions[@$cmd.parse-args]="$(build-args-parser)"
        functions[@$cmd.impl]="$functions[impl]"
        functions[@$cmd]="
            \"@$cmd.parse-args\" \"\$@\" &&
            \"@$cmd.impl\"
            return \$?
        "
        MuxCmds[$cmd]="@$cmd"

        unfunction build-args-parser impl
    done

    functions[main]="
        local -A MuxCmds
        MuxCmds=(${(kv)MuxCmds})
        this-mux \"\$@\"
    "

    function this-mux() {
        # initialize variables that impls will read or write
        local -A MuxArgs
        local -A MuxValues
        local -A MuxFifos
        local -a mux_argv
        local -a mux_varnames
        local -a mux_regnames

        if [[ ! -v MuxCmds[$1] ]]; then
            echo "Unknown mux command $1" >&2
            return 1
        fi

        MuxArgs[cmd]="$1"
        shift
        "@${MuxArgs[cmd]}" "$@"
    }
} "${0:a:h}"
