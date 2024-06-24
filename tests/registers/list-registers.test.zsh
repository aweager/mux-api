#!/bin/zsh

function list-registers.test() {
    function arrange() { }

    function act() {
        "$SUT" list-registers
    }

    function assert() {
        setopt err_return
        assert-file-empty stderr

        cat <<- EOF | assert-file-equal stdout
unnamed
a
b
c
EOF

        source "$(get-param-dump mux-impl-list-registers)"
        assert-equal \
            "MuxArgs[cmd]" list-registers

        assert-unset \
            "MuxArgs[scope]" \
            "MuxArgs[location]" \
            "MuxArgs[location-id]"
    }
}
