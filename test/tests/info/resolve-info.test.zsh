#!/bin/zsh

function icon-info.test() {
    function arrange() { }

    function act() {
        "$SUT" resolve-info --location t:tab_id \
            --icon \
            --icon-color
    }

    function assert() {
        setopt err_return
        assert-empty STDERR

        assert-equal \
            STDOUT \
"resolving vars
icon: Value for icon
icon-color: Value for icon-color
"

        assert-equal \
            "MuxArgs[cmd]" resolve-info \
            "MuxArgs[scope]" tab \
            "MuxArgs[location]" t:tab_id \
            "MuxArgs[location-id]" tab_id \
            "MuxArgs[namespace]" info
    }
}

function title-info.test() {
    function arrange() { }

    function act() {
        "$SUT" resolve-info --location t:tab_id \
            --title \
            --title-style
    }

    function assert() {
        setopt err_return
        assert-empty STDERR

        assert-equal \
            STDOUT \
"resolving vars
title: Value for title
title-style: Value for title-style
"

        assert-equal \
            "MuxArgs[cmd]" resolve-info \
            "MuxArgs[scope]" tab \
            "MuxArgs[location]" t:tab_id \
            "MuxArgs[location-id]" tab_id \
            "MuxArgs[namespace]" info
    }
}

function all-info.test() {
    function arrange() { }

    function act() {
        "$SUT" resolve-info --location t:tab_id
    }

    function assert() {
        setopt err_return
        assert-empty STDERR

        assert-equal \
            STDOUT \
"resolving vars
icon: Value for icon
icon-color: Value for icon-color
title: Value for title
title-style: Value for title-style
"

        assert-equal \
            "MuxArgs[cmd]" resolve-info \
            "MuxArgs[scope]" tab \
            "MuxArgs[location]" t:tab_id \
            "MuxArgs[location-id]" tab_id \
            "MuxArgs[namespace]" info
    }
}
