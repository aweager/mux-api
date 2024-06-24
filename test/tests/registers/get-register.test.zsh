#!/bin/zsh

test_names=(
    unnamed
)

function unnamed() {
    function arrange() { }

    function act() {
        "$SUT" get-register unnamed
    }

    function assert() {
        setopt err_return
        assert-empty STDOUT STDERR

        assert-equal \
            "MuxArgs[cmd]" get-register \
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
