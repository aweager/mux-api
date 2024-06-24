#!/bin/zsh

function tab-scoped.test() {
    function arrange() { }

    function act() {
        "$SUT" delete-var --location t:tab_id name
    }

    function assert() {
        setopt err_return
        assert-empty STDOUT STDERR

        assert-equal \
            "MuxArgs[cmd]" delete-var \
            "MuxArgs[scope]" tab \
            "MuxArgs[location]" t:tab_id \
            "MuxArgs[location-id]" tab_id \
            "MuxArgs[varname]" name \
            "MuxArgs[namespace]" user
    }
}
