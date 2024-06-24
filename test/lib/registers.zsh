zmodload zsh/param/private

function mux-impl-set-registers mux-impl-update-registers() {
    init-param-dump "$0"

    private key fifo
    local -A FifoValues
    for key fifo in "${(@kv)MuxFifos}"; do
        FifoValues[$key]="$(cat "$fifo")"
    done
    maybe-print FifoValues

    maybe-print-all
}

function mux-impl-delete-registers() {
    init-param-dump "$0"
    maybe-print-all
}

function mux-impl-get-registers() {
    init-param-dump "$0"

    private key fifo
    for key fifo in "${(@kv)MuxFifos}"; do
        echo -n "Value for $key" > "$fifo"
    done

    maybe-print-all
}

function mux-impl-list-registers() {
    init-param-dump "$0"
    reply=(unnamed a b c)
    maybe-print-all
}
