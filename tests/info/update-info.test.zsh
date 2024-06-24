#!/bin/zsh

function icon-info.test() {
    function arrange() { }

    function act() {
        "$SUT" update-info --location t:tab_id \
            --icon X \
            --icon-color green
    }

    function assert() {
        setopt err_return
        assert-file-empty stderr stdout

        source "$(get-param-dump mux-impl-update-vars)"
        assert-equal \
            "FifoValues[icon]" X \
            "FifoValues[icon-color]" green

        assert-equal \
            "MuxArgs[cmd]" update-info \
            "MuxArgs[scope]" tab \
            "MuxArgs[location]" t:tab_id \
            "MuxArgs[location-id]" tab_id
    }
}

function title-info.test() {
    function arrange() { }

    function act() {
        "$SUT" update-info --location t:tab_id \
            --title name \
            --title-style italic
    }

    function assert() {
        setopt err_return
        assert-file-empty stderr stdout

        source "$(get-param-dump mux-impl-update-vars)"
        assert-equal \
            "FifoValues[title]" name \
            "FifoValues[title-style]" italic

        assert-equal \
            "MuxArgs[cmd]" update-info \
            "MuxArgs[scope]" tab \
            "MuxArgs[location]" t:tab_id \
            "MuxArgs[location-id]" tab_id
    }
}

function all-info.test() {
    function arrange() { }

    function act() {
        "$SUT" update-info --location t:tab_id \
            --icon X \
            --icon-color green \
            --title name \
            --title-style italic
    }

    function assert() {
        setopt err_return
        assert-file-empty stderr stdout

        source "$(get-param-dump mux-impl-update-vars)"
        assert-equal \
            "FifoValues[icon]" X \
            "FifoValues[icon-color]" green \
            "FifoValues[title]" name \
            "FifoValues[title-style]" italic

        assert-equal \
            "MuxArgs[cmd]" update-info \
            "MuxArgs[scope]" tab \
            "MuxArgs[location]" t:tab_id \
            "MuxArgs[location-id]" tab_id
    }
}
