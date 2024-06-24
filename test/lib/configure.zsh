() {
    private dir="$1"
    source "$dir/utils.zsh"
    source "$dir/vars.zsh"
    source "$dir/registers.zsh"
    source "$dir/info.zsh"
} "${0:a:h}"
