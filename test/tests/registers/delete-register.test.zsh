#!/bin/zsh

function unnamed.test() {
    function arrange() { }

    function act() {
        "$SUT" delete-register unnamed
    }

    function assert() {
        setopt err_return
        assert-file-empty stdout stderr

        source "$(get-param-dump mux-impl-delete-registers)"
        assert-equal \
            "MuxArgs[cmd]" delete-register \
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
