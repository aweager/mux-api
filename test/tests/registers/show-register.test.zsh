#!/bin/zsh

function unnamed.test() {
    function arrange() { }

    function act() {
        "$SUT" show-register unnamed
    }

    function assert() {
        setopt err_return
        assert-empty STDERR

        assert-equal \
            STDOUT \
"getting registers
Value for unnamed
"

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
