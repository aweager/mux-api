#!/bin/zsh

function tab-scoped.test() {
    function arrange() { }

    function act() {
        "$SUT" set-var --location t:tab_id name value
    }

    function assert() {
        setopt err_return
        assert-file-empty stderr stdout

        source "$(get-param-dump mux-impl-update-vars)"
        assert-equal \
            "MuxArgs[cmd]" set-var \
            "MuxArgs[scope]" tab \
            "MuxArgs[location]" t:tab_id \
            "MuxArgs[location-id]" tab_id \
            "MuxArgs[varname]" name \
            "MuxArgs[value]" value \
            "MuxArgs[namespace]" user
    }
}

function old-vars-unset.test() {
    function arrange() { }

    function act() {
        "$SUT" set-var -t --location t:tab_id name value
    }

    function assert() {
        setopt err_return

        source "$(get-param-dump mux-impl-update-vars)"
        assert-unset \
            cmd_name \
            scope \
            location \
            locationid \
            varname \
            value
    }
}
