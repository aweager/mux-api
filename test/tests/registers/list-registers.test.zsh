#!/bin/zsh

function list-registers.test() {
    function arrange() { }

    function act() {
        "$SUT" list-registers
    }

    function assert() {
        setopt err_return
        assert-empty STDERR

        assert-equal \
            STDOUT \
"unnamed
a
b
c
"

        assert-equal \
            "MuxArgs[cmd]" list-registers

        assert-unset \
            "MuxArgs[scope]" \
            "MuxArgs[location]" \
            "MuxArgs[location-id]"
    }
}
