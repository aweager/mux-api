#!/bin/zsh

function unnamed.test() {
    function arrange() { }

    function act() {
        "$SUT" set-register unnamed value
    }

    function assert() {
        setopt err_return
        assert-empty STDERR

        assert-equal \
            STDOUT \
"updating registers
"

        assert-equal \
            "MuxArgs[cmd]" set-register \
            "MuxArgs[regname]" unnamed \
            "MuxArgs[value]" value \
            "FifoValues[unnamed]" value

        assert-unset \
            "MuxArgs[scope]" \
            "MuxArgs[location]" \
            "MuxArgs[location-id]" \
            "MuxArgs[varname]" \
            regname
    }
}
