function maybe-print() {
    local name
    for name; do
        if [[ -v "$name" ]]; then
            echo "$name='${(P)name}'"
        fi
    done
}

function maybe-print-all() {
    maybe-print \
        cmd_name \
        scope \
        location \
        locationid \
        varname \
        regname \
        info_keys \
        "info_dict[icon]" \
        "info_dict[icon-color]" \
        "info_dict[title]" \
        "info_dict[title-style]" \
        value
}
