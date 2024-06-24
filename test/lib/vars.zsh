zmodload zsh/param/private

function mux-impl-set-vars() {
    echo "setting vars"

    private key fifo
    local -A FifoValues
    for key fifo in "${(@kv)MuxFifos}"; do
        FifoValues[$key]="$(cat "$fifo")"
    done
    maybe-print FifoValues

    maybe-print-all
}

function mux-impl-update-vars() {
    echo "updating vars"

    private key fifo
    local -A FifoValues
    for key fifo in "${(@kv)MuxFifos}"; do
        FifoValues[$key]="$(cat "$fifo")"
    done
    maybe-print FifoValues

    maybe-print-all
}

function mux-impl-delete-vars() {
    maybe-print-all
}

function mux-impl-get-vars() {
    echo "getting vars"

    private key fifo
    for key fifo in "${(@kv)MuxFifos}"; do
        echo -n "Value for $key" > "$fifo" &!
    done

    maybe-print-all
}

function mux-impl-resolve-vars() {
    echo "resolving vars"

    private key fifo
    for key fifo in "${(@kv)MuxFifos}"; do
        echo -n "Value for $key" > "$fifo" &!
    done

    maybe-print-all
}
