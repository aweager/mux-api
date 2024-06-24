#### Reporting parameter values for inspection during assert stage

function init-param-dump() {
    if [[ -z $UNDER_TEST ]]; then
        return
    fi

    export REPORTED_PARAMS_FILE="$(get-param-dump "$1")"

    echo "
        typeset -a reported_params
    " > "$REPORTED_PARAMS_FILE"
}

function get-param-dump() {
    mkdir -p "$REPORTED_PARAMS_DIR"
    echo "$REPORTED_PARAMS_DIR/$1.params.zsh"
}

function report-parameter() {
    if [[ -z "$REPORTED_PARAMS_FILE" ]]; then
        return
    fi

    local -T PARAM_TYPES param_types '-'
    PARAM_TYPES="${(tP)1}"

    local typeset_command
    case $param_types[1] in
        array)
            typeset_command="typeset -a ${1}"
            ;;
        integer)
            typeset_command="typeset -i ${1}"
            ;;
        float)
            typeset_command="typeset -F ${1}"
            ;;
        association)
            typeset_command="typeset -A ${1}"
            ;;
        *)
            typeset_command="typeset ${1}"
            ;;
    esac

    local assignment
    case $param_types[1] in
        array)
            local key val
            key=1
            for val in "${(P)1[@]}"; do
                assignment+="
                    ${1}[$key]='$val'
                "
                (( key += 1 ))
            done
            ;;
        association)
            local key val
            for key val in "${(@kvP)1}"; do
                assignment+="
                    ${1}[$key]='$val'
                "
            done
            ;;
        *)
            assignment="${1}='${(P)1}'"
            ;;
    esac

    echo "
        ${typeset_command}
        ${assignment}
        reported_params+=(${1})
    " >> "$REPORTED_PARAMS_FILE"
}

#### Outputting messages to the test runner

function error() {
    stderr "%F{red}ERROR:%f $*"
}

function debug() {
    stdout "%F{cyan}DEBUG:%f $*"
}

function info() {
    stdout "%F{8}INFO: $*%f"
}

function trace() {
    stdout "%F{yellow}TRACE:%f $*"
}

function stdout() {
    if [[ -z $UNDER_TEST ]]; then
        print -P "${INDENT}$1"
    else
        print -P "${INDENT}$1" >&3
    fi
}

function stderr() {
    if [[ -z $UNDER_TEST ]]; then
        print -P "${INDENT}$1"
    else
        print -P "${INDENT}$1" >&4
    fi
}

# Assertions
function assert-empty() {
    private p
    for p in "$@"; do
        if ! [[ -v ${p} ]]; then
            error "Expected empty param $p but was unset"
            return 1
        elif [[ -n ${(P)p} ]]; then
            error "Expected empty param $p but had value: ${(P)p}"
            return 2
        fi
    done
}

function assert-unset() {
    private p
    for p in "$@"; do
        if [[ -v ${p} ]]; then
            error "Expected param $p to be unset"
            return 1
        fi
    done
}

function assert-equal() {
    private p v
    for p v in "$@"; do
        if ! [[ -v ${p} ]]; then
            error "Expected param $p to have value '$v' but was unset"
            return 1
        elif [[ "${(P)p}" != "$v" ]]; then
            error "Expected param $p to have value '$v' but had value: '${(P)p}'"
            return 2
        fi
    done
}

function assert-file-equal() {
    private -a arg_strip_newline
    zparseopts -D -E -F -- \
        {n,-strip-newline}=arg_strip_newline

    private diff_result
    if [[ -z $arg_strip_newline ]]; then
        diff_result="$(diff "$1" /dev/stdin)" || true
    else
        diff_result="$(perl -p -e 'chomp if eof' | diff "$1" /dev/stdin)" || true
    fi

    if [[ -n "$diff_result" ]]; then
        error "File $1 diff:"
        echo "$diff_result" >&2
        return 1
    fi
}

function assert-file-empty() {
    private filename
    for filename; do
        echo -n "" | assert-file-equal "$filename"
    done
}
