function .make-fifos() {
    private key fifo
    for key in "$@"; do
        fifo="$(mktemp -u)"
        mkfifo -m 600 "$fifo"
        MuxFifos[$key]="$fifo"
    done
}

function .write-values() {
    .make-fifos "${(@k)MuxValues}"

    private key
    for key in "${(@k)MuxValues}"; do
        echo -n "$MuxValues[$key]" > "$MuxFifos[$key]" &!
    done
}

function .cleanup-fifos() {
    if [[ -n "${(@v)MuxFifos}" ]]; then
        rm "${(@v)MuxFifos}"
    fi
}

function .parse-fifo() {
    if [[ ! -f "$1" ]]; then
        echo "Fifo '$1' is not a file" >&2
        return 1
    fi
}
