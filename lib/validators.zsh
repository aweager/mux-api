function __mux-build-validator() {
    local -a arg_val_allowed_scopes
    local -a arg_val_scope
    local -a arg_val_location
    local -a arg_val_spec

    zmodload zsh/zutil
    zparseopts -D -E -F -- \
        {s,t,p,b}+=arg_val_allowed_scopes \
        -scope=arg_val_scope \
        -location=arg_val_location \
        -spec+:-=arg_val_spec ||
    return 1

    local -a -U local_vars
    local setup=''
    local opt_specs=""
    local validators=""
    local positional_arg_names=("$@")

    local -a allowed_scopes
    local entry
    for entry in $arg_val_allowed_scopes; do
        case "$entry" in
            -s)
                allowed_scopes+=(session)
                ;;
            -t)
                allowed_scopes+=(tab)
                ;;
            -p)
                allowed_scopes+=(pane)
                ;;
            -b)
                allowed_scopes+=(buffer)
                ;;
            *)
                :
                ;;
        esac
    done

    if [[ ! -z $arg_val_scope ]]; then
        setup+='
            local -a arg_scope
        '
        opt_specs+=' {s,t,p,b}=arg_scope -scope:=arg_scope'
        validators+="
            __mux-validate-scope || return 1
        "
    fi

    if [[ ! -z $arg_val_location ]]; then
        setup+='
            local -a arg_location
        '
        opt_specs+=' {l,-location}:=arg_location'
        validators+='
            __mux-validate-location || return 1
        '
    fi

    if [[ ! -z $arg_val_scope && ! -z $arg_val_location ]]; then
        validators+='
            if [[ -z $MuxArgs[scope] && -z $MuxArgs[location] ]]; then
                echo "One of scope or location is required" >&2
                return 1
            fi
        '
    elif [[ ! -z $arg_val_scope ]]; then
        validators+='
            if [[ -z $MuxArgs[scope] ]]; then
                echo "Scope is required" >&2
                return 1
            fi
        '
    fi

    if [[ -n $allowed_scopes ]]; then
        validators+="
            local -a allowed_scopes
            allowed_scopes=($allowed_scopes)
            if ! [[ -z \$MuxArgs[scope] || \$allowed_scopes[(Ie)\$MuxArgs[scope]] -gt 0 ]]; then
                echo 'Only ($allowed_scopes) scopes are allowed' >&2
                return 1
            fi
        "
    fi

    local spec
    for spec in $arg_val_spec; do
        opt_specs+=" ${spec:6}"
    done

    local num_args="${#positional_arg_names}"
    if [[ $num_args -eq 0 ]]; then
        validators+='
            if [[ $# -ne 0 ]]; then
                echo "$MuxArgs[cmd]: expected 0 arguments but received $#: ($*)" >&2
                return 1
            fi
        '
    else
        validators+="
            if [[ \$# -ne $num_args ]]; then
                echo \"\$MuxArgs[cmd]: expected $num_args arguments ($positional_arg_names[*]) but received \$#: (\$*)\" >&2
                return 1
            fi
        "
    fi

    local positional_arg_name
    local index=1
    local arg_name
    for arg_name in $positional_arg_names; do
        validators+="
            __mux-validate-$arg_name \"\$$index\" || return 1
        "
        ((index ++))
    done

    echo "
        $setup

        zmodload zsh/zutil
        zparseopts -D -E -F -- $opt_specs || return 1

        $validators
    "
}

function __mux-validate-scope() {
    if [[ -z $arg_scope ]]; then
        return
    fi

    local scope_key="$arg_scope[-1]"
    local -A valid_scopes
    valid_scopes=(
        session session
        -s session
        tab tab
        -t tab
        pane pane
        -p pane
        buffer buffer
        -b buffer
    )

    MuxArgs[scope]="$valid_scopes[$scope_key]"
    if [[ -z "$MuxArgs[scope]" ]]; then
        echo "Invalid scope: '$scope_key'" >&2
        return 1
    fi
}

function __mux-validate-location() {
    if [[ -z "$arg_location" ]]; then
        return
    fi

    local location="$arg_location[-1]"
    MuxArgs[location]="$location"
    local location_prefix="${location:0:2}"
    local location_scope

    case "$location_prefix" in
        "s:")
            if [[ "${#location}" -ne 2 ]]; then
                echo "Session locations must exactly match 's:'" >&2
                return 1
            fi
            location_scope="session"
            ;;
        "t:")
            location_scope="tab"
            ;;
        "p:")
            location_scope="pane"
            ;;
        "b:")
            location_scope="buffer"
            ;;
        *)
            echo "Invalid location '$location'. Must begin with s:, t:, p:, or b:" >&2
            return 1
            ;;
    esac

    if [[ -n $MuxArgs[scope] ]]; then
        if [[ $MuxArgs[scope] != $location_scope ]]; then
            echo "Specified scope '$MuxArgs[scope]' does not match specified location '$location'" >&2
            return 1
        fi
    else
        MuxArgs[scope]="$location_scope"
    fi

    MuxArgs[location-id]="${location:2}"
}

function __mux-validate-value() {
    # Nothing is forbidden
    MuxArgs[value]="$1"
}

function __mux-check-alphanumeric() {
    if [[ "$1" =~ [^a-zA-Z0-9] ]]; then
        return 1
    fi
}