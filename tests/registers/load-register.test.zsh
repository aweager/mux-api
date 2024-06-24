#!/bin/zsh

function unnamed.test() {
    function arrange() { }

    function act() {
        echo -n value | "$SUT" load-register unnamed
    }

    function assert() {
        setopt err_return
        assert-file-empty stderr stdout

        source "$(get-param-dump mux-impl-update-registers)"
        assert-equal \
            "MuxArgs[cmd]" load-register \
            "MuxArgs[regname]" unnamed \
            "FifoValues[unnamed]" value

        assert-unset \
            "MuxArgs[scope]" \
            "MuxArgs[location]" \
            "MuxArgs[location-id]" \
            "MuxArgs[varname]" \
            "MuxArgs[value]" \
            regname
    }
}
