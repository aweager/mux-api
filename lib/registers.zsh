function @set-register() {
    function build-args-parser() {
        .build-standard-parser \
            regname value
    }

    function impl() {
        MuxValues[$MuxArgs[regname]]="$MuxArgs[value]"
        {
            .write-values
            mux-impl-update-registers
        } always {
            .cleanup-fifos
        }
    }
}

function @get-register() {
    function build-args-parser() {
        .build-standard-parser \
            regname
    }

    function impl() {
        private regname="$MuxArgs[regname]"
        {
            .make-fifos "$regname"
            mux-impl-get-registers &!
            (< "$MuxFifos[$regname]")
        } always {
            .cleanup-fifos
        }
    }
}

function @show-register() {
    function build-args-parser() {
        .build-standard-parser \
            regname
    }

    function impl() {
        echo "$(@get-register.impl)"
    }
}

function @delete-register() {
    function build-args-parser() {
        .build-standard-parser \
            regname
    }

    function impl() {
        local -a mux_regnames
        mux_regnames=($MuxArgs[regname])
        mux-impl-delete-registers
    }
}

function @load-register() {
    function build-args-parser() {
        .build-standard-parser \
            regname
    }

    function impl() {
        private regname="$MuxArgs[regname]"
        {
            .make-fifos "$regname"
            cat > "$MuxFifos[$regname]" &!
            mux-impl-update-registers
        } always {
            .cleanup-fifos
        }
    }
}

function @list-registers() {
    function build-args-parser() {
        .build-standard-parser # no args
    }

    function impl() {
        local -a reply
        reply=()
        mux-impl-list-registers

        private regname
        for regname in "$reply[@]"; do
            echo "$regname"
        done
    }
}

function @dump-registers() {
    function build-args-parser() {
        .build-standard-parser --varargs
        echo '.parse-register-dump-map "$@" || return 1'
    }

    function impl() {
        unset "MuxArgs[regname]"
        mux-impl-get-registers
    }
}

function .parse-regname() {
    MuxArgs[regname]="$1"
    if [[ "$1" == "unnamed" ]]; then
        return 0
    fi

    if [[ ${#1} -ne 1 || "$1" =~ [^a-z] ]]; then
        echo "Register name must be [a-z] or \"unnamed\" but was \"$1\"" >&2
        return 1
    fi
}

function .parse-register-dump-map() {
    private regname fifo
    for regname fifo in "$@"; do
        .parse-regname "$regname" || return 1

        if [[ -v MuxFifos[$regname] ]]; then
            echo "Register $regname already has a fifo" >&2
            return 1
        fi

        .parse-fifo "$fifo" || return 1
        MuxFifos[$regname]="$fifo"
    done
}
