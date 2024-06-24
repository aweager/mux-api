zmodload zsh/param/private

function mux-impl-set-registers() {
    echo "setting registers"

    private key fifo
    local -A FifoValues
    for key fifo in "${(@kv)MuxFifos}"; do
        FifoValues[$key]="$(cat "$fifo")"
    done
    maybe-print FifoValues

    maybe-print-all
}

function mux-impl-update-registers() {
    echo "updating registers"

    private key fifo
    local -A FifoValues
    for key fifo in "${(@kv)MuxFifos}"; do
        FifoValues[$key]="$(cat "$fifo")"
    done
    maybe-print FifoValues

    maybe-print-all
}

function mux-impl-delete-registers() {
    maybe-print-all
}

function mux-impl-get-registers() {
    echo "getting registers"

    private key fifo
    for key fifo in "${(@kv)MuxFifos}"; do
        echo -n "Value for $key" > "$fifo"
    done

    maybe-print-all
}

function mux-impl-list-registers() {
    reply=(unnamed a b c)
    maybe-print-all
}
