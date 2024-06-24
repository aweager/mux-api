zmodload zsh/param/private

function mux-impl-set-vars mux-impl-update-vars () {
    init-param-dump "$0"

    private key fifo
    local -A FifoValues
    for key fifo in "${(@kv)MuxFifos}"; do
        FifoValues[$key]="$(cat "$fifo")"
    done
    maybe-print FifoValues

    maybe-print-all
}

function mux-impl-delete-vars() {
    init-param-dump "$0"
    maybe-print-all
}

function mux-impl-get-vars mux-impl-resolve-vars() {
    init-param-dump "$0"

    private key fifo
    for key fifo in "${(@kv)MuxFifos}"; do
        if [[ "$key" == "parent_mux" || "$key" == "child_mux" ]]; then
            echo -n "$(whence -p test-mux)" > "$fifo"
        fi

        echo -n "Value for $key" > "$fifo" &!
    done

    maybe-print-all
}
