#!/bin/zsh

function get-mux-cmd.test() {
    function arrange() { }

    function act() {
        "$SUT" get-mux-cmd
    }

    function assert() {
        setopt err_return
        assert-file-empty stderr

        cat <<- EOF | assert-file-equal stdout
$(whence -p test-mux)
EOF

        source "$(get-param-dump mux-impl-get-mux-cmd)"
        assert-equal \
            "MuxArgs[cmd]" get-mux-cmd

        assert-unset \
            "MuxArgs[scope]" \
            "MuxArgs[location]" \
            "MuxArgs[location-id]" \
            "MuxArgs[varname]" \
            "MuxArgs[namespace]"
    }
}
