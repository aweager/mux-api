#!/bin/zsh

test_names=(
    tab-scoped
)

function tab-scoped() {
    function arrange() { }

    function act() {
        "$SUT" show-var --location t:tab_id name
    }

    function assert() {
        setopt err_return
        assert-empty STDOUT STDERR

        assert-equal \
            "MuxArgs[cmd]" show-var \
            "MuxArgs[scope]" tab \
            "MuxArgs[location]" t:tab_id \
            "MuxArgs[location-id]" tab_id \
            "MuxArgs[varname]" name
    }
}
