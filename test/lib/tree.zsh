function mux-impl-get-mux-cmd() {
    init-param-dump "$0"
    maybe-print-all

    REPLY="$(whence -p test-mux)"
}
