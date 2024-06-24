#!/bin/zsh

test_names=(
    unnamed
)

function unnamed() {
    function arrange() { }

    function act() {
        echo -n value | "$SUT" load-register unnamed
    }

    function assert() {
        setopt err_return
        assert-empty STDERR

        assert-equal STDOUT value

        assert-equal \
            "MuxArgs[cmd]" load-register \
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
