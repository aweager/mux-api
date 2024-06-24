#!/bin/zsh

function unnamed.test() {
    function arrange() { }

    function act() {
        "$SUT" show-register unnamed
    }

    function assert() {
        setopt err_return
        assert-file-empty stderr

        cat <<- EOF | assert-file-equal stdout
Value for unnamed
EOF

        source "$(get-param-dump mux-impl-get-registers)"
        assert-equal \
            "MuxArgs[cmd]" show-register \
            "MuxArgs[regname]" unnamed

        assert-unset \
            "MuxArgs[scope]" \
            "MuxArgs[location]" \
            "MuxArgs[location-id]" \
            "MuxArgs[varname]" \
            "MuxArgs[value]" \
            regname
    }
}
