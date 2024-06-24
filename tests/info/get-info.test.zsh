#!/bin/zsh

function icon-info.test() {
    function arrange() { }

    function act() {
        "$SUT" get-info --location t:tab_id \
            --icon \
            --icon-color
    }

    function assert() {
        setopt err_return
        assert-file-empty stderr

        cat <<- EOF | assert-file-equal stdout
icon: Value for icon
icon-color: Value for icon-color
EOF

        source "$(get-param-dump mux-impl-get-vars)"
        assert-equal \
            "MuxArgs[cmd]" get-info \
            "MuxArgs[scope]" tab \
            "MuxArgs[location]" t:tab_id \
            "MuxArgs[location-id]" tab_id \
            "MuxArgs[namespace]" info
    }
}

function title-info.test() {
    function arrange() { }

    function act() {
        "$SUT" get-info --location t:tab_id \
            --title \
            --title-style
    }

    function assert() {
        setopt err_return
        assert-file-empty stderr

        cat <<- EOF | assert-file-equal stdout
title: Value for title
title-style: Value for title-style
EOF

        source "$(get-param-dump mux-impl-get-vars)"
        assert-equal \
            "MuxArgs[cmd]" get-info \
            "MuxArgs[scope]" tab \
            "MuxArgs[location]" t:tab_id \
            "MuxArgs[location-id]" tab_id \
            "MuxArgs[namespace]" info
    }
}

function all-info.test() {
    function arrange() { }

    function act() {
        "$SUT" get-info --location t:tab_id
    }

    function assert() {
        setopt err_return
        assert-file-empty stderr

        cat <<- EOF | assert-file-equal stdout
icon: Value for icon
icon-color: Value for icon-color
title: Value for title
title-style: Value for title-style
EOF

        source "$(get-param-dump mux-impl-get-vars)"
        assert-equal \
            "MuxArgs[cmd]" get-info \
            "MuxArgs[scope]" tab \
            "MuxArgs[location]" t:tab_id \
            "MuxArgs[location-id]" tab_id \
            "MuxArgs[namespace]" info
    }
}
