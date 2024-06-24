() {
    local mux_api_root="${0:a:h}"

    fpath+=("$mux_api_root/fbin")
    path+=("$mux_api_root/bin")
    export PATH

    autoload -Uz mux
} "${0:a:h}"
