#!/bin/zsh

function unnamed-abc.test() {
    function arrange() { }

    function act() {
        touch unnamed.txt a.txt b.txt c.txt
        "$SUT" dump-registers \
            unnamed unnamed.txt \
            a a.txt \
            b b.txt \
            c c.txt
    }

    function assert() {
        setopt err_return
        assert-file-empty stderr stdout

        cat <<- EOF | assert-file-equal -n unnamed.txt
Value for unnamed
EOF
        cat <<- EOF | assert-file-equal -n a.txt
Value for a
EOF
        cat <<- EOF | assert-file-equal -n b.txt
Value for b
EOF
        cat <<- EOF | assert-file-equal -n b.txt
Value for b
EOF

        source "$(get-param-dump mux-impl-get-registers)"
        assert-equal \
            "MuxArgs[cmd]" dump-registers

        assert-unset \
            "MuxArgs[scope]" \
            "MuxArgs[location]" \
            "MuxArgs[location-id]" \
            "MuxArgs[varname]" \
            "MuxArgs[regname]" \
            "MuxArgs[value]" \
            regname
    }
}

function all-registers.test() {
    function arrange() { }

    function act() {
        private -A RegnameToFifo
        private regname
        for regname in unnamed a b c d e f g h i j k l m n o p q r s t u v w x y z; do
            RegnameToFifo[$regname]="$regname.txt"
        done

        touch "${(@v)RegnameToFifo}"

        "$SUT" dump-registers "${(@kv)RegnameToFifo}"
    }

    function assert() {
        setopt err_return
        assert-file-empty stderr stdout

        private regname
        for regname in unnamed a b c d e f g h i j k l m n o p q r s t u v w x y z; do
            cat <<- EOF | assert-file-equal -n "$regname.txt"
Value for $regname
EOF
        done

        source "$(get-param-dump mux-impl-get-registers)"
        assert-equal \
            "MuxArgs[cmd]" dump-registers

        assert-unset \
            "MuxArgs[scope]" \
            "MuxArgs[location]" \
            "MuxArgs[location-id]" \
            "MuxArgs[varname]" \
            "MuxArgs[regname]" \
            "MuxArgs[value]" \
            regname
    }
}
