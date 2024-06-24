#### Register commands ####
#
# Required mux impls:
#   - export-registers
#   - import-registers
#   - replace-registers
#   - list-registers
#   - delete-registers


### Retrieving data ###
mux_cmds+=(
    show-register
    get-register
    has-register
    list-registers
)

function @show-register() {
    function build-args-parser() {
        .build-standard-parser \
            regname
    }

    function impl() {
        echo "$(@get-register.impl)"
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
            < "$MuxFifos[$regname]"
        } always {
            .cleanup-fifos
        }
    }
}

function @has-register() {
    function build-args-parser() {
        .build-standard-parser \
            regname
    }

    function impl() {
        local -a reply
        reply=()
        mux-impl-list-registers

        if (( ${reply[(Ie)$MuxArgs[regname]]} )); then
            return 0
        else
            return 1
        fi
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

        print -rC1 "$reply[@]"
    }
}

### Modifying data ###
mux_cmds+=(
    set-register
    delete-register
)

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

### Piping data to/from files ###
mux_cmds+=(
    export-registers
    replace-registers
    import-registers
)

function @export-registers() {
    function build-args-parser() {
        .build-standard-parser --varargs
        echo '.parse-register-file-map "$@" || return 1'
    }

    function impl() {
        mux-impl-get-registers
    }
}

function @replace-registers() {
    function build-args-parser() {
        .build-standard-parser --varargs
        echo '.parse-register-file-map "$@" || return 1'
    }

    function impl() {
        mux-impl-replace-registers
    }
}

function @import-registers() {
    function build-args-parser() {
        .build-standard-parser --varargs
        echo '.parse-register-file-map "$@" || return 1'
    }

    function impl() {
        mux-impl-update-registers
    }
}

### Parsers ###

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

function .parse-register-file-map() {
    private regname file
    for regname file in "$@"; do
        .parse-regname "$regname" || return 1

        if [[ -v MuxFifos[$regname] ]]; then
            echo "Register $regname already has a file" >&2
            return 1
        fi

        .parse-fifo "$file" || return 1
        MuxFifos[$regname]="$file"
    done
}
