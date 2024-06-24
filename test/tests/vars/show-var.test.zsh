#!/bin/zsh

function tab-scoped.test() {
    function arrange() { }

    function act() {
        "$SUT" show-var --location t:tab_id name
    }

    function assert() {
        setopt err_return
        assert-empty STDERR

        assert-equal \
            STDOUT \
"getting vars
Value for name
"

        assert-equal \
            "MuxArgs[cmd]" show-var \
            "MuxArgs[scope]" tab \
            "MuxArgs[location]" t:tab_id \
            "MuxArgs[location-id]" tab_id \
            "MuxArgs[varname]" name \
            "MuxArgs[namespace]" user
    }
}
