typeset -T MUX_STACK mux_stack ";"
export MUX_STACK

() {
    local script_dir="$1"
    source "$1/main.zsh"
    source "$1/vars.zsh"
    source "$1/registers.zsh"
    source "$1/tree.zsh"
    source "$1/info.zsh"
    source "$1/tabs.zsh"
    source "$1/system.zsh"
    source "$1/utils.zsh"
} "${0:a:h}"
