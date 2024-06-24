#### Reporting parameter values for inspection during assert stage

function report-parameter() {
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
    RESULT=0
    if ! [[ -v ${1} ]]; then
        error "Expected empty param $1 but was unset"
        RESULT=1
    elif [[ -n ${(P)1} ]]; then
        error "Expected empty param $1 but had value: ${(P)1}"
        RESULT=2
    fi
    return $RESULT
}

function assert-unset() {
    RESULT=0
    if [[ -v ${1} ]]; then
        error "Expected param $1 to be unset"
        RESULT=1
    fi
    return $RESULT
}

function assert-equal() {
    RESULT=0
    if ! [[ -v ${1} ]]; then
        error "Expected param $1 to have value '$2' but was unset"
        RESULT=1
    elif [[ "${(P)1}" != "$2" ]]; then
        error "Expected param $1 to have value '$2' but had value: ${(P)1}"
        RESULT=2
    fi
    return $RESULT
}
