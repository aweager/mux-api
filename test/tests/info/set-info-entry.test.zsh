#!/bin/zsh

function icon.test() {
    function arrange() { }

    function act() {
        "$SUT" set-icon --location t:tab_id X
    }

    function assert() {
        setopt err_return
        assert-file-empty stderr stdout

        source "$(get-param-dump mux-impl-update-vars)"
        assert-equal \
            "FifoValues[icon]" X

        assert-equal \
            "MuxArgs[cmd]" set-icon \
            "MuxArgs[scope]" tab \
            "MuxArgs[location]" t:tab_id \
            "MuxArgs[location-id]" tab_id
    }
}

function title.test() {
    function arrange() { }

    function act() {
        "$SUT" set-title --location t:tab_id name
    }

    function assert() {
        setopt err_return
        assert-file-empty stderr stdout

        source "$(get-param-dump mux-impl-update-vars)"
        assert-equal \
            "FifoValues[title]" name

        assert-equal \
            "MuxArgs[cmd]" set-title \
            "MuxArgs[scope]" tab \
            "MuxArgs[location]" t:tab_id \
            "MuxArgs[location-id]" tab_id
    }
}
