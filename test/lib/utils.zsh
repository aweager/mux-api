source "${0:a:h}/../test-utils.zsh"

function maybe-print() {
    local name
    for name; do
        if [[ -v "$name" ]]; then
            report-parameter "$name"
        fi
    done
}

function maybe-print-all() {
    maybe-print \
        MuxArgs \
        MuxInfo \
        mux_info_keys \
        cmd_name \
        scope \
        location \
        locationid \
        varname \
        regname \
        info_keys \
        info_dict \
        value
}
