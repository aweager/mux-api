() {
    local test_mux_root="${0:a:h}"

    # TODO properly depend
    source ../../../private-func/configure.zsh
    fpath+=("$test_mux_root/fbin")
    path+=("$test_mux_root/bin")

    autoload -Uz test-mux
} "${0:a:h}"
