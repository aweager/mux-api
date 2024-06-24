() {
    local test_mux_root="${0:a:h}"

    fpath+=("$test_mux_root/fbin")
    path+=("$test_mux_root/bin")

    autoload -Uz test-mux
} "${0:a:h}"
