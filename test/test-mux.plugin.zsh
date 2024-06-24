() {
    local test_mux_root="$1"

    # TODO properly depend
    source "$test_mux_root/../../../private-func/configure.zsh"
    fpath+=("$test_mux_root/fbin")
    path+=("$test_mux_root/bin")

    export PATH

    autoload -Uz test-mux
} "${0:a:h}"
