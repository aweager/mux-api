#!/bin/zsh

test_names=(
    tab-scoped
    old-vars-unset
)

function tab-scoped() {
    function arrange() { }

    function act() {
        "$SUT" set-var --location t:tab_id name value
    }

    function assert() {
        setopt err_return
        assert-empty STDOUT STDERR

        assert-equal \
            "MuxArgs[cmd]" set-var \
            "MuxArgs[scope]" tab \
            "MuxArgs[location]" t:tab_id \
            "MuxArgs[location-id]" tab_id \
            "MuxArgs[varname]" name \
            "MuxArgs[value]" value
    }
}

function old-vars-unset() {
    function arrange() { }

    function act() {
        "$SUT" set-var -t --location t:tab_id name value
    }

    function assert() {
        setopt err_return

        assert-unset \
            cmd_name \
            scope \
            location \
            locationid \
            varname \
            value
    }
}
